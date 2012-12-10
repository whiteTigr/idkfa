unit uProteusDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uGlobal, StdCtrls, ExtCtrls, Grids, ComCtrls, uProteusDeviceCore, uCommonFunctions,
  uProteusComModel, uLed, uSimVga, Buttons;

type
  TfProteusDevice = class(TForm)
    PanelInout: TPanel;
    Splitter1: TSplitter;
    tabStacks: TTabControl;
    sgStack: TStringGrid;
    rgStackBase: TRadioGroup;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton1: TSpeedButton;
    eCommandsCount: TLabeledEdit;
    procedure tabStacksChange(Sender: TObject);
    procedure rgStackBaseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  published
    procedure ShowDevice;
  end;

var
  fProteusDevice: TfProteusDevice;

implementation

var
  IntToStrBased: function(Value: integer): string;
  ShowStack: procedure;
  ProteusDevice: TProteusDevice absolute debuger;

{$R *.dfm}

{ TfProteusDevice }

procedure ShowStack_Data;
begin
  ShowIntStack(fProteusDevice.sgStack, @ProteusDevice.DStack, IntToStrBased);
end;

procedure ShowStack_Ret;
begin
  ShowIntStack(fProteusDevice.sgStack, @ProteusDevice.RStack, IntToStrBased);
end;

procedure TfProteusDevice.tabStacksChange(Sender: TObject);
begin
  case tabStacks.TabIndex of
    0: ShowStack := ShowStack_Data;
    1: ShowStack := ShowStack_Ret;
  end;
  ShowStack;
end;

procedure TfProteusDevice.rgStackBaseClick(Sender: TObject);
begin
  case rgStackBase.ItemIndex of
    0: IntToStrBased := IntToStr;
    1: IntToStrBased := IntToStrHex;
    2: IntToStrBased := IntToStrChar;
  end;
  ShowStack;
end;

procedure ShowCommandAtLastStepOver;
begin
  fProteusDevice.eCommandsCount.Text := IntToStr(CommandsAtLastStepOver);
end;

procedure TfProteusDevice.ShowDevice;
begin
  ShowStack;
  ShowCommandAtLastStepOver;
end;

procedure TfProteusDevice.SpeedButton1Click(Sender: TObject);
begin
  if fProteusComModel.Visible then
    fProteusComModel.Hide
  else
    fProteusComModel.Show;
end;

procedure TfProteusDevice.SpeedButton2Click(Sender: TObject);
begin
  if fLed.Visible then
    fLed.Hide
  else
    fLed.Show;
end;

procedure TfProteusDevice.SpeedButton3Click(Sender: TObject);
begin
  if fSimVga.Visible then
    fSimVga.Hide
  else
    fSimVga.Show;
end;

procedure TfProteusDevice.FormCreate(Sender: TObject);
begin
  ShowStack := ShowStack_Data;
  IntToStrBased := IntToStr;
end;

end.
