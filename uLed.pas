unit uLed;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TfLed = class(TForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fLed: TfLed;
  MaxLeds: integer = 8;
  leds: array[0..7] of TShape;

function Inport(addr: integer): integer;
procedure Outport(addr, data: integer);

implementation

{$R *.dfm}

procedure TfLed.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to MaxLeds-1 do
  begin
    if leds[i] = nil then
      leds[i] := TShape.Create(fLed);
    leds[i].Parent := fLed;
    leds[i].Shape := stCircle;
    leds[i].Width := 16;
    leds[i].Height := 16;
    leds[i].Left := 8 + (leds[i].Width + 8) * (7 - i);
    leds[i].Top := 8;
    leds[i].Brush.Color := clDkGray;
  end;
  fLed.Width := leds[0].Left + leds[0].Width + 16;
end;

function Gradient(colorFrom, colorTo: TColor; percent: real): TColor;
var
  rFrom, rTo, rRes: byte;
  gFrom, gTo, gRes: byte;
  bFrom, bTo, bRes: byte;
begin
  rFrom := colorFrom and $FF;
  rTo := colorTo and $FF;
  rRes := trunc(rFrom * (1 - percent) + rTo * percent);

  gFrom := (colorFrom shr 8) and $FF;
  gTo := (colorTo shr 8) and $FF;
  gRes := trunc(gFrom * (1 - percent) + gTo * percent);

  bFrom := (colorFrom shr 16) and $FF;
  bTo := (colorTo shr 16) and $FF;
  bRes := trunc(bFrom * (1 - percent) + bTo * percent);

  Result := (bRes shl 16) or (gRes shl 8) or (rRes);
end;

function Inport(addr: integer): integer;
begin
  Result := 0;
end;

procedure Outport(addr, data: integer);
const
  sqrt1024 = 32;
var
  ledNumber: integer;
  varData: integer;
  light: real;
begin
  varData := data;
  case addr of
    3000:
    begin
      for ledNumber := 0 to MaxLeds-1 do
      begin
        if (varData and $1) <> 0 then
          leds[ledNumber].Brush.Color := clLime
        else
          leds[ledNumber].Brush.Color := clDkGray;
        varData := varData shr 1;
      end;
    end;
    3010..3017:
    begin
      ledNumber := addr - 3010;
      light := data and 1023;
      light := sqrt(light) / sqrt1024;
      leds[ledNumber].Brush.Color := Gradient(clDkGray, clLime, light);
    end;
  end;
end;

end.
