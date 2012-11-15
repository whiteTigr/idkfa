unit uProteusSoftDebuger;

interface

uses
  Windows, SysUtils, uGlobal, uProteusDeviceCore, DateUtils, uCommonFunctions;

type
  PProtuesSoftDebuger = ^TProteusSoftDebuger;
  TProteusSoftDebuger = class(TProteusDevice)
  private
    MaxWaitingTime: integer;

    isPutNewNumber: boolean;
    PeriferalComponents: array[0..MaxPeriferal-1] of TPeriferalComponent;
    PeriferalCount: integer;

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

    procedure SetDataToCom(value: byte);
    function GetDataFromCom: byte;
  end;

implementation

{ TProteusSoftDebuger }

constructor TProteusSoftDebuger.Create;
begin
  inherited;
  PeriferalCount := 0;
  MaxWaitingTime := 10;
end;

destructor TProteusSoftDebuger.Destroy;
begin
  inherited;
end;

procedure TProteusSoftDebuger.AddPeriferal(startAddr, endAddr: integer; inport,
  outport: pointer);
begin
  PeriferalComponents[PeriferalCount].startAddr := startAddr;
  PeriferalComponents[PeriferalCount].endAddr := endAddr;
  PeriferalComponents[PeriferalCount].Inport := inport;
  PeriferalComponents[PeriferalCount].Outport := outport;
  inc(PeriferalCount);
end;

function TProteusSoftDebuger.FindPeriferal(addr: integer): integer;
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

function TProteusSoftDebuger.GetDataFromCom: byte;
begin

end;

function TProteusSoftDebuger.Inport(addr: integer): integer;
var
  periferalIndex: integer;
begin
  Result := -1;
  periferalIndex := FindPeriferal(addr);
  if periferalIndex = -1 then Exit;
  if @PeriferalComponents[periferalIndex].Inport = nil then Exit;
  Result := PeriferalComponents[periferalIndex].Inport(addr);
end;

procedure TProteusSoftDebuger.Outport(addr, data: integer);
var
  periferalIndex: integer;
begin
  periferalIndex := FindPeriferal(addr);
  if periferalIndex = -1 then Exit;
  if @PeriferalComponents[periferalIndex].Outport = nil then Exit;
  PeriferalComponents[periferalIndex].Outport(addr, data);
end;

procedure TProteusSoftDebuger.Reset;
begin
  DStack.Reset;
  RStack.Reset;
  PC := 0;
  isPutNewNumber := true;
end;

procedure TProteusSoftDebuger.TurnOff;
begin
  inherited;

end;

procedure TProteusSoftDebuger.TurnOn;
begin
  inherited;
  Reset;
end;

procedure TProteusSoftDebuger.ExecuteCommand;
var
  cmd: integer;
  int1, int2: integer;
  LCell: TLoopCell;
begin
  cmd := Code[PC];

  // ����
  case cmd of
    cmdNOT:
      DStack.Push(not DStack.Pop);

    cmdFETCH:
      DStack.Push(Data[DStack.Pop]);

    cmdSHL:
      DStack.Push(DStack.Pop shl 1);

    cmdSHR:
      DStack.Push(DStack.Pop shr 1);

    cmdSHRA:
      DStack.Push(shra(DStack.Pop, 1));

    cmdINPORT:
    begin
      int1 := DStack.Pop;
      DStack.Push(Inport(int1));
    end;

    cmdSWAP:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1);
      DStack.Push(int2);
    end;

    cmdDUP:
      DStack.Push(DStack.ReadTop);

    cmdOVER:
    begin
      int1 := DStack.Pop;
      int2 := DStack.ReadTop;
      DStack.Push(int1);
      DStack.Push(int2);
    end;

    cmdFROMR:
      DStack.Push(RStack.Pop);

    cmdSYSREG:
    begin
      int1 := DStack.Pop;
      case int1 of
        sysDEPTH: DStack.Push(DStack.Top);
        sysRDEPTH: DStack.Push(RStack.Top);
        sysI: DStack.Push(LStack.ReadTop.cur);
        sysDIV: begin
          int1 := DStack.Pop;
          int2 := DStack.ReadTop;
          DStack.Push(int1);
          DStack.Push(int2 div int1);
        end;
        sysMOD: begin
          int1 := DStack.Pop;
          int2 := DStack.ReadTop;
          DStack.Push(int1);
          DStack.Push(int2 mod int1);
        end;
        sysTXSTATE: DStack.Push(int1);
        sysRECEIVED: DStack.Push(int1);
        sysRXCOUNTER: DStack.Push(int1);
        sysSYSTIMER_LOW: DStack.Push(int1);
        sysSYSTIMER_HI: DStack.Push(int1);
        sysUSEC: DStack.Push(int1);
        sysMSEC: DStack.Push(int1);
        sysSEC: DStack.Push(int1);
        sysMIN: DStack.Push(int1);
        sysHOUR: DStack.Push(int1);
      end;
    end;

    cmdPLUS:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      DStack.Push(int1 + int2);
    end;

    cmdMINUS:
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

    cmdLESSER:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if int2 < int1 then
        DStack.Push(-1)
      else
        DStack.Push(0);
    end;

    cmdGREATER:
    begin
      int1 := DStack.Pop;
      int2 := DStack.Pop;
      if int2 > int1 then
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

    cmdTOR:
      RStack.Push(DStack.Pop);

    cmdSTORE:
    begin
      int1 := DStack.Pop; // addr
      int2 := DStack.Pop; // data
      if (int1 >= 0) and (int1 <= MaxData) then
      begin
        Data[int1] := int2;
        OnDataChange(int1, int2);
      end
      else
      begin
        Outport(int1, int2);
      end;
    end;

    cmdDO:
    begin
      int1 := DStack.Pop; // min
      int2 := DStack.Pop; // max
      LStack.Push(LoopCell(int1, int2, PC + 1));
    end;
  end;

  // ��������
  case cmd of
    $00..$1F: // other cmd
      isPutNewNumber := true;

    $20..$3F: // lit
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
        int1 := (DStack.Pop shl 5) or (cmd and LitMask);
      end;

      DStack.Push(int1);
    end;
  end;

  // ��������
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
      PC := PC + DStack.Pop;

    cmdRIF:
    begin
      int1 := DStack.Pop;
      if DStack.Pop = 0 then
        PC := PC + int1
      else
        inc(PC);
    end;

    cmdUNTIL:
    begin
      int1 := DStack.Pop;
      if DStack.Pop = 0 then
        PC := PC - int1
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
    raise Exception.Create('PC < 0. ����������� � 0.');
  end;

  if PC >= MaxCode then
  begin
    PC := MaxCode-1;
    raise Exception.Create('PC > MaxCode. ����������� � MaxCode.');
  end;
end;

procedure TProteusSoftDebuger.RunForCommands(commandCount: integer);
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

procedure TProteusSoftDebuger.RunForStepOverCommands(
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

procedure TProteusSoftDebuger.RunForTime(milliSeconds: integer);
var
  time: real;
begin
  time := Now;
  while (MilliSecondOf(Now - time) < milliSeconds) do
    StepOver;
end;

procedure TProteusSoftDebuger.RunToCursor(programmCounter: integer);
var
  time: real;
begin
  time := Now;
  while (PC <> programmCounter) and (SecondOf(Now - time) < MaxWaitingTime) do
    StepOver;
end;

procedure TProteusSoftDebuger.RunUntilReturn;
var
  time: real;
begin
  time := Now;
  while (Code[PC] <> cmdRET) and (SecondOf(Now - time) < MaxWaitingTime) do
    StepOver;
end;

procedure TProteusSoftDebuger.SetDataToCom(value: byte);
begin

end;

procedure TProteusSoftDebuger.StepOver;
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

procedure TProteusSoftDebuger.TraceInto;
begin
  ExecuteCommand;
end;

end.
