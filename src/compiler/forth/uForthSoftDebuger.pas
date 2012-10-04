unit uForthSoftDebuger;

interface

uses
  Windows, SysUtils, Messages, DateUtils, uForthDeviceCore, uRecordList, uGlobal, Forms;

type
  PForthSoftDebug = ^TForthSoftDebug;
  TForthSoftDebug = class(TForthDevice)
  private
    MaxWaitingTime: integer;
    HereID: integer;
    CHereID: integer;
    PeriferalComponents: array[0..MaxPeriferal-1] of TPeriferalComponent;
    PeriferalCount: integer;

    procedure ExecuteCommand;
    function FindPeriferal(addr: integer): integer;
    procedure Outport(addr, data: integer);
    function Inport(addr: integer): integer;
  public

    constructor Create;
    destructor Destroy; override;
    procedure TurnOn; override;
    procedure TurnOff; override;
    procedure AddPeriferal(startAddr, endAddr: integer; inport: pointer; outport: pointer);
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

{ TSoftDebug }

constructor TForthSoftDebug.Create;
begin
  inherited;
  MaxWaitingTime := defaultMaxWaitingTime;
  PeriferalCount := 0;
end;

destructor TForthSoftDebug.Destroy;
begin
  inherited;
end;

procedure TForthSoftDebug.ExecuteCommand;
var
  cmd: integer;
  int1, int2: integer;
  LoopCell: ^TLoopCell;
begin
  cmd := Code[PC];

  // работа со стеком
  case cmd of
    $30000..$3FFFF: // lit x
    begin
      int1 := cmd and $FFFF;
      if (int1 and $8000) <> 0 then
        int1 := integer($FFFF0000) or int1;
      DStack.Push(int1);
    end;

    $20000..$2FFFF: // lit h
      DStack.Push((cmd and $FFFF) shl 16);

    $10000..$1FFFF: // lit l
      DStack.Push(DStack.Pop or (cmd and $FFFF));

    16: // I
      DStack.Push(TLoopCell(LStack.ReadTop^).Cur);

    cmdFROMR: // R>
      DStack.Push(RStack.Pop);

    18: // temp>
      DStack.Push(FCPU_Temp);

    19: // depth
      DStack.Push(DStack.Top);

    20: // rdepth
      DStack.Push(RStack.Top);

    21: // dup
      DStack.Push(DStack.ReadTop);

    22: // over
    begin
      int1 := DStack.Pop;
      int2 := DStack.ReadTop;
      DStack.Push(int1);
      DStack.Push(int2);
    end;

    23: // depth
      DStack.Push(DStack.Top);

    24: // rdepth
      DStack.Push(RStack.Top);

    48: // @
      DStack.Push(Data[DStack.Pop]);

    49: // [C]@
      DStack.Push(Code[DStack.Pop]);

    50: // not
      DStack.Push(not DStack.Pop);

    55: // shl
      DStack.Push(DStack.Pop shl 1);

    56: // shr
      DStack.Push(DStack.Pop shr 1);

    57: // shra
    begin
      int1 := DStack.Pop;
      DStack.Push((int1 shr 1) or (int1 and integer($80000000)));
    end;

    58: // inport
    begin
      int1 := DStack.Pop;
      DStack.Push(Inport(int1));
    end;

    cmdTOR: // >R
      RStack.Push(DStack.Pop);

    66: // drop
      DStack.Pop;

    80: // nip
    begin
      int1 := DStack.Pop;
      FCPU_Temp := DStack.Pop;
      DStack.Push(int1);
    end;

    81: // +
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 + int2);
    end;

    82: // -
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int2 - int1);
    end;

    83: // and
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 and int2);
    end;

    84: // or
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 or int2);
    end;

    85: // xor
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 xor int2);
    end;

    86: // =
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if int1 = int2 then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    87: // <
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if int2 < int1 then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    88: // >
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if int2 > int1 then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    112: // !
    begin
      int1 := DStack.Pop; // addr
      int2 := DStack.Pop; // data
      Data[int1] := int2;
      OnDataChange(int1, int2);
    end;

    114: // do
    begin
      LoopCell := AllocMem(sizeof(TLoopCell));
      LoopCell.Jmp := PC + 1;
      LoopCell.Cur := DStack.Pop;
      LoopCell.Last := DStack.Pop;
      LStack.Push(LoopCell);
      FreeMemory(LoopCell);
    end;

    122: // outport
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      Outport(int1, int2);
    end;

    115: // [C]!
    begin
      int1 := DStack.Pop; // addr
      int2 := DStack.Pop; // data
      Code[int1] := int2;
      OnCodeChange(int1, int2);
    end;

    89: // *
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 * int2);
    end;

    127: // /MOD
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int2 div int1);
      DStack.Push(int2 mod int1);
    end;
  end;

  // переходы
  case cmd of
    $20: // ret
    begin
      PC := RStack.Pop;
    end;

    $22: // loop
    begin
      LoopCell := LStack.ReadTop;
      if LoopCell.Cur >= LoopCell.Last - 1 then
      begin
        LStack.Pop;
        PC := PC + 1;
      end
      else
      begin
        PC := LoopCell.Jmp;
        LoopCell.Cur := LoopCell.Cur + 1;
      end;
    end;

    $4000..$7FFF: // jmp
    begin
      PC := cmd and $3FFF;
    end;

    $8000..$BFFF: // if
    begin
      if DStack.Pop = 0 then
        PC := cmd and $3FFF
      else
        PC := PC + 1;
    end;

    $C000..$FFFF: // call
    begin
      RStack.Push(PC + 1);
      PC := cmd and $3FFF;
    end;

    else // nop
      PC := PC + 1;
  end;

  if PC < 0 then
  begin
    PC := 0;
    MessageBox(0, 'PC < 0. Установлено в 0.', 'Ошибка', MB_OK or MB_ICONWARNING);
  end;

  if PC >= MaxCode then
  begin
    PC := MaxCode-1;
    MessageBox(0, 'PC > MaxCode. Установлено в MaxCode.', 'Ошибка', MB_OK or MB_ICONWARNING);
  end;
end;

procedure TForthSoftDebug.AddPeriferal(startAddr, endAddr: integer; inport,
  outport: pointer);
begin
  PeriferalComponents[PeriferalCount].startAddr := startAddr;
  PeriferalComponents[PeriferalCount].endAddr := endAddr;
  PeriferalComponents[PeriferalCount].Inport := inport;
  PeriferalComponents[PeriferalCount].Outport := outport;
  inc(PeriferalCount);
end;

function TForthSoftDebug.FindPeriferal(addr: integer): integer;
var
  periferalIndex: integer;
begin
  for periferalIndex := 0 to PeriferalCount-1 do
    if (addr >= PeriferalComponents[periferalIndex].startAddr) and
      (addr <= PeriferalComponents[periferalIndex].endAddr) then
    begin
      Result := periferalIndex;
      Exit;
    end;
  Result := -1;
end;

function TForthSoftDebug.Inport(addr: integer): integer;
var
  periferalIndex: integer;
begin
  Result := -1;
  periferalIndex := FindPeriferal(addr);
  if periferalIndex = -1 then Exit;
  if @PeriferalComponents[periferalIndex].Inport = nil then Exit;
  Result := PeriferalComponents[periferalIndex].Inport(addr);
end;

procedure TForthSoftDebug.Outport(addr, data: integer);
var
  periferalIndex: integer;
begin
  periferalIndex := FindPeriferal(addr);
  if periferalIndex = -1 then Exit;
  if @PeriferalComponents[periferalIndex].Outport = nil then Exit;
  PeriferalComponents[periferalIndex].Outport(addr, data);
end;

procedure TForthSoftDebug.Reset;
begin
  DStack.Reset;
  RStack.Reset;
  LStack.Reset;
  PC := 0;
  HereID := -1;
  CHereID := -1;
end;

procedure TForthSoftDebug.RunForCommands(commandCount: integer);
var
  commandExecuted: integer;
  time: real;
begin
  time := Now;
  commandExecuted := 0;
  while (commandExecuted < commandCount) and (SecondOf(Now - time) < MaxWaitingTime) do
  begin
    TraceInto;
    inc(commandExecuted);
  end;
end;

procedure TForthSoftDebug.RunForStepOverCommands(commandCount: integer);
var
  commandExecuted: integer;
  time: real;
begin
  time := Now;
  commandExecuted := 0;
  while (commandExecuted < commandCount) and (SecondOf(Now - time) < MaxWaitingTime) do
  begin
    StepOver;
    inc(commandExecuted);
  end;
end;

procedure TForthSoftDebug.RunForTime(milliSeconds: integer);
var
  time: real;
begin
  time := Now;
  while (MilliSecondOf(Now - time) < milliSeconds) do
    StepOver;
end;

procedure TForthSoftDebug.RunToCursor(programmCounter: integer);
var
  time: real;
begin
  time := Now;
  while (PC <> programmCounter) and (SecondOf(Now - time) < MaxWaitingTime) do
    StepOver;
end;

procedure TForthSoftDebug.RunUntilReturn;
var
  time: real;
begin
  time := Now;
  while (Code[PC] <> cmdRET) and (SecondOf(Now - time) < MaxWaitingTime) do
    StepOver;
end;

procedure TForthSoftDebug.StepOver;
var
  RTop: integer;
  time: real;
begin
  RTop := RStack.Top;
  time := Now;
  repeat
    if Code[PC] = cmdTOR then
      inc(RTop);
    if Code[PC] = cmdFROMR then
      dec(RTop);
    ExecuteCommand;
  until (RStack.Top <= RTop) or (SecondOf(Now - time) > MaxWaitingTime);
end;

procedure TForthSoftDebug.TraceInto;
begin
  ExecuteCommand;
end;

procedure TForthSoftDebug.TurnOff;
begin
  inherited;
end;

procedure TForthSoftDebug.TurnOn;
begin
  inherited;
  Reset;
end;

end.
