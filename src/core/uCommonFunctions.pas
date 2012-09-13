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
function UniPos(const substr, str: string; strpos: integer = 1): Integer;

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

function _UniPos(const substr, str: string; strpos: integer = 1): Integer;
asm
       push  ebx
       push  esi
       add   esp, -16
       test  edx, edx
       jz    @NotFound
       test  eax, eax
       jz    @NotFound
       dec   ecx
       mov   esi, [edx-4] //Length(Str)
       sub   esi, strpos
       add   esi, esi
       add   edx, strpos
       add   edx, strpos
       mov   ebx, [eax-4] //Length(Substr)
       add   ebx, ebx
       cmp   esi, ebx
       jl    @NotFound
       test  ebx, ebx
       jle   @NotFound
       sub   ebx, 2
       add   esi, edx
       add   edx, ebx
       mov   [esp+8], esi
       add   eax, ebx
       mov   [esp+4], edx
       neg   ebx
       movzx ecx, word ptr [eax]
       mov   [esp], ebx
       jnz   @FindString

       sub   esi, 4
       mov   [esp+12], esi

@FindChar2:
       cmp   cx, word ptr [edx]
       jz    @Matched0ch
       cmp   cx, word ptr [edx+2]
       jz    @Matched1ch
       add   edx, 4
       cmp   edx, [esp+12]
       jb    @FindChar4
       cmp   edx, [esp+8]
       jb    @FindChar2
@NotFound:
       xor   eax, eax
       jmp   @Exit0ch

@FindChar4:
       cmp   cx, word ptr [edx]
       jz    @Matched0ch
       cmp   cx, word ptr [edx+2]
       jz    @Matched1ch
       cmp   cx, word ptr [edx+4]
       jz    @Matched2ch
       cmp   cx, word ptr [edx+6]
       jz    @Matched3ch
       add   edx, 8
       cmp   edx, [esp+12]
       jb    @FindChar4
       cmp   edx, [esp+8]
       jb    @FindChar2
       xor   eax, eax
       jmp   @Exit0ch

@Matched2ch:
       add   edx, 4
@Matched0ch:
       add   edx, 2
       mov   eax, edx
       sub   eax, [esp+4]
@Exit0ch:
       shr   eax, 1
       add   esp, 16
       pop   esi
       pop   ebx
       ret

@Matched3ch:
       add   edx, 4
@Matched1ch:
       add   edx, 4
       xor   eax, eax
       cmp   edx, [esp+8]
       ja    @Exit1ch
       mov   eax, edx
       sub   eax, [esp+4]
@Exit1ch:
       shr   eax, 1
       add   esp, 16
       pop   esi
       pop   ebx
       ret

@FindString4:
       cmp   cx, word ptr [edx]
       jz    @Test0
       cmp   cx, word ptr [edx+2]
       jz    @Test1
       cmp   cx, word ptr [edx+4]
       jz    @Test2
       cmp   cx, word ptr [edx+6]
       jz    @Test3
       add   edx, 8
       cmp   edx, [esp+12]
       jb    @FindString4
       cmp   edx, [esp+8]
       jb    @FindString2
       xor   eax, eax
       jmp   @Exit1

@FindString:
       sub   esi, 4
       mov   [esp+12], esi
@FindString2:
       cmp   cx, word ptr [edx]
       jz    @Test0
@AfterTest0:
       cmp   cx, word ptr [edx+2]
       jz    @Test1
@AfterTest1:
       add   edx, 4
       cmp   edx, [esp+12]
       jb    @FindString4
       cmp   edx, [esp+8]
       jb    @FindString2
       xor   eax, eax
       jmp   @Exit1

@Test3:
       add   edx, 4
@Test1:
       mov   esi, [esp]
@Loop1:
       mov   ebx, [esi+eax]
       cmp   ebx, [esi+edx+2]
       jnz   @AfterTest1
       add   esi, 4
       jl    @Loop1
       add   edx, 4
       xor   eax, eax
       cmp   edx, [esp+8]
       ja    @Exit1
@RetCode1:
       mov   eax, edx
       sub   eax, [esp+4]
@Exit1:
       shr   eax, 1
       add   esp, 16
       pop   esi
       pop   ebx
       ret

@Test2:
       add   edx, 4
@Test0:
       mov   esi, [esp]
@Loop0:
       mov   ebx, [esi+eax]
       cmp   ebx, [esi+edx]
       jnz   @AfterTest0
       add   esi, 4
       jl    @Loop0
       add   edx, 2
@RetCode0:
       mov   eax, edx
       sub   eax, [esp+4]
       shr   eax, 1
       add   esp, 16
       pop   esi
       pop   ebx
end;

// todo: понаставил тут костылей...
function UniPos(const substr, str: string; strpos: integer = 1): Integer;
begin
  Result := _UniPos(substr, str, strpos) - 1;
  If Result <> -1 then
    Result := Result + strpos - 1;
end;

end.
