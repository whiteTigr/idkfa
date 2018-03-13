unit uKf7Compiler;

interface

uses
  Windows, SysUtils, uGlobal, uKf7DeviceCore, uCommonFunctions, Classes,
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

  TKf7Compiler = class(TTargetCompiler)
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
    procedure _FetchCmd;
    procedure _CmdNop;
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
    procedure AddFetchCmdToken(name: string; tag: integer);
    procedure AddCmdNopToken(name: string; tag: integer);
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

var
  LogFile: TextFile;

const
  sNone = 0;
  sIF = 1;
  sBEGIN = 2;
  sDO = 3;

  RJmpSize = 2;

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

{ TKf7Compiler }

procedure TKf7Compiler.CodeAllot(value: integer);
begin
  inc(CP, value);
  if value > UserMaxCode then
    Error(errCodeMemoryIsFull);
end;

procedure TKf7Compiler.DataAllot(value: integer);
begin
  inc(DP, value);
  if value > UserMaxData then
    Error(errDataMemoryIsFull);
end;

procedure TKf7Compiler.Compile(code: integer; ToTempCode: boolean = false);
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

procedure TKf7Compiler.Compile(code: array of integer; ToTempCode: boolean = false);
var
  i: integer;
begin
  for i := Low(code) to High(code) do
    Compile(code[i], ToTempCode);
end;

var
  CompileCallToCacheWord: string;
  CompileCallToCacheResult: integer;
procedure TKf7Compiler.CompileCallTo(name: string);
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

procedure TKf7Compiler.CompileTo(position: integer; value: integer);
var
  storeCP: integer;
begin
  storeCP := CP;
  CP := position;
  Compile(value);
  CP := storeCP;
end;

procedure TKf7Compiler.CompileRJmpTo(position, _value: integer);
var
  i: integer;
  value: integer;
begin
  value := _value;
  for i := RJmpSize-1 downto 0 do
  begin
    CompileTo(position + i, cmdLIT + value and LitMask);
    value := shra(value, LITSize);
  end;
  if value <> 0 then
    Error(errRJumpTooLong);
end;

procedure TKf7Compiler.CompileNumber(_value: integer; ToTempCode: boolean = false);
var
  value: integer;
  buffer: array[0..8] of integer;
  wrongPositive: boolean;
  wrongNegative: boolean;
  needCorrectSignExtention: boolean;
  i: integer;
  done: boolean;
begin
  value := _value;
  LastNumber := value;
  LastNumberSize := 0;

  repeat
    buffer[LastNumberSize] := cmdLIT or (value and LitMask);
    inc(LastNumberSize);
    if SignExtention then
    begin
      value := shra(value, LITSize);
      done := (value = 0) or (value = -1);
    end
    else
    begin
      value := value shr LITSize;
      done := (value = 0);
    end;
  until done;


  wrongPositive := SignExtention and (_value > 0) and ((buffer[LastNumberSize-1] and NegativeBit) <> 0);
  wrongNegative := SignExtention and (_value < 0) and ((buffer[LastNumberSize-1] and NegativeBit) = 0);
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

procedure TKf7Compiler.ReserveCodeForNumber(_value: integer);
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
function TKf7Compiler.CompileNumberTo(position: integer; _value: integer): integer;
var
  storeCP: integer;
begin
  storeCP := CP;
  CP := position;
  CompileNumber(_value);
  Result := CP;
  CP := storeCP;
end;

procedure TKf7Compiler.ReserveCodeForJump;
begin
  ReserveCodeForNumber(integer($7FFFFFFF));
  Compile(cmdNOP);
end;

procedure TKf7Compiler.CopyTempCode;
var
  i: integer;
begin
  for i := 0 to TCP - 1 do
    Compile(FTempCode[i].value);
end;

procedure TKf7Compiler.AddNopAfterLiteral(ToTempCode: boolean = false);
begin
  if LastCmdIsLiteral(ToTempCode) then
    Compile(cmdNOP, ToTempCode);
end;

procedure TKf7Compiler.AddReference(source: integer;
  RefCommands: array of integer);
var
  i: integer;
begin
  ControlPush(ControlStackCell(CP, source));
  for i := 0 to RJmpSize-1 do
    Compile(cmdNOP);
  Compile(RefCommands);
end;

function TKf7Compiler.ControlPop: TControlStackCell;
begin
  if ControlStackTop <= 0 then
  begin
    Error(errControlStackUnderflow);
    Exit;
  end;

  dec(ControlStackTop);
  Result := FControlStack[ControlStackTop];
end;

procedure TKf7Compiler.ControlPush(value: TControlStackCell);
begin
  if ControlStackTop >= ControlStackSize then
  begin
    Error(errControlStackOverflow);
    Exit;
  end;

  FControlStack[ControlStackTop] := value;
  inc(ControlStackTop);
end;

function TKf7Compiler.ControlReadTop: TControlStackCell;
begin
  if ControlStackTop <= 0 then
  begin
    Error(errControlStackUnderflow);
    Exit;
  end;

  Result := FControlStack[ControlStackTop-1];
end;

procedure TKf7Compiler.Error(code: integer);
begin
  FError := code;
end;

function TKf7Compiler.GetErrorMessage: string;
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

procedure TKf7Compiler.MemoryAlloc(CellsCount, CellSize: integer;
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

procedure TKf7Compiler.SetCodeSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TCodeCell), pointer(FCode), CodeSize);
  MemoryAlloc(newSize, sizeof(TCodeCell), pointer(FTempCode), TempCodeSize);
end;

procedure TKf7Compiler.SetControlStackSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TControlStackCell), pointer(FControlStack), ControlStackSize);
end;

procedure TKf7Compiler.SetDataSize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TDataCell), pointer(FData), DataSize);
end;

procedure TKf7Compiler.SetVocabularySize(newSize: integer);
begin
  MemoryAlloc(newSize, sizeof(TTokenWord), pointer(FVocabulary), VocabularySize);
end;

procedure TKf7Compiler.AddToken(value: TTokenWord);
begin
  if VP >= VocabularySize then
  begin
    Error(errVocabularyIsFull);
    Exit;
  end;

  FVocabulary^[VP] := value;
  inc(VP);
end;

procedure TKf7Compiler.AddImmToken(name: string; proc: TProc; tag: integer = 0; memory: pointer = nil);
begin
  AddToken(TokenWord(name, tag, true, proc, memory));
  AddSynlightWord(name, tokImmediate);
end;

procedure TKf7Compiler.AddForthToken(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, false, nil, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TKf7Compiler.AddFetchCmdToken(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, true, _FetchCmd, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TKf7Compiler.AddCmdNopToken(name: string; tag: integer);
begin
  AddToken(TokenWord(name, tag, true, _CmdNop, nil));
  AddSynlightWord(name, tokAlfabet);
end;

procedure TKf7Compiler.AddVarChange(name: string; _var: pointer);
begin
  AddToken(TokenWord(name, integer(_var), true, _VarChange, nil));
  AddSynlightWord(name, tokDict);
end;

function TKf7Compiler.AddVariable(name: string; size: integer = 1): integer;
begin
  AddToken(TokenWord(name, DP, true, _VariableProc, nil));
  AddSynlightWord(name, tokVar);
  Result := DP;
  DataAllot(size);
end;

procedure TKf7Compiler.InitBasicCommands;
begin
  // Dqa
  AddForthToken('NOP', cmdNOP);
  AddForthToken('NOT', cmdNOT);
  AddForthToken('SHL', cmdSHL);
  AddForthToken('SHR', cmdSHR);
  AddForthToken('SHRA', cmdSHRA);
  AddForthToken('SHL8', cmdSHL8);
  AddForthToken('SHR8', cmdSHR8);
  AddForthToken('DUP', cmdDUP);

  // Dqb
  AddForthToken('SWAP', cmdSWAP);
  AddForthToken('SAVEB', cmdSAVEB);
  AddForthToken('OVER', cmdOVER);
  AddForthToken('DROP', cmdDROP);
  AddForthToken('LOCALW', cmdLOCALW);
  AddForthToken('JMP', cmdJMP);
  AddForthToken('CALL', cmdCALL);
  AddForthToken('RJMP', cmdRJMP);
  AddForthToken('SETDEPTH', cmdSETDEPTH);
  AddForthToken('>DEBUG', cmdDEBUG);

  // ALU
  AddImmToken('+', _ArithmeticOptimization, cmdADD);
  AddImmToken('-', _ArithmeticOptimization, cmdSUB);
  AddForthToken('AND', cmdAND);
  AddForthToken('OR', cmdOR);
  AddForthToken('XOR', cmdXOR);
  AddForthToken('=', cmdEQUAL);
  AddForthToken('U<', cmdULESS);
  AddForthToken('U>', cmdUGREATER);
  AddImmToken('*', _ArithmeticOptimization, cmdMULT);
  AddForthToken('<', cmdLESS);
  AddForthToken('>', cmdGREATER);

  // D2m
  AddCmdNopToken('!', cmdSTORE);
  AddCmdNopToken('STORE', cmdSTORE);
  AddForthToken('OUTPORT', cmdSTORE);
  AddForthToken('ARGSTORE', cmdARGSTORE);
  AddForthToken('DO', cmdDO);
  AddForthToken('[C]!', cmdCSTORE);
  AddForthToken('RIF', cmdRIF);
  AddForthToken('UNTIL', cmdUNTIL);

  // MIX
  AddForthToken('LOCALR', cmdLOCALR);
  AddForthToken('[C]@', cmdCFETCH);
  AddForthToken('DEPTH', cmdDEPTH);
  AddForthToken('I', cmdI);
  AddForthToken('FETCH', cmdFETCH);
  AddForthToken('cmdPICK', cmdPICK);
  AddForthToken('ARGFETCH', cmdARGFETCH);
  AddForthToken('IX', cmdIX);

  // G5
  AddImmToken('RET',     _RET, cmdRET);
  AddImmToken(';',       _RET, cmdRET);
  AddImmToken('ENDPROC', _RET, cmdRET);
  AddForthToken('EXIT', cmdRET);
  AddImmToken('RETS',    _RET, cmdRETS);
  AddImmToken(';S',      _RET, cmdRETS);
  AddForthToken('EXITS', cmdRETS);
  AddImmToken('RETI',    _RET, cmdRETI);
  AddImmToken(';I',      _RET, cmdRETI);
  AddForthToken('EXITI', cmdRETI);
  AddCmdNopToken('LOOP', cmdLOOP);



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

  AddVarChange('#MaxCode=', @UserMaxCode);
  AddVarChange('#MaxData=', @UserMaxData);

  ReserveCodeForJump;
end;

function TKf7Compiler.isCompiling: boolean;
begin
  Result := State <> stInterpreting;
end;

function TKf7Compiler.isInterpreting: boolean;
begin
  Result := State = stInterpreting;
end;

procedure TKf7Compiler.BeginInitCommandSystem;
begin
  CP := 0;
  DP := 0;
  VP := 0;
  SynLightWords.Clear;
  InitBasicCommands;
end;

procedure TKf7Compiler.EndInitCommandSystem;
begin
  HardwiredCodeCount := CP;
  HardwiredDataCount := DP;
  HardwiredWordsCount := VP;
  HardwiredWords.AddStrings(SynLightWords);
end;

procedure TKf7Compiler.FindToken;
begin
  TokenID := FindToken(Parser.token);
  if TokenID <> -1 then
    Token := @FVocabulary[TokenID]
  else
    Token := nil;
end;

function TKf7Compiler.FindToken(const name: string): integer;
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

function TKf7Compiler.TryDispatchIntegerNumber: boolean;
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
      curDigit := curDigit - ord('A') + ord('9') + 1;
    if (curDigit < 0) or (curDigit > base) then
    begin
      Result := false;
      Exit;
    end;
    res := res * base + curDigit;
  end;

  Number := sign * res;
  Result := true;
end;

function TKf7Compiler.TryDispatchFloatNumber: boolean;
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
    Number := PInt(@fvalue)^;
end;

procedure TKf7Compiler.TryDispatchNumber;
begin
  if TryDispatchIntegerNumber then Exit;
  if TryDispatchFloatNumber then Exit;
  Error(errInvalideNumber);
end;

procedure TKf7Compiler.WritePredefinedVariables;
begin
//  if FindToken('HERE') <> -1 then CompileNumberTo(PredefinedVariablePos[0], DP);
//  if FindToken('[C]HERE') <> -1 then CompileNumberTo(PredefinedVariablePos[1], CP);
  FData[0].value := DP;
  FData[1].value := CP;
end;

function TKf7Compiler.LastCmd(InTempCode: boolean = false): integer;
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

function TKf7Compiler.CmdIsLiteral(cmd: integer): boolean;
begin
  Result := (cmd and cmdLIT) <> 0;
end;

function TKf7Compiler.LastCmdIsLiteral(InTempCode: boolean = false): boolean;
begin
  Result := CmdIsLiteral(LastCmd(InTempCode));
end;

function TKf7Compiler.FindWord(tag: integer): integer;
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

function TKf7Compiler.FindProcedure(tag: integer): integer;
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

function TKf7Compiler.FindVariable(tag: integer): integer;
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

procedure TKf7Compiler.DeleteCode(fromPos, toPos: integer);
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

procedure TKf7Compiler.CorrectJumps(delPos, delCount: integer);
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

function TKf7Compiler.FindJump(from: integer): integer;
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

function TKf7Compiler.GetLastNumber: integer;
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

function TKf7Compiler.GetLastString: string;
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

function TKf7Compiler.GetLiteralPos(from: integer): integer;
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

function TKf7Compiler.GetLiteralValue(from: integer): integer;
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

function TKf7Compiler.GetLiteralSize(from: integer): integer;
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

function TKf7Compiler.GetNopCount(from, _to: integer): integer;
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

procedure TKf7Compiler.ClearJumps;
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

procedure TKf7Compiler._Comment;
begin
  Parser.tib := '';
end;

procedure TKf7Compiler._IF;
begin
  AddNopAfterLiteral;
  AddReference(sIf, [cmdRIF]);
end;

procedure TKf7Compiler._ELSE;
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
  CompileRJmpTo(ref.Addr, CP - 1 - ref.Addr - RJmpSize);
end;

procedure TKf7Compiler._THEN;
var
  ref: TControlStackCell;
begin
  ref := ControlPop;
  if (ref.Source <> sIF) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  CompileRJmpTo(ref.Addr, CP - 1 - ref.Addr - RJmpSize);
end;

procedure TKf7Compiler._MainDef;
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

procedure TKf7Compiler._BEGIN;
begin
  AddNopAfterLiteral;
  ControlPush(ControlStackCell(CP, sBegin));
end;

procedure TKf7Compiler._AGAIN;
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

procedure TKf7Compiler._UNTIL;
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
  CompileRJmpTo(CP, CP + 1 + RJmpSize - ref.Addr);
  inc(CP, RJmpSize);
  Compile(cmdUNTIL);
end;

procedure TKf7Compiler._WHILE;
begin
  if (ControlReadTop.Source <> sBegin) then
  begin
    Error(errControlMismatch);
    Exit;
  end;

  _IF;
end;

procedure TKf7Compiler._REPEAT;
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

procedure TKf7Compiler._String;
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

procedure TKf7Compiler._USE;
begin
  ParseToken;
  FindToken;
  if TokenID <> -1 then
    CompileNumber(Token.tag);
end;

procedure TKf7Compiler._ArithmeticOptimization;
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
      cmdADD:  CompileNumber(A + B);
      cmdSUB: CompileNumber(A - B);
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

procedure TKf7Compiler._PROC;
begin
  ParseToken;
  AddToken(TokenWord(Parser.token, CP, true, _CompileCall, nil));
  AddSynlightWord(Parser.token, tokDict);
end;

procedure TKf7Compiler._CompilePROC;
begin
  _PROC;
  State := stCompiling;
end;

procedure TKf7Compiler._RET;
begin
  if ControlStackTop > 0 then
  begin
    Error(errControlStackNotEmpty);
    Exit;
  end;
  State := stInterpreting;
  Compile([token.tag]);
end;

procedure TKf7Compiler._CompileCall;
begin
  CompileNumber(token.tag);
  Compile([cmdCALL]);
end;

procedure TKf7Compiler._CompileInline;
var
  i: integer;
  cmd: integer;
begin
  if CmdIsLiteral(PByteArray(Token.memory)[0]) and CmdIsLiteral(Code(CP-1)) then
    Compile(cmdNOP);

  i := 0;
  cmd := PByteArray(Token.memory)[i];
  while not ((cmd = cmdRET) or (cmd = cmdRETS) or (cmd = cmdRETI)) do
  begin
    Compile(cmd);
    inc(i);
    cmd := PByteArray(Token.memory)[i];
  end;
end;

procedure TKf7Compiler._VARIABLE;
begin
  ParseToken;
  AddVariable(Parser.token);
end;

procedure TKf7Compiler._CREATE;
begin
  ParseToken;
  AddVariable(Parser.token, 0);
end;

procedure TKf7Compiler._DumpVocabulary;
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

procedure TKf7Compiler._ARRAY;
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

procedure TKf7Compiler._VariableProc;
begin
  CompileNumber(Token.tag);
end;

procedure TKf7Compiler._VarChange;
var
  newValue: integer;
  pint: ^integer;
begin
  newValue := ParseInt;
  pint := pointer(Token.tag);
  pint^ := newValue;
end;

procedure TKf7Compiler._FetchCmd;
begin
  Compile(cmdFETCH);
  Compile(Token.tag);
end;

procedure TKf7Compiler._CmdNop;
begin
  Compile(Token.tag);
  Compile(cmdNOP);
end;

procedure TKf7Compiler._Loop;
begin
  Compile([cmdLOOP, cmdNOP]);
end;

procedure TKf7Compiler._AddCmd;
var
  name: string;
  value: integer;
begin
  name := ParseToken;
  value := ParseInt;
  AddForthToken(name, value);
end;

procedure TKf7Compiler._Inline;
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

procedure TKf7Compiler._LoadFile;
var
  inputFile: TextFile;
  fileName: string;
  str: string;
  lineNumber: integer;
begin
  fileName := GetLastString;

  if FilePath <> '' then
  begin
    str := FilePath + fileName;
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
      ErrorComment := format('at line %d in file %s', [lineNumber, fileName]);
    end;
  finally
    CloseFile(inputFile);
  end;
end;

procedure TKf7Compiler._Interpret;
begin
  CompileNumber(CP, true);
  Compile(cmdCALL, true);
  State := 1; // compiling
end;

procedure TKf7Compiler._Z;
begin
  Compile(GetLastNumber);
end;

procedure TKf7Compiler._WriteCode;
begin
  if isInterpreting then
  begin
    Compile(GetLastNumber);
  end
  else
  begin
    CompileCallTo('_[C],');
  end;
end;

procedure TKf7Compiler._WriteData;
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

procedure TKf7Compiler._ALLOT;
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

procedure TKf7Compiler._STRUCT;
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

procedure TKf7Compiler._StructElement;
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

procedure TKf7Compiler._CompileSTRUCT;
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

procedure TKf7Compiler.CompileStruct(_cell: PStructCell);
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

procedure TKf7Compiler.FreeStructMemory(_cell: PStructCell);
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

function TKf7Compiler.GetLastStructureElement: PStructCell;
begin
  Result := PStructCell(FVocabulary[VP-1].memory);
  while (Result <> nil) and (Result^.next <> nil) do
    Result := Result^.next;
end;

function TKf7Compiler.GetStructureSize(_cell: PStructCell): integer;
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

procedure TKf7Compiler._ENDSTRUCT;
var
  cell: PStructCell;
  size: integer;
begin
  isStructure := false;
  size := GetStructureSize(PStructCell(FVocabulary[VP-1].memory));
  Evaluate(format(': %s.Size %d ; INLINE', [FVocabulary[VP-1].name, size]));
end;

function TKf7Compiler.GetCmdColor(cmd: integer): cardinal;
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
    cmdLIT..cmdLIT+LITMask: // number
      Result := $FF6050;
    else
      Result := $000000;
  end;
end;

procedure TKf7Compiler.Evaluate(const tib: string);
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

function TKf7Compiler.Code(pos: integer): integer;
begin
  if FCode <> nil then
    Result := FCode[pos].value
  else
    Result := -1;
end;

function TKf7Compiler.CodeCount: integer;
begin
  Result := CP;
end;

function TKf7Compiler.MaxCode: integer;
begin
  Result := UserMaxCode;
end;

function TKf7Compiler.Data(pos: integer): integer;
begin
  if FData <> nil then
    Result := FData[pos].value
  else
    Result := -1;
end;

function TKf7Compiler.DataCount: integer;
begin
  Result := DP;
end;

function TKf7Compiler.MaxData: integer;
begin
  Result := UserMaxData;
end;

constructor TKf7Compiler.Create;
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

destructor TKf7Compiler.Destroy;
begin
  HardwiredWords.Free;
  inherited;
end;

function TKf7Compiler.DizasmCmd(cmd: integer): string;
var
  WordID: integer;
  WordS: string;
begin
  Result := 'Unknown';
  case cmd of
    cmdNOP: Result := 'NOP';
    cmdRET: Result := 'RET';
    cmdSTORE: Result := '!';
    cmdLIT..cmdLIT + LitMask: Result := IntToHex(cmd and LitMask, 0);
    else
      WordID := FindWord(cmd);
      if WordID = -1 then
        WordS := '$' + IntToHex(cmd, 2)
      else
        WordS := string(FVocabulary[WordID].name);
      Result := WordS;
  end;
end;

function TKf7Compiler.GetPrevLiteral(var addr: integer; out valueGetted: boolean): integer;
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

function TKf7Compiler.DizasmAddr(addr: integer): string;
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
      dec(addr);
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

procedure TKf7Compiler.BeginCompile;
var
  i: integer;
  procStructure: TProc;
begin
  inherited;

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

procedure TKf7Compiler.EndCompile;
begin
  WritePredefinedVariables;
  Compiled := FError = 0;
end;

function TKf7Compiler.LastError: integer;
begin
  Result := FError;
end;

function TKf7Compiler.LastErrorMessage: string;
begin
  Result := GetErrorMessage;
  if ErrorComment <> '' then
    Result := Result + ' ' + ErrorComment;
end;

function TKf7Compiler.LastToken: string;
begin
  Result := Parser.token;
end;

function TKf7Compiler.ParseToken: string;
begin
  if not Parser.NextWord then
  begin
    Error(errUnexceptedEOLN);
//    raise Exception.Create(UNEXCEPTED_EOLN);
  end;

  Result := Parser.token;
end;

function TKf7Compiler.ParseInt: integer;
begin
  Result := StrToInt(ParseToken);
end;

function TKf7Compiler.NewFileText: string;
begin
  Result := '// for Kf7 compiler' +#13#10
    + '                 // Запись программы' +#13#10
    + '#COM 1           // по нужному COM-порту' +#13#10
    + '#BAUDRATE 115200 // с нужной скоростью' +#13#10
    + '#PACKSIZE= 1     // пакетами по PACKSIZE байт' +#13#10
    + '#WAITCOEF= 2     // с задержкой, вычисляемой по формуле' +#13#10
    + '                 // (PackSize * 8 / BaudRate) * WaitCoef секунд' +#13#10
    + '// Если программа не зашивается, попробуйте уменьшить размер пакетов' +#13#10
    + '// и увеличить задержку' +#13#10
    + '' +#13#10
    + '// подгрузка библиотек' +#13#10
    + '// " Kf7.lib" L' +#13#10
    + '' +#13#10
    + 'MAIN:' +#13#10
    + '' +#13#10
    + 'BEGIN' +#13#10
    + '' +#13#10
    + 'AGAIN';
end;

procedure TKf7Compiler.Optimize;
begin
//  bugged
//  ClearJumps;
end;


initialization
//  AssignFile(LogFile, 'Kf7Compiler.log');
//  Rewrite(LogFile);
finalization
//  CloseFile(LogFile);
end.
