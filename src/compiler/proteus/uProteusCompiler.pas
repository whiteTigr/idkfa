unit uProteusCompiler;

interface

uses
  Windows, SysUtils, uGlobal, uProteusDeviceCore, uCommonFunctions, Classes,
  uCompilerCore, StrUtils;

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
    name : string[255];
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

  TProteusCompiler = class(TTargetCompiler)
  private
    Parser: TParserCore;

    FCode: PCodeArray;
    CodeSize: integer;
    CP: integer;

    FTempCode: PCodeArray;
    TempCodeSize: integer;
    TCP: integer;

    // todo: сделать загрузку служебного кода. upd: и что € тут имел в виду?
    FServiceCode: PCodeArray;
    ServiceCodeSize: integer;
    SCP: integer;

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

    HardwiredWords: TStringList;
    HardwiredWordsCount: integer;
    UserMaxCode: integer;
    UserMaxData: integer;

    LastNumber: integer;
    LastNumberSize: integer;

    LastString: string;

    procedure Compile(code: integer; ToTempCode: boolean = false); overload;
    procedure Compile(code: array of integer; ToTempCode: boolean = false); overload;
    procedure CompileTo(position: integer; value: integer);
    procedure CompileRJmpTo(position: integer; _value: integer);
    procedure CompileNumber(_value: integer; ToTempCode: boolean = false);
    function  CompileNumberTo(position: integer; _value: integer): integer;

    procedure ReserveCodeForJump;
    procedure ReserveCodeForNumber(_value: integer);
    procedure CopyTempCode;

    procedure AddNopAfterLiteral(ToTempCode: boolean = false);
    procedure AddReference(source: integer; RefCommands: array of integer);

    function ControlPop: TControlStackCell;
    procedure ControlPush(value: TControlStackCell);
    function ControlReadTop: TControlStackCell;

    procedure Error(code: integer);
    function GetErrorMessage: string;

    procedure MemoryAlloc(CellsCount, CellSize: integer;
      var dest: pointer; var newSizeVariable: integer);
    procedure SetCodeSize(newSize: integer);
    procedure SetDataSize(newSize: integer);
    procedure SetControlStackSize(newSize: integer);
    procedure SetVocabularySize(newSize: integer);

    procedure InitBasicCommands;
    procedure FindToken; overload;
    function FindToken(const name: string): integer; overload;
    procedure ClearVocabulary;

    procedure TryDispatchNumber;

    function LastCmd(InTempCode: boolean = false): integer;
    function CmdIsLiteral(cmd: integer): boolean;
    function LastCmdIsLiteral(InTempCode: boolean = false): boolean;

    function FindWord(tag: integer): integer;

    procedure WritePredefinedVariables;

    procedure DeleteCode(fromPos, toPos: integer);
    procedure CorrectJumps(delPos, delCount: integer);
    function FindJump(from: integer): integer;
    function GetLiteralPos(from: integer): integer;
    function GetLiteralValue(from: integer): integer;
    function GetLiteralSize(from: integer): integer;
    function GetNopCount(from, _to: integer): integer;
    procedure ClearJumps;


    procedure _Comment;
    procedure _IF;
    procedure _ELSE;
    procedure _THEN;
    procedure _MainDef;
    procedure _BEGIN;
    procedure _AGAIN;
    procedure _UNTIL;
    procedure _WHILE;
    procedure _REPEAT;
    procedure _CREATE;
    procedure _CompileCall;
    procedure _CompileInline;
    procedure _VARIABLE;
    procedure _ARRAY;
    procedure _VariableProc;
    procedure _VarChange;
    procedure _Cmd2;
    procedure _Cmd3;
    procedure _Loop;
    procedure _AddCmd;
    procedure _Inline;
    procedure _LoadFile;
    procedure _Interpret;
    procedure _Z;
    procedure _String;
  public
    procedure BeginInitCommandSystem;
    procedure EndInitCommandSystem;
    procedure AddToken(value: TTokenWord);
    procedure AddImmToken(name: string; proc: TProc; tag: integer = 0);
    procedure AddForthToken(name: string; tag: integer);
    procedure AddCmd2Token(name: string; tag: integer);
    procedure AddCmd3Token(name: string; tag: integer);
    procedure AddVarChange(name: string; _var: pointer);

    function Code(pos: integer): integer; override;
    function CodeCount: integer; override;
    function MaxCode: integer; override;

    function Data(pos: integer): integer; override;
    function DataCount: integer; override;
    function MaxData: integer; override;

    function Dizasm(cmd: integer): string; override;
    function GetCmdColor(cmd: integer): cardinal; override;

    procedure Evaluate(const tib: string); override;
    procedure BeginCompile; override;
    procedure EndCompile; override;

    function LastError: integer; override;
    function LastToken: string; override;
    function LastErrorMessage: string; override;

    constructor Create;
    destructor Destroy; override;

    function NewFileText: string; override;
    procedure Optimize; override;

    function ParseToken: string;
    function ParseInt: integer;
  end;

const
  UNEXCEPTED_EOLN = 'Ќе ожидаемый конец строки';

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

const
  PredefinedVariable: array[0..1] of string = ('HERE', '[C]HERE');

var
  PredefinedVariablePos: array[Low(PredefinedVariable)..High(PredefinedVariable)] of integer;

const
  sNone = 0;
  sIF = 1;
  sBEGIN = 2;
  sDO = 3;

  RJmpSize = 2;

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

{ TProteusCompiler }

procedure TProteusCompiler.Compile(code: integer; ToTempCode: boolean = false);
begin
  if ToTempCode then
  begin
    FTempCode[TCP].value := code;
    inc(TCP);
  end
  else
  begin
    FCode[CP].value := code;
    inc(CP);
  end;
end;

procedure TProteusCompiler.Compile(code: array of integer; ToTempCode: boolean = false);
var
  i: integer;
begin
  for i := Low(code) to High(code) do
    Compile(code[i], ToTempCode);
end;

procedure TProteusCompiler.CompileTo(position: integer; value: integer);
var
  storeCP: integer;
begin
  storeCP := CP;
  CP := position;
  Compile(value);
  CP := storeCP;
end;

procedure TProteusCompiler.CompileRJmpTo(position, _value: integer);
var
  i: integer;
  value: integer;
begin
  value := _value;
  for i := RJmpSize-1 downto 0 do
  begin
    CompileTo(position + i, cmdLIT + value and LitMask);
    value := shra(value, 5);
  end;
end;

procedure TProteusCompiler.CompileNumber(_value: integer; ToTempCode: boolean = false);
var
  value: integer;
  buffer: array[0..7] of integer;
  wrongPositive: boolean;
  wrongNegative: boolean;
  needCorrectSignExtention: boolean;
  i: integer;
begin
  value := _value;
  LastNumber := value;
  LastNumberSize := 0;

  repeat
    buffer[LastNumberSize] := cmdLIT or (value and LitMask);
    value := value shr 5; // shra(value, 5);
    inc(LastNumberSize);
  until (value = 0); // or (value = -1);

  wrongPositive := (_value > 0) and ((buffer[LastNumberSize-1] and NegativeBit) <> 0);
  wrongNegative := (_value < 0) and ((buffer[LastNumberSize-1] and NegativeBit) = 0);
  needCorrectSignExtention := wrongPositive or wrongNegative;
  if needCorrectSignExtention then
  begin
    buffer[LastNumberSize] := cmdLIT or (value and LitMask);
    inc(LastNumberSize);
  end;

  if LastCmdIsLiteral(ToTempCode) then
  begin
    buffer[LastNumberSize] := cmdNOP;
    inc(LastNumberSize);
  end;

  for i := LastNumberSize - 1 downto 0 do
    Compile(buffer[i], ToTempCode);
end;

procedure TProteusCompiler.ReserveCodeForNumber(_value: integer);
var
  storeCP: integer;
  i: integer;
begin
  storeCP := CP;
  CompileNumber(_value);
  for i := CP-1 downto storeCP do
    FCode[i].value := cmdNop;
end;

// на выходе позици€ CP _за_ скомпилированным числом
function TProteusCompiler.CompileNumberTo(position: integer; _value: integer): integer;
var
  storeCP: integer;
begin
  storeCP := CP;
  CP := position;
  CompileNumber(_value);
  Result := CP;
  CP := storeCP;
end;

procedure TProteusCompiler.ReserveCodeForJump;
begin
  ReserveCodeForNumber(integer($80000000));
  Compile(cmdNOP);
end;

procedure TProteusCompiler.CopyTempCode;
var
  i: integer;
begin
  for i := 0 to TCP - 1 do
    Compile(FTempCode[i].value);
end;

procedure TProteusCompiler.AddNopAfterLiteral(ToTempCode: boolean = false);
begin
  if LastCmdIsLiteral(ToTempCode) then
    Compile(cmdNOP, ToTempCode);
end;

procedure TProteusCompiler.AddReference(source: integer;
  RefCommands: array of integer);
var
  i: integer;
begin
  ControlPush(ControlStackCell(CP, source));
  for i := 0 to RJmpSize-1 do
    Compile(cmdNOP);
  Compile(RefCommands);
end;

function TProteusCompiler.ControlPop: TControlStackCell;
begin
  if ControlStackTop <= 0 then
  begin
    Error(errControlStackUnderflow);
    Exit;
  end;

  dec(ControlStackTop);
  Result := FControlStack[ControlStackTop];
end;

procedure TProteusCompiler.ControlPush(value: TControlStackCell);
begin
  if ControlStackTop >= ControlStackSize then
  begin
    Error(errControlStackOverflow);
    Exit;
  end;

  FControlStack[ControlStackTop] := value;
  inc(ControlStackTop);
end;

function TProteusCompiler.ControlReadTop: TControlStackCell;
begin
  if ControlStackTop <= 0 then
  begin
    Error(errControlStackUnderflow);
    Exit;
  end;

  Result := FControlStack[ControlStackTop-1];
end;

procedure TProteusCompiler.Error(code: integer);
begin
  FError := code;
end;

function TProteusCompiler.GetErrorMessage: string;
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

procedure TProteusCompiler.MemoryAlloc(CellsCount, CellSize: integer;
  var dest: pointer; var newSizeVariable: integer);
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

procedure TProteusCompiler.SetCodeSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TCodeCell), pointer(FCode), CodeSize);
  MemoryAlloc(newSize, sizeof(TCodeCell), pointer(FTempCode), TempCodeSize);
  MemoryAlloc(newSize, sizeof(TCodeCell), pointer(FServiceCode), ServiceCodeSize);
end;

procedure TProteusCompiler.SetControlStackSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TControlStackCell), pointer(FControlStack), ControlStackSize);
end;

procedure TProteusCompiler.SetDataSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TDataCell), pointer(FData), DataSize);
end;

procedure TProteusCompiler.SetVocabularySize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TTokenWord), pointer(FVocabulary), VocabularySize);
end;

procedure TProteusCompiler.AddToken(value: TTokenWord);
begin
  if VP >= VocabularySize then
  begin
    Error(errVocabularyIsFull);
    Exit;
  end;

  FVocabulary^[VP] := value;
  inc(VP);
end;

procedure TProteusCompiler.AddImmToken(name: string; proc: TProc; tag: integer = 0);
begin
  AddToken(TokenWord(name, tag, true, proc));
  AddSynlightWord(name, tokImmediate);
end;

procedure TProteusCompiler.AddForthToken(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, false, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TProteusCompiler.AddCmd2Token(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, true, _Cmd2));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TProteusCompiler.AddCmd3Token(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, true, _Cmd3));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TProteusCompiler.AddVarChange(name: string; _var: pointer);
begin
  AddToken(TokenWord(name, integer(_var), true, _VarChange));
  AddSynlightWord(name, tokDict);
end;

procedure TProteusCompiler.InitBasicCommands;
begin
  AddForthToken('NOP', cmdNOP);
  AddForthToken('NOT', cmdNOT);
  AddCmd2Token ('@', cmdFETCH);
  AddForthToken('SHL', cmdSHL);
  AddForthToken('SHR', cmdSHR);
  AddForthToken('SHRA', cmdSHRA);
  AddCmd2Token ('INPORT', cmdINPORT);
  AddForthToken('SWAP', cmdSWAP);
  AddForthToken('DUP', cmdDUP);
  AddForthToken('OVER', cmdOVER);
  AddForthToken('R>', cmdFROMR);
  AddImmToken  ('LOOP', _Loop, cmdLoop);
  AddForthToken('SYSREG@', cmdSYSREG);
  AddForthToken('+', cmdPLUS);
  AddForthToken('-', cmdMINUS);
  AddForthToken('AND', cmdAND);
  AddForthToken('OR', cmdOR);
  AddForthToken('XOR', cmdXOR);
  AddForthToken('=', cmdEQUAL);
  AddForthToken('<', cmdLESSER);
  AddForthToken('>', cmdGREATER);
  AddCmd3Token ('*', cmdMULT);
  AddForthToken('DROP', cmdDROP);
  AddForthToken('JMP', cmdJMP);
  AddForthToken('CALL', cmdCALL);
  AddForthToken('RJMP', cmdRJMP);
  AddForthToken('>R', cmdTOR);
  AddForthToken('OUTPORT', cmdSTORE);
  AddForthToken('!', cmdSTORE);
  AddForthToken('DO', cmdDO);
  AddForthToken('RIF', cmdRIF);
  AddForthToken('UNTIL', cmdUNTIL);
  AddForthToken(';', cmdRET);
  AddForthToken('EXIT', cmdRET);
  AddForthToken('RET', cmdRET);

  AddImmToken('//', _Comment);
  AddImmToken('\', _Comment);
  AddImmToken('IF', _IF);
  AddImmToken('ELSE', _ELSE);
  AddImmToken('THEN', _THEN);
  AddImmToken('MAIN:', _MainDef);
  AddImmToken('BEGIN', _Begin);
  AddImmToken('AGAIN', _Again);
  AddImmToken('WHILE', _While);
  AddImmToken('REPEAT', _Repeat);
  AddImmToken('UNTIL', _Until);
  AddImmToken(':', _Create);
  AddImmToken('VARIABLE', _Variable);
  AddImmToken('ARRAY', _Array);
  AddImmToken('CMD', _AddCmd);
  AddImmToken('INLINE', _Inline);
  AddImmToken('L', _LoadFile);
  AddImmToken(',Z', _Z);

  AddImmToken('{', _Interpret);
  AddForthToken('}', cmdRET);

  AddImmToken('"', _String);

  AddVarChange('#MaxCode=', @UserMaxCode);
  AddVarChange('#MaxData=', @UserMaxData);
end;

procedure TProteusCompiler.BeginInitCommandSystem;
begin
  VP := 0;
  SynLightWords.Clear;
  InitBasicCommands;
end;

procedure TProteusCompiler.EndInitCommandSystem;
begin
  HardwiredWordsCount := VP;
  HardwiredWords.AddStrings(SynLightWords);
end;

procedure TProteusCompiler.FindToken;
begin
  TokenID := FindToken(Parser.token);
  if TokenID <> -1 then
    Token := @FVocabulary[TokenID]
  else
    Token := nil;
end;

function TProteusCompiler.FindToken(const name: string): integer;
var
  i: integer;
begin
  for i := VP-1 downto 0 do
    if FVocabulary[i].name = ShortString(name) then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

procedure TProteusCompiler.ClearVocabulary;
begin
  VP := 0;
end;

procedure TProteusCompiler.TryDispatchNumber;
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

procedure TProteusCompiler.WritePredefinedVariables;
begin
  if FindToken('HERE') <> -1 then CompileNumberTo(PredefinedVariablePos[0], DP);
  if FindToken('[C]HERE') <> -1 then CompileNumberTo(PredefinedVariablePos[1], CP);
end;

function TProteusCompiler.LastCmd(InTempCode: boolean = false): integer;
begin
  if InTempCode then
  begin
    if TCP > 0 then
      Result := FTempCode[TCP-1].value
    else
      Result := cmdNOP;
  end
  else
  begin
    if CP > 0 then
      Result := FCode[CP-1].value
    else
      Result := cmdNOP;
  end;
end;

function TProteusCompiler.CmdIsLiteral(cmd: integer): boolean;
begin
  Result := (cmd and cmdLIT) <> 0;
end;

function TProteusCompiler.LastCmdIsLiteral(InTempCode: boolean = false): boolean;
begin
  Result := CmdIsLiteral(LastCmd(InTempCode));
end;

function TProteusCompiler.FindWord(tag: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := HardwiredWordsCount-1 downto 0 do
    if (FVocabulary[i].tag = tag) then
    begin
      Result := i;
      Exit;
    end;
end;

procedure TProteusCompiler.DeleteCode(fromPos, toPos: integer);
var
  deletedCount: integer;
  i: integer;
begin
  Assert(fromPos <= toPos);
  deletedCount := toPos - fromPos + 1;
  dec(CP, deletedCount);

  for i := fromPos to CP - 1 do
    FCode[i] := FCode[i + deletedCount];
  for i := CP to CP + deletedCount - 1 do
    FCode[i].value := cmdNOP;

  CorrectJumps(fromPos, deletedCount);
end;

procedure TProteusCompiler.CorrectJumps(delPos, delCount: integer);
var
  pos: integer;
  jmpPos: integer;
  cmd: integer;
  LitPos: integer;
  LitValue: integer;
  LitSize, NewLitSize: integer;
  i: integer;
  jmpBelowDelpos: boolean;
  rjmpThroughDelpos: boolean;
  needJmpCorrect: boolean;
begin
  pos := 0;
  while (pos < CP) do
  begin
    jmpPos := FindJump(pos);
    if jmpPos = -1 then
      break;

    cmd := Code(jmpPos);
    LitPos := GetLiteralPos(jmpPos);
    LitValue := GetLiteralValue(LitPos);
    LitSize := GetLiteralSize(LitPos);

    jmpBelowDelPos := false;
    if (cmd in AbsoluteJmpCommands) then
      jmpBelowDelpos := (LitValue > delPos);

    rjmpThroughDelpos := false;
    if (cmd in RelativeJmpCommands) then
    begin
      if jmpPos < delPos then
        rjmpThroughDelpos := (jmpPos + LitValue >= (DelPos + DelCount))
      else if jmpPos >= delPos + DelCount then
        rjmpThroughDelpos := (jmpPos + LitValue < DelPos);
    end;

    needJmpCorrect := jmpBelowDelpos or rjmpThroughDelpos;

    if needJmpCorrect then
    begin
      LitValue := LitValue - delCount;
      CompileNumberTo(LitPos, LitValue);
      NewLitSize := LastNumberSize;
      for i := NewLitSize to LitSize-1 do
        CompileTo(LitPos + i, cmdNOP);
    end;
    pos := jmpPos + 1;
  end;
end;

function TProteusCompiler.FindJump(from: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := from to CP-1 do
    if Code(i) in JmpCommands then
    begin
      Result := i;
      Exit;
    end;
end;

function TProteusCompiler.GetLiteralPos(from: integer): integer;
var
  pos: integer;
begin
  pos := from;

  while (pos >= 0) and (not CmdIsLiteral(FCode[pos].value)) do
    dec(pos);
  while (pos >= 0) and (CmdIsLiteral(FCode[pos].value)) do
    dec(pos);

  Result := pos + 1;
end;

function TProteusCompiler.GetLiteralValue(from: integer): integer;
var
  pos: integer;
  cmd: integer;
  value: integer;
  firstPart: boolean;
  ValueIsNegative: boolean;
begin
  pos := from;
  value := 0;
  firstPart := true;

  while (pos < CP) do
  begin
    cmd := FCode[pos].value;
    if not CmdIsLiteral(cmd) then
      break;

    value := (value shl 5) or (cmd and LitMask);

    if firstPart then
    begin
      firstPart := false;
      ValueIsNegative := (cmd and NegativeBit) <> 0;
      if ValueIsNegative then
        value := value or (not LitMask);
    end;

    inc(pos);
  end;

  Result := value;
end;

function TProteusCompiler.GetLiteralSize(from: integer): integer;
var
  pos: integer;
  cmd: integer;
  size: integer;
begin
  pos := from;
  size := 0;

  while (pos < CP) do
  begin
    cmd := FCode[pos].value;
    if not CmdIsLiteral(cmd) then
      break;
    inc(size);
    inc(pos);
  end;

  Result := size;
end;

function TProteusCompiler.GetNopCount(from, _to: integer): integer;
var
  i: integer;
  count: integer;
begin
  count := 0;
  for i := from to _to do
    if FCode[i].value = cmdNOP then
      inc(count);
  Result := count;
end;

procedure TProteusCompiler.ClearJumps;
var
  hasError: boolean;
  pos: integer;
  litPos: integer;
  nopCount: integer;
begin
  repeat
    pos := 0;
    hasError := false;
    while pos < CP do
    begin
      pos := FindJump(pos);
      if pos = -1 then
        break;
      litPos := GetLiteralPos(pos);
      nopCount := GetNopCount(litPos, pos);
      inc(pos);
      if nopCount = 0 then
        continue;
      while FCode[litPos].value <> cmdNop do
        inc(litPos);
      DeleteCode(litPos, litPos + nopCount - 1);
      hasError := true;
    end;
  until not hasError;
end;

procedure TProteusCompiler._Comment;
begin
  Parser.tib := '';
end;

procedure TProteusCompiler._IF;
begin
  AddNopAfterLiteral;
  AddReference(sIf, [cmdRIF]);
end;

procedure TProteusCompiler._ELSE;
var
  ref: TControlStackCell;
begin
  ref := ControlPop;
  if (ref.Source <> sIF) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  AddNopAfterLiteral;
  AddReference(sIf, [cmdRJMP]);
  CompileRJmpTo(ref.Addr, CP - ref.Addr - RJmpSize);
end;

procedure TProteusCompiler._THEN;
var
  ref: TControlStackCell;
begin
  ref := ControlPop;
  if (ref.Source <> sIF) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  CompileRJmpTo(ref.Addr, CP - ref.Addr - RJmpSize)
end;

procedure TProteusCompiler._MainDef;
var
  _CP: integer;
  i: integer;
  tmp: integer;
begin
  _CP := CompileNumberTo(0, CP);
  CompileTo(_CP, cmdJMP);

  for i := Low(PredefinedVariable) to High(PredefinedVariable) do
  begin
    tmp := FindToken(PredefinedVariable[i]);
    if tmp <> -1 then
    begin
      PredefinedVariablePos[i] := CP;
      ReserveCodeForNumber(integer($80000000)); // reserve code for max number
      Compile(cmdNOP);
      CompileNumber(FVocabulary[tmp].tag);
      Compile(cmdStore);
    end;
  end;

  CopyTempCode;
end;

procedure TProteusCompiler._BEGIN;
begin
  AddNopAfterLiteral;
  ControlPush(ControlStackCell(CP, sBegin));
end;

procedure TProteusCompiler._AGAIN;
var
  ref: TControlStackCell;
begin
  ref := ControlPop;
  if (ref.Source <> sBegin) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  CompileNumber(ref.Addr);
  Compile(cmdJMP);
end;

procedure TProteusCompiler._UNTIL;
var
  ref: TControlStackCell;
begin
  ref := ControlPop;
  if (ref.Source <> sBegin) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  AddNopAfterLiteral;
  CompileRJmpTo(CP, CP + RJmpSize - ref.Addr);
  inc(CP, 2);
  Compile(cmdUNTIL);
end;

procedure TProteusCompiler._WHILE;
begin
  if (ControlReadTop.Source <> sBegin) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  _IF;
end;

procedure TProteusCompiler._REPEAT;
var
  ref: TControlStackCell;
begin
  ref := ControlPop;
  if (ref.Source <> sIf) or (ControlReadTop.Source <> sBegin) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  _AGAIN;
  ControlPush(ref);
  _THEN;
end;

procedure TProteusCompiler._String;
var
  addr: integer;
begin
  with Parser do
  begin
    addr := DP;
    LastString := '';
    repeat
      CompileNumber(integer(tib[tibPos]), true);
      CompileNumber(DP, true);
      Compile(cmdSTORE, true);
      inc(DP);
      LastString := LastString + tib[tibPos];
    until (not IncTibPos) or (tib[tibPos] = '"');
    CompileNumber(0, true);
    CompileNumber(DP, true);
    Compile(cmdSTORE, true);
    inc(DP);
    IncTibPos;

    CompileNumber(addr);
  end;
end;

procedure TProteusCompiler._Create;
begin
  ParseToken;
  AddToken(TokenWord(Parser.token, CP, true, _CompileCall));
  AddSynlightWord(Parser.token, tokDict);
end;

procedure TProteusCompiler._CompileCall;
begin
  CompileNumber(Token.tag);
  Compile(cmdCALL);
end;

procedure TProteusCompiler._CompileInline;
var
  i: integer;
begin
  i := Token.tag;
  if ((Code(i) and cmdLIT) <> 0) and ((Code(CP-1) and cmdLIT) <> 0) then
    Compile(cmdNOP);

  while Code(i) <> cmdRET do
  begin
    Compile(Code(i));
    inc(i);
  end;
end;

procedure TProteusCompiler._VARIABLE;
begin
  ParseToken;
  AddToken(TokenWord(Parser.token, DP, true, _VariableProc));
  AddSynlightWord(Parser.token, tokVar);
  inc(DP);
end;

procedure TProteusCompiler._ARRAY;
var
  name: string;
  size: integer;
begin
  name := ParseToken;
  size := ParseInt;
  AddToken(TokenWord(name, DP, true, _VariableProc));
  AddSynlightWord(name, tokVar);
  inc(DP, size);
end;

procedure TProteusCompiler._VariableProc;
begin
  CompileNumber(Token.tag);
end;

procedure TProteusCompiler._VarChange;
var
  newValue: integer;
  pint: ^integer;
begin
  newValue := ParseInt;
  pint := pointer(Token.tag);
  pint^ := newValue;
end;

procedure TProteusCompiler._Cmd2;
begin
  Compile(cmdNOP);
  Compile(Token.tag);
end;

procedure TProteusCompiler._Cmd3;
begin
  Compile([cmdNOP, cmdNOP]);
  Compile(Token.tag);
end;

procedure TProteusCompiler._Loop;
begin
  Compile([cmdLOOP, cmdNOP]);
end;

procedure TProteusCompiler._AddCmd;
var
  name: string;
  value: integer;
begin
  name := ParseToken;
  value := ParseInt;
  AddForthToken(name, value);
end;

procedure TProteusCompiler._Inline;
begin
  FVocabulary[VP-1].proc := _CompileInline;
end;

procedure TProteusCompiler._LoadFile;
var
  inputFile: TextFile;
  fileName: string;
  str: string;
begin
  fileName := LastString;

  if uGlobal.FilePath <> '' then
  begin
    str := FilePath + fileName;
    if not FileExists(str) then
      str := '';
  end
  else
    str := '';

  if str = '' then
    str := ExePath + fileName;

  AssignFile(inputFile, str);
  Reset(inputFile);
  while not EoF(inputFile) and (LastError = 0) do
  begin
    readln(inputFile, str);
    Evaluate(str);
  end;
  CloseFile(inputFile);
end;

procedure TProteusCompiler._Interpret;
begin
  CompileNumber(CP, true);
  Compile(cmdCALL, true);
end;

procedure TProteusCompiler._Z;
begin
  dec(CP, LastNumberSize);
  Compile(LastNumber and $3F);
end;

function TProteusCompiler.GetCmdColor(cmd: integer): cardinal;
begin
  case cmd of
    cmdNOP:
      Result := $C0C0C0;
    cmdRET:
      Result := $00B0FF;
    cmdJMP, cmdRJMP:
      Result := $2090FF;
    cmdRIF:
      Result := $4070FF;
    cmdCALL:
      Result := $6050FF;
    $20..$3F: // number
      Result := $FF6050;
    else
      Result := $000000;
  end;
end;

procedure TProteusCompiler.Evaluate(const tib: string);
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

function TProteusCompiler.Code(pos: integer): integer;
begin
  if FCode <> nil then
    Result := FCode[pos].value
  else
    Result := -1;
end;

function TProteusCompiler.CodeCount: integer;
begin
  Result := CP;
end;

function TProteusCompiler.MaxCode: integer;
begin
  Result := UserMaxCode;
end;

function TProteusCompiler.Data(pos: integer): integer;
begin
  if FData <> nil then
    Result := FData[pos].value
  else
    Result := -1;
end;

function TProteusCompiler.DataCount: integer;
begin
  Result := DP;
end;

function TProteusCompiler.MaxData: integer;
begin
  Result := UserMaxData;
end;

constructor TProteusCompiler.Create;
begin
  inherited Create;

  Parser := TParserCore.Create;
  SetCodeSize(defaultCodeSize);
  SetDataSize(defaultDataSize);
  SetControlStackSize(defaultControlStackSize);
  SetVocabularySize(defaultVocabularySize);

  HardwiredWords := TStringList.Create;
  Parser.separators := ' ';
end;

destructor TProteusCompiler.Destroy;
begin
  HardwiredWords.Free;
  inherited;
end;


function TProteusCompiler.Dizasm(cmd: integer): string;
var
  WordID: integer;
  WordS: string;
begin
  Result := 'Unknown';
  case cmd of
    cmdNOP: Result := 'NOP';
    cmdRET: Result := 'RET';
    $20..$3F: Result := IntToHex(cmd and LitMask, 0);
    else
      WordID := FindWord(cmd);
      if WordID = -1 then
        WordS := '$' + IntToHex(cmd, 2)
      else
        WordS := string(FVocabulary[WordID].name);
      Result := WordS;
  end;
end;

procedure TProteusCompiler.BeginCompile;
begin
  inherited;

  FError := 0;
  LineCount := 0;

  TCP := 0;
  CP := 0;
  DP := 0;
  ControlStackTop := 0;
  VP := HardwiredWordsCount;
  SynLightWords.Clear;
  SynLightWords.AddStrings(HardwiredWords);

  UserMaxCode := CodeSize;
  UserMaxData := DataSize;

  ReserveCodeForJump;
end;

procedure TProteusCompiler.EndCompile;
begin
  WritePredefinedVariables;
  Compiled := FError = 0;
end;

function TProteusCompiler.LastError: integer;
begin
  Result := FError;
end;

function TProteusCompiler.LastErrorMessage: string;
begin
  Result := GetErrorMessage;
end;

function TProteusCompiler.LastToken: string;
begin
  Result := Parser.token;
end;

function TProteusCompiler.ParseToken: string;
begin
  if not Parser.NextWord then
    raise Exception.Create(UNEXCEPTED_EOLN);

  Result := Parser.token;
end;

function TProteusCompiler.ParseInt: integer;
begin
  Result := StrToInt(ParseToken);
end;

function TProteusCompiler.NewFileText: string;
begin
  Result := '// for Proteus compiler' +#13#10
    + '                // «апись программы' +#13#10
    + '#COM 1          // по нужному COM-порту' +#13#10
    + '#PACKSIZE= 1    // пакетами по PACKSIZE байт' +#13#10
    + '#WAITCOEF= 2    // с задержкой, вычисл€емой по формуле' +#13#10
    + '                // (PackSize * 8 / BaudRate) * WaitCoef секунд' +#13#10
    + '// ≈сли программа не зашиваетс€, попробуйте уменьшить размер пакетов' +#13#10
    + '// и увеличить задержку' +#13#10
    + '' +#13#10
    + '// подгрузка библиотек' +#13#10
    + '// " proteus.lib" L' +#13#10
    + '' +#13#10
    + 'MAIN:' +#13#10
    + '' +#13#10
    + 'BEGIN' +#13#10
    + '' +#13#10
    + 'AGAIN';
end;

procedure TProteusCompiler.Optimize;
begin
  ClearJumps;
end;

end.
