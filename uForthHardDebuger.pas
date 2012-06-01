unit uForthHardDebuger;

interface

uses SysUtils, Windows, Messages, uGlobal, uRecordList, DateUtils, uForthDeviceCore;

type
  TTinyArrayOfByte = array[0..63] of byte;

  TForthHardDebuger = class(TForthDevice)
  private
    valueInCpu: integer;

    procedure SendValue(value: integer);
    procedure PrepareToSend(const _value, _lastValue: integer; var buf: TTinyArrayOfByte;
      var count: integer);

    function ReadCode(position: integer): integer;
    function ReadData(position: integer): integer;
    procedure UpdateInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Init;
    procedure TurnOn; override;
    procedure TurnOff; override;
    procedure Reset; override;
    procedure TraceInto; override;
    procedure StepOver; override;
    procedure RunToCursor(programmCounter: integer); override;
    procedure RunUntilReturn; override;
    procedure RunForTime(milliSeconds: integer); override;
    procedure RunForCommands(commandCount: integer); override;
    procedure RunForStepOverCommands(commandCount: integer); override;
  end;

implementation

//                        7  6  5  4  3  2  1  0
// value operations       [    0    ][   cmd   ]
// value[3-0] = data      [    1    ][   data  ]
// value[7-4] = data      [    2    ][   data  ]
// value[11-8] = data     [    3    ][   data  ]
// value[15-12] = data    [    4    ][   data  ]
// value[19-16] = data    [    5    ][   data  ]
// value[23-20] = data    [    6    ][   data  ]
// value[27-24] = data    [    7    ][   data  ]
// value[31-28] = data    [    8    ][   data  ]
// Get                    [    9    ][   cmd   ]
// Set                    [    A    ][   cmd   ]
// GetSetAdv              [    B    ][   cmd   ]
// Watchers               [    C    ][   cmd   ]
// BreakPoints            [    D    ][   cmd   ]
// Commands               [    E    ][   cmd   ]
// RESERVED               [    F    ] X  X  X  X
//
// value operations
// 00
// 0 not used
// 1 value = $00000000
// 2 value = $FFFFFFFF
// 3 value = value + 1
// 4 value = value - 1
// 5 addr = value
//
// Get
// 90
// 0 Code[value]
// 1 Data[value]
// 2 DataStackTop
// 3 DataStackUnderTop
// 4 DataStackPop
// 5 DataStackDepth
// 6 RetStackTop
// 7 RetStackUnderTop
// 8 RetStackPop
// 9 RetStackDepth
// A PC
// B HERE
// C CHERE
// D CMD
// E --
// F --
//
// Set
// A0
// 0 Code[addr] = value
// 1 Data[addr] = value
// 2 DataStackPush
// 3 --
// 4 --
// 5 --
// 6 RetStackPush
// 7 --
// 8 --
// 9 --
// A PC
// B HERE
// C CHERE
// D --
// E --
// F --
//
// GetSetAdv B0-BF
//
// Watchers C0-CF
// BreakPoints D0-DF
//
// Commands E0-EF
// 0 TraceInto
// 1 StepOver
// 2 RunToCursor
// 3 RunUntilReturn
// 4 RunForTime
// 5 RunForTraceIntoCommands
// 6 RunForStepOverCommands
// 7 Reset
// 8
// 9
// A
// B
// C
// D
// E
// F

const
  cmdValueOps = $00;
  cmdValueBase = $10;
  cmdGet = $90;
  cmdSet = $A0;
  cmdGetSetAdv = $B0;
  cmdWatchers = $C0;
  cmdBreakPoints = $D0;
  cmdExecute = $E0;

  // Value
  cmdZerosToValue = $01;
  cmdOnesToValue = $02;
  cmdValueDec = $03;
  cmdValueInc = $04;

  // Get
  cmdGetCode = $90;
  cmdGetData = $91;
  cmdGetDataStackTop = $92;
  cmdGetDataStackUnderTop = $93;
  cmdGetDataStackPop = $94;
  cmdGetDataStackDepth = $95;
  cmdGetRetStackTop = $96;
  cmdGetRetStackUnderTop = $97;
  cmdGetRetStackPop = $98;
  cmdGetRetStackDepth = $99;
  cmdGetPC = $9A;
  cmdGetHere = $9B;
  cmdGetCHere = $9C;
  cmdGetCmd = $9D;

  // Set
  cmdSetCode = $A0;
  cmdSetData = $A1;
  cmdSetDataStackPush = $A2;
  cmdSetRetStackPush = $A6;
  cmdSetPC = $AA;
  cmdSetHere = $AB;
  cmdSetCHere = $AC;

  // GetSetAdv

  // Exe
  cmdTraceInto = $E0;
  cmdStepOver = $E1;
  cmdRunToCursor = $E2;
  cmdRunUntilReturn = $E3;
  cmdReset = $E7;

{ THardDebug }

constructor TForthHardDebuger.Create;
begin
  inherited;
end;

destructor TForthHardDebuger.Destroy;
begin
  inherited;
end;

procedure TForthHardDebuger.Init;
begin
end;


procedure AddToBuf(data: integer; var buf: array of byte; var count: integer);
begin
  buf[count] := data;
  inc(count);
end;

procedure TForthHardDebuger.PrepareToSend(const _value, _lastValue: integer; var buf: TTinyArrayOfByte;
  var count: integer);
var
  i: integer;
  mask: integer;
  value, lastValue: integer;
  command: integer;
begin
  mask := $F;
  value := _value;
  lastValue := _lastValue;
  command := cmdValueBase;
  for i := 0 to 7 do
  begin
    if (value and mask) <> (lastValue and mask) then
      AddToBuf(command + (value and mask), buf, count);
    value := value shr 4;
    lastValue := lastValue shr 4;
    command := command + $10;
  end;
end;

function TForthHardDebuger.ReadCode(position: integer): integer;
begin
  SendValue(position);
  downloader.SendByte(cmdGetCode);
  downloader.Get(Result);
end;

function TForthHardDebuger.ReadData(position: integer): integer;
begin
  SendValue(position);
  downloader.SendByte(cmdGetData);
  downloader.Get(result);
end;

procedure TForthHardDebuger.Reset;
begin
  downloader.SendByte(cmdReset);
end;

procedure TForthHardDebuger.RunForCommands(commandCount: integer);
begin
  // todo:
end;

procedure TForthHardDebuger.RunForStepOverCommands(commandCount: integer);
begin
  // todo:
end;

procedure TForthHardDebuger.RunForTime(milliSeconds: integer);
begin
  // todo:
end;

procedure TForthHardDebuger.RunToCursor(programmCounter: integer);
begin
  SendValue(programmCounter);
  downloader.SendByte(cmdRunToCursor);
  UpdateInfo;
end;

procedure TForthHardDebuger.RunUntilReturn;
begin
  downloader.SendByte(cmdRunUntilReturn);
  UpdateInfo;
end;

procedure TForthHardDebuger.SendValue(value: integer);
const
  MaxVariants = 5;
var
  Buff: array[0..MaxVariants-1] of record
    buffer: TTinyArrayOfByte;
    count: integer;
  end;
  index: integer;
  indexMin: integer;
begin
  with Buff[0] do
  begin
    count := 0;
    PrepareToSend(value, valueInCpu, buffer, count);
  end;

  with Buff[1] do
  begin
    count := 0;
    AddToBuf(cmdZerosToValue, buffer, count);
    PrepareToSend(value, $00000000, buffer, count);
  end;

  with Buff[2] do
  begin
    count := 0;
    AddToBuf(cmdOnesToValue, buffer, count);
    {$WARNINGS OFF}
    PrepareToSend(value, $FFFFFFFF, buffer, count);
    {$WARNINGS ON}
  end;

  with Buff[3] do
  begin
    count := 0;
    AddToBuf(cmdValueInc, buffer, count);
    PrepareToSend(value, valueInCpu + 1, buffer, count);
  end;

  with Buff[4] do
  begin
    count := 0;
    AddToBuf(cmdValueDec, buffer, count);
    PrepareToSend(value, valueInCpu - 1, buffer, count);
  end;

  indexMin := 0;
  for index := 1 to MaxVariants-1 do
    if Buff[index].count < Buff[indexMin].count then
      indexMin := index;

  downloader.Send(Buff[indexMin].buffer, Buff[indexMin].count);
end;

procedure TForthHardDebuger.StepOver;
begin
  downloader.SendByte(cmdStepOver);
  UpdateInfo;
end;

procedure TForthHardDebuger.TraceInto;
begin
  downloader.SendByte(cmdTraceInto);
  UpdateInfo;
end;

procedure TForthHardDebuger.TurnOff;
begin
  downloader.Close;
end;

procedure TForthHardDebuger.TurnOn;
begin
  downloader.Open;

  downloader.SendByte(cmdZerosToValue);
  valueInCpu := 0;
end;

procedure TForthHardDebuger.UpdateInfo;
var
  command: integer;
begin
  downloader.SendByte(cmdGetPC);
  downloader.Get(PC);
  downloader.SendByte(cmdGetCmd);
  downloader.Get(command);
  Code[PC] := command;
  OnCodeChange(PC, command);
end;

end.
