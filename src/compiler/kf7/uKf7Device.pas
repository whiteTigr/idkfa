unit uKf7Device;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uGlobal, StdCtrls, ExtCtrls, Grids, ComCtrls, uKf7DeviceCore, uCommonFunctions,
  uKf7ComModel, uLed, uSimVga, Buttons;

type
  TfKf7Device = class(TForm)
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
  fKf7Device: TfKf7Device;

implementation

var
  IntToStrBased: function(Value: integer): string;
  ShowStack: procedure;
  Kf7Device: TKf7Device absolute debuger;

{$R *.dfm}

{ TfKf7Device }

procedure ShowStack_Data;
begin
  ShowIntStack(fKf7Device.sgStack, @Kf7Device.DStack, IntToStrBased);
end;

procedure ShowStack_Ret;
begin
  ShowIntStack(fKf7Device.sgStack, @Kf7Device.RStack, IntToStrBased);
end;

procedure TfKf7Device.tabStacksChange(Sender: TObject);
begin
  case tabStacks.TabIndex of
    0: ShowStack := ShowStack_Data;
    1: ShowStack := ShowStack_Ret;
  end;
  ShowStack;
end;

procedure TfKf7Device.rgStackBaseClick(Sender: TObject);
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
  fKf7Device.eCommandsCount.Text := IntToStr(CommandsAtLastStepOver);
end;

procedure TfKf7Device.ShowDevice;
begin
  ShowStack;
  ShowCommandAtLastStepOver;
end;

procedure TfKf7Device.SpeedButton1Click(Sender: TObject);
begin
  if fKf7ComModel.Visible then
    fKf7ComModel.Hide
  else
    fKf7ComModel.Show;
end;

procedure TfKf7Device.SpeedButton2Click(Sender: TObject);
begin
  if fLed.Visible then
    fLed.Hide
  else
    fLed.Show;
end;

procedure TfKf7Device.SpeedButton3Click(Sender: TObject);
begin
  if fSimVga.Visible then
    fSimVga.Hide
  else
    fSimVga.Show;
end;

procedure TfKf7Device.FormCreate(Sender: TObject);
begin
  ShowStack := ShowStack_Data;
  IntToStrBased := IntToStr;
end;

end.
