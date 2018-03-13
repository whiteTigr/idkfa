----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:04:17 05/13/2015 
-- Design Name: 
-- Module Name:    kf6 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity kf7 is
    generic(DATAWIDTH : integer := 32;
	          CORE : integer := 0;
					  FCORE : integer := 50_000_000;
				    UART_BAUDRATE : integer := 115200;
				    PROGRAMSIZE : integer := 16384;
				    DATASIZE : integer := 1024;
				    HARDWARE_MULTIPLIER : string := "REGISTERED"; 
				    MAXSTACK : integer := 1024;
				    PCWIDTH : integer := 16;
		        INFO : string := "kf7 core"
		        );
    Port ( clk : in  STD_LOGIC;
           addr : out  STD_LOGIC_VECTOR (19 downto 0);
           data : out  STD_LOGIC_VECTOR (DATAWIDTH - 1 downto 0);
           wrio : out  STD_LOGIC;
           rdio : out  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (DATAWIDTH - 1 downto 0);
           reset : in  STD_LOGIC;
           intr : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           tx : out  STD_LOGIC);
end kf7;

architecture Behavioral of kf7 is

type TRam is array(0 to DATASIZE - 1) of std_logic_vector(DATAWIDTH - 1 downto 0);
type TCmd is array(0 to PROGRAMSIZE - 1) of std_logic_vector(7 downto 0);

shared variable Stack : TRam := (
  5 => x"00001000",
  others => (others => '0')
);

-- 2 3 + @ (FETCH SAVEA)
-- DROP 16 CALL
--
--

shared variable Program : TCmd := (
0  => conv_std_logic_vector(137 , 8),
1  => conv_std_logic_vector(0 , 8),
2  => conv_std_logic_vector(0 , 8),
3  => conv_std_logic_vector(0 , 8),
4  => conv_std_logic_vector(81 , 8),
5  => conv_std_logic_vector(135 , 8),
6  => conv_std_logic_vector(235 , 8),
7  => conv_std_logic_vector(97 , 8),
8  => conv_std_logic_vector(1 , 8),
9  => conv_std_logic_vector(128 , 8),
10  => conv_std_logic_vector(0 , 8),
11  => conv_std_logic_vector(129 , 8),
12  => conv_std_logic_vector(64 , 8),
13  => conv_std_logic_vector(32 , 8),
14  => conv_std_logic_vector(133 , 8),
15  => conv_std_logic_vector(82 , 8),
16  => conv_std_logic_vector(133 , 8),
17  => conv_std_logic_vector(0 , 8),
18  => conv_std_logic_vector(128 , 8),
19  => conv_std_logic_vector(99 , 8),
20  => conv_std_logic_vector(4 , 8),
21  => conv_std_logic_vector(0 , 8),
22  => conv_std_logic_vector(138 , 8),
23  => conv_std_logic_vector(81 , 8),
others => (others => '0')); 


attribute RAM_STYLE : string;
attribute RAM_STYLE of Program : variable is "BLOCK";
-- attribute RAM_STYLE of Stack : signal is "BLOCK";

-- 0 stack DEPTH

constant cmdNOP : integer := 0;

constant cmdRET : integer := 1;
constant cmdRETS : integer := 2; -- return with stack frame restore
constant cmdRETI : integer := 3; -- return from interrupt

constant cmdLOOP : integer := 4;

constant cmdNOT : integer := 16; -- 0x10
constant cmdSHL : integer := 17; -- 0x11
constant cmdSHR : integer := 18; -- 0x12
constant cmdSHRA : integer := 19; -- 0x13
constant cmdINPORT : integer := 20; -- 0x14
constant cmdSWAP : integer := 21; -- 0x15
constant cmdSHL8 : integer := 22; -- 0x16
constant cmdSHR8 : integer := 23; -- 0x17
constant cmdDEPTH : integer := 24; -- 0x18


-- +1 stack DEPTH
constant cmdDUP : integer := 32;   -- 0x20
constant cmdOVER : integer := 33;  -- 0x21

constant cmdSAVEA : integer := 35; -- 0x23
constant cmdSAVEB : integer := 36; -- 0x24

constant cmdLOCALR : integer := 37; -- 0x25
constant cmdSPR : integer := 38; -- 0x26


-- -1 stack DEPTH

constant cmdPLUS : integer := 64;  -- 0x40
constant cmdMINUS : integer := 65;
constant cmdAND : integer := 66;
constant cmdOR : integer := 67;
constant cmdXOR : integer := 68;
constant cmdEQUAL : integer := 69;
constant cmdULESS : integer := 70;
constant cmdUGREATER : integer := 71;
constant cmdMULT : integer := 72;

constant cmdDROP : integer := 80; -- 0x50
constant cmdJMP : integer := 81; -- 0x51
constant cmdCALL : integer := 82; -- 0x52
constant cmdRJMP : integer := 83; -- 0x53
constant cmdFETCH : integer := 85; -- 0x55
constant cmdPICK : integer := 86;
constant cmdARGFETCH : integer := 87;
constant cmdSETDEPTH : integer := 88;

constant cmdLOCALW : integer := 88;

-- -2 stack DEPTH

constant cmdSTORE : integer := 96; --  POKE == STORE
constant cmdARGSTORE : integer := 97;

constant cmdRIF : integer := 113;
constant cmdUNTIL : integer := 114; -- 
constant cmdOUTPORT : integer := 115;

constant INTERRUPT : integer := 4; -- interrupt addr

signal Depth, NewDepth, NewDepthSelected, adra, adrb, adra_temp : integer range 0 to MAXSTACK - 1;
signal Dqa, Dqb, Rdqa, Rdqb, Stacka, Stackb, dataa, datab, Result, LoadSData : std_logic_vector(DATAWIDTH - 1 downto 0);
signal NewDqa, NewDqb : std_logic_vector(DATAWIDTH - 1 downto 0);
signal OpNot, OpEqual, OpLesser, OpGreater : std_logic_vector(DATAWIDTH - 1 downto 0);
signal wea, web : std_logic;
signal werama, weramb : std_logic;
signal ip, newip : integer range 0 to 2**(PCWIDTH - 1);
signal cmd : std_logic_vector(7 downto 0) := x"00";

signal state, newstate : std_logic := '0';
signal LitPrev : std_logic := '0';

signal Rtop, Rdata : std_logic_vector(PCWIDTH downto 0);
signal wer : std_logic := '0';


signal MultResult, MultResultReg : std_logic_vector(DATAWIDTH * 2 - 1 downto 0);

signal Iflag : std_logic := '0';

signal Lit, local, sp : std_logic_vector(DATAWIDTH - 1 downto 0); 

signal depth1m, depth2m, depth1p : std_logic;

signal received, transmit : std_logic_vector(7 downto 0);
signal LoadAddr : std_logic_vector(PCWIDTH - 1 downto 0);
signal LoadData : std_logic_vector(31 downto 0);
signal LoadWe, DataLoad, int_reset : std_logic := '0';
signal rxstate, txstate : integer range 0 to (FCORE * 12) / UART_BAUDRATE := 0;
signal rxcounter, txcounter : std_logic_vector(DATAWIDTH - 1 downto 0) := (others => '0');
signal ActiveCore : std_logic_vector(3 downto 0);

begin

process(clk)
begin
  if clk'event and clk = '1' then
    case rxstate is
	   when 0 to FCORE / 2 / UART_BAUDRATE => if rx = '0' then rxstate <= rxstate + 1; end if;
	   when 3  * FCORE / 2 / UART_BAUDRATE => received(0) <= rx; rxstate <= rxstate + 1;
	   when 5  * FCORE / 2 / UART_BAUDRATE => received(1) <= rx; rxstate <= rxstate + 1;
	   when 7  * FCORE / 2 / UART_BAUDRATE => received(2) <= rx; rxstate <= rxstate + 1;
	   when 9  * FCORE / 2 / UART_BAUDRATE => received(3) <= rx; rxstate <= rxstate + 1;
	   when 11 * FCORE / 2 / UART_BAUDRATE => received(4) <= rx; rxstate <= rxstate + 1;
	   when 13 * FCORE / 2 / UART_BAUDRATE => received(5) <= rx; rxstate <= rxstate + 1;
	   when 15 * FCORE / 2 / UART_BAUDRATE => received(6) <= rx; rxstate <= rxstate + 1;
	   when 17 * FCORE / 2 / UART_BAUDRATE => received(7) <= rx; rxstate <= rxstate + 1;
	   when 19 * FCORE / 2 / UART_BAUDRATE => rxstate <= 0; rxcounter <= rxcounter + 1;

		  case conv_integer(received) is
		    when 0 to 15 => LoadData(3 downto 0) <= received(3 downto 0); LoadSData <= LoadSData(DATAWIDTH - 5 downto 0) & received(3 downto 0);
			 when 16 to 31 => LoadData(7 downto 4) <= received(3 downto 0);
			 when 32 to 47 => LoadData(11 downto 8) <= received(3 downto 0);
			 when 48 to 63 => LoadData(15 downto 12) <= received(3 downto 0);
			 when 64 to 79 => LoadData(19 downto 16) <= received(3 downto 0);
			 when 80 to 95 => LoadData(23 downto 20) <= received(3 downto 0);
			 when 96 to 111 => LoadData(27 downto 24) <= received(3 downto 0);
			 when 112 to 127 => LoadData(31 downto 28) <= received(3 downto 0);
			 when 224 to 239 => ActiveCore <= received(3 downto 0);
			 when 240 => LoadAddr <= (others => '0'); -- 32
			 when 241 => if conv_integer(ActiveCore) = CORE then LoadWe <= '1'; end if; -- 33
			 when 242 => if conv_integer(ActiveCore) = CORE then LoadWe <= '0'; DataLoad <= '0'; LoadAddr <= LoadAddr + 1; end if; -- 34
			 when 243 => if conv_integer(ActiveCore) = CORE then int_reset <= '1'; end if;-- 35
			 when 244 => if conv_integer(ActiveCore) = CORE then int_reset <= '0'; end if;-- 36
			 when 245 => if conv_integer(ActiveCore) = CORE then DataLoad <= '1'; end if;
			 when others => null;
		  end case;
      when others => rxstate <= rxstate + 1;
	 end case;
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
    if state = '1' and conv_integer(cmd) = cmdOUTPORT and Dqa(DATAWIDTH - 1 downto 0) = sxt("1", DATAWIDTH) then transmit <= Dqb(7 downto 0); end if;
  end if;
end process;


process(clk)
begin
  if clk'event and clk = '1' then
    case txstate is
	   when 0 => tx <= '1';
		          if state = '1' and conv_integer(cmd) = cmdOUTPORT and Dqa = sxt("1", DATAWIDTH) then txstate <= 1; end if;
	   when 1 => tx <= '0'; txstate <= txstate + 1;
	   when FCORE / UART_BAUDRATE => tx <= transmit(0); txstate <= txstate + 1;
	   when 2 * FCORE / UART_BAUDRATE => tx <= transmit(1); txstate <= txstate + 1;
	   when 3 * FCORE / UART_BAUDRATE => tx <= transmit(2); txstate <= txstate + 1;
	   when 4 * FCORE / UART_BAUDRATE => tx <= transmit(3); txstate <= txstate + 1;
	   when 5 * FCORE / UART_BAUDRATE => tx <= transmit(4); txstate <= txstate + 1;
	   when 6 * FCORE / UART_BAUDRATE => tx <= transmit(5); txstate <= txstate + 1;
	   when 7 * FCORE / UART_BAUDRATE => tx <= transmit(6); txstate <= txstate + 1;
	   when 8 * FCORE / UART_BAUDRATE => tx <= transmit(7); txstate <= txstate + 1;
	   when 9 * FCORE / UART_BAUDRATE => tx <= '1'; txstate <= txstate + 1;
		when 11 * FCORE / UART_BAUDRATE => txstate <= 0;
      when others => txstate <= txstate + 1;
	 end case;
  end if;
end process;

adra_temp <= conv_integer(Dqa) when ((conv_integer(cmd) = cmdFETCH) or (conv_integer(cmd) = cmdSTORE))
	else conv_integer(Depth - Dqa) when conv_integer(cmd) = cmdPICK 
	else Depth - 2 when cmd(7 downto 4) = "0100"
	else NewDepth - 1 when NewDepth > 0
	else 0;
	
adra <= adra_temp - 2 when adra_temp >= 2 else 0 ;	
adrb <= NewDepth - 3 when NewDepth >= 3 else 0;

process(clk)
begin
  if rising_edge(clk) then
    if cmd(7) = '1' and LitPrev = '1' then
      Lit <= Lit(DATAWIDTH - 8 downto 0) & cmd(6 downto 0);
      elsif cmd(7) = '1' and LitPrev = '0' then Lit <= sxt(cmd(6 downto 0), DATAWIDTH);
		  else Lit <= (others => '0');
    end if;
  end if;
end process;

NewDqa <= Lit(DATAWIDTH - 8 downto 0) & cmd(6 downto 0) when cmd(7) = '1' and LitPrev = '1' else Result;
NewDqb <= Dqa;

wea <= '1' and state when cmd(7 downto 4) = "0001" 
                       or cmd(7) = '1' 
							  or cmd(7 downto 4) = "0010" 
							  or cmd(7 downto 4) = "0100" 
							  or cmd(7 downto 4) = "0110" 
							  else '0';

web <= '1' and state when conv_integer(cmd) = cmdSWAP else '0';

OpNot <= (others => '1') when conv_integer(Dqa) = 0 else (others => '0');
OpEqual <= (others => '1') when conv_integer(Dqa) = conv_integer(Dqb) else (others => '0');
OpLesser <= (others => '1') when conv_integer(Dqa) > conv_integer(Dqb) else (others => '0');
OpGreater <= (others => '1') when conv_integer(Dqa) < conv_integer(Dqb) else (others => '0');

MultGenerateYes: if HARDWARE_MULTIPLIER = "YES" generate
  begin
    MultResult <= Dqa * Dqb;
  end generate;
  
MultGenerateReg: if HARDWARE_MULTIPLIER = "REGISTERED" generate
begin
  RDqa <= Dqa when rising_edge(clk);
  RDqb <= Dqb when rising_edge(clk);
  MultResultReg <= RDqa * RDqb;
  MultResult <= MultResultReg when rising_edge(clk);
end generate;
  
MultGenerateNo : if HARDWARE_MULTIPLIER /= "YES" and HARDWARE_MULTIPLIER /= "REGISTERED" generate
  begin
    MultResult <= (others => '0');
  end generate;

with conv_integer(cmd) select
Result <= Dqa + Dqb when cmdPLUS,
          Dqb - Dqa when cmdMINUS,
			 Dqa and Dqb when cmdAND,
			 Dqa or Dqb when cmdOR,
			 Dqa xor Dqb when cmdXOR,
			 OpNot when cmdNOT,
			 Dqa(DATAWIDTH - 2 downto 0) & '0' when cmdSHL,
			 '0' & Dqa(DATAWIDTH - 1 downto 1) when cmdSHR,
			 Dqa(DATAWIDTH - 1) & Dqa(DATAWIDTH - 1 downto 1) when cmdSHRA,
			 din when cmdINPORT,
			 Dqb when cmdSWAP,
			 Dqa(DATAWIDTH - 9 downto 0) & x"00" when cmdSHL8,
			 x"00" & Dqa(DATAWIDTH - 1 downto 8) when cmdSHR8,
			 OpEqual when cmdEQUAL,
			 OpLesser when cmdULESS,
			 OpGreater when cmdUGREATER,
			 MultResult(DATAWIDTH - 1 downto 0) when cmdMULT,
			 Dqa when cmdPICK,
			 Dqa when cmdARGFETCH,
			 Dqa when cmdDUP,
			 Dqb when cmdOVER,
			 Dqb when cmdARGSTORE,
			 Dqb when cmdSTORE,
			 conv_std_logic_vector(Depth, DATAWIDTH) when cmdDEPTH,
			 local when cmdLOCALR,
			 sp when cmdSPR,
			 sxt(cmd(6 downto 0), DATAWIDTH) when 128 to 255,
       x"00000000" when others;

NewDepth <= conv_integer(Dqa) when state = '1' and conv_integer(cmd) = cmdSETDEPTH 
            else NewDepthSelected;

depth1m <= '1' when ((conv_integer(LitPrev & cmd) >= 64) and (conv_integer(LitPrev & cmd) <= 95))
                 or ((conv_integer(LitPrev & cmd) >= 320) and (conv_integer(LitPrev & cmd) <= 351)) else '0';

depth2m <= '1' when ((conv_integer(LitPrev & cmd) >= 96) and (conv_integer(LitPrev & cmd) <= 127))
                 or ((conv_integer(LitPrev & cmd) >= 352) and (conv_integer(LitPrev & cmd) <= 383)) else '0';

depth1p <= '1' when ((conv_integer(LitPrev & cmd) >= 32) and (conv_integer(LitPrev & cmd) <= 63))
                 or ((conv_integer(LitPrev & cmd) >= 128) and (conv_integer(LitPrev & cmd) <= 255)) 
                 or ((conv_integer(LitPrev & cmd) >= 288) and (conv_integer(LitPrev & cmd) <= 319)) 
								 else '0';


with conv_integer(LitPrev & cmd) select
NewDepthSelected <= Depth + 1 when 128 to 255,
										Depth + 1 when 32 to 63,
										Depth + 1 when 288 to 319, -- 32 .. 63 + 256
										Depth - 1 when 64 to 95,
										Depth - 1 when 320 to 351,
										Depth - 2 when 96 to 127,
										Depth - 2 when 352 to 383,
										Depth when others;

dataa <= Dqa when depth2m = '1' else Dqb;
datab <= Dqb;

werama <= '1' when depth1p = '1' else '0';
weramb <= '1' when depth1p = '1' else '0';

process(clk)
begin
  if rising_edge(clk) then
    if werama = '1' then
      Stack(adra) := dataa;
	 end if;
	 Stacka <= Stack(adra);
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
    if weramb = '1' then
      Stack(adrb) := datab;
	 end if;
	 Stackb <= Stack(adrb);
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
	  if wea = '1' then Dqa <= NewDqa; end if;
  end if;
end process;	

process(clk)
begin
  if rising_edge(clk) then
	  if web = '1' then Dqb <= NewDqb; end if;
  end if;
end process;	

process(clk)
begin
  if rising_edge(clk) then
    if reset = '1' then Depth <= 0;
      elsif state = '1' then
        Depth <= NewDepth;
	 end if;
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
    LitPrev <= cmd(7) and state;
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
	  if state = '1' and conv_integer(cmd) = cmdLOCALW then
		  local <= Dqa;
		end if;
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
	  if state = '1' and conv_integer(cmd) = cmdCALL then
		  sp <= conv_std_logic_vector(Depth, DATAWIDTH);
		end if;
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
	 cmd <= Program(ip);
  end if;
end process;

process(clk)
begin
  if rising_edge(clk) then
    if LoadWe = '1' then
	   Program(conv_integer(LoadAddr)) := LoadData(7 downto 0);
	 end if;
  end if;
end process;

	NewIp <= 0 when reset = '1' or int_reset = '1'
     else INTERRUPT when intr = '1' and state = '1' and conv_integer(cmd) /= cmdSAVEA and conv_integer(cmd) /= cmdSAVEB
		 else conv_integer(Dqa) when (conv_integer(cmd) = cmdJMP or conv_integer(cmd) = cmdCALL)and state = '1' 
		 else conv_integer(Ip + Dqa) when (((conv_integer(cmd) = cmdRIF) and conv_integer(Dqb) = 0) or (conv_integer(cmd) = cmdRJMP))and state = '1' 
		 else conv_integer(Ip - Dqa) when (conv_integer(cmd) = cmdUNTIL) and conv_integer(Dqb) = 0 and state = '1' 
		 else Ip + 1;

	process(clk)
	begin
	  if rising_edge(clk) then
		 if reset = '1' or int_reset = '1' or (intr = '1' and state = '1' and conv_integer(cmd) /= cmdSAVEA and conv_integer(cmd) /= cmdSAVEB)
			  or ((conv_integer(cmd) = cmdJMP or conv_integer(cmd) = cmdCALL or conv_integer(cmd) = cmdRJMP) and state = '1')
			  or ((conv_integer(cmd) = cmdRIF and conv_integer(Dqb) = 0) and state = '1') 
			  or ((conv_integer(cmd) = cmdUNTIL) and state = '1')
			then state <= '0';
			else state <= '1';
		 end if;
	  end if;
	end process;

process(clk)
begin
  if rising_edge(clk) then
	 Ip <= NewIp;
  end if;
end process;

wrio <= state when conv_integer(cmd) = cmdOUTPORT else '0';
rdio <= state when conv_integer(cmd) = cmdINPORT else '0';

addr <= Dqa(19 downto 0);
data <= Dqb;

end Behavioral;

