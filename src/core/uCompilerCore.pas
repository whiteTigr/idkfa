unit uCompilerCore;

interface

uses uRecordList, uGlobal, SysUtils, StrUtils;

const
  defaultCodeSize = 1 * 1024 * 1024; // 1 mb
  defaultDataSize = 1 * 1024 * 1024; // 1 mb
  defaultVocabularySize = 100000;
  defaultControlStackSize = 128;

  MaxCode = 32 * 1024 * 1024; // 32 mb
  MaxData = 32 * 1024 * 1024; // 32 mb
  MaxVocabulary = 1 * 1024 * 1024; // 1 mb
  MaxControlStackSize = 32 * 1024 * 1024; // 32 mb;

type
  TProc = procedure of object;
  PProc = ^TProc;

  PParserCore = ^TParserCore;
  TParserCore = class
  private
    procedure SetTib(tib: string);
    procedure SetSeparators(separators: string);
    function isSeparator(symbol: char): boolean;
    procedure PassSeparators;
    procedure CutToken;
  protected
    FTib: string;
    FTibPos: integer;
    FTibLength: integer;
    FSeparators: string;
    FSeparatorsLength: integer;
    FToken: string;
  public
    property tib: string read FTib write SetTib;
    property tibPos: integer read FTibPos write FTibPos;
    function IncTibPos: boolean;
    property separators: string read FSeparators write SetSeparators;
    property token: string read FToken;
    constructor Create; virtual;
    // "выкусывание" токена. Возвращает успешность операции.
    // токен в переменной FToken.
    function NextWord: boolean; virtual;
  end;

  TCodeCell = record
    value: integer;
  end;
  PCodeArray = ^TCodeArray;
  TCodeArray = array[0..MaxCode-1] of TCodeCell;

  TDataCell = record
    value: integer;
  end;
  PDataArray = ^TDataArray;
  TDataArray = array[0..MaxData-1] of TDataCell;

  PTokenWord = ^TTokenWord;
  TTokenWord = record
    name : string[32];
    tag : integer;
    immediate : boolean;
    proc : TProc;
  end;
  PVocabulary = ^TVocabulary;
  TVocabulary = array[0..MaxVocabulary-1] of TTokenWord;

  TControlStackCell = record
    Addr : integer;
    Source : integer;
  end;
  PControlStack = ^TControlStack;
  TControlStack = array[0..MaxControlStackSize-1] of TControlStackCell;

  TCompilerCore = class(TTargetCompiler)
  protected
    Parser: TParserCore;

    FCode: PCodeArray;
    CodeSize: integer;
    CP: integer;

    FData: PDataArray;
    DataSize: integer;
    DP: integer;

    FVocabulary: PVocabulary;
    VocabularySize: integer;
    VP: integer;

    TokenID: integer;
    Token: PTokenWord;
    Number: integer;

    FControlStack: PControlStack;
    ControlStackSize: integer;
    ControlStackTop: integer;

    FError: integer;

    LineCount: integer;
    Compiled: boolean;

    function ControlPop: TControlStackCell;
    procedure ControlPush(value: TControlStackCell);
    function ControlReadTop: TControlStackCell;
    procedure Error(code: integer);
    procedure MemoryAlloc(CellsCount, CellSize: integer;
      var dest: pointer; var newSizeVariable: integer);
    function GetErrorMessage: string;
    procedure FindToken; virtual;
    procedure Compile(code: integer); overload; virtual;
    procedure Compile(code: array of integer); overload;
    procedure CompileNumber(value: integer); virtual;
    procedure TryDispatchNumber; virtual;
    procedure ClearVocabulary;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetCodeSize(newSize: integer);
    procedure SetDataSize(newSize: integer);
    procedure SetControlStackSize(newSize: integer);
    procedure SetVocabularySize(newSize: integer);

    function Code(pos: integer): integer; override;
    function CodeCount: integer; override;
    function MaxCode: integer; override;

    function Data(pos: integer): integer; override;
    function DataCount: integer; override;
    function MaxData: integer; override;

    procedure Evaluate(const tib: string); override;
    procedure BeginCompile; override;
    procedure EndCompile; override;

    function LastError: integer; override;
    function LastToken: string; override;
    function LastErrorMessage: string; override;

    procedure AddToken(value: TTokenWord);
  end;

const
  errOk = 0;
  errControlStackUnderflow = 1;
  errControlStackOverflow = 2;
  errMemoryAllocFailed = 3;
  errVocabularyIsFull = 4;
  errCodeMemoryIsFull = 5;
  errDataMemoryIsFull = 6;
  errInvalideNumber = 7;
  errUnknownToken = 8;
  errControlMismatch = 9;
  errCount = 10;

  ErrorMessage: array[0..errCount-1] of record
    code: integer;
    msg: string;
  end =
  ((code: errOk; msg: 'OK'),
   (code: errControlStackUnderflow; msg: 'Control stack underflow'),
   (code: errControlStackOverflow; msg: 'Control stack overflow'),
   (code: errMemoryAllocFailed; msg: 'MemoryAlloc failed'),
   (code: errVocabularyIsFull; msg: 'Vocabulary is full'),
   (code: errCodeMemoryIsFull; msg: 'Code memory is full'),
   (code: errDataMemoryIsFull; msg: 'Data memory is full'),
   (code: errInvalideNumber; msg: 'Invalide number'),
   (code: errUnknownToken; msg: 'Unknown token'),
   (code: errControlMismatch; msg: 'Control mismatch')
  );

function TokenWord(name: string; tag: integer; immediate: boolean; proc: TProc): TTokenWord;
function ControlStackCell(addr: integer; source: integer): TControlStackCell;

implementation

function TokenWord(name: string; tag: integer; immediate: boolean; proc: TProc): TTokenWord;
begin
  Result.name := ShortString(name);
  Result.tag := tag;
  Result.immediate := immediate;
  Result.proc := proc;
end;

function ControlStackCell(addr: integer; source: integer): TControlStackCell;
begin
  Result.Addr := addr;
  Result.Source := source;
end;

{ TParserCore }

constructor TParserCore.Create;
begin
  inherited;
  separators := ' ';
end;

procedure TParserCore.CutToken;
begin
  FToken := '';
  while (FTibPos <= FTibLength) and (not isSeparator(FTib[FTibPos])) do
  begin
    FToken := FToken + FTib[FTibPos];
    inc(FTibPos);
  end;
  if (FTibPos <= FTibLength) then
    inc(FTibPos);
end;

function TParserCore.IncTibPos: boolean;
begin
  inc(FTibPos);
  Result := FTibPos <= FTibLength;
end;

function TParserCore.isSeparator(symbol: char): boolean;
var
  i: integer;
begin
  Result := true;
  for i := 1 to FSeparatorsLength do
    if symbol = FSeparators[i] then
      Exit;
  Result := false;
end;

function TParserCore.NextWord: boolean;
begin
  PassSeparators;
  CutToken;
  Result := Token <> '';
end;

procedure TParserCore.PassSeparators;
begin
  while (FTibPos <= FTibLength) and (isSeparator(FTib[FTibPos])) do
    inc(FTibPos);
end;

procedure TParserCore.SetSeparators(separators: string);
begin
  FSeparators := separators;
  FSeparatorsLength := Length(separators);
end;

procedure TParserCore.SetTib(tib: string);
begin
  FTib := tib;
  FTibPos := 1;
  FTibLength := length(FTib);
end;

{ TCompilerCore }

procedure TCompilerCore.AddToken(value: TTokenWord);
begin
  if VP >= VocabularySize then
  begin
    Error(errVocabularyIsFull);
    Exit;
  end;

  FVocabulary^[VP] := value;
  inc(VP);
end;

procedure TCompilerCore.BeginCompile;
begin
  FError := 0;
  LineCount := 0;
  CP := 0;
  DP := 0;
end;

procedure TCompilerCore.ClearVocabulary;
begin
  VP := 0;
end;

function TCompilerCore.Code(pos: integer): integer;
begin
  if FCode <> nil then
    Result := FCode[pos].value
  else
    Result := -1;
end;

function TCompilerCore.CodeCount: integer;
begin
  Result := CP;
end;

procedure TCompilerCore.Compile(code: integer);
begin
  if CP >= CodeSize then
  begin
    Error(errCodeMemoryIsFull);
    Exit;
  end;

  FCode[CP].value := code;
  inc(CP);
end;

function TCompilerCore.ControlPop: TControlStackCell;
begin
  if ControlStackTop <= 0 then
  begin
    Error(errControlStackUnderflow);
    Exit;
  end;

  dec(ControlStackTop);
  Result := FControlStack[ControlStackTop];
end;

procedure TCompilerCore.ControlPush(value: TControlStackCell);
begin
  if ControlStackTop >= ControlStackSize then
  begin
    Error(errControlStackOverflow);
    Exit;
  end;

  FControlStack[ControlStackTop] := value;
  inc(ControlStackTop);
end;

function TCompilerCore.ControlReadTop: TControlStackCell;
begin
  if ControlStackTop <= 0 then
  begin
    Error(errControlStackUnderflow);
    Exit;
  end;

  Result := FControlStack[ControlStackTop-1];
end;

constructor TCompilerCore.Create;
begin
  inherited Create;

  Parser := TParserCore.Create;
  SetCodeSize(defaultCodeSize);
  SetDataSize(defaultDataSize);
  SetControlStackSize(defaultControlStackSize);
  SetVocabularySize(defaultVocabularySize);
end;

destructor TCompilerCore.Destroy;
begin
  Parser.Destroy;
  FreeMemory(FCode);
  FreeMemory(FData);
  FreeMemory(FVocabulary);
  FreeMemory(FControlStack);

  inherited;
end;

function TCompilerCore.Data(pos: integer): integer;
begin
  if FData <> nil then
    Result := FData[pos].value
  else
    Result := -1;
end;

function TCompilerCore.DataCount: integer;
begin
  Result := DP;
end;

procedure TCompilerCore.EndCompile;
begin
  Compiled := FError = 0;
end;

procedure TCompilerCore.Error(code: integer);
begin
  FError := code;
end;

procedure TCompilerCore.Evaluate(const tib: string);
begin
  inc(LineCount);
  Parser.tib := tib;
  while (FError = errOk) and Parser.NextWord do
  begin
    FindToken;
    if TokenID = -1 then // возможно число
    begin
      TryDispatchNumber;
      if FError = errInvalideNumber then
        Error(errUnknownToken)
      else
      begin
        CompileNumber(Number);
      end;
    end else begin
      with FVocabulary[TokenID] do
      begin
        if immediate then
          proc
        else
          Compile(tag);
      end;
    end;
  end;
end;

procedure TCompilerCore.FindToken;
var
  i: integer;
begin
  for i := VP-1 downto 0 do
    if FVocabulary[i].name = ShortString(Parser.token) then
    begin
      TokenID := i;
      Token := @FVocabulary[TokenID];
      Exit;
    end;
  Token := nil;
  TokenID := -1;
end;

function TCompilerCore.GetErrorMessage: string;
var
  i: integer;
begin
  for i := Low(ErrorMessage) to High(ErrorMessage) do
    if ErrorMessage[i].code = FError then
    begin
      Result := ErrorMessage[i].msg;
      Exit;
    end;

  Result := 'Unknown error';
end;

function TCompilerCore.LastError: integer;
begin
  Result := FError;
end;

function TCompilerCore.LastErrorMessage: string;
begin
  Result := GetErrorMessage;
end;

function TCompilerCore.LastToken: string;
begin
  Result := Parser.token;
end;

function TCompilerCore.MaxCode: integer;
begin
  Result := CodeSize;
end;

function TCompilerCore.MaxData: integer;
begin
  Result := DataSize;
end;

procedure TCompilerCore.MemoryAlloc(CellsCount, CellSize: integer; var dest: pointer; var newSizeVariable: integer);
begin
  if dest <> nil then
    FreeAndNil(dest);
  newSizeVariable := 0;

  dest := AllocMem(CellsCount * CellSize);

  if dest = nil then
  begin
    Error(errMemoryAllocFailed);
    Exit;
  end;

  newSizeVariable := CellsCount;
end;

procedure TCompilerCore.SetCodeSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TCodeCell), pointer(FCode), CodeSize);
end;

procedure TCompilerCore.SetControlStackSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TControlStackCell), pointer(FControlStack), ControlStackSize);
end;

procedure TCompilerCore.SetDataSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TDataCell), pointer(FData), DataSize);
end;

procedure TCompilerCore.SetVocabularySize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TTokenWord), pointer(FVocabulary), VocabularySize);
end;

procedure TCompilerCore.TryDispatchNumber;
var
  instr: string;
  curChar: char;
  curDigit: integer;
  pos: integer;
  base: integer;
  sign: integer;
  res: integer;
  i: integer;
begin
  base := 10;
  instr := Parser.token;
  pos := 1;
  sign := 1;

  if instr[pos] = '-' then
  begin
    sign := -1;
    inc(pos);
  end;

  if MidStr(instr, pos, 2) = '0x' then
  begin
    base := 16;
    inc(pos, 2);
  end;

  if MidStr(instr, pos, 2) = '0d' then
  begin
    base := 10;
    inc(pos, 2);
  end;

  if MidStr(instr, pos, 2) = '0b' then
  begin
    base := 2;
    inc(pos, 2);
  end;

  if MidStr(instr, pos, 2) = '0o' then
  begin
    base := 8;
    inc(pos, 2);
  end;

  if instr[pos] = '-' then
  begin
    sign := -1;
    inc(pos);
  end;

  res := 0;
  for i := pos to Length(instr) do
  begin
    curChar := UpCase(instr[i]);
    curDigit := ord(curChar) - ord('0');
    if curDigit > 9 then
      curDigit := curDigit - ord('A') + ord('9') + 1;
    if (curDigit < 0) or (curDigit > base) then
    begin
      Error(errInvalideNumber);
      res := -1;
      break;
    end;
    res := res * base + curDigit;
  end;

  Number := sign * res;
end;

procedure TCompilerCore.CompileNumber(value: integer);
begin
  //
end;

procedure TCompilerCore.Compile(code: array of integer);
var
  i: integer;
begin
  for i := Low(code) to High(code) do
    Compile(code[i]);
end;

end.
