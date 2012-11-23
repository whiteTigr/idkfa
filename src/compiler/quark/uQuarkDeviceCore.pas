unit uQuarkDeviceCore;

interface

uses
  Windows, Messages, Sysutils, uGlobal;

const
  cmdNOP     = 0;

  cmdNOT     = 1;
  cmdFETCH   = 2; // cmd2
  cmdSHL     = 3;
  cmdSHR     = 4;
  cmdSHRA    = 5;
  cmdINPORT  = 6; // cmd2

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
  TQuarkDeviceCore = class(TDebuger)
  private
  public
  end;

implementation

end.
