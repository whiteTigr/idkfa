unit uForthCompiler;

interface

uses Classes, uRecordList, uGlobal, Windows;

type
  TProc = procedure of object;
  PProc = ^TProc;

  TForthWord = record
    name : string;
    comment: string;
    tag : integer;
    immediate : boolean;
    proc : TProc;
  end;

  TControlStackCell = record
    Addr : integer;
    Source : integer;
  end;

const
  erFirst = 0;
  erOK = 0;
  erNotFound = 1;
  erControlOverflow = 2;
  erControlUnderflow = 3;
  erControlMismatch = 4;
  erEoln = 5;
  erNotNumber = 6;
  erOutOfRange = 7;
  erLast = 7;

  MsgTitle = 'idkfa';

  ErrorMsg: array[erFirst..erLast] of string =
  ('OK',
   'Not found',
   'Control stack overflow',
   'Control stack underflow',
   'Control mismatch',
   'Unexcepted end of line',
   'Not number',
   'Out of range'
  );

  MaxCode = 1024 * 16;
  MaxData = 1024 * 16;
  UserMaxCode: integer = 1024 * 16;
  UserMaxData: integer = 1024 * 16;
  MaxWords = 10000;

  MaxControls = 100;
  sNone = 0;
  sIF = 1;
  sBEGIN = 2;
  sDO = 3;
  sELSIF = 4;

type
  PForthCompiler = ^TForthCompiler;
  TForthCompiler = class(TTargetCompiler)
  private
    FLineNumber: integer;
    Base : integer;
    lastpos: integer;
    LastNumber, LastNumberSize: integer;

    LP : integer;
    ControlStack : array [0..MaxControls] of TControlStackCell;
    ElsifStack: array[0..MaxControls] of integer;
    ElsifTop: integer;

    Dict : array [0..MaxWords-1] of TForthWord;
    WordCount : integer;
    HardwiredWordCount: integer;

    FCode, TempCode: array[0..MaxCode-1] of integer;
    FData : array[0..MaxData-1] of integer;
    CP, TCP, DP: integer;

    usesCode: array[0..MaxCode-1] of integer;

    Tib : string;
    TibPos: integer;
    Token: string;

    HereCodePosition: integer;
    CHereCodePosition: integer;

    FError: integer;

    HardwiredWords: TStringList;

    procedure InitBasicCommands;

    procedure Compile(x : integer; isTempCode: boolean = false);
    procedure CompileData(x : integer);
    procedure CompileCall(x : integer; isTempCode: boolean = false);
    procedure CompileLiteral(x : integer);
    procedure CompileTempCode;

    procedure PushForwardRef(Src : integer);
    function PopControl(): TControlStackCell;

    function Find(Token: string): integer;
    procedure AddWord(name: string; comment: string; proc: TProc; tag: integer; immediate: boolean);
    procedure AddForthWord(name: string; tag: integer);
    procedure AddCommentedForthWord(name: string; comment: string; tag: integer);
    function FindWord(pos: integer): integer;

    function Number(Token : string): integer;
    procedure PassSpaces;
    procedure CutWord;
    function Parse: boolean;

    procedure AddUsesCode(ip: integer);
    function isCall(n: integer): boolean;
    function isIf(n: integer): boolean;
    function isJmp(n: integer): boolean;
    procedure BeginOptimize;
    procedure EndOptimize;

    procedure ForthCmdFile;
    procedure ForthCmd;
    procedure ForthIF;
    procedure ForthTHEN;
    procedure ForthELSE;
    procedure ForthELSIF;
    procedure CompileHereWrite;
    procedure CompileCHereWrite;
    procedure ForthMainDef;
    procedure ForthBEGIN;
    procedure ForthAGAIN;
    procedure ForthUNTIL;
    procedure ForthInterpretCreate;
    procedure ForthCommentLine;
    procedure ForthVarChange;
    procedure ForthCreate;
    procedure ForthVARIABLE;
    procedure ForthARRAY;
    procedure ForthString;
    procedure ForthUSE;
    procedure ForthNewMain;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginInitCommandSystem;
    procedure EndInitCommandSystem;

    function GetCHerePosition: integer;
    function Code(pos: integer): integer; override;
    function CodeCount: integer; override;
    function MaxCode: integer; override;
    function Dizasm(cmd: integer): string; override;
    function GetCmdColor(cmd: integer): cardinal; override;

    function GetHerePosition: integer;
    function Data(pos: integer): integer; override;
    function DataCount: integer; override;
    function MaxData: integer; override;

    procedure LoadCommandSystem(fileName: string);
    procedure BeginCompile; override;
    procedure EndCompile; override;
    procedure Evaluate(const s: string); override;
    function LastError: integer; override;
    function LastToken: string; override;
    function LastErrorMessage: string; override;

    procedure Optimize; override;

    procedure AddImmWord(name: string; proc: TProc);
    procedure AddVarChange(name: string; _var: pointer);
    function ParseToken: string;
    function ParseInt: integer;
    function ParseHex: integer;

    function GetTokenComment(token: string): string;

    function NewFileText: string; override;
  end;

implementation

uses SysUtils, StrUtils;

const
  HiLitMask     = $20000;
  LoLitMask     = $10000;
  ShortLitMask  = $30000;
  ShortLimitPos =  32767;
  ShortLimitNeg = -32768;
  LoNumberMask  =  65535;
  CallMask      =  $C000;
  JmpMask       =  $4000;
  IfMask        =  $8000;

procedure TForthCompiler.Compile(x : integer; isTempCode: boolean = false);
var
  CodeMem: PIntegerArray;
  CP: PInteger;
begin
  // Работа через указатели была организована для более простой работы
  // с большой структурой ячейки кода.
  if isTempCode then
  begin
    CodeMem := @TempCode;
    CP := @self.TCP;
  end
  else
  begin
    CodeMem := @FCode;
    CP := @self.CP;
  end;
  CodeMem[CP^] := x;
  CP^ := CP^ + 1;
end;

procedure TForthCompiler.CompileTempCode;
var
  i: integer;
begin
  for i := 0 to TCP-1 do
  begin
    FCode[CP] := TempCode[i];
    inc(CP);
  end;
end;

procedure TForthCompiler.CompileData(x : integer);
begin
  FData[DP] := x;
  Inc(DP);
end;

procedure TForthCompiler.CompileCall(x : integer; isTempCode: boolean = false);
begin
  Compile(x + CallMask, isTempCode);
end;

procedure TForthCompiler.CompileLiteral(x : integer);
begin
  LastNumber := x;
  if ((x > ShortLimitPos) or (x < ShortLimitNeg)) then
  begin
    LastNumberSize := 2;
    Compile(Longword(HiLitMask) + (Longword(x) div Longword(LoNumberMask + 1)));
    Compile(Longword(LoLitMask) + (Longword(x) and Longword(LoNumberMask)));
  end
  else
  begin
    LastNumberSize := 1;
    Compile(ShortLitMask + (x and LoNumberMask));
  end;
end;

procedure TForthCompiler.PushForwardRef(Src : integer);
begin
  if LP = MaxControls then
  begin
    FError := erControlOverflow;
    exit;
  end;
  ControlStack[LP].Addr := CP;
  ControlStack[LP].Source := Src;
  Inc(LP);
end;

function TForthCompiler.PopControl(): TControlStackCell;
begin
  if LP = 0 then
  begin
    FError := erControlUnderflow;
    exit;
  end;
  Dec(LP);
  Result := ControlStack[LP];
end;

procedure TForthCompiler.ForthIF;
begin
  if ControlStack[LP-1].Source <> sELSIF then
  begin
    ElsifStack[ElsifTop] := 0;
    inc(ElsifTop);
  end;
  PushForwardRef(sIF);
  Compile(IfMask);
end;

procedure TForthCompiler.ForthTHEN;
var
  Ref : TControlStackCell;
  i: integer;
begin
  dec(ElsifTop);
  for i := 0 to ElsifStack[ElsifTop] do
  begin
    Ref := PopControl;
    if (Ref.Source <> sIF) and (Ref.Source <> sELSIF) then
    begin
      FError := erControlMismatch;
      exit;
    end;
    FCode[Ref.Addr] := FCode[Ref.Addr] + CP;
  end;
end;

procedure TForthCompiler.ForthELSE;
var
  Ref : TControlStackCell;
begin
  Ref := PopControl;
  if (Ref.Source <> sIF) and (Ref.Source <> sELSIF) then
  begin
    FError := erControlMismatch;
    exit;
  end;
  PushForwardRef(sIF);
  Compile(JmpMask);
  FCode[Ref.Addr] := FCode[Ref.Addr] + CP;
end;

procedure TForthCompiler.ForthELSIF;
var
  Ref: TControlStackCell;
begin
  inc(ElsifStack[ElsifTop-1]);
  Ref := PopControl;
  if Ref.Source <> sIF then
  begin
    FError := erControlMismatch;
    exit;
  end;
  PushForwardRef(sELSIF);
  Compile(JmpMask);
  FCode[Ref.Addr] := FCode[Ref.Addr] + CP;
end;

procedure TForthCompiler.CompileHereWrite;
var
  oldCP: integer;
begin
  oldCP := CP;
  CP := HereCodePosition;
  CompileLiteral(DP);
  if lastNumberSize = 1 then
    Compile(0);
  Compile(Dict[Find('HERE')].tag);
  Compile(Dict[Find('!')].tag);
  CP := oldCP;
end;

procedure TForthCompiler.CompileCHereWrite;
var
  oldCP: integer;
begin
  oldCP := CP;
  CP := CHereCodePosition;
  CompileLiteral(oldCP);
  if lastNumberSize = 1 then
    Compile(0);
  Compile(Dict[Find('[C]HERE')].tag);
  Compile(Dict[Find('!')].tag);
  CP := oldCP;
end;

procedure TForthCompiler.ForthMainDef;
var i : integer;
begin
  FCode[0] := JmpMask + CP;
  for i := 1 to 6 do FCode[i] := JmpMask + i;
  if Find('HERE') <> -1 then
  begin
    HereCodePosition := CP;
    inc(CP, 4);
  end;
  if Find('[C]HERE') <> -1 then
  begin
    CHereCodePosition := CP;
    inc(CP, 4);
  end;
  CompileTempCode;
end;

procedure TForthCompiler.ForthBEGIN;
begin
  PushForwardRef(sBEGIN);
end;

procedure TForthCompiler.ForthAGAIN;
var
  Ref : TControlStackCell;
begin
  Ref := PopControl;
  if Ref.Source <> sBEGIN then
  begin
    FError := erControlMismatch;
    exit;
  end;
  Compile(JmpMask + Ref.Addr);
end;

procedure TForthCompiler.ForthUNTIL;
var
  Ref : TControlStackCell;
begin
  Ref := PopControl;
  if Ref.Source <> sBEGIN then
  begin
    FError := erControlMismatch;
    exit;
  end;
  Compile(IfMask + Ref.Addr);
end;

procedure TForthCompiler.ForthInterpretCreate;
begin
  CompileCall(CP, true);
end;

procedure TForthCompiler.ForthCommentLine;
begin
  Tib := '';
end;

function TForthCompiler.Find(Token: string): integer;
var
  i: integer;
begin
  for i := WordCount-1 downto 0 do
    if Dict[i].Name = Token then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

function TForthCompiler.Number(Token : string): integer;
const DIGITS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var digit, i : integer;
    Symb : char;
    Sign : integer;
    StoreBase : integer;
    StartSym : integer;
begin
  Result := 0;
  StoreBase := Base;
  Sign := 1;
  StartSym := 1;
  if Length(Token) > 1 then
  begin
    if Copy(Token,1,2) = '0x' then begin Base := 16; StartSym := 3; end;
    if Copy(Token,1,2) = '0b' then begin Base := 2;  StartSym := 3; end;
    if Copy(Token,1,2) = '0d' then begin Base := 10; StartSym := 3; end;
  end;
  if Token[1] = '-' then begin Sign := -1; StartSym := 2; end;
  for i := StartSym to Length(Token) do
  begin
    Symb := Token[i];
    digit := Pos(Upcase(Symb), Copy(DIGITS, 1, Base));
    if digit <> 0 then
      Result := Result * Base + digit - 1
    else
    begin
      FError := erNotFound;
      Base := StoreBase;
      exit;
    end;
  end; // do
  Base := StoreBase;
  Result := Sign*Result;
end;

procedure TForthCompiler.PassSpaces;
begin
  while (TibPos <= length(tib)) and (tib[TibPos] = ' ') do inc(TibPos);
end;

procedure TForthCompiler.CutWord;
begin
  Token := '';
  while (TibPos <= length(tib)) and (tib[TibPos] <> ' ') do
  begin
    Token := Token + tib[TibPos];
    inc(TibPos);
  end;
end;

function TForthCompiler.Parse: boolean;
begin
  lastpos := TibPos;
  PassSpaces;
  CutWord;
  Result := Token <> '';
end;

function TForthCompiler.ParseToken: string;
begin
  Result := '';
  if not Parse then
  begin
    FError := erEoln;
    Exit;
  end;
  Result := Token;
end;

function TForthCompiler.ParseInt: integer;
begin
  Result := -1;
  ParseToken;
  if LastError <> 0 then
    Exit;
  Result := Number(Token);
end;

function TForthCompiler.ParseHex: integer;
var
  StoreBase: integer;
begin
  StoreBase := Base;
  Base := 16;
  try
    Result := ParseInt;
  finally
    Base := StoreBase;
  end;
end;

procedure TForthCompiler.ForthVarChange;
var
  id: integer;
  _var: ^integer;
  value: integer;
begin
  id := Find(Token);
  _var := pointer(Dict[id].tag);
  value := ParseInt;
  if LastError <> 0 then Exit;
  _var^ := value;
end;

procedure TForthCompiler.AddWord(name: string; comment: string; proc: TProc; tag: integer; immediate: boolean);
begin
  Dict[WordCount].name := name;
  Dict[WordCount].comment := comment;
  Dict[WordCount].proc := proc;
  Dict[WordCount].tag := tag;
  Dict[WordCount].immediate := immediate;
  inc(WordCount);
end;

procedure TForthCompiler.AddImmWord(name: string; proc: TProc);
begin
  AddWord(name, 'immediate', proc, 0, true);
  AddSynlightWord(name, tokImmediate);
end;

procedure TForthCompiler.AddForthWord(name: string; tag: integer);
begin
  AddWord(name, 'forth word', nil, tag, false);
end;

procedure TForthCompiler.AddCommentedForthWord(name, comment: string;
  tag: integer);
begin
  AddWord(name, comment, nil, tag, false);
end;

procedure TForthCompiler.AddVarChange(name: string; _var: pointer);
begin
  AddWord(name, 'var change', ForthVarChange, integer(_var), true);
  AddSynlightWord(name, tokDict);
end;

procedure TForthCompiler.ForthCreate;
begin
  ParseToken;
  AddCommentedForthWord(Token, Tib, CallMask + CP);
  AddSynlightWord(token, tokDict);
end;

procedure TForthCompiler.ForthVARIABLE;
begin
  ParseToken;
  AddCommentedForthWord(Token, Tib, ShortLitMask + DP);
  AddSynlightWord(token, tokVar);
  Inc(DP);
end;

procedure TForthCompiler.ForthARRAY;
var
  ArraySize, Err : integer;
begin
  ParseToken;
  AddCommentedForthWord(Token, Tib, ShortLitMask + DP);
  AddSynlightWord(token, tokVar);
  ParseInt;
  Val(Token, ArraySize, Err);
  if Err <> 0 then
    FError := erNotFound
  else
    Inc(DP, ArraySize);
end;

procedure TForthCompiler.ForthString;
var
  str: string;
  i: integer;
  addr: integer;
begin
  PassSpaces;
  str := '';
  while (TibPos <= length(tib)) and (Tib[TibPos] <> '"') do
  begin
    str := str + tib[TibPos];
    inc(TibPos);
  end;
  inc(TibPos);
  addr := DP;
  for i := 1 to length(str) do
    CompileData(ord(str[i]));
  CompileData(0);
  CompileLiteral(addr);
end;

procedure TForthCompiler.ForthUSE;
var
  id: integer;
  addr: integer;
begin
  Parse;
  id := Find(Token);
  addr := Dict[id].tag - CallMask;
  CompileLiteral(addr);
end;

procedure TForthCompiler.ForthNewMain;
var
  id: integer;
begin
  id := Find('[C]!');
  if id = -1 then
  begin
    MessageBox(0, 'Не существует команды записи в память кода [C]!'+#13#10
               +'Слово NewMAIN: не было выполнено', MsgTitle, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  CompileLiteral(CP + JmpMask + 3);
  CompileLiteral(0);
  Compile(Dict[id].tag);
end;

procedure TForthCompiler.EndCompile;
begin
  if HereCodePosition <> -1 then
    CompileHereWrite;
  if CHereCodePosition <> -1 then
    CompileCHereWrite;
end;


procedure TForthCompiler.BeginOptimize;
var
  i: integer;
begin
  for i := 0 to MaxCode - 1 do
    usesCode[i] := 0;
end;

function TForthCompiler.isCall(n: integer): boolean;
begin
  Result := (n >= $C000) and (n < $10000);
end;

function TForthCompiler.isIf(n: integer): boolean;
begin
  Result := (n >= $8000) and (n < $C000);
end;

function TForthCompiler.isJmp(n: integer): boolean;
begin
  Result := (n >= $4000) and (n < $10000);
end;

var
  isOptError: boolean;
procedure TForthCompiler.AddUsesCode(ip: integer);
begin
  if usesCode[ip] > 0 then Exit;
  usesCode[ip] := usesCode[ip] + 1;
  isOptError := true;
end;

procedure TForthCompiler.Optimize;
var
  i: integer;
begin
  BeginOptimize;
  usesCode[0] := 1;
  repeat
    isOptError := false;
    for i := 0 to CP-1 do
    begin
      if usesCode[i] = 0 then continue;
      if FCode[i] = 32 then continue;
      if isCall(FCode[i]) or isIf(FCode[i]) then
      begin
        AddUsesCode(FCode[i] and $3FFF);
        AddUsesCode(i + 1);
      end
      else if isJmp(FCode[i]) then
      begin
        AddUsesCode(FCode[i] and $3FFF);
      end
      else
        AddUsesCode(i + 1);
    end;
  until not isOptError;
  EndOptimize;
end;

procedure TForthCompiler.EndOptimize;
var
  i, j: integer;
begin
  for i := CP - 1 downto 7 do
  begin
    if usesCode[i] > 0 then continue;
    for j := i to CP - 2 do
      FCode[j] := FCode[j+1];
    FCode[CP-1] := 0; // nop
    dec(CP);
    for j := 0 to CP - 1 do
    begin
      if isJmp(FCode[j]) and ((FCode[j] and $3FFF) > i) then // переход
        FCode[j] := (FCode[j] and $C000) or ((FCode[j] and $3FFF) - 1); // уменьшение адреса на 1
    end;
    if CHereCodePosition > i then dec(CHereCodePosition);
    if HereCodePosition > i then dec(HereCodePosition);
  end;

  if HereCodePosition <> -1 then
    CompileHereWrite;
  if CHereCodePosition <> -1 then
    CompileCHereWrite;
end;

{ TForthTC }

procedure TForthCompiler.BeginCompile;
begin
  CP := 7;
  TCP := 0;
  DP := 0;
  ElsifTop := 0;
  LP := 0;
  Base := 10;

  FLineNumber := 0;
  HereCodePosition := -1;
  CHereCodePosition := -1;

  FError := 0;

  WordCount := HardwiredWordCount;
  SynLightWords.Clear;
  SynLightWords.AddStrings(HardwiredWords);
end;

function TForthCompiler.Code(pos: integer): integer;
begin
  Result := FCode[pos];
end;

function TForthCompiler.CodeCount: integer;
begin
  Result := CP;
end;

constructor TForthCompiler.Create;
begin
  inherited;
  HardwiredWords := TStringList.Create;
end;

function TForthCompiler.Data(pos: integer): integer;
begin
  Result := FData[pos];
end;

function TForthCompiler.DataCount: integer;
begin
  Result := DP;
end;

destructor TForthCompiler.Destroy;
begin
  HardwiredWords.Destroy;
  inherited;
end;

function TForthCompiler.FindWord(pos: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := WordCount-1 downto 0 do
    if (not Dict[i].Immediate) and ((Dict[i].tag) = pos) then
    begin
      Result := i;
      Exit;
    end;
end;

function TForthCompiler.Dizasm(cmd: integer): string;
var
  WordID: integer;
  WordS: string;
begin
  Result := 'Unknown';
  case cmd of
    $20: Result := 'RET';
    $30000..$3FFFF: Result := IntToHex(cmd and $FFFF, 0);
    $20000..$2FFFF: Result := 'H ' + IntToHex(cmd and $FFFF, 0);
    $10000..$1FFFF: Result := 'L ' + IntToHex(cmd and $FFFF, 0);
    $4000..$FFFF:
    begin
      WordID := FindWord(cmd);
      if WordID = -1 then
        WordS := IntToHex(cmd and $3FFF, 0)
      else
        WordS := Dict[WordID].Name;

      case cmd of
        $4000..$7FFF: Result := 'J ' + WordS;
        $8000..$BFFF: Result := 'I ' + WordS;
        $C000..$FFFF:
          if  WordID = -1 then
            Result := 'C ' + WordS
          else
            Result := WordS;
      end;
    end
    else
      WordID := FindWord(cmd);
      if WordID = -1 then
        WordS := IntToHex(cmd, 2)
      else
        WordS := Dict[WordID].Name;
      Result := WordS;
  end;
end;

procedure TForthCompiler.Evaluate(const s: string);
var
  Index : integer;
begin
  inc(FLineNumber);

  tib := s;
  FError := 0;
  TibPos := 1;
  while (LastError = 0) and Parse do
  begin
    Index := Find(Token);
    if Index = -1 then
      CompileLiteral(Number(Token))
    else
    begin
      if Dict[Index].Immediate then
        Dict[Index].proc
      else
        Compile(Dict[Index].tag)
    end;
  end;
end;

function TForthCompiler.LastError: integer;
begin
  Result := FError;
end;

function TForthCompiler.LastErrorMessage: string;
begin
  if (FError >= Low(ErrorMsg)) and (FError <= High(ErrorMsg)) then
    Result := ErrorMsg[FError]
  else
    Result := 'Unknown error';
end;

procedure TForthCompiler.LoadCommandSystem(fileName: string);
var
  f: TextFile;
  name: string;
  tag: integer;
begin
  if FileExists(fileName) then
  begin
    AssignFile(f, fileName);
    Reset(f);
    while not eof(f) do
    begin
      readln(f, name);
      if eof(f) then break;
      readln(f, tag);
      AddCommentedForthWord(name, 'command system word', tag);
      AddSynlightWord(name, tokAlfabet);
    end;
    CloseFile(f);
  end;
end;

function TForthCompiler.MaxCode: integer;
begin
  Result := UserMaxCode;
end;

function TForthCompiler.MaxData: integer;
begin
  Result := UserMaxData;
end;

procedure TForthCompiler.InitBasicCommands;
begin
  AddImmWord('CmdFile:', ForthCmdFile);
  AddImmWord('Cmd:',     ForthCmd);
  AddImmWord('IF',       ForthIF);
  AddImmWord('THEN',     ForthTHEN);
  AddImmWord(':',        ForthCreate);
  AddImmWord('MAIN:',    ForthMainDef);
  AddImmWord('ELSE',     ForthELSE);
  AddImmWord('ELSIF',    ForthELSIF);
  AddImmWord('BEGIN',    ForthBEGIN);
  AddImmWord('AGAIN',    ForthAGAIN);
  AddImmWord('UNTIL',    ForthUNTIL);
  AddImmWord('VARIABLE', ForthVARIABLE);
  AddImmWord('ARRAY',    ForthARRAY);
  AddImmWord('\',        ForthCommentLine);
  AddImmWord('//',       ForthCommentLine);
  AddImmWord('"',        ForthString);
  AddImmWord('''',       ForthUSE);
  AddImmWord('NewMAIN:', ForthNewMain);
  AddImmWord('{',        ForthInterpretCreate);
  AddForthWord('}', 32);

  AddVarChange('#MaxCode=', @UserMaxCode);
  AddVarChange('#MaxData=', @UserMaxData);
end;

procedure TForthCompiler.BeginInitCommandSystem;
begin
  WordCount := 0;
  SynLightWords.Clear;
  InitBasicCommands;
end;

procedure TForthCompiler.EndInitCommandSystem;
begin
  HardwiredWordCount := WordCount;
  HardwiredWords.AddStrings(SynLightWords);
end;

procedure TForthCompiler.ForthCmdFile;
var
  fileName: string;
begin
  PassSpaces;
  fileName := Copy(tib, tibPos, length(tib) - tibPos + 1);
  LoadCommandSystem(fileName);
  tibPos := length(tib) + 1;
end;

procedure TForthCompiler.ForthCmd;
var
  tokenStr: string;
  tokenInt: integer;
begin
  tokenStr := ParseToken;
  if LastError <> erOk then Exit;
  tokenInt := ParseInt;
  if LastError <> erOk then Exit;
  AddCommentedForthWord(tokenStr, 'user command', tokenInt);
  AddSynlightWord(tokenStr, tokAlfaBet);
end;

function TForthCompiler.GetCHerePosition: integer;
var
  id: integer;
begin
  Result := -1;
  id := Find('[C]HERE');
  if id = -1 then Exit;
  Result := Dict[id].tag - ShortLitMask;
end;

function TForthCompiler.GetHerePosition: integer;
var
  id: integer;
begin
  Result := -1;
  id := Find('HERE');
  if id = -1 then Exit;
  Result := Dict[id].tag - ShortLitMask;
end;

function TForthCompiler.LastToken: string;
begin
  Result := Token;
end;

function TForthCompiler.GetTokenComment(token: string): string;
var
  index: integer;
begin
  index := Find(token);
  if index = -1 then
    Result := 'word not found'
  else
    Result := Dict[index].comment;
end;

function TForthCompiler.NewFileText: string;
begin
  Result := 'CmdFile: kf332.cmd' +#13#10
    + '#CORE A         // запись программы в выбранный процессор' +#13#10
    + '#COM 1          // по нужному COM-порту' +#13#10
    + '#PACKSIZE= 16   // пакетами по PACKSIZE байт' +#13#10
    + '#WAITCOEF= 2    // с задержкой, вычисляемой по формуле' +#13#10
    + '                // (PackSize * 8 / BaudRate) * WaitCoef секунд' +#13#10
    + '// Если программа не зашивается, попробуйте уменьшить размер пакетов' +#13#10
    + '// и увеличить задержку' +#13#10
    + '#MaxCode= 8192 // Размер памяти кода' +#13#10
    + '#MaxData= 4096 // Размер памяти данных' +#13#10
    + '' +#13#10
    + 'MAIN:';
end;

function TForthCompiler.GetCmdColor(cmd: integer): cardinal;
begin
  case cmd of
    $20: // ret
      Result := $00B0FF;
    $4000..$7FFF: // jmp
      Result := $2090FF;
    $8000..$BFFF: // if
      Result := $4070FF;
    $C000..$FFFF: // call
      Result := $6050FF;
    $10000..$1FFFF: // number
      Result := $FF2090;
    $20000..$2FFFF:
      Result := $FF4070;
    $30000..$3FFFF:
      Result := $FF6050;
    else
      Result := $000000;
  end;
end;

initialization

end.
