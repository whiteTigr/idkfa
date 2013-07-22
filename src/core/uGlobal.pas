unit uGlobal;

interface

uses
  Windows, Messages, Sysutils, Classes, uRecordList;

const
  MaxCode = 1024 * 128;
  MaxData = 1024 * 128;

type
  TDeviceType =
  (devNone,
   devForth,
   devBrainfuck,
   devProteus,
   devQuark);

  TCompilerType =
  (compilerNone,
   compilerForth,
   compilerBrainfuck,
   compilerProteus,
   compilerQuark);

  PProc = ^TProc;
  TProc = procedure;

  TLoopCell = record
    Jmp: integer;
    Last: integer;
    Cur: integer;
  end;

  TValueChangedEvent = procedure(position: integer; newValue: integer);

  PDebuger = ^TDebuger;
  TDebuger = class
  protected
    FError: integer;
    FOnCodeChange: TValueChangedEvent;
    FOnDataChange: TValueChangedEvent;

  public
    PC: integer;
    Code: array[0..MaxCode-1] of integer;
    Data: array[0..MaxData-1] of integer;

    property LastError: integer read FError;
    property OnCodeChange: TValueChangedEvent read FOnCodeChange write FOnCodeChange;
    property OnDataChange: TValueChangedEvent read FOnDataChange write FOnDataChange;

    constructor Create;
    destructor Destroy; override;
    procedure Error(errorNumber: integer);

    procedure ClearCode;
    procedure ClearData;

    procedure TurnOn; virtual;
    procedure TurnOff; virtual;

    // Сброс модели
    procedure Reset; virtual;
    // Шаг, с заходов в подпрограммы
    procedure TraceInto; virtual;
    // Шаг, без захода в подпрограммы
    procedure StepOver; virtual;
    // Выполнение программы до курсора (programmCounter)
    procedure RunToCursor(programmCounter: integer); virtual;
    // Выполнение программы до команды выхода из подпрограммы
    procedure RunUntilReturn; virtual;
    // Выполнение программы в течении заданого времени
    procedure RunForTime(milliSeconds: integer); virtual;
    // Выполнение заданого количества комманд программы
    procedure RunForCommands(commandCount: integer); virtual;
    // Выполенение заданого количества комманд программы, без захода в подпрограммы
    procedure RunForStepOverCommands(commandCount: integer); virtual;
  end;

  PTargetCompiler = ^TTargetCompiler;
  TTargetCompiler = class
  private
  public
    // Необходимо установить в true, если переопределена процедура Evaluate
    // Или переопределить EvaluateFile и установить в false
    hasEvaluate: boolean;

    constructor Create;

    // * - обязательно для переопределения. Минимальный набор для своего компилятора.
    // * Получение кода по адресу
    function Code(pos: integer): integer; virtual;
    // * Сколько скомпилировано кода
    function CodeCount: integer; virtual;
    // Получение цвета команды (для симулятора)
    function GetCmdColor(cmd: integer): cardinal; virtual;
    // Максимальный размер памяти кода
    function MaxCode: integer; virtual;
    // Дизасемблирование отдельной команды с кодом cmd
    function DizasmCmd(cmd: integer): string; virtual;
    // Дизасемблирование отдельной команды по адресу addr
    function DizasmAddr(addr: integer): string; virtual;

    // Получение данных по адресу
    function Data(pos: integer): integer; virtual;
    // Сколько скомпилировано данных
    function DataCount: integer; virtual;
    // Максимальный размер памяти данных
    function MaxData: integer; virtual;

    // * Обработка строки
    procedure Evaluate(const tib: string); virtual;
    // or
    // * Обработка всего файла, в этом случае дополнительно нужно сбросить флаг hasEvaluate
    procedure EvaluateFile(const fileName: string); virtual;

    // Вызывается перед компиляцией
    procedure BeginCompile; virtual;
    // Вызывается после компиляции
    procedure EndCompile; virtual;

    // * Получение кода последней ошибки
    function LastError: integer; virtual;
    // Получение последнего разбираемого слова
    function LastToken: string; virtual;
    // Получение сообщения об ошибке
    function LastErrorMessage: string; virtual;

    // Текст нового файла
    function NewFileText: string; virtual;
    // Оптимизация
    procedure Optimize; virtual;
  end;

  // todo: переделать в TProtocol и пусть он сам заботится о том, по какому интерфейсу заливать код
  PDownloader = ^TDownloader;
  TDownloader = class
  private
  public
    function isOpen: boolean; virtual;
    procedure Open; virtual; abstract;
    procedure Close; virtual; abstract;

    procedure SendByte(buf: byte); virtual; abstract;
    procedure Send(buf: array of byte); overload; virtual;
    procedure Send(buf: array of byte; size: integer); overload; virtual;
    procedure Send(buf: integer); overload; virtual;
    procedure Send(buf: word); overload; virtual;
    procedure Send(buf: byte); overload; virtual;

    procedure GetByte(var buf: byte); virtual; abstract;
    procedure Get(var buf: array of byte); overload; virtual;
    procedure Get(var buf: array of byte; size: integer); overload; virtual;
    procedure Get(var buf: integer); overload; virtual;
    procedure Get(var buf: word); overload; virtual;
    procedure Get(var buf: byte); overload; virtual;
  end;

const
  DONT_HAS_EVALUATE = 'Компилятор не имеет функции Evaluate.';

  // подсветка
  tokUser              = 255;
  tokImmediate         = tokUser;
  tokAlfaBet           = tokUser - 1;
  tokVar               = tokUser - 2;
  tokDict              = tokUser - 3;
  tokErrorDict         = tokUser - 4;

var
  compiler: TTargetCompiler = nil;
  debuger: TDebuger = nil;
  downloader: TDownloader = nil;

  currentDevice: TDeviceType = devNone;
  currentCompiler: TCompilerType = compilerNone;
  SynLightWords: TStringList = nil;

  ExePath: string;
  FilePath: string;

  hTakt: THandle;

procedure AddSynlightWord(name: string; _type: integer);


implementation

procedure AddSynlightWord(name: string; _type: integer);
begin
  if SynLightWords = nil then
    SynLightWords := TStringList.Create;
  SynLightWords.AddObject(name, TObject(_type));
end;

{ TDebuger }

procedure TDebuger.ClearCode;
var
  i: integer;
begin
  for i := 0 to MaxCode-1 do
    Code[i] := 0;
end;

procedure TDebuger.ClearData;
var
  i: integer;
begin
  for i := 0 to MaxData-1 do
    Data[i] := 0;
end;

constructor TDebuger.Create;
begin
  inherited;
end;

destructor TDebuger.Destroy;
begin
  inherited;
end;

procedure TDebuger.Error(errorNumber: integer);
begin
  FError := errorNumber;
end;

procedure TDebuger.Reset;
begin
  
end;

procedure TDebuger.RunForCommands(commandCount: integer);
begin
  {do nothing};
end;

procedure TDebuger.RunForStepOverCommands(commandCount: integer);
begin
  {do nothing};
end;

procedure TDebuger.RunForTime(milliSeconds: integer);
begin
  {do nothing};
end;

procedure TDebuger.RunToCursor(programmCounter: integer);
begin
  {do nothing};
end;

procedure TDebuger.RunUntilReturn;
begin
  {do nothing};
end;

procedure TDebuger.StepOver;
begin
  {do nothing};
end;

procedure TDebuger.TraceInto;
begin
  {do nothing};
end;

procedure TDebuger.TurnOff;
begin
  {do nothing};
end;

procedure TDebuger.TurnOn;
begin
  Reset;
end;

{ TTargetCompiler }

procedure TTargetCompiler.BeginCompile;
begin
  {do nothing}
end;

function TTargetCompiler.Code(pos: integer): integer;
begin
  Result := 0;
end;

function TTargetCompiler.CodeCount: integer;
begin
  Result := 0;
end;

function TTargetCompiler.Data(pos: integer): integer;
begin
  Result := 0;
end;

function TTargetCompiler.DataCount: integer;
begin
  Result := 0;
end;

function TTargetCompiler.DizasmCmd(cmd: integer): string;
begin
  Result := IntToHex(cmd, 0);
end;

function TTargetCompiler.DizasmAddr(addr: integer): string;
begin
  Result := DizasmCmd(Code(addr));
end;

function TTargetCompiler.GetCmdColor(cmd: integer): cardinal;
begin
  Result := $000000;
end;

procedure TTargetCompiler.EndCompile;
begin
  {do nothing}
end;

procedure TTargetCompiler.Evaluate(const tib: string);
begin
  {do nothing}
end;

procedure TTargetCompiler.EvaluateFile(const fileName: string);
var
  inputFile: TextFile;
  str: string;
begin
  if not hasEvaluate then
    raise Exception.Create(DONT_HAS_EVALUATE);

  if not FileExists(fileName) then
    Exit;

  AssignFile(inputFile, fileName);
  Reset(inputFile);

  BeginCompile;
  while not EoF(inputFile) and (LastError = 0) do
  begin
    readln(inputFile, str);
    Evaluate(str);
  end;
  EndCompile;

  CloseFile(inputFile);
end;

function TTargetCompiler.LastError: integer;
begin
  Result := 0;
end;

function TTargetCompiler.LastErrorMessage: string;
begin
  Result := '';
end;

function TTargetCompiler.LastToken: string;
begin
  Result := '';
end;

function TTargetCompiler.MaxCode: integer;
begin
  Result := 0;
end;

function TTargetCompiler.MaxData: integer;
begin
  Result := 0;
end;

function TTargetCompiler.NewFileText: string;
begin
  Result := '';
end;

procedure TTargetCompiler.Optimize;
begin
  {do nothing};
end;

constructor TTargetCompiler.Create;
begin
  inherited;

  hasEvaluate := true;
end;

{ TDownloader }

procedure TDownloader.Send(buf: array of byte);
begin
  Send(buf, sizeof(buf));
end;

procedure TDownloader.Send(buf: array of byte; size: integer);
var
  i: integer;
begin
  try
    for i := 0 to size-1 do
      SendByte(buf[Low(buf)+i]);
  except
    {$WARNINGS OFF}
    on EAbstractError do
      Assert(false, 'TDownloader.Send: Ошибка при вызове SendByte.'+#13#10+
                    'Необходимо определить SendByte в наследуемом классе.');
    {$WARNINGS ON}
    else
      MessageBox(0, 'Ошибка при отправке байта', 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TDownloader.Send(buf: integer);
begin
  Send([buf, buf shr 8, buf shr 16, buf shr 24]);
end;

procedure TDownloader.Send(buf: word);
begin
  Send([buf, buf shr 8]);
end;

procedure TDownloader.Send(buf: byte);
begin
  Send([buf]);
end;

procedure TDownloader.Get(var buf: array of byte);
begin
  Get(buf, sizeof(buf));
end;

procedure TDownloader.Get(var buf: array of byte; size: integer);
var
  i: integer;
begin
  try
    for i := 0 to size-1 do
      GetByte(buf[Low(buf)+i]);
  except
    {$WARNINGS OFF}
    on EAbstractError do
      Assert(false, 'TDownloader.Get: Ошибка при вызове GetByte.'+#13#10+
                    'Необходимо определить GetByte в наследуемом классе.');
    {$WARNINGS ON}
    else
      MessageBox(0, 'Ошибка при принятии байта', 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

procedure TDownloader.Get(var buf: integer);
type
  tinyArr = array[0..3] of byte;
begin
  Get(tinyArr(buf));
end;

procedure TDownloader.Get(var buf: word);
type
  tinyArr = array[0..1] of byte;
begin
  Get(tinyArr(buf));
end;

procedure TDownloader.Get(var buf: byte);
type
  tinyArr = array[0..0] of byte;
begin
  Get(tinyArr(buf));
end;

function TDownloader.isOpen: boolean;
begin
  Result := true;
end;

end.

