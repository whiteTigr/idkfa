unit uProteusDeviceCore;

interface

uses
  Windows, SysUtils, uGlobal, uRecordList, Generics.Collections;

const
  DStackSize = 32;
  RStackSize = 32;
  LStackSize = 32;
  MaxPeriferal = 32;

  cmdNOP     = 0;

  cmdNOT     = 1;
  cmdFETCH   = 2; // cmd2
  cmdSHL     = 3;
  cmdSHR     = 4;
  cmdSHRA    = 5;
  cmdFP      = 6;

  cmdSWAP    = 7;

  cmdDUP     = 8;
  cmdOVER    = 9;
  cmdFROMR   = 10;
  cmdLOOP    = 11;
  cmdSYSREG  = 12;

  cmdPLUS    = 13;
  cmdMINUS   = 14;
  cmdAND     = 15;
  cmdOR      = 16;
  cmdXOR     = 17;
  cmdEQUAL   = 18;
  cmdLESSER  = 19;
  cmdGREATER = 20;
  cmdMULT    = 21; // cmd3

  cmdDROP    = 22;
  cmdJMP     = 23;
  cmdCALL    = 24;
  cmdRJMP    = 25;
  cmdTOR     = 26;

  cmdSTORE   = 27;
  cmdDO      = 28;
  cmdRIF     = 29;
  cmdUNTIL   = 30;

  cmdRET     = 31;

  cmdLIT     = 32;

  LitMask    = $1F;
  NegativeBit = (LitMask + 1) shr 1; // $10 for LitMask = $1F

  sysDEPTH   = 0;
  sysRDEPTH  = 1;
  sysI       = 2;
  sysDIV     = 3;
  sysMOD     = 4;
  sysTXSTATE = 5;
  sysRECEIVED = 6;
  sysRXCOUNTER = 7;
  sysSYSTIMER_LOW = 8;
  sysSYSTIMER_HI = 9;
  sysUSEC    = 10;
  sysMSEC    = 11;
  sysSEC     = 12;
  sysMIN     = 13;
  sysHOUR    = 14;

  AbsoluteJmpCommands = [cmdJMP, cmdCALL, cmdUNTIL];
  RelativeJmpCommands = [cmdRJMP, cmdRIF];
  JmpCommands = AbsoluteJmpCommands + RelativeJmpCommands;

type
  TLoopCell = record
    max, cur: integer;
    jmp: integer;
  end;

  PStackLoop = ^TStackLoop;
  TStackLoop = class(TStack)
  public
    constructor Create(size: integer = 0);
    procedure Push(value: TLoopCell);
    function  Pop: TLoopCell;
    function ReadTop: TLoopCell;
  end;

  PProteusDevice = ^TProteusDevice;
  TProteusDevice = class(TDebuger)
  public
    DStack: TStackInt;
    RStack: TStackInt;
    LStack: TStackLoop;

    constructor Create;
    destructor Destroy; override;
  end;

  TPeriferalComponent = record
    startAddr: integer;
    endAddr: integer;
    Inport: function(addr: integer): integer;
    Outport: procedure(addr, data: integer);
  end;

var
  CommandsAtLastStepOver: integer;

function LoopCell(cur, max, jmp: integer): TLoopCell;

implementation

function LoopCell(cur, max, jmp: integer): TLoopCell;
begin
  Result.max := max;
  Result.cur := cur;
  Result.jmp := jmp;
end;

{ TProteusDevice }

constructor TProteusDevice.Create;
begin
  inherited;
  DStack := TStackInt.Create(DStackSize);
  RStack := TStackInt.Create(RStackSize);
  LStack := TStackLoop.Create(LStackSize);
end;

destructor TProteusDevice.Destroy;
begin
  DStack.Destroy;
  RStack.Destroy;
  LStack.Destroy;
  inherited;
end;

{ TStackLoop }

constructor TStackLoop.Create(size: integer);
begin
  inherited Create(sizeof(TLoopCell), size);
end;

function TStackLoop.Pop: TLoopCell;
begin
  Result := TLoopCell(inherited Pop^);
end;

procedure TStackLoop.Push(value: TLoopCell);
begin
  inherited Push(@value);
end;

function TStackLoop.ReadTop: TLoopCell;
begin
  Result := TLoopCell(inherited ReadTop^);
end;

end.
