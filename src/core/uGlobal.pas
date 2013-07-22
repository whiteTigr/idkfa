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

    // ����� ������
    procedure Reset; virtual;
    // ���, � ������� � ������������
    procedure TraceInto; virtual;
    // ���, ��� ������ � ������������
    procedure StepOver; virtual;
    // ���������� ��������� �� ������� (programmCounter)
    procedure RunToCursor(programmCounter: integer); virtual;
    // ���������� ��������� �� ������� ������ �� ������������
    procedure RunUntilReturn; virtual;
    // ���������� ��������� � ������� �������� �������
    procedure RunForTime(milliSeconds: integer); virtual;
    // ���������� �������� ���������� ������� ���������
    procedure RunForCommands(commandCount: integer); virtual;
    // ����������� �������� ���������� ������� ���������, ��� ������ � ������������
    procedure RunForStepOverCommands(commandCount: integer); virtual;
  end;

  PTargetCompiler = ^TTargetCompiler;
  TTargetCompiler = class
  private
  public
    // ���������� ���������� � true, ���� �������������� ��������� Evaluate
    // ��� �������������� EvaluateFile � ���������� � false
    hasEvaluate: boolean;

    constructor Create;

    // * - ����������� ��� ���������������. ����������� ����� ��� ������ �����������.
    // * ��������� ���� �� ������
    function Code(pos: integer): integer; virtual;
    // * ������� �������������� ����
    function CodeCount: integer; virtual;
    // ��������� ����� ������� (��� ����������)
    function GetCmdColor(cmd: integer): cardinal; virtual;
    // ������������ ������ ������ ����
    function MaxCode: integer; virtual;
    // ����������������� ��������� ������� � ����� cmd
    function DizasmCmd(cmd: integer): string; virtual;
    // ����������������� ��������� ������� �� ������ addr
    function DizasmAddr(addr: integer): string; virtual;

    // ��������� ������ �� ������
    function Data(pos: integer): integer; virtual;
    // ������� �������������� ������
    function DataCount: integer; virtual;
    // ������������ ������ ������ ������
    function MaxData: integer; virtual;

    // * ��������� ������
    procedure Evaluate(const tib: string); virtual;
    // or
    // * ��������� ����� �����, � ���� ������ ������������� ����� �������� ���� hasEvaluate
    procedure EvaluateFile(const fileName: string); virtual;

    // ���������� ����� �����������
    procedure BeginCompile; virtual;
    // ���������� ����� ����������
    procedure EndCompile; virtual;

    // * ��������� ���� ��������� ������
    function LastError: integer; virtual;
    // ��������� ���������� ������������ �����
    function LastToken: string; virtual;
    // ��������� ��������� �� ������
    function LastErrorMessage: string; virtual;

    // ����� ������ �����
    function NewFileText: string; virtual;
    // �����������
    procedure Optimize; virtual;
  end;

  // todo: ���������� � TProtocol � ����� �� ��� ��������� � ���, �� ������ ���������� �������� ���
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
  DONT_HAS_EVALUATE = '���������� �� ����� ������� Evaluate.';

  // ���������
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
      Assert(false, 'TDownloader.Send: ������ ��� ������ SendByte.'+#13#10+
                    '���������� ���������� SendByte � ����������� ������.');
    {$WARNINGS ON}
    else
      MessageBox(0, '������ ��� �������� �����', '������', MB_OK or MB_ICONERROR);
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
      Assert(false, 'TDownloader.Get: ������ ��� ������ GetByte.'+#13#10+
                    '���������� ���������� GetByte � ����������� ������.');
    {$WARNINGS ON}
    else
      MessageBox(0, '������ ��� �������� �����', '������', MB_OK or MB_ICONERROR);
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

