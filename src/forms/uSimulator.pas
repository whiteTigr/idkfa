unit uSimulator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls, ComCtrls, ToolWin, Menus,
  Gauges, uRecordList, ActnList, ImgList, Buttons,
  uLed, uComModel, uGlobal, TabNotBk, uForthDevice,
  uForthSoftDebuger, uForthHardDebuger, uBrainfuckDevice, uProteusDevice,
  uProteusSoftDebuger, uQuarkDevice, uSimVga;

type
  TfSimulator = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    mmConsole: TRichEdit;
    WorkSpace: TPanel;
    PanelLeft: TPanel;
    PanelSystemInfo: TPanel;
    PanelMemory: TPanel;
    PanelCode: TPanel;
    PanelLeftside: TPanel;
    rgCodeBase: TRadioGroup;
    sgCode: TStringGrid;
    PanelData: TPanel;
    Splitter3: TSplitter;
    PanelLeftside2: TPanel;
    rgDataBase: TRadioGroup;
    sgData: TStringGrid;
    ePC: TLabeledEdit;
    bReset: TToolButton;
    ActionList1: TActionList;
    bTraceInto: TToolButton;
    bStepOver: TToolButton;
    ToolButton4: TToolButton;
    ActStep: TAction;
    ActStepOver: TAction;
    Label1: TLabel;
    gaugeCode: TGauge;
    gaugeData: TGauge;
    Label2: TLabel;
    ToolButton7: TToolButton;
    eTime: TEdit;
    bTraceIntoCommands: TToolButton;
    ImageList1: TImageList;
    ActRunToCursor: TAction;
    ActRunUntilReturn: TAction;
    bRunToCursor: TToolButton;
    bRunUntilReturn: TToolButton;
    ToolButton10: TToolButton;
    cbDebuger: TComboBox;
    ActReset: TAction;
    bStepOverCommands: TToolButton;
    ActStepOverCommands: TAction;
    ActTraceIntoCommands: TAction;
    ActRunForTime: TAction;
    PanelDevice: TPanel;
    Splitter2: TSplitter;
    bRunForTime: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure rgCodeBaseClick(Sender: TObject);
    procedure rgDataBaseClick(Sender: TObject);
    procedure sgCodeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sgCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ActResetExecute(Sender: TObject);
    procedure ActStepExecute(Sender: TObject);
    procedure ActStepOverExecute(Sender: TObject);
    procedure ActRunToCursorExecute(Sender: TObject);
    procedure ActRunUntilReturnExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbDebugerChange(Sender: TObject);
    procedure ActRunForTimeExecute(Sender: TObject);
    procedure ActStepOverCommandsExecute(Sender: TObject);
    procedure ActTraceIntoCommandsExecute(Sender: TObject);
  private
    { Private declarations }
  public
    procedure CodeDraw(Sender: TObject; ACol, ARow: Longint;
      Rect: TRect; State: TGridDrawState);
  end;

var
  fSimulator: TfSimulator;

  FormDevice: TForm;
  ShowDevice: procedure;

procedure Prepare;
procedure ChangeDevice(newDevice: TDeviceType);
procedure ChangeDebuger(index: integer);

procedure ClearDebugers;
procedure AddDebuger(name: string; InitProcedure: pointer);
procedure ForthSoftDebugInit;
procedure ForthHardDebugInit;

implementation

uses DateUtils, Types;

procedure UpdateShow; forward;

var
  minPanelDeviceSize: integer;

{$R *.dfm}

procedure ClearDebugers;
begin
  fSimulator.cbDebuger.Clear;
end;

procedure AddDebuger(name: string; InitProcedure: pointer);
begin
  fSimulator.cbDebuger.AddItem(name, TObject(InitProcedure));
end;

procedure DoNothing;
begin
end;

procedure SetProgress(gauge: TGauge; progress: integer);
begin
  if gauge.ForeColor <> clRed then
    gauge.Color := gauge.ForeColor;

  if progress > gauge.MaxValue then
    gauge.ForeColor := clRed
  else
    gauge.ForeColor := gauge.Color;

  gauge.Progress := progress;
  gauge.Hint := IntToStr(gauge.Progress) + '/' + IntToStr(gauge.MaxValue);
end;

procedure RedrawCode(posX, posY: integer); overload;
begin    
  fSimulator.CodeDraw(nil, posX, posY, fSimulator.sgCode.CellRect(posX, posY), []);
end;

procedure RedrawCode(position: integer); overload;
var
  posX, posY: integer;
begin
  posX := 1 + position mod 16;
  posY := 1 + position div 16;
  RedrawCode(posX, posY);
end;

procedure OnCodeChange(position: integer; newValue: integer);
var
  posX: integer;
  posY: integer;
begin
  posX := 1 + position mod 16;
  posY := 1 + position div 16;
  case fSimulator.rgCodeBase.ItemIndex of
    0: fSimulator.sgCode.Cells[posX, posY] := IntToHex(newValue, 5);
    1: fSimulator.sgCode.Cells[posX, posY] := compiler.DizAsm(newValue);
  end;
  fSimulator.sgCode.Objects[posX, posY] := TObject(newValue);
  RedrawCode(posX, posY);
end;

procedure OnDataChange(position: integer; newValue: integer);
var
  posX: integer;
  posY: integer;
begin
  posX := 1 + position mod 16;
  posY := 1 + position div 16;
  case fSimulator.rgDataBase.ItemIndex of
    0: fSimulator.sgData.Cells[posX, posY] := IntToStr(newValue);
    1: fSimulator.sgData.Cells[posX, posY] := IntToHex(newValue, 0);
    2: fSimulator.sgData.Cells[posX, posY] := chr(newValue and $FF);
  end;
end;

procedure TfSimulator.CodeDraw(Sender: TObject; ACol, ARow: Longint;
    Rect: TRect; State: TGridDrawState);
var
  isCurrentCommand: boolean;
  isBoundCell: boolean;
begin
  isCurrentCommand := debuger.PC = ((ACol - 1) + (ARow - 1) * 16);
  isBoundCell := (ACol = 0) or (ARow = 0);
  if isCurrentCommand then
  begin
    sgCode.Canvas.Brush.Color := $D0D0FF;
    sgCode.Canvas.Font.Color := clBlack;
  end
  else if isBoundCell then
  begin
    sgCode.Canvas.Brush.Color := clBtnFace;
    sgCode.Canvas.Font.Color := clBlack;
  end
  else
  begin
    sgCode.Canvas.Brush.Color := sgCode.Color;
    sgCode.Canvas.Font.Color := compiler.GetCmdColor(integer(sgCode.Objects[ACol, ARow]))
  end;

  fSimulator.sgCode.Canvas.TextRect(Rect, Rect.Left+2, Rect.Top+2, fSimulator.sgCode.Cells[ACol, ARow]);
end;

procedure GridLabels(grid: TStringGrid);
var
  i: integer;
begin
  for i := 0 to grid.ColCount - 1 do
  begin
    grid.Cells[1 + i, 0] := IntToHex(i, 1);
    grid.Objects[1 + i, 0] := nil;
  end;

  for i := 0 to grid.RowCount - 1 do
  begin
    grid.Cells[0, 1 + i] := IntToHex(i * 16, 5);
    grid.Objects[0, 1 + i] := nil;
  end;
end;

procedure ShowCode;
var
  i: integer;
begin
  with fSimulator.sgCode do
  begin
    RowCount := MaxCode div 16 + 2;
    ColCount := 17;

    GridLabels(fSimulator.sgCode);
    for i := 0 to MaxCode-1 do
    begin
      case fSimulator.rgCodeBase.ItemIndex of
        0: Cells[1 + i mod 16, 1 + i div 16] := IntToHex(debuger.Code[i], 0);
        1: Cells[1 + i mod 16, 1 + i div 16] := IntToStr(debuger.Code[i]);
        2: Cells[1 + i mod 16, 1 + i div 16] := compiler.DizAsm(debuger.Code[i]);
      end;
      Objects[1 + i mod 16, 1 + i div 16] := TObject(debuger.Code[i]);
    end;
  end;

  with fSimulator.gaugeCode do
  begin
    MaxValue := compiler.MaxCode;
    SetProgress(fSimulator.gaugeCode, compiler.CodeCount);
  end;
end;

procedure ShowData;
var
  i: integer;
begin
  with fSimulator.sgData do
  begin
    RowCount := MaxData div 16 + 2;
    ColCount := 17;

    GridLabels(fSimulator.sgData);

    for i := 0 to MaxData-1 do
    begin
      case fSimulator.rgDataBase.ItemIndex of
        0: Cells[1 + i mod 16, 1 + i div 16] := IntToStr(debuger.Data[i]);
        1: Cells[1 + i mod 16, 1 + i div 16] := IntToHex(debuger.Data[i], 0);
        2: Cells[1 + i mod 16, 1 + i div 16] := chr(debuger.Data[i] and $FF);
      end;
    end;
  end;

  with fSimulator.gaugeData do
  begin
    MaxValue := compiler.MaxData;
    SetProgress(fSimulator.gaugeData, compiler.DataCount);
  end;
end;

procedure ShowSystemInfo;
begin
  fSimulator.ePC.Text := IntToHex(debuger.PC, 5);
end;

procedure ShowAll;
begin
  if (debuger <> nil) and (compiler <> nil) then
  begin
    ShowCode;
    ShowData;
    ShowSystemInfo;
    UpdateShow;
  end;
end;

procedure TfSimulator.FormShow(Sender: TObject);
begin
  if fSimulator.Visible then
    ShowAll;
end;

procedure ResizeGrid(grid: TStringGrid);
const
  rightWidth = 38;
var
  i: integer;
  dw: real;
  count: real;
  ColCount: integer;
begin
  ColCount := grid.ColCount;
  dw := (grid.Width - rightWidth) / ColCount -
         trunc((grid.Width - rightWidth) / ColCount);
  count := 0;
  for i := 0 to ColCount-1 do
  begin
    grid.ColWidths[i] := trunc((grid.Width - rightWidth) / ColCount);
    count := count + dw;
    if trunc(count) > 0 then
    begin
      grid.ColWidths[i] := grid.ColWidths[i] + trunc(count);
      count := count - trunc(count);
    end;
  end;
end;

procedure TfSimulator.FormResize(Sender: TObject);
begin
  ResizeGrid(sgCode);
  ResizeGrid(sgData);
end;

procedure TfSimulator.rgCodeBaseClick(Sender: TObject);
begin
  ShowCode;
end;

procedure TfSimulator.rgDataBaseClick(Sender: TObject);
begin
  ShowData;
end;

procedure SelectCellToScreen(grid: TStringGrid);
begin
  if grid.Selection.Top - grid.TopRow < 0 then
    grid.TopRow := grid.Selection.Top
  else if grid.Selection.Top - grid.TopRow > grid.VisibleRowCount - 2 then
    grid.TopRow := grid.Selection.Top - grid.VisibleColCount + 3;
  if grid.Selection.Left - grid.LeftCol < 0 then
    grid.LeftCol := grid.Selection.Left
  else if grid.Selection.Left - grid.LeftCol > grid.VisibleColCount - 1 then
    grid.LeftCol := grid.Selection.Left - grid.VisibleRowCount + 2;
end;

procedure SelectCell(grid: TStringGrid; x, y: integer);
var
  Select: TGridRect;
begin
  Select.Left := x;
  Select.Top  := y;
  Select.Right := Select.Left;
  Select.Bottom := Select.Top;
  grid.Selection := Select;
  SelectCellToScreen(grid);
end;

const
  TinyRetStackSize = 16;
var
  TinyRetStack: array[0..TinyRetStackSize-1] of integer;
  TinyRetStackTop: integer;

procedure TinyRetPush(pos: integer);
begin
  if TinyRetStackTop = TinyRetStackSize-1 then
  begin
    MessageBox(0, 'Переполнение стека TinyRetStack', 'Ошибка', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  TinyRetStack[TinyRetStackTop] := Pos;
  TinyRetStackTop := TinyRetStackTop + 1;
end;

function TinyRetPop: integer;
begin
  if TinyRetStackTop = 0 then
  begin
    MessageBox(0, 'Исчерпание стека TinyRetStack', 'Ошибка', MB_OK or MB_ICONWARNING);
    Result := -1;
    Exit;
  end;
  TinyRetStackTop := TinyRetStackTop - 1;
  Result := TinyRetStack[TinyRetStackTop];
end;

var
  PressedKey: Word;
procedure TfSimulator.sgCodeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if PressedKey = 0 then Exit;
  PressedKey := 0;
end;

procedure TfSimulator.sgCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  PressedKey := Key;

  case Key of
    VK_RIGHT:
    begin
      if sgCode.Selection.Left = sgCode.ColCount - 1 then
        if sgCode.Selection.Top < sgCode.RowCount - 1 then
        begin
          SelectCell(sgCode, 1, sgCode.Selection.Top + 1);
          Key := 0;
        end;
    end;
    VK_LEFT:
    begin
      if sgCode.Selection.Left = 1 then
        if sgCode.Selection.Top > 1 then
        begin
          SelectCell(sgCode, sgCode.ColCount - 1, sgCode.Selection.Top - 1);
          Key := 0;
        end;
    end;
  end;
end;

procedure TfSimulator.ActResetExecute(Sender: TObject);
begin
  debuger.Reset;
  ShowAll;
  UpdateShow;
end;

procedure Prepare;
var
  i: integer;
begin
  if debuger = nil then
    Exit;

  debuger.OnCodeChange := OnCodeChange;
  debuger.OnDataChange := OnDataChange;

  debuger.ClearCode;
  debuger.ClearData;

  if compiler <> nil then
  begin
    for i := 0 to MaxCode-1 do
      debuger.Code[i] := compiler.Code(i);
    for i := 0 to MaxData-1 do
      debuger.Data[i] := compiler.Data(i);
  end;

  debuger.Reset;
end;

var
  LastPC: integer;
procedure UpdateShow;
begin
  ShowSystemInfo;
  SelectCell(fSimulator.sgCode, debuger.PC mod 16 + 1, debuger.PC div 16 + 1);
  fSimulator.sgCode.SetFocus;
  RedrawCode(LastPC);
  RedrawCode(debuger.PC);
  LastPC := debuger.PC;
  ShowDevice;
end;

procedure TfSimulator.ActStepExecute(Sender: TObject);
begin
  debuger.TraceInto;
  UpdateShow;
end;

procedure TfSimulator.ActStepOverExecute(Sender: TObject);
begin
  debuger.StepOver;
  UpdateShow;
end;

procedure ForthSoftDebugInit;
var
  ForthSoftDebug: TForthSoftDebug absolute debuger;
begin
  ForthSoftDebug := TForthSoftDebug.Create;
  ForthSoftDebug.AddPeriferal(3000, 3099, @uLed.Inport, @uLed.Outport);
  ForthSoftDebug.AddPeriferal(1100, 1104, @uComModel.Inport, @uComModel.Outport);

  uSimVga.BaseAddr := 300;
  ForthSoftDebug.AddPeriferal(300, 399, @uSimVga.Inport, @uSimVga.Outport);
end;

procedure ForthHardDebugInit;
var
  ForthHardDebuger: TForthHardDebuger absolute debuger;
begin
  ForthHardDebuger := TForthHardDebuger.Create;
end;

procedure EmptyDebugerInit;
var
  EmptyDebuger: TDebuger absolute debuger;
begin
  EmptyDebuger := TDebuger.Create;
end;

procedure ProteusSoftDebugInit;
var
  ProteusSoftDebuger: TProteusSoftDebuger absolute debuger;
begin
  ProteusSoftDebuger := TProteusSoftDebuger.Create;
  uSimVga.BaseAddr := 120000;
  ProteusSoftDebuger.AddPeriferal(120000, 120999, @uSimVga.Inport, @uSimVga.Outport);
end;

procedure Init;
begin
  ShowDevice := DoNothing;
end;

procedure TfSimulator.ActRunToCursorExecute(Sender: TObject);
var
  posX, posY: integer;
begin
  posX := fSimulator.sgCode.Selection.Left - 1;
  posY := fSimulator.sgCode.Selection.Top - 1;
  debuger.RunToCursor(posY * 16 + posX);
  UpdateShow;
end;

procedure TfSimulator.ActRunUntilReturnExecute(Sender: TObject);
begin
  debuger.RunUntilReturn;
  UpdateShow;
end;

procedure TfSimulator.FormCreate(Sender: TObject);
begin
  fSimulator.Visible := false;
  fSimulator.sgCode.OnDrawCell := fSimulator.CodeDraw;

  minPanelDeviceSize := fSimulator.PanelSystemInfo.Width;
end;

procedure SetFormCaption;
begin
  fSimulator.Caption := 'Debuger: ' + debuger.ClassName;
end;

var
  currentDebuger: integer = -1;

procedure CloseCurrentDebuger;
begin
  if debuger <> nil then
  begin
    debuger.TurnOff;
    debuger.Destroy;
    debuger := nil;
  end;
end;

procedure ChangeDebuger(index: integer);
var
  proc: TProc;
begin
  fSimulator.cbDebuger.ItemIndex := index;
  currentDebuger := index;
  CloseCurrentDebuger;
  proc := pointer(fSimulator.cbDebuger.Items.Objects[index]);
  TProc(proc);
  debuger.TurnOn;
  Prepare;
  SetFormCaption;
end;

procedure TfSimulator.cbDebugerChange(Sender: TObject);
var
  newDebuger: integer;
  indexValid: boolean;
  changingDebuger: boolean;
  questionResult: integer;
begin
  newDebuger := cbDebuger.ItemIndex;
  indexValid := (newDebuger >= 0) and (newDebuger < cbDebuger.Items.Count);
  changingDebuger := indexValid and (newDebuger <> currentDebuger);
  if not changingDebuger then Exit;

  questionResult := MessageBox(0,
    'Вы уверены что хотите изменить отладчик?',
    PChar(Application.Title),
    MB_YESNO or MB_ICONQUESTION);
  if questionResult = mrNo then
    Exit;

  ChangeDebuger(newDebuger);
  ShowAll;

  sgCode.SetFocus;
end;

procedure CloseCurrentDevice;
begin
  if FormDevice <> nil then
    if FormDevice.CloseQuery then
    begin
      FormDevice.Close;
      FormDevice := nil;
    end;

  if debuger <> nil then
  begin
    debuger.TurnOff;
    debuger.Destroy;
    debuger := nil;
  end;
end;

procedure OpenDeviceForm(InstanceClass: TComponentClass; var Reference);
var
  windowState: integer;
begin
  Application.CreateForm(InstanceClass, Reference);
  FormDevice := TForm(Reference);

  FormDevice.Visible := false;
  FormDevice.Parent := fSimulator.PanelDevice;

  windowState := GetWindowLong(FormDevice.Handle, GWL_Style);
  windowState := windowState and not WS_CAPTION and not WS_SIZEBOX;
  SetWindowLong(FormDevice.Handle, GWL_Style, windowState);

  FormDevice.Left := 0;
  FormDevice.Top := 0;

  if FormDevice.Width < minPanelDeviceSize then
    fSimulator.PanelLeft.Width := minPanelDeviceSize
  else
    fSimulator.PanelLeft.Width := FormDevice.Width;

  ShowDevice := FormDevice.MethodAddress('ShowDevice');
  if not Assigned(ShowDevice) then
    ShowDevice := DoNothing;

  FormDevice.Visible := true;
end;

procedure OpenForthDevice;
begin
  OpenDeviceForm(TfForthDevice, fForthDevice);

  ClearDebugers;
  AddDebuger('Soft', @ForthSoftDebugInit);
  AddDebuger('Hard', @ForthHardDebugInit);

  ChangeDebuger(0);
end;

procedure OpenBrainfuckDevice;
begin
  OpenDeviceForm(TfBrainfuckDevice, fBrainfuckDevice);

  ClearDebugers;
  AddDebuger('<no debuger>', @EmptyDebugerInit);

  ChangeDebuger(0);
end;

procedure OpenProteusDevice;
begin
  OpenDeviceForm(TfProteusDevice, fProteusDevice);

  ClearDebugers;
  AddDebuger('Soft', @ProteusSoftDebugInit);

  ChangeDebuger(0);
end;

procedure OpenQuarkDevice;
begin
  OpenDeviceForm(TfQuarkDevice, fQuarkDevice);

  ClearDebugers;
  AddDebuger('<no debuger>', @EmptyDebugerInit);

  ChangeDebuger(0);
end;

procedure ChangeDevice(newDevice: TDeviceType);
begin
  if newDevice = currentDevice then Exit;

  CloseCurrentDevice;

  case newDevice of
    devForth: OpenForthDevice;
    devBrainfuck: OpenBrainfuckDevice;
    devProteus: OpenProteusDevice;
    devQuark: OpenQuarkDevice;
  end;
end;

procedure TfSimulator.ActRunForTimeExecute(Sender: TObject);
begin
  debuger.RunForTime(StrToInt(eTime.Text));
  UpdateShow;
end;

procedure TfSimulator.ActStepOverCommandsExecute(Sender: TObject);
begin
  debuger.RunForStepOverCommands(StrToInt(eTime.Text));
  UpdateShow;
end;

procedure TfSimulator.ActTraceIntoCommandsExecute(Sender: TObject);
begin
  debuger.RunForCommands(StrToInt(eTime.Text));
  UpdateShow;
end;

initialization
  Init;
end.
