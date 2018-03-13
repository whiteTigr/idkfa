unit uKf7SoftDebuger;

interface

uses
  Windows, SysUtils, uGlobal, uKf7DeviceCore, DateUtils, uCommonFunctions;

type
  PProtuesSoftDebuger = ^TKf7SoftDebuger;
  TKf7SoftDebuger = class(TKf7Device)
  private
    FCommandsCount: integer;

    MaxWaitingTime: integer;

    isPutNewNumber: boolean;
    PeriferalComponents: array[0..MaxPeriferal-1] of TPeriferalComponent;
    PeriferalCount: integer;

    RXCounter: integer;
    Received: byte;

    DivSt: integer;
    DivA, DivB: integer;
    RDiv, RRem: integer;

    function FindPeriferal(addr: integer): integer;
    procedure Outport(addr, data: integer);
    function Inport(addr: integer): integer;
    procedure ExecuteCommand;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddPeriferal(startAddr, endAddr: integer; inport: pointer; outport: pointer);

    procedure Reset; override;
    procedure TurnOn; override;
    procedure TurnOff; override;
    procedure TraceInto; override;
    procedure StepOver; override;
    procedure RunToCursor(programmCounter: integer); override;
    procedure RunUntilReturn; override;
    procedure RunForTime(milliSeconds: integer); override;
    procedure RunForCommands(commandCount: integer); override;
    procedure RunForStepOverCommands(commandCount: integer); override;

    procedure TransmitToCom(value: byte);

    property CommandsCount: integer read FCommandsCount;
  end;

implementation

{ TKf7SoftDebuger }

constructor TKf7SoftDebuger.Create;
begin
  inherited;
  PeriferalCount := 0;
  MaxWaitingTime := 10;
  RXCounter := 0;
  DivSt := 0;
end;

destructor TKf7SoftDebuger.Destroy;
begin
  inherited;
end;

procedure TKf7SoftDebuger.AddPeriferal(startAddr, endAddr: integer; inport,
  outport: pointer);
begin
  PeriferalComponents[PeriferalCount].startAddr := startAddr;
  PeriferalComponents[PeriferalCount].endAddr := endAddr;
  PeriferalComponents[PeriferalCount].Inport := inport;
  PeriferalComponents[PeriferalCount].Outport := outport;
  inc(PeriferalCount);
end;

function TKf7SoftDebuger.FindPeriferal(addr: integer): integer;
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

function TKf7SoftDebuger.Inport(addr: integer): integer;
var
  periferalIndex: integer;
begin
  Result := -1;
  periferalIndex := FindPeriferal(addr);
  if periferalIndex = -1 then Exit;
  if @PeriferalComponents[periferalIndex].Inport = nil then Exit;
  Result := PeriferalComponents[periferalIndex].Inport(addr);
end;

procedure TKf7SoftDebuger.Outport(addr, data: integer);
var
  periferalIndex: integer;
begin
  periferalIndex := FindPeriferal(addr);
  if periferalIndex = -1 then Exit;
  if @PeriferalComponents[periferalIndex].Outport = nil then Exit;
  PeriferalComponents[periferalIndex].Outport(addr, data);
end;

procedure TKf7SoftDebuger.Reset;
begin
  DStack.Reset;
  RStack.Reset;
  PC := 0;
  FCommandsCount := 0;
  isPutNewNumber := true;
end;

procedure TKf7SoftDebuger.TurnOff;
begin
  inherited;

end;

procedure TKf7SoftDebuger.TurnOn;
begin
  inherited;
  Reset;
end;

procedure TKf7SoftDebuger.ExecuteCommand;
var
  cmd: integer;
  int1, int2: integer;
  LCell: TLoopCell;
  time64: int64;
begin
  inc(FCommandsCount);
  cmd := Code[PC];

  // стек
  case cmd of
    cmdNOT:
      if DStack.Pop = 0 then
        DStack.Push(-1)
      else
        DStack.Push(0);

    cmdFETCH:
      DStack.Push(Data[DStack.Pop]);

    cmdSHL:
      DStack.Push(DStack.Pop shl 1);

    cmdSHR:
      DStack.Push(DStack.Pop shr 1);

    cmdSHRA:
      DStack.Push(shra(DStack.Pop, 1));

    cmdSWAP:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1);
      DStack.Push(int2);
    end;

    cmdDEPTH:
      DStack.Push(DStack.Top);

    cmdDUP:
      DStack.Push(DStack.ReadTop);

    cmdOVER:
    begin
      int1 := DStack.Pop;
      int2 := DStack.ReadTop;
      DStack.Push(int1);
      DStack.Push(int2);
    end;

    cmdADD:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 + int2);
    end;

    cmdSUB:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int2 - int1);
    end;

    cmdAND:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 and int2);
    end;

    cmdOR:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 or int2);
    end;

    cmdXOR:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 xor int2);
    end;

    cmdEQUAL:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if int2 = int1 then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    cmdULESS:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if cardinal(int2) < cardinal(int1) then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    cmdUGREATER:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if cardinal(int2) > cardinal(int1) then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    cmdMULT:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 * int2);
    end;

    cmdDROP:
      DStack.Pop;

    cmdDEBUG:
      DStack.Pop;

    cmdSTORE:
    begin
      int1 := DStack.Pop; // addr
      int2 := DStack.Pop; // data
      if (int1 >= 0) and (int1 <= MaxData) then
      begin
        Data[int1] := int2;
        OnDataChange(int1, int2);
      end
      else if (int1 = -1) then // ->COM
      begin
        Outport(-1, int2); // Forward to fKf7ComModel
      end
      else
      begin
        Outport(int1, int2);
      end;
    end;

//    cmdDO:
//    begin
//      int1 := DStack.Pop; // min
//      int2 := DStack.Pop; // max
//      LStack.Push(LoopCell(int1, int2, PC + 1));
//    end;
  end;

  // литералы
  case cmd of
    $00 .. LITMask: // other cmd
      isPutNewNumber := true;

    cmdLIT..cmdLIT + LITMask: // lit
    begin
      if isPutNewNumber then
      begin
        isPutNewNumber := false;
        int1 := (cmd and LitMask);
        if (cmd and NegativeBit) <> 0 then
          int1 := int1 or (not LitMask);
      end
      else
      begin
        int1 := (DStack.Pop shl LITSize) or (cmd and LitMask);
      end;

      DStack.Push(int1);
    end;
  end;

  // деление
  if cmd <> cmdNOP then
  begin
    DivSt := 1;
  end
  else if DivSt = 1 then
  begin
    // получение двух верхних чисел на стеке без проверки на границы
    int1 := cardinal(DStack.Top - 1) mod cardinal(DStack.Size);
    DivA := integer(DStack.Item(int1)^);
    int1 := cardinal(DStack.Top - 2) mod cardinal(DStack.Size);
    DivB := integer(DStack.Item(int1)^);
    inc(DivSt);
  end
  else if DivSt = 34 then
  begin
    if DivA <> 0 then
    begin
      RDiv := DivB div DivA;
      RRem := DivB mod DivA;
    end
    else
    begin
      RDiv := -1;
      RRem := -1;
    end;
  end
  else
  begin
    inc(DivSt);
  end;
//
//
//
//
//  case DivSt of
//    0: begin
//      // получение двух верхних чисел на стеке без проверки на границы
//      int1 := cardinal(DStack.Top - 1) mod DStack.Size;
//      DivA := integer(DStack.Item(int1)^);
//      int1 := cardinal(DStack.Top - 2) mod DStack.Size;
//      DivB := integer(DStack.Item(int1)^);
//      DivSt := 1;
//    end;
//    1..33: begin
//      if cmd = cmdNOP then
//        inc(DivSt)
//      else
//        DivSt := 0;
//    end;
//    34: begin
//      if DivA <> 0 then
//      begin
//        RDiv := DivB div DivA;
//        RRem := DivB mod DivA;
//      end
//      else
//      begin
//        RDiv := -1;
//        RRem := -1;
//      end;
//      DivSt := 0;
//    end;
//  end;

  // переходы
  case cmd of
    cmdLOOP:
    begin
      LCell := LStack.Pop;
      inc(LCell.cur);
      if LCell.cur = LCell.max then
      begin
        inc(PC);
      end
      else
      begin
        LStack.Push(LCell);
        PC := LCell.jmp;
      end;
    end;

    cmdJMP:
      PC := DStack.Pop;

    cmdCALL:
    begin
      RStack.Push(PC + 1);
      PC := DStack.Pop;
    end;

    cmdRJMP:
      PC := PC + 1 + DStack.Pop;

    cmdRIF:
    begin
      int1 := DStack.Pop;
      if DStack.Pop = 0 then
        PC := PC + 1 + int1
      else
        inc(PC);
    end;

    cmdUNTIL:
    begin
      int1 := DStack.Pop;
      if DStack.Pop = 0 then
        PC := PC + 1 - int1
      else
        inc(PC);
    end;

    cmdRET:
      PC := RStack.Pop;

    else
     inc(PC);
  end;

  if PC < 0 then
  begin
    PC := 0;
    raise Exception.Create('PC < 0. Установлено в 0.');
  end;

  if PC >= MaxCode then
  begin
    PC := MaxCode-1;
    raise Exception.Create('PC > MaxCode. Установлено в MaxCode.');
  end;
end;

procedure TKf7SoftDebuger.RunForCommands(commandCount: integer);
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

procedure TKf7SoftDebuger.RunForStepOverCommands(
  commandCount: integer);
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

procedure TKf7SoftDebuger.RunForTime(milliSeconds: integer);
var
  time: real;
begin
  time := Now;
  while (MilliSecondOf(Now - time) < milliSeconds) do
    StepOver;
end;

procedure TKf7SoftDebuger.RunToCursor(programmCounter: integer);
var
  time: real;
begin
  time := Now;
  while (PC <> programmCounter) and (SecondOf(Now - time) < MaxWaitingTime) do
    StepOver;
end;

procedure TKf7SoftDebuger.RunUntilReturn;
var
  time: real;
begin
  time := Now;
  while (Code[PC] <> cmdRET) and (SecondOf(Now - time) < MaxWaitingTime) do
    StepOver;
end;

procedure TKf7SoftDebuger.StepOver;
var
  RTop: integer;
  time: real;
  StartCommandsCount: integer;
begin
  StartCommandsCount := CommandsCount;
  RTop := RStack.Top;
  time := Now;
  repeat
    ExecuteCommand;
  until (RStack.Top <= RTop) or (SecondOf(Now - time) > MaxWaitingTime);
  CommandsAtLastStepOver := CommandsCount - StartCommandsCount;
end;

procedure TKf7SoftDebuger.TraceInto;
begin
  ExecuteCommand;
end;

procedure TKf7SoftDebuger.TransmitToCom(value: byte);
begin
  Received := value;
  inc(RXCounter);
end;

end.
