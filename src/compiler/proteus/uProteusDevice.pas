unit uProteusDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uGlobal, StdCtrls, ExtCtrls, Grids, ComCtrls, uProteusDeviceCore, uCommonFunctions;

type
  TfProteusDevice = class(TForm)
    PanelInout: TPanel;
    Splitter1: TSplitter;
    tabStacks: TTabControl;
    sgStack: TStringGrid;
    rgStackBase: TRadioGroup;
    procedure tabStacksChange(Sender: TObject);
    procedure rgStackBaseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TfProteusDevice.ShowDevice;
begin
  ShowStack;
end;

procedure TfProteusDevice.FormCreate(Sender: TObject);
begin
  ShowStack := ShowStack_Data;
  IntToStrBased := IntToStr;
end;

end.
