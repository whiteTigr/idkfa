unit uForthDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, ComCtrls, uForthDeviceCore, uRecordList, uGlobal, uCommonFunctions,
  Buttons, uComModel, uLed, uSimVga;

type
  TfForthDevice = class(TForm)
    Splitter1: TSplitter;
    PanelInout: TPanel;
    tabStacks: TTabControl;
    sgStack: TStringGrid;
    rgStackBase: TRadioGroup;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure tabStacksChange(Sender: TObject);
    procedure rgStackBaseClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
  published
    procedure ShowDevice;
  end;

var
  fForthDevice: TfForthDevice;

implementation

{$R *.dfm}

var
  IntToStrRG: function(Value: integer): string;
  ShowStack: procedure;

function ForthDevice: PForthDevice;
begin
  Result := @TForthDevice(debuger);
end;

procedure ShowStack_Data;
begin
  ShowIntStack(fForthDevice.sgStack, @ForthDevice.DStack, IntToStrRG);
end;

procedure ShowStack_Ret;
begin
  ShowIntStack(fForthDevice.sgStack, @ForthDevice.RStack, IntToStrRG);
end;

procedure ShowStack_Loop;
var
  i: integer;
  pos: integer;
  item: ^TLoopCell;
begin
  with fForthDevice.sgStack do
  begin
    ColCount := 4;
    RowCount := DStackSize + 1;

    Cells[0, 0] := 'Addr';
    Cells[1, 0] := 'Cur';
    Cells[2, 0] := 'Last';
    Cells[3, 0] := 'Jmp';

    ColWidths[0] := 49;
    ColWidths[1] := 49;
    ColWidths[2] := 49;
    ColWidths[3] := 49;

    Pos := PositiveMod(ForthDevice.LStack.Top - 1, ForthDevice.LStack.Size);
    for i := 0 to ForthDevice.LStack.Size-1 do
    begin
      Cells[0, 1 + i] := IntToHex(Pos, 2);
      item := ForthDevice.LStack.Item(Pos);
      Cells[1, 1 + i] := IntToStrRG(item.Cur);
      Cells[2, 1 + i] := IntToStrRG(item.Last);
      Cells[3, 1 + i] := IntToStrRG(item.Jmp);
      Pos := PositiveMod(Pos - 1, ForthDevice.LStack.Size);
    end;
  end;
end;

procedure TfForthDevice.FormCreate(Sender: TObject);
begin
  ShowStack := ShowStack_Data;
  IntToStrRG := IntToStr;
end;

procedure TfForthDevice.tabStacksChange(Sender: TObject);
begin
  case tabStacks.TabIndex of
    0: ShowStack := ShowStack_Data;
    1: ShowStack := ShowStack_Ret;
    2: ShowStack := ShowStack_Loop;
  end;
  ShowStack;
end;

procedure TfForthDevice.rgStackBaseClick(Sender: TObject);
begin
  case rgStackBase.ItemIndex of
    0: IntToStrRG := IntToStr;
    1: IntToStrRG := IntToStrHex;
    2: IntToStrRG := IntToStrChar;
  end;
  ShowStack;
end;

procedure TfForthDevice.ShowDevice;
begin
  ShowStack;
end;

procedure TfForthDevice.SpeedButton1Click(Sender: TObject);
begin
  if fComModel.Visible then
    fComModel.Hide
  else
    fComModel.Show;
end;

procedure TfForthDevice.SpeedButton2Click(Sender: TObject);
begin
  if fLed.Visible then
    fLed.Hide
  else
    fLed.Show;
end;

procedure TfForthDevice.SpeedButton3Click(Sender: TObject);
begin
  if fSimVga.Visible then
    fSimVga.Hide
  else
    fSimVga.Show;
end;

end.
