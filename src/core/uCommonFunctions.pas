unit uCommonFunctions;

interface

uses
  Windows, Forms, SysUtils, Grids, uRecordList;

type
  TIntToStrFunc = function(value: integer): string;

function PositiveMod(a, b: integer): integer;
function IntToStrHex(Value: integer): string;
function IntToStrChar(Value: integer): string;
procedure ShowIntStack(var grid: TStringGrid; stack: PStackInt; IntToStrFunc: TIntToStrFunc);
function shra(value: integer; shiftCount: integer): integer;

implementation

// a mod b
function PositiveMod(a, b: integer): integer;
begin
  Result := a mod b;
  if Result < 0 then
    Result := Result + b;
end;

function IntToStrHex(Value: integer): string;
begin
  Result := IntToHex(Value, 0);
end;

function IntToStrChar(Value: integer): string;
begin
  Result := chr(Value);
end;

procedure ShowIntStack(var grid: TStringGrid; stack: PStackInt; IntToStrFunc: TIntToStrFunc);
var
  i: integer;
  pos: integer;
begin
  with grid do
  begin
    ColCount := 2;
    RowCount := stack.Size + 1;
    ColWidths[0] := 60;
    ColWidths[1] := 60;

    Cells[0, 0] := 'Addr';
    Cells[1, 0] := 'Value';

    Pos := PositiveMod(Stack.Top - 1, Stack.Size);
    for i := 0 to Stack.Size-1 do
    begin
      Cells[0, i + 1] := IntToHex(Pos, 2);
      Cells[1, i + 1] := IntToStrFunc(integer(Stack.Item(Pos)^));
      Pos := PositiveMod(Pos - 1, Stack.Size);
    end;
  end;
end;

function shra(value: integer; shiftCount: integer): integer;
const
  shiftMask: array[0..31] of cardinal =
  ($00000000,
   $80000000, $C0000000, $E0000000, $F0000000,
   $F8000000, $FC000000, $FE000000, $FF000000,
   $FF800000, $FFC00000, $FFE00000, $FFF00000,
   $FFF80000, $FFFC0000, $FFFE0000, $FFFF0000,
   $FFFF8000, $FFFFC000, $FFFFE000, $FFFFF000,
   $FFFFF800, $FFFFFC00, $FFFFFE00, $FFFFFF00,
   $FFFFFF80, $FFFFFFC0, $FFFFFFE0, $FFFFFFF0,
   $FFFFFFF8, $FFFFFFFC, $FFFFFFFE);
begin
  Result := value shr shiftCount;
  {$WARNINGS OFF}
  if (value and $80000000) <> 0 then
    Result := Result or shiftMask[shiftCount and 31];
  {$WARNINGS ON}
end;

end.
