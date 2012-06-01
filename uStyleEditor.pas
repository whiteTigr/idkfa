unit uStyleEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, UnitSyntaxMemo;

type
  TfStyleEditor = class(TForm)
    GroupBox1: TGroupBox;
    bLoadFromFile: TButton;
    bSaveToFile: TButton;
    GroupBox2: TGroupBox;
    cbElementName: TComboBox;
    GroupBox3: TGroupBox;
    chkBold: TCheckBox;
    chkItalic: TCheckBox;
    chkUnderline: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    imgFore: TImage;
    imgBack: TImage;
    GroupBox4: TGroupBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ColorDialog1: TColorDialog;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    procedure chkBoldClick(Sender: TObject);
    procedure chkItalicClick(Sender: TObject);
    procedure chkUnderlineClick(Sender: TObject);
    procedure imgForeClick(Sender: TObject);
    procedure imgBackClick(Sender: TObject);
    procedure cbElementNameChange(Sender: TObject);
    procedure bSaveToFileClick(Sender: TObject);
    procedure bLoadFromFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fStyleEditor: TfStyleEditor;
  mmCodeP: ^TMPSyntaxMemo;

procedure Init;

implementation

uses
  uMain;

{$R *.dfm}

procedure ChangeCheckBold(new: boolean);
begin
  fStyleEditor.chkBold.Checked := new;
  if fStyleEditor.chkBold.Checked then
    fStyleEditor.chkBold.Font.Style := [fsBold]
  else
    fStyleEditor.chkBold.Font.Style := [];
end;

procedure ChangeCheckItalic(new: boolean);
begin
  fStyleEditor.chkItalic.Checked := new;
  if fStyleEditor.chkItalic.Checked then
    fStyleEditor.chkItalic.Font.Style := [fsItalic]
  else
    fStyleEditor.chkItalic.Font.Style := [];
end;

procedure ChangeCheckUnderline(new: boolean);
begin
  fStyleEditor.chkUnderline.Checked := new;
  if fStyleEditor.chkUnderline.Checked then
    fStyleEditor.chkUnderline.Font.Style := [fsUnderline]
  else
    fStyleEditor.chkUnderline.Font.Style := [];
end;

procedure SetFontStyle;
var
  index: integer;
  FontStyle: TFontStyles;
begin
  index := fStyleEditor.cbElementName.ItemIndex;
  if index = -1 then Exit;
  FontStyle := [];
  if fStyleEditor.chkBold.Checked then Include(FontStyle, fsBold);
  if fStyleEditor.chkItalic.Checked then Include(FontStyle, fsItalic);
  if fStyleEditor.chkUnderline.Checked then Include(FontStyle, fsUnderline);
  mmCodeP.SyntaxAttributes.FontStyle[StyleConsts[index].id] := FontStyle;
end;

procedure ShowElement;
var
  index: integer;
begin
  index := fStyleEditor.cbElementName.ItemIndex;
  if index = -1 then
  begin
    ChangeCheckBold(false);
    ChangeCheckItalic(false);
    ChangeCheckUnderline(false);
    fStyleEditor.imgFore.Canvas.Brush.Color := clDefault;
    fStyleEditor.imgFore.Canvas.FillRect(rect(0, 0, fStyleEditor.imgFore.Width-1, fStyleEditor.imgFore.Height-1));
    fStyleEditor.imgBack.Canvas.Brush.Color := clDefault;
    fStyleEditor.imgBack.Canvas.FillRect(rect(0, 0, fStyleEditor.imgBack.Width-1, fStyleEditor.imgBack.Height-1));
  end else begin
    ChangeCheckBold(fsBold in mmCodeP.SyntaxAttributes.FontStyle[StyleConsts[index].id]);
    ChangeCheckItalic(fsItalic in mmCodeP.SyntaxAttributes.FontStyle[StyleConsts[index].id]);
    ChangeCheckUnderline(fsUnderline in mmCodeP.SyntaxAttributes.FontStyle[StyleConsts[index].id]);
    fStyleEditor.imgFore.Canvas.Brush.Color := mmCodeP.SyntaxAttributes.FontColor[StyleConsts[index].id];
    fStyleEditor.imgFore.Canvas.FillRect(rect(0, 0, fStyleEditor.imgFore.Width-1, fStyleEditor.imgFore.Height-1));
    fStyleEditor.imgBack.Canvas.Brush.Color := mmCodeP.SyntaxAttributes.BackColor[StyleConsts[index].id];
    fStyleEditor.imgBack.Canvas.FillRect(rect(0, 0, fStyleEditor.imgBack.Width-1, fStyleEditor.imgBack.Height-1));
  end;
end;

procedure Init;
var
  i: integer;
begin
  fStyleEditor.cbElementName.Items.Clear;
  for i := Low(StyleConsts) to High(StyleConsts) do
    fStyleEditor.cbElementName.Items.Add(StyleConsts[i].str);
  fStyleEditor.cbElementName.ItemIndex := 0;
  ShowElement;
end;

procedure TfStyleEditor.chkBoldClick(Sender: TObject);
begin
  if chkBold.Checked then
    chkBold.Font.Style := [fsBold]
  else
    chkBold.Font.Style := [];
  SetFontStyle;
end;

procedure TfStyleEditor.chkItalicClick(Sender: TObject);
begin
  if chkItalic.Checked then
    chkItalic.Font.Style := [fsItalic]
  else
    chkItalic.Font.Style := [];
  SetFontStyle;
end;

procedure TfStyleEditor.chkUnderlineClick(Sender: TObject);
begin
  if chkUnderline.Checked then
    chkUnderline.Font.Style := [fsUnderline]
  else
    chkUnderline.Font.Style := [];
  SetFontStyle;
end;

procedure TfStyleEditor.imgForeClick(Sender: TObject);
var
  index: integer;
begin
  index := cbElementName.ItemIndex;
  if index = -1 then Exit;
  ColorDialog1.Color := mmCode[fMain.Tabs.PageIndex].SyntaxAttributes.FontColor[StyleConsts[index].id];
  if ColorDialog1.Execute then
  begin
    mmCodeP.SyntaxAttributes.FontColor[StyleConsts[index].id] := ColorDialog1.Color;
    imgFore.Canvas.Brush.Color := ColorDialog1.Color;
    imgFore.Canvas.FillRect(rect(0, 0, imgFore.Width-1, imgFore.Height-1));
  end;
end;

procedure TfStyleEditor.imgBackClick(Sender: TObject);
var
  index: integer;
begin
  index := cbElementName.ItemIndex;
  if index = -1 then Exit;
  ColorDialog1.Color := mmCode[fMain.Tabs.PageIndex].SyntaxAttributes.BackColor[StyleConsts[index].id];
  if ColorDialog1.Execute then
  begin
    mmCodeP.SyntaxAttributes.BackColor[StyleConsts[index].id] := ColorDialog1.Color;
    imgBack.Canvas.Brush.Color := ColorDialog1.Color;
    imgBack.Canvas.FillRect(rect(0, 0, imgFore.Width-1, imgFore.Height-1));
  end;
end;

procedure TfStyleEditor.cbElementNameChange(Sender: TObject);
begin
  ShowElement;
end;

procedure TfStyleEditor.bSaveToFileClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
    mmCodeP.SyntaxAttributes.SaveToFile(SaveDialog1.FileName);
end;

procedure TfStyleEditor.bLoadFromFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    mmCodeP.SyntaxAttributes.LoadFromFile(OpenDialog1.FileName);
end;

end.
