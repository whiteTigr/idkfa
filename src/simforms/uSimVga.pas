unit uSimVga;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TfSimVga = class(TForm)
    imageMain: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fSimVga: TfSimVga;
  BaseAddr: integer = 300;

procedure Outport(_addr, data: integer);
function Inport(_addr: integer): integer;

implementation

{$R *.dfm}

type
  TSymbol = array[0..15] of byte;

var
  Symbols: array[0..255] of TSymbol; // initialized from resource
  Screen: array[0..1999] of integer; // 17:13 - bgcolor; 12:8 - color; 7:0 - symbol
  Pallete: array[0..31] of TColor =
  ($000000, $0000FF, $00FF00, $00FFFF, $FF0000, $FF00FF, $FFFF00, $FFFFFF,
   $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF,
   $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF,
   $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF, $FFFFFF);

  LowLevel: boolean = false;
  ScreenAddr: integer = 0;
  PalleteAddr: integer = 0;
  SymbolAddr: integer = 0;
  NewSymbol: TSymbol;

  bgcolor: TColor = 0;
  forecolor: TColor = 2;

  CaretPos: TPoint = (x: 0; y: 0);

procedure InitSymbols;
var
  stream: TResourceStream;
begin
  stream := TResourceStream.Create(hInstance, 'SimVgaSymbols', RT_RCDATA);
  try
    CopyMemory(@Symbols, stream.Memory, stream.Size);
  finally
    stream.Free;
  end;
end;

procedure InitScreen;
begin
  FillMemory(@Screen, Length(Screen) * sizeof(integer), 0);
end;

procedure DrawSymbol(x, y, bcolor, fcolor, sym: integer); overload;
var
  dx, dy: integer;
  line: integer;
  curColor: TColor;
begin
  for dy := 0 to 15 do
  begin
    line := Symbols[sym][dy];
    for dx := 0 to 7 do
    begin
      if (line and $80) <> 0 then
        curColor := Pallete[fcolor]
      else
        curColor := Pallete[bcolor];
      fSimVga.imageMain.Canvas.Pixels[x + dx, y + dy] := curColor;
      line := line shl 1;
    end;
  end;
end;

procedure DrawSymbol(index: integer); overload;
var
  fcolor: TColor;
  bcolor: TColor;
  sym: integer;
begin
  bcolor := (Screen[index] shr 13) and $1F;
  fcolor := (Screen[index] shr  8) and $1F;
  sym := Screen[index] and $FF;
  DrawSymbol((index mod 80) * 8, (index div 80) * 16, bcolor, fcolor, sym);
end;

procedure ShowScreen;
var
  i: integer;
  bcolor, fcolor: integer;
  sym: integer;
begin
  for i := 0 to 1999 do
  begin
    bcolor := (Screen[i] shr 13) and $1F;
    fcolor := (Screen[i] shr  8) and $1F;
    sym := Screen[i] and $FF;
    DrawSymbol((i mod 80) * 8, (i div 80) * 16, bcolor, fcolor, sym);
  end;
end;

procedure Outport(_addr, data: integer);
var
  addr: integer;
begin
  addr := _addr - BaseAddr;

  case addr of
    0:
      if LowLevel then
      begin
        Screen[ScreenAddr] := data and $3FF;
        DrawSymbol(ScreenAddr);
      end;
    1: ScreenAddr := data and $7FF;
    2: if cardinal(data) > 79 then CaretPos.X := 0 else CaretPos.X := data;
    3: if cardinal(data) > 24 then CaretPos.Y := 0 else CaretPos.Y := data;
    4: forecolor := data and $1F;
    5: bgcolor := data and $1F;
    6:
      begin
        Screen[CaretPos.X + CaretPos.Y * 80] := (bgcolor shl 13) + (forecolor shl 8) + (data and $FF);
        DrawSymbol(CaretPos.X + CaretPos.Y * 80);
        if CaretPos.X = 79 then
        begin
          CaretPos.X := 0;
          if CaretPos.Y = 24 then
            CaretPos.Y := 0
          else
            inc(CaretPos.Y);
        end
        else
          inc(CaretPos.X);
      end;
    7: LowLevel := (data and $1) <> 0;
    8: if CaretPos.Y = 24 then CaretPos.Y := 0 else inc(CaretPos.Y);
    9:
      if LowLevel then
      begin
        Screen[ScreenAddr] := data and $3FF;
        DrawSymbol(ScreenAddr);
        inc(ScreenAddr);
      end;
    { ... }
    30: PalleteAddr := data and $1F;
    31: Pallete[PalleteAddr] := data and $FFFFFF;
    35: SymbolAddr := data and $FF;
    37: Symbols[SymbolAddr] := NewSymbol;
    40..43:
      begin
        NewSymbol[(addr - 40) * 4 + 0] := data and $FF;
        NewSymbol[(addr - 40) * 4 + 1] := (data shr 8) and $FF;
        NewSymbol[(addr - 40) * 4 + 2] := (data shr 16) and $FF;
        NewSymbol[(addr - 40) * 4 + 3] := (data shr 24) and $FF;
      end;
  end;
end;

function Inport(_addr: integer): integer;
var
  addr: integer;
begin
  addr := _addr - BaseAddr;
  Result := not addr;

  case addr of
    0: Result := Screen[ScreenAddr];
  end;
end;

initialization
  InitSymbols;
  InitScreen;
finalization

end.
