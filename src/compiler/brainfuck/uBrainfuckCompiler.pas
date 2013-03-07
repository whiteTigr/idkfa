unit uBrainfuckCompiler;

interface

uses Windows, Messages, Sysutils, uGlobal, uCompilerCore;

const
  MaxCode = 16384;

  errOk = 0;

type
  TBrainfuckParser = class(TParserCore)
  public
    function NextWord: boolean; override;
  end;

  PBrainfuckCompiler = ^TBrainfuckCompiler;
  TBrainfuckCompiler = class(TCompilerCore)
  private
    procedure BrainfuckWord;
  protected
    procedure TryDispatchNumber; override;
  public
    constructor Create;
    procedure InitVocabulary;
    function DizasmCmd(cmd: integer): string; override;
  end;

implementation

{ TBrainfuckParser }

function TBrainfuckParser.NextWord: boolean;
const
  ValidChar: string = '+-><[],.';
var
  index: integer;
begin
  index := 0;
  FToken := '';

  while (FTibPos <= FTibLength) do
  begin
    FToken := Tib[FTibPos];
    index := Pos(FToken, ValidChar);
    inc(FTibPos);
    if index > 0 then
      break;
  end;

  Result := index > 0;
end;

{ BrainfuckTC }

procedure TBrainfuckCompiler.BrainfuckWord;
begin
  Compile(FVocabulary[TokenID].tag);
end;

constructor TBrainfuckCompiler.Create;
begin
  inherited Create;
  Parser.Destroy;
  Parser := TBrainfuckParser.Create;
  InitVocabulary;
end;

function TBrainfuckCompiler.DizasmCmd(cmd: integer): string;
const
  CmdToChar: array[0..7] of char = '+-><[],.';
var
  isValid: boolean;
begin
  isValid := (cmd >= 0) and (cmd <= 7);
  if isValid then
    Result := CmdToChar[cmd]
  else
    Result := 'unkwn';
end;

procedure TBrainfuckCompiler.InitVocabulary;
begin
  ClearVocabulary;
  AddToken(TokenWord('+', 0, false, BrainfuckWord));
  AddToken(TokenWord('-', 1, false, BrainfuckWord));
  AddToken(TokenWord('>', 2, false, BrainfuckWord));
  AddToken(TokenWord('<', 3, false, BrainfuckWord));
  AddToken(TokenWord('[', 4, false, BrainfuckWord));
  AddToken(TokenWord(']', 5, false, BrainfuckWord));
  AddToken(TokenWord(',', 6, false, BrainfuckWord));
  AddToken(TokenWord('.', 7, false, BrainfuckWord));
end;

procedure TBrainfuckCompiler.TryDispatchNumber;
begin
  // делать ничего не нужно. Любой непонятный токен в брейнфаке
  // просто пропускается
  {do nothing};
end;

end.
