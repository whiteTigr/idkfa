unit uProteusCompiler;

interface

uses
  Windows, SysUtils, uGlobal, uProteusDeviceCore, uCommonFunctions, Classes,
  uCompilerCore, StrUtils, math;

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
    controlDepth: integer;
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
    name: string[255];
    tag: integer;
    immediate: boolean;
    proc: TProc;
    memory: pointer;
  end;
  PVocabulary = ^TVocabulary;
  TVocabulary = array[0..MaxVocabulary-1] of TTokenWord;

  TControlStackCell = record
    Addr : integer;
    Source : integer;
  end;
  PControlStack = ^TControlStack;
  TControlStack = array[0..MaxControlStackSize-1] of TControlStackCell;

  PStructCell = ^TStructCell;
  TStructCell = record
    name: string[255];
    size: integer;
    root: boolean;
    nested: PStructCell;
    next: PStructCell;
  end;

  TProteusCompiler = class(TTargetCompiler)
  private
    Parser: TParserCore;

    State: integer;

    FCode: PCodeArray;
    CodeSize: integer;
    CP: integer;

    FTempCode: PCodeArray;
    TempCodeSize: integer;
    TCP: integer;

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
    ErrorComment: string;

    LineCount: integer;
    Compiled: boolean;

    HardwiredWords: TStringList;
    HardwiredWordsCount: integer;
    HardwiredCodeCount: integer;
    HardwiredDataCount: integer;
    UserMaxCode: integer;
    UserMaxData: integer;

    LastNumber: integer;
    LastNumberSize: integer;

    LastString: string;
    LastStringTempCodeSize: integer;
    LastStringCodeSize: integer;
    LastStringDataSize: integer;

    FHere: integer;
    FCHere: integer;

    isStructure: boolean;
    StructureName: string[255];
    StructureRoot: PStructCell;
    StructureOffset: integer;
    StructurePrefix: AnsiString;

    procedure Compile(code: integer; ToTempCode: boolean = false); overload;
    procedure Compile(code: array of integer; ToTempCode: boolean = false); overload;
    procedure CompileTo(position: integer; value: integer);
    procedure CompileCallTo(name: string);
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

    function TryDispatchIntegerNumber: boolean;
    function TryDispatchFloatNumber: boolean;
    procedure TryDispatchNumber;

    function LastCmd(InTempCode: boolean = false): integer;
    function CmdIsLiteral(cmd: integer): boolean;
    function LastCmdIsLiteral(InTempCode: boolean = false): boolean;

    function FindWord(tag: integer): integer;
    function FindProcedure(tag: integer): integer;
    function FindVariable(tag: integer): integer;

    procedure WritePredefinedVariables;

    function isCompiling: boolean;
    function isInterpreting: boolean;

    function GetLastNumber: integer;
    function GetLastString: string;

    procedure CodeAllot(value: integer);
    procedure DataAllot(value: integer);

    procedure DeleteCode(fromPos, toPos: integer);
    procedure CorrectJumps(delPos, delCount: integer);
    function FindJump(from: integer): integer;
    function GetLiteralPos(from: integer): integer;
    function GetLiteralValue(from: integer): integer;
    function GetPrevLiteral(var addr: integer; out valueGetted: boolean): integer;
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
    procedure _PROC;
    procedure _CompilePROC;
    procedure _RET;
    procedure _CompileCall;
    procedure _CompileInline;
    procedure _VARIABLE;
    procedure _CREATE;
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
    procedure _USE;
    procedure _ArithmeticOptimization;

    procedure _DumpVocabulary;

    procedure _WriteData;
    procedure _WriteCode;
    procedure _ALLOT;

    procedure _STRUCT;
    procedure _CompileSTRUCT;
    procedure _ENDSTRUCT;
    procedure _StructElement;
    function GetLastStructureElement: PStructCell;
    function GetStructureSize(_cell: PStructCell): integer;
    procedure CompileStruct(_cell: PStructCell);
    procedure FreeStructMemory(_cell: PStructCell);
  public
    procedure BeginInitCommandSystem;
    procedure EndInitCommandSystem;
    procedure AddToken(value: TTokenWord);
    procedure AddImmToken(name: string; proc: TProc; tag: integer = 0; memory: pointer = nil);
    procedure AddForthToken(name: string; tag: integer);
    procedure AddCmd2Token(name: string; tag: integer);
    procedure AddCmd3Token(name: string; tag: integer);
    function AddVariable(name: string; size: integer = 1): integer;
    procedure AddVarChange(name: string; _var: pointer);

    function Code(pos: integer): integer; override;
    function CodeCount: integer; override;
    function MaxCode: integer; override;

    function Data(pos: integer): integer; override;
    function DataCount: integer; override;
    function MaxData: integer; override;

    function DizasmCmd(cmd: integer): string; override;
    function DizasmAddr(addr: integer): string; override;
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
  UNEXCEPTED_EOLN = 'Не ожидаемый конец строки';

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
  errFileNotFound = 10;
  errControlStackNotEmpty = 11;
  errUnexceptedEOLN = 12;
  errRJumpTooLong = 13;
  errCount = 14;

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
   (code: errControlMismatch; msg: 'Control mismatch'),
   (code: errFileNotFound; msg: 'File not found'),
   (code: errControlStackNotEmpty; msg: 'Control stack not empty'),
   (code: errUnexceptedEOLN; msg: 'Unexcepted end of line'),
   (code: errRJumpTooLong; msg: 'Relative jump too long')
  );

  stCompiling = 1;
  stInterpreting = 0;

function TokenWord(name: string; tag: integer; immediate: boolean; proc: TProc; memory: pointer): TTokenWord;
function ControlStackCell(addr: integer; source: integer): TControlStackCell;

implementation

const
  PredefinedVariable: array[0..1] of string = ('HERE', '[C]HERE');

var
  PredefinedVariablePos: array[Low(PredefinedVariable)..High(PredefinedVariable)] of integer;
  LogFile: TextFile;

const
  sNone = 0;
  sIF = 1;
  sBEGIN = 2;
  sDO = 3;

  RJmpSize = 4;

function TokenWord(name: string; tag: integer; immediate: boolean; proc: TProc; memory: pointer): TTokenWord;
begin
  Result.name := ShortString(name);
  Result.tag := tag;
  Result.immediate := immediate;
  Result.proc := proc;
  Result.memory := memory;
end;

function ControlStackCell(addr: integer; source: integer): TControlStackCell;
begin
  Result.Addr := addr;
  Result.Source := source;
end;

{ TProteusCompiler }

procedure TProteusCompiler.CodeAllot(value: integer);
begin
  inc(CP, value);
  if value > UserMaxCode then
    Error(errCodeMemoryIsFull);
end;

procedure TProteusCompiler.DataAllot(value: integer);
begin
  inc(DP, value);
  if value > UserMaxData then
    Error(errDataMemoryIsFull);
end;

procedure TProteusCompiler.Compile(code: integer; ToTempCode: boolean = false);
begin
  if ToTempCode then
  begin
    FTempCode[TCP].value := code;
    FTempCode[TCP].controlDepth := ControlStackTop;
    inc(TCP);
  end
  else
  begin
    FCode[CP].value := code;
    FCode[CP].controlDepth := ControlStackTop;
    CodeAllot(1);
  end;
end;

procedure TProteusCompiler.Compile(code: array of integer; ToTempCode: boolean = false);
var
  i: integer;
begin
  for i := Low(code) to High(code) do
    Compile(code[i], ToTempCode);
end;

var
  CompileCallToCacheWord: string;
  CompileCallToCacheResult: integer;
procedure TProteusCompiler.CompileCallTo(name: string);
var
  addr: integer;
begin
  if name = CompileCallToCacheWord then
    addr := CompileCallToCacheResult
  else
  begin
    addr := FindToken(name);
    if addr = -1 then
    begin
      Error(errUnknownToken);
      Exit;
    end;
    CompileCallToCacheWord := name;
    CompileCallToCacheResult := addr;
  end;

  CompileNumber(FVocabulary[addr].tag);
  Compile(cmdCALL);
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
  if value <> 0 then
    Error(errRJumpTooLong);
end;

procedure TProteusCompiler.CompileNumber(_value: integer; ToTempCode: boolean = false);
var
  value: integer;
  buffer: array[0..8] of integer;
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

// на выходе позиция CP _за_ скомпилированным числом
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

procedure TProteusCompiler.AddImmToken(name: string; proc: TProc; tag: integer = 0; memory: pointer = nil);
begin
  AddToken(TokenWord(name, tag, true, proc, memory));
  AddSynlightWord(name, tokImmediate);
end;

procedure TProteusCompiler.AddForthToken(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, false, nil, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TProteusCompiler.AddCmd2Token(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, true, _Cmd2, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TProteusCompiler.AddCmd3Token(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, true, _Cmd3, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TProteusCompiler.AddVarChange(name: string; _var: pointer);
begin
  AddToken(TokenWord(name, integer(_var), true, _VarChange, nil));
  AddSynlightWord(name, tokDict);
end;

function TProteusCompiler.AddVariable(name: string; size: integer = 1): integer;
begin
  AddToken(TokenWord(name, DP, true, _VariableProc, nil));
  AddSynlightWord(name, tokVar);
  Result := DP;
  DataAllot(size);
end;

procedure TProteusCompiler.InitBasicCommands;
begin
  AddForthToken('NOP', cmdNOP);
  AddForthToken('NOT', cmdNOT);
  AddCmd3Token ('@', cmdFETCH);
  AddForthToken('SHL', cmdSHL);
  AddForthToken('SHR', cmdSHR);
  AddForthToken('SHRA', cmdSHRA);
  AddCmd3Token ('INPORT', cmdFETCH);
  AddForthToken('FP', cmdFP);
  AddForthToken('SWAP', cmdSWAP);
  AddForthToken('DUP', cmdDUP);
  AddForthToken('OVER', cmdOVER);
  AddForthToken('R>', cmdFROMR);
  AddImmToken  ('LOOP', _Loop, cmdLoop);
  AddForthToken('SYSREG@', cmdSYSREG);
  AddImmToken('+', _ArithmeticOptimization, cmdPLUS);
  AddImmToken('-', _ArithmeticOptimization, cmdMINUS);
  AddImmToken('*', _ArithmeticOptimization, cmdMULT);
  AddForthToken('AND', cmdAND);
  AddForthToken('OR', cmdOR);
  AddForthToken('XOR', cmdXOR);
  AddForthToken('=', cmdEQUAL);
  AddForthToken('<', cmdLESSER);
  AddForthToken('>', cmdGREATER);
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
  AddImmToken(';', _RET);
  AddImmToken('ENDPROC', _RET);
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
  AddImmToken('PROC', _CompilePROC);
  AddImmToken(':', _CompilePROC);
  AddImmToken('VARIABLE', _Variable);
  AddImmToken('CREATE', _CREATE);
  AddImmToken('ARRAY', _Array);
  AddImmToken('CMD', _AddCmd);
  AddImmToken('INLINE', _Inline);
  AddImmToken('L', _LoadFile);
  AddImmToken(',Z', _Z);
  AddImmToken(',', _WriteData);
  AddImmToken('[C],', _WriteCode);
  AddImmToken('ALLOT', _ALLOT);
  AddImmToken('''', _USE);
  AddImmToken('USE', _USE);

  AddImmToken('STRUCT', _STRUCT);
  AddImmToken('--', _StructElement);
  AddImmToken('END-STRUCT', _ENDSTRUCT);


  AddImmToken('{', _Interpret);
  AddImmToken('}', _RET);

  AddImmToken('"', _String);

  AddImmToken('DumpVocabulary', _DumpVocabulary);

  FHere := AddVariable('HERE');
  FCHere := AddVariable('[C]HERE');

  AddVarChange('#MaxCode=', @UserMaxCode);
  AddVarChange('#MaxData=', @UserMaxData);

  ReserveCodeForJump;
  Evaluate(': DP++ HERE @ 1 + HERE ! ;');
  Evaluate(': CP++ [C]HERE @ 1 + [C]HERE ! ;');
  Evaluate(': _ALLOT HERE @ + HERE ! ;');
  Evaluate(': _[C]ALLOT [C]HERE @ + [C]HERE ! ;');
  Evaluate(': _, HERE @ ! DP++ ;');
//  Evaluate(': _[C], [C]HERE @ [C]! CP++ ;'); // нет команды [C]!
end;

function TProteusCompiler.isCompiling: boolean;
begin
  Result := State <> stInterpreting;
end;

function TProteusCompiler.isInterpreting: boolean;
begin
  Result := State = stInterpreting;
end;

procedure TProteusCompiler.BeginInitCommandSystem;
begin
  CP := 0;
  DP := 0;
  VP := 0;
  SynLightWords.Clear;
  InitBasicCommands;
end;

procedure TProteusCompiler.EndInitCommandSystem;
begin
  HardwiredCodeCount := CP;
  HardwiredDataCount := DP;
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

function TProteusCompiler.TryDispatchIntegerNumber: boolean;
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

  if instr[pos] = '$' then
  begin
    base := 16;
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
    begin
      curDigit := curDigit - ord('A') + ord('9') + 1;
      if curDigit < 10 then
      begin
        Result := false;
        Exit;
      end;
    end;
    if (curDigit < 0) or (curDigit > base) then
    begin
      Result := false;
      Exit;
    end;
    res := res * base + curDigit;
  end;

  Number := sign * res;
  CompileNumber(Number);
  Result := true;
end;

function TProteusCompiler.TryDispatchFloatNumber: boolean;
var
  instr: string;
  fvalue: single;
  len: integer;
  i: integer;
begin
  instr := Parser.token;
  len := Length(instr);
  for i := 1 to len do
    if (instr[i] = '.') or (instr[i] = ',') then
      instr[i] := DecimalSeparator;

  Result := TryStrToFloat(instr, fvalue);
  if Result then
  begin
    Number := PInt(@fvalue)^;
    CompileNumber(Number);
    TokenID := FindToken('FPUSH');
    if (TokenID <> -1) then
    begin
      Token := @FVocabulary[TokenID];
      Token.proc();
    end;
  end;
end;

procedure TProteusCompiler.TryDispatchNumber;
begin
  if TryDispatchIntegerNumber then Exit;
  if TryDispatchFloatNumber then Exit;
  Error(errInvalideNumber);
end;

procedure TProteusCompiler.WritePredefinedVariables;
begin
//  if FindToken('HERE') <> -1 then CompileNumberTo(PredefinedVariablePos[0], DP);
//  if FindToken('[C]HERE') <> -1 then CompileNumberTo(PredefinedVariablePos[1], CP);
  FData[0].value := DP;
  FData[1].value := CP;
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
  for i := 0 to HardwiredWordsCount-1 do
    if (FVocabulary[i].tag = tag) then
    begin
      Result := i;
      Exit;
    end;
end;

function TProteusCompiler.FindProcedure(tag: integer): integer;
var
  i: integer;
  CallProcedure: TProc;
  CallCode: pointer;
begin
  Result := -1;
  CallProcedure := _CompileCall;
  CallCode := TMethod(CallProcedure).Code;
  for i := 0 to VP-1 do
    begin
      if (FVocabulary[i].tag = tag) and (TMethod(FVocabulary[i].proc).Code = CallCode) then
      begin
        Result := i;
        Exit;
      end;
    end;
end;

function TProteusCompiler.FindVariable(tag: integer): integer;
var
  i: integer;
  VariableProcedure: TProc;
  VariableCode: pointer;
begin
  Result := -1;
  VariableProcedure := _VariableProc;
  VariableCode := TMethod(VariableProcedure).Code;
  for i := 0 to VP-1 do
    begin
      if (FVocabulary[i].tag = tag) and (TMethod(FVocabulary[i].proc).Code = VariableCode) then
      begin
        Result := i;
        Exit;
      end;
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

function TProteusCompiler.GetLastNumber: integer;
var
  addr: integer;
  getted: boolean;
  value: integer;
begin
  addr := CP;
  value := GetPrevLiteral(addr, getted);
  CP := addr;
  if not getted then
    Error(errInvalideNumber);
  Result := value;
end;

function TProteusCompiler.GetLastString: string;
var
  i: integer;
begin
  dec(CP, LastStringCodeSize);
  dec(TCP, LastStringTempCodeSize);
  for i := 0 to LastStringDataSize-1 do
  begin
    dec(DP);
    FData[DP].value := 0;
  end;
  Result := LastString;
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
//    sign extention
//      ValueIsNegative := (cmd and NegativeBit) <> 0;
//      if ValueIsNegative then
//        value := value or (not LitMask);
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

//  for i := Low(PredefinedVariable) to High(PredefinedVariable) do
//  begin
//    tmp := FindToken(PredefinedVariable[i]);
//    if tmp <> -1 then
//    begin
//      PredefinedVariablePos[i] := CP;
//      ReserveCodeForNumber(integer($80000000)); // reserve code for max number
//      Compile(cmdNOP);
//      CompileNumber(FVocabulary[tmp].tag);
//      Compile(cmdNOP);
//      Compile(cmdStore);
//    end;
//  end;

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
  inc(CP, RJmpSize);
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
  procedure CompileCharacter(value: char);
  begin
//    CompileNumber(integer(AnsiString(value)[1]), true);
//    CompileNumber(DP, true);
//    Compile(cmdNop, true);
//    Compile(cmdSTORE, true);
    FData[DP].value := integer(AnsiString(value)[1]);
    DataAllot(1);
  end;
begin
  with Parser do
  begin
    addr := DP;
    LastString := '';
    LastStringTempCodeSize := TCP;
    LastStringCodeSize := CP;
    LastStringDataSize := DP;
    repeat
      CompileCharacter(tib[tibPos]);
      LastString := LastString + tib[tibPos];
    until (not IncTibPos) or (tib[tibPos] = '"');
    CompileCharacter(#0);
    IncTibPos;

    CompileNumber(addr);
    LastStringTempCodeSize := TCP - LastStringTempCodeSize;
    LastStringCodeSize := CP - LastStringCodeSize;
    LastStringDataSize := DP - LastStringDataSize;
  end;
end;

procedure TProteusCompiler._USE;
begin
  ParseToken;
  FindToken;
  if TokenID <> -1 then
    CompileNumber(Token.tag);
end;

procedure TProteusCompiler._ArithmeticOptimization;
var
  addr: integer;
  A, B: integer;
  valid: boolean;
begin
  addr := CP;
  B := GetPrevLiteral(addr, valid);
  if valid then
    A := GetPrevLiteral(addr, valid);
  if valid then
  begin
    CP := addr;
    case Token.tag of
      cmdPLUS:  CompileNumber(A + B);
      cmdMINUS: CompileNumber(A - B);
      cmdMULT:  CompileNumber(A * B);
    end;
  end
  else
  begin
    if Token.tag = cmdMULT then
      Compile([cmdNOP, cmdNOP]);
    Compile(Token.tag);
  end;
end;

procedure TProteusCompiler._PROC;
begin
  ParseToken;
  AddToken(TokenWord(Parser.token, CP, true, _CompileCall, nil));
  AddSynlightWord(Parser.token, tokDict);
end;

procedure TProteusCompiler._CompilePROC;
begin
  _PROC;
  State := stCompiling;
end;

procedure TProteusCompiler._RET;
begin
  if ControlStackTop > 0 then
  begin
    Error(errControlStackNotEmpty);
    Exit;
  end;
  State := stInterpreting;
  Compile(cmdRet);
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
  if CmdIsLiteral(PByteArray(Token.memory)[0]) and CmdIsLiteral(Code(CP-1)) then
    Compile(cmdNOP);

  i := 0;
  while PByteArray(Token.memory)[i] <> cmdRET do
  begin
    Compile(PByteArray(Token.memory)[i]);
    inc(i);
  end;
end;

procedure TProteusCompiler._VARIABLE;
begin
  ParseToken;
  AddVariable(Parser.token);
end;

procedure TProteusCompiler._CREATE;
begin
  ParseToken;
  AddVariable(Parser.token, 0);
end;

procedure TProteusCompiler._DumpVocabulary;
var
  f: TextFile;
  i: integer;
begin
  AssignFile(f, 'dump.txt');
  Rewrite(f);
  writeln(f,
      format('%32s %10s %8s %5s %8s %8s',
      ['name', 'tag dec', 'tag hex', 'imm', 'proc', 'memory']));
  for i := 0 to VP-1 do
    writeln(f,
        format('%32s %10d %8x %5s %8x %8x',
        [FVocabulary[i].name, FVocabulary[i].tag, FVocabulary[i].tag, BoolToStr(FVocabulary[i].immediate), integer(TMethod(FVocabulary[i].proc).Code), integer(FVocabulary[i].memory)]));
  CloseFile(f);
end;

procedure TProteusCompiler._ARRAY;
var
  name: string;
  size: integer;
begin
  name := ParseToken;
  size := ParseInt;
  AddToken(TokenWord(name, DP, true, _VariableProc, nil));
  AddSynlightWord(name, tokVar);
  DataAllot(size);
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
var
  i: integer;
  length: integer;
begin
  // todo: нужна проверка на то, что последняя запись в словаре - это процедура
  // todo: требование INLINE строго после процедуры
  FVocabulary[VP-1].proc := _CompileInline;
  length := CP - FVocabulary[VP-1].tag;
  CP := FVocabulary[VP-1].tag;

  if FVocabulary[VP-1].memory <> nil then
    FreeMemory(FVocabulary[VP-1].memory);
  FVocabulary[VP-1].memory := GetMemory(length);

  for i := 0 to length - 1 do
    PByteArray(FVocabulary[VP-1].memory)[i] := Byte(FCode[CP + i].value);
end;

procedure TProteusCompiler._LoadFile;
var
  inputFile: TextFile;
  fileName: string;
  str: string;
  lineNumber: integer;
begin
  fileName := GetLastString;

  if FilesStack.Top() <> '' then
  begin
    str := FilesStack.Top() + fileName;
    if not FileExists(str) then
      str := '';
  end;

  if str = '' then
  begin
    str := ExePath + fileName;
    if not FileExists(str) then
    begin
      Error(errFileNotFound);
      Exit;
    end;
  end;

  FilesStack.Push(str);
  lineNumber := 1;
  AssignFile(inputFile, str);
  Reset(inputFile);
  try
    while not EoF(inputFile) and (LastError = 0) do
    begin
      readln(inputFile, str);
      Evaluate(str);
      inc(lineNumber);
    end;

    if (LastError <> 0) then
    begin
      ErrorComment := ErrorComment + format('at line %d in file %s ', [lineNumber, fileName]);
    end;
  finally
    CloseFile(inputFile);
    FilesStack.Pop();
  end;
end;

procedure TProteusCompiler._Interpret;
begin
  CompileNumber(CP, true);
  Compile(cmdCALL, true);
  State := 1; // compiling
end;

procedure TProteusCompiler._Z;
begin
  Compile(GetLastNumber and $3F);
end;

procedure TProteusCompiler._WriteCode;
begin
  if isInterpreting then
  begin
    Compile(GetLastNumber and $3F);
  end
  else
  begin
    CompileCallTo('_[C],');
  end;
end;

procedure TProteusCompiler._WriteData;
var
  dummy: boolean;
begin
  if isInterpreting then
  begin
    FData[DP].value := GetLastNumber;
    DataAllot(1);
  end
  else
  begin
    CompileCallTo('_,');
  end;
end;

procedure TProteusCompiler._ALLOT;
var
  dummy: boolean;
begin
  if isInterpreting then
  begin
    DataAllot(GetLastNumber);
  end
  else
  begin
    CompileCallTo('_ALLOT');
  end;
end;

procedure TProteusCompiler._STRUCT;
var
  rootElement: PStructCell;
begin
  ParseToken;
  isStructure := true;
  rootElement := AllocMem(sizeof(TStructCell));
  rootElement.name := Parser.token;
  rootElement.size := 0;
  rootElement.root := true;
  rootElement.nested := nil;
  rootElement.next := nil;
  AddImmToken(Parser.token, _CompileSTRUCT, 0, rootElement);
end;

procedure TProteusCompiler._StructElement;
var
  getted: boolean;
  addr: integer;
  value: integer;
  lastElement, nextElement: PStructCell;
begin
  addr := CP;
  value := GetPrevLiteral(addr, getted);
  if not getted then
  begin
    Error(14);
    Exit;
  end;
  CP := addr;

  lastElement := GetLastStructureElement;
  nextElement := AllocMem(sizeof(TStructCell));
  nextElement^.name := ParseToken;
  nextElement^.root := false;
  nextElement^.next := nil;
  lastElement^.next := nextElement;
  AddSynlightWord(nextElement^.name, tokVar);

  if value and $80000000 = 0 then
  begin
    nextElement^.size := value;
    nextElement^.nested := nil;
  end
  else
  begin
    value := GetPrevLiteral(addr, getted);
    if not getted then
    begin
      Error(14);
      Exit;
    end;
    CP := addr;
    nextElement^.size := 0;
    nextElement^.nested := PStructCell(value);
  end;
end;

procedure TProteusCompiler._CompileSTRUCT;
var
  size: integer;
begin
  if isStructure then
  begin
    CompileNumber(integer(Token.memory));
    CompileNumber($80000000);
  end
  else
  begin
    ParseToken;
    StructureRoot := Token.memory;
    StructureName := Parser.Token;
    StructureOffset := 0;
    StructurePrefix := Parser.Token;
    size := GetStructureSize(StructureRoot);
    if StructureRoot <> nil then
    begin
      Evaluate(format('VARIABLE p%s', [StructureName]));
      Evaluate(format(': %s p%s @ ; INLINE', [StructureName, StructureName]));
      Evaluate(format(': sizeof(%s) %d ; INLINE', [StructureName, size]));
      if StructureRoot.next <> nil then
        CompileStruct(StructureRoot.next);
    end;
  end;
end;

procedure TProteusCompiler.CompileStruct(_cell: PStructCell);
var
  PrefixStore: AnsiString;
  cell: PStructCell;
begin
  cell := _cell;
  while cell <> nil do
  begin
    if not cell.root then
    begin
      Evaluate(format(': %s.%s p%s @ %d + ; INLINE', [StructurePrefix, cell.name, StructureName, StructureOffset]));
      inc(StructureOffset, cell.size);
      if cell.nested <> nil then
      begin
        PrefixStore := StructurePrefix;
        StructurePrefix := StructurePrefix + '.' + cell.name;
        CompileStruct(cell.nested);
        StructurePrefix := PrefixStore;
      end;
    end;
    cell := cell.next;
  end;
end;

procedure TProteusCompiler.FreeStructMemory(_cell: PStructCell);
var
  cell: PStructCell;
  next: PStructCell;
begin
  cell := _cell;
  while cell <> nil do
  begin
    next := cell.next;
    cell.next := nil;
    FreeMemory(cell);
    cell := next;
  end;
end;

function TProteusCompiler.GetLastStructureElement: PStructCell;
begin
  Result := PStructCell(FVocabulary[VP-1].memory);
  while (Result <> nil) and (Result^.next <> nil) do
    Result := Result^.next;
end;

function TProteusCompiler.GetStructureSize(_cell: PStructCell): integer;
var
  cell: PStructCell;
  res: integer;
begin
  cell := _cell;
  res := 0;
  while cell <> nil do
  begin
    res := res + cell.size + GetStructureSize(cell.nested);
    cell := cell.next;
  end;
  Result := res;
end;

procedure TProteusCompiler._ENDSTRUCT;
var
  cell: PStructCell;
  size: integer;
begin
  isStructure := false;
  size := GetStructureSize(PStructCell(FVocabulary[VP-1].memory));
  Evaluate(format(': %s.Size %d ; INLINE', [FVocabulary[VP-1].name, size]));
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
//  writeln(LogFile, tib);
//  Flush(LogFile);
  inc(LineCount);
  Parser.tib := tib;
  while (FError = errOk) and Parser.NextWord do
  begin
    FindToken;
    if TokenID = -1 then // возможно число
    begin
      TryDispatchNumber;
      if FError = errInvalideNumber then
      begin
        Error(errUnknownToken);
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
  Parser.separators := ' '#9;
end;

destructor TProteusCompiler.Destroy;
begin
  HardwiredWords.Free;
  inherited;
end;

function TProteusCompiler.DizasmCmd(cmd: integer): string;
var
  WordID: integer;
  WordS: string;
begin
  Result := 'Unknown';
  case cmd of
    cmdNOP: Result := 'NOP';
    cmdRET: Result := 'RET';
    cmdSTORE: Result := '!';
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

function TProteusCompiler.GetPrevLiteral(var addr: integer; out valueGetted: boolean): integer;
var
  cmdAddr: integer;
begin
  cmdAddr := addr;
  dec(addr);
  while (addr > 0) and (FCode[addr].value = cmdNOP) do
    dec(addr);
  while (addr > 0) and CmdIsLiteral(FCode[addr].value) do
    dec(addr);
  inc(addr);

  valueGetted := (addr < cmdAddr) and CmdIsLiteral(FCode[addr].value)
    and (ControlStackTop = FCode[addr].controlDepth);
  if valueGetted then
    Result := GetLiteralValue(addr);
end;

function TProteusCompiler.DizasmAddr(addr: integer): string;
var
  cmd: integer;
  value: integer;
  valueGetted: boolean;
  index: integer;
begin
  Result := 'Unknown';
  cmd := Code(addr);
  case cmd of
    cmdSTORE, cmdFETCH:
    begin
      value := GetPrevLiteral(addr, valueGetted);
      if valueGetted then
        index := FindVariable(value)
      else
        index := -1;

      Result := DizasmCmd(cmd);
      if index > 0 then
        Result := FVocabulary[index].name + ' ' + Result;
    end;

    cmdCALL:
    begin
      value := GetPrevLiteral(addr, valueGetted);
      if valueGetted then
        index := FindProcedure(value)
      else
        index := -1;

      if index > 0 then
        Result := 'C ' + FVocabulary[index].name
      else
        Result := 'CALL';
    end;
    else
      Result := DizasmCmd(cmd);
  end;
end;

procedure TProteusCompiler.BeginCompile;
var
  i: integer;
  procStructure: TProc;
begin
  inherited;

  FilesStack.Clear();
  FilesStack.Push(FilePath);

  FError := 0;
  ErrorComment := '';
  LineCount := 0;

  State := 0;
  TCP := 0;
  CP := HardwiredCodeCount;
  FillMemory(@FCode[CP], sizeof(TCodeCell) * (MaxCode - HardwiredCodeCount), 0);
  DP := HardwiredDataCount;
  FillMemory(@FData[DP], sizeof(TDataCell) * (MaxData - HardwiredDataCount), 0);
  ControlStackTop := 0;
  isStructure := false;

  procStructure := _CompileStruct;
  for i := HardwiredWordsCount to VP-1 do
    if FVocabulary[i].memory <> nil then
    begin
      if integer(TMethod(FVocabulary[i].proc).Code) = integer(TMethod(procStructure).Code) then
        FreeStructMemory(PStructCell(FVocabulary[i].memory));
      FreeMemory(FVocabulary[i].memory);
      FVocabulary[i].memory := nil;
    end;
  VP := HardwiredWordsCount;
  SynLightWords.Clear;
  SynLightWords.AddStrings(HardwiredWords);

  UserMaxCode := CodeSize;
  UserMaxData := DataSize;
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
  if ErrorComment <> '' then
    Result := Result + ' ' + ErrorComment;
end;

function TProteusCompiler.LastToken: string;
begin
  Result := Parser.token;
end;

function TProteusCompiler.ParseToken: string;
begin
  if not Parser.NextWord then
  begin
    Error(errUnexceptedEOLN);
//    raise Exception.Create(UNEXCEPTED_EOLN);
  end;

  Result := Parser.token;
end;

function TProteusCompiler.ParseInt: integer;
begin
  Result := StrToInt(ParseToken);
end;

function TProteusCompiler.NewFileText: string;
begin
  Result := '// for Proteus compiler' +#13#10
    + '                 // Запись программы' +#13#10
    + '#COM 1           // по нужному COM-порту' +#13#10
    + '#BAUDRATE 115200 // с нужной скоростью' +#13#10
    + '#PACKSIZE= 1     // пакетами по PACKSIZE байт' +#13#10
    + '#WAITCOEF= 2     // с задержкой, вычисляемой по формуле' +#13#10
    + '                 // (PackSize * 8 / BaudRate) * WaitCoef секунд' +#13#10
    + '// Если программа не зашивается, попробуйте уменьшить размер пакетов' +#13#10
    + '// и увеличить задержку' +#13#10
    + '' +#13#10
    + '#MaxCode= 65536' +#13#10
    + '#MaxData= 65536' +#13#10
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
//  bugged
//  ClearJumps;
end;


initialization
//  AssignFile(LogFile, 'ProteusCompiler.log');
//  Rewrite(LogFile);
finalization
//  CloseFile(LogFile);
end.
