unit uKf7DeviceCore;

interface

uses
  Windows, SysUtils, uGlobal, uRecordList, Generics.Collections;

const
  DStackSize = 32;
  RStackSize = 32;
  LStackSize = 32;
  MaxPeriferal = 32;

  // Dqa
  cmdNOP     = $00;
  cmdNOT     = $01;
  cmdSHL     = $02;
  cmdSHR     = $03;
  cmdSHRA    = $04;
  cmdSHL8    = $05;
  cmdSHR8    = $06;
  cmdDUP     = $07;
  cmdNEGATE  = $0F;

  // Dqb
  cmdSWAP    = $10;
  cmdSAVEB   = $11;
  cmdOVER    = $12;
  cmdDROP    = $13;
  cmdLOCALW  = $14;
  cmdJMP     = $18;
  cmdCALL    = $19;
  cmdRJMP    = $1A;
  cmdSETDEPTH= $1E;
  cmdDEBUG   = $1F;

  // ALU
  cmdADD     = $20;
  cmdSUB     = $21;
  cmdAND     = $22;
  cmdOR      = $23;
  cmdXOR     = $24;
  cmdEQUAL   = $25;
  cmdULESS   = $26;
  cmdUGREATER= $27;
  cmdMULT    = $28;
  cmdLESS    = $29;
  cmdGREATER = $2A;

  // D2m
  cmdSTORE   = $30;
  cmdARGSTORE= $31;
  cmdDO      = $32;
  cmdCSTORE  = $33;
  cmdRIF     = $34;
  cmdUNTIL   = $35;

  // MIX
  cmdLOCALR  = $40;
  cmdCFETCH  = $41;
  cmdDEPTH   = $42;
  cmdI       = $43;
  cmdFETCH   = $48;
  cmdPICK    = $49;
  cmdARGFETCH= $4A;
  cmdIX      = $4B;

  // G5
  cmdRET     = $50;
  cmdRETS    = $51;
  cmdRETI    = $52;
  cmdLOOP    = $53;

  INTERRUPT  = 4; // interrupt addr

  SignExtention = true;
  LITSize    = 7;
  cmdLIT     = 128; // 2^7
  LitMask    = cmdLIT - 1;
  NegativeBit = cmdLIT shr 1;

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

  PKf7Device = ^TKf7Device;
  TKf7Device = class(TDebuger)
  public
    DStack: TStackInt;
    RStack: TStackInt;
    LStack: TStackLoop;

    Depth: integer;


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

{ TKf7Device }

constructor TKf7Device.Create;
begin
  inherited;
  DStack := TStackInt.Create(DStackSize);
  RStack := TStackInt.Create(RStackSize);
  LStack := TStackLoop.Create(LStackSize);
end;

destructor TKf7Device.Destroy;
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
