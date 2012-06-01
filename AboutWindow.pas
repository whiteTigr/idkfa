unit AboutWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfAbout = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAbout: TfAbout;

implementation

{$R *.dfm}

function CurrentFileInfo: string;
var
  dump: DWORD;
  size: integer;
  buffer: PChar;
  VersionPointer, TransBuffer: PChar;
  Temp: integer;
  CalcLangCharSet: string;
  NameApp: string;
begin
  NameApp := paramstr(0);

  size := GetFileVersionInfoSize(PChar(NameApp), dump);
  buffer := StrAlloc(size+1);
  try
    GetFileVersionInfo(PChar(NameApp), 0, size, buffer);

    VerQueryValue(buffer, '\VarFileInfo\Translation', pointer(TransBuffer),
    dump);
    if dump >= 4 then
    begin
      temp:=0;
      StrLCopy(@temp, TransBuffer, 1);
      CalcLangCharSet:=IntToHex(temp, 4);
      StrLCopy(@temp, TransBuffer+1, 1);
      CalcLangCharSet := CalcLangCharSet+IntToHex(temp, 4);
    end;

    VerQueryValue(buffer, pchar('\StringFileInfo\'+CalcLangCharSet+
    '\'+'FileVersion'), pointer(VersionPointer), dump);
    if (dump > 1) then
    begin
      Result := VersionPointer;
      // SetLength(Result, dump);
      // StrLCopy(Pchar(Result), VersionPointer, dump);
    end
    else
      Result := '0.0.0.0';
  finally
    StrDispose(Buffer);
  end;
end;

function GetBuild: string;
var
  pos: integer;
  s: string;
begin
  s := CurrentFileInfo;
  Result := '';
  Pos := Length(s);
  while (Pos >= 1) and (s[pos] <> '.') do
  begin
    Result := s[pos] + result;
    dec(pos);
  end;
end;

procedure TfAbout.FormCreate(Sender: TObject);
begin
  Label2.Caption := '(build: ' + GetBuild + ')';
end;

procedure BeginScreenUpdate(hwnd: THandle);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(hwnd, nil, 0, RDW_FRAME + RDW_INVALIDATE +
    RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (erase) then
    Windows.InvalidateRect(hwnd, nil, True);
end;

procedure TfAbout.Panel1Click(Sender: TObject);
begin
  // Сделано так, а не timer1.Enabled := not timer1.Enabled
  // т.к. были дополнительные действия при переключении таймера.
  if not timer1.Enabled then
  begin
    timer1.Enabled := true;
  end
  else
  begin
    timer1.Enabled := false;
  end;
end;

function Gradient(colorFrom, colorTo: cardinal; percent: real): cardinal;
var
  r, g, b: integer;
begin
  r := trunc((colorFrom and $0000FF) * (1 - percent) + (colorTo and $0000FF) * percent) and $0000FF;
  g := trunc((colorFrom and $00FF00) * (1 - percent) + (colorTo and $00FF00) * percent) and $00FF00;
  b := trunc((colorFrom and $FF0000) * (1 - percent) + (colorTo and $FF0000) * percent) and $FF0000;
  Result := r + g + b;
end;

var
  MouseLeft: boolean = false;
  MouseRight: boolean = false;
  MousePos: TPoint = (x:0; y:0);
procedure TfAbout.Timer1Timer(Sender: TObject);
const
  Radius = 7;
  SqrRadius = Radius * Radius;
var
  x, y: integer;
begin
  BeginScreenUpdate(fAbout.Handle);
  for y := MousePos.Y - Radius to MousePos.Y + Radius do
  begin
    if (y < 0) or (y > Image1.Height-1) then
      continue;
    for x := MousePos.X - Radius to MousePos.X + Radius do
    begin
      if (x < 0) or (x > Image1.Width-1) then
        continue;
      if (sqr(x - MousePos.X) + sqr(y - MousePos.Y)) > SqrRadius then
        continue;
      if MouseLeft then
        Image1.Canvas.Pixels[x, y] := Gradient(Image1.Canvas.Pixels[x, y], clWhite, 0.1);
      if MouseRight then
        Image1.Canvas.Pixels[x, y] := Gradient(Image1.Canvas.Pixels[x, y], clBlack, 0.1);
    end;
  end;
  EndScreenUpdate(fAbout.Handle, false);
end;

procedure TfAbout.Button1Click(Sender: TObject);
begin
  Timer1.Enabled := false;
end;

procedure TfAbout.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseLeft := Button = mbLeft;
  MouseRight := Button = mbRight;
  MousePos := Point(x, y);
end;

procedure TfAbout.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseLeft := MouseLeft and not (Button = mbLeft);
  MouseRight := MouseRight and not (Button = mbRight);
  MousePos := Point(x, y);  
end;

procedure TfAbout.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MousePos := Point(x, y);
end;

end.
