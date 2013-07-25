unit uTermSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Buttons;

type
  TfmTermSet = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnFont: TButton;
    btnBGcolor: TButton;
    edTestTerm: TEdit;
    rbCharsOnly: TRadioButton;
    rbCharsWithHex: TRadioButton;
    GroupBox1: TGroupBox;
    seStrLen: TSpinEdit;
    cbHexLen: TComboBox;
    dlgFont: TFontDialog;
    dlgColor: TColorDialog;
    procedure btnFontClick(Sender: TObject);
    procedure btnBGcolorClick(Sender: TObject);
    procedure cbHexLenSelect(Sender: TObject);
    procedure seStrLenClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmTermSet: TfmTermSet;

implementation

{$R *.dfm}

procedure TfmTermSet.btnBGcolorClick(Sender: TObject);
begin
  if dlgColor.Execute() then
  begin
    edTestTerm.Color := dlgColor.Color;
  end;
end;

procedure TfmTermSet.btnFontClick(Sender: TObject);
begin
  if dlgFont.Execute() then
  begin
    edTestTerm.Font := dlgFont.Font;
  end;
end;

procedure TfmTermSet.cbHexLenSelect(Sender: TObject);
begin
  rbCharsWithHex.Checked := true;
end;

procedure TfmTermSet.seStrLenClick(Sender: TObject);
begin
  rbCharsOnly.Checked := true;
end;

end.
