unit uQuarkCompiler;

interface

uses
  Forms, Windows, Messages, Sysutils, uGlobal, uQuarkDeviceCore;

type
  TQuarkCompiler = class(TTargetCompiler)
  private
    DLLHandle: THandle;
    LastLine: AnsiString;
    FLastError: integer;
    FCode: PByteArray;
    FData: PIntegerArray;

    function _Evaluate(const str: AnsiString): integer;
    function Forth(str:string): integer;
  public
    CompilerName: string;

    constructor Create;
    destructor Destroy; override;

    function Code(pos: integer): integer; override;
    function CodeCount: integer; override;
    function MaxCode: integer; override;

    function Data(pos: integer): integer; override;
    function DataCount: integer; override;
    function MaxData: integer; override;

    function LastError: integer; override;
    function LastToken: string; override;
    function LastErrorMessage: string; override;

    procedure BeginCompile; override;
    procedure EndCompile; override;
    procedure Evaluate(const str: string); override;
    procedure EvaluateFile(const fileName: string); override;

    function GetCmdColor(cmd: integer): cardinal; override;

    function NewFileText: string; override;
  end;

const
  QuarkDll = 'quark.dll';

implementation

var
  eval_str: AnsiString;

function QuarkEvaluate(s : integer): integer; external QuarkDll name 'Evaluate';
function QuarkEvaluateC(s : integer): integer; external QuarkDll name 'EvaluateC';
function QuarkInit(): integer; external QuarkDll name 'Init';
function QuarkDone(): integer; external QuarkDll name 'Done';
function QuarkGetCode(): integer; external QuarkDll name 'GetCode';
function QuarkGetData(): integer; external QuarkDll name 'GetData';
function QuarkGetStack(): integer; external QuarkDll name 'GetStack';
function QuarkGetDepth(): integer; external QuarkDll name 'GetDepth';
function QuarkGetScreen(): integer; external QuarkDll name 'GetScreen';
function QuarkSetHWindow(hwnd : integer): integer; external QuarkDll name 'SetHWindow';
function QuarkForthInfo(): integer; external QuarkDll name 'ForthInfo';

function ExecAndWait(const FileName: string;
                     const WinState: Word): boolean; export;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
  created: boolean;
begin
  CmdLine := '"' + string(Filename) + '" ';
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;

  created := CreateProcess(nil, PChar(string(FileName)), nil, nil, True,
      NORMAL_PRIORITY_CLASS,
      nil, nil, StartInfo, ProcInfo);

  if created then
  begin
    while (WaitForSingleObject(ProcInfo.hProcess, 1) = WAIT_TIMEOUT) do
      Application.ProcessMessages;
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;

  Result := created;
end;

{ TQuarkCompiler }

procedure TQuarkCompiler.BeginCompile;
begin
  QuarkDone;
  QuarkInit;

  Evaluate('" ' + CompilerName + '.tc" L');
  Evaluate('END');
  FCode := PByteArray(Forth('CODE[] DROP'));
  FData := PIntegerArray(Forth('DATA[] DROP'));
  Evaluate('START:');
end;

constructor TQuarkCompiler.Create;
begin
  inherited;

  FCode := 0;
  FData := 0;

  QuarkInit;

  CompilerName := 'kf532';
  hasEvaluate := true;
end;

destructor TQuarkCompiler.Destroy;
begin
  QuarkDone;
//  FreeLibrary(DLLHandle);
  inherited;
end;

procedure TQuarkCompiler.EndCompile;
begin
  if FLastError = 0 then
    Evaluate('END');
end;

function TQuarkCompiler._Evaluate(const str: AnsiString): integer;
begin
  Result := QuarkEvaluate(integer(str));
end;

procedure TQuarkCompiler.Evaluate(const str: string);
begin
  LastLine := str;
  FLastError := _Evaluate(str + #0#0);
end;

procedure TQuarkCompiler.EvaluateFile(const fileName: string);
begin
  ExecAndWait('quark.exe ' + string(fileName), SW_SHOW);
end;

function TQuarkCompiler.Forth(str: string): integer;
var
  Ptr: pointer;
begin
  if _Evaluate(str + #0#0) = 0 then
  begin
    Ptr := pointer(QuarkGetStack + QuarkGetDepth*4);
    Result := integer(Ptr^);
  end
  else
    Result := 0;
end;

function TQuarkCompiler.Code(pos: integer): integer;
begin
  if integer(FCode) > 0 then
    Result := PByte(integer(FCode) + pos)^
  else
    Result := 0;
end;

function TQuarkCompiler.CodeCount: integer;
begin
  Result := Forth('CODE^ DROP');
end;

function TQuarkCompiler.MaxCode: integer;
begin
  Result := Forth('MAXCODE DROP');
end;

function TQuarkCompiler.Data(pos: integer): integer;
begin
  if integer(FData) > 0 then
    Result := PByte(integer(FData) + pos)^
  else
    Result := 0;
end;

function TQuarkCompiler.DataCount: integer;
begin
  Result := Forth('DATA^ DROP');
end;

function TQuarkCompiler.MaxData: integer;
begin
  Result := Forth('MAXDATA DROP');
end;

function TQuarkCompiler.NewFileText: string;
begin
  Result :=
    'MAIN:'#13#10 +
    '2 2 +';
end;

function TQuarkCompiler.LastError: integer;
begin
  Result := FLastError;
end;

function TQuarkCompiler.LastToken: string;
var
  pos: integer;
  res: string;
begin
  if FLastError > 0 then
  begin
    res := '';
    pos := FLastError;
    while (pos > 1) and (LastLine[pos] <> ' ') do
    begin
      dec(pos);
      res := LastLine[pos] + res;
    end;
    Result := res;
  end;
end;

function TQuarkCompiler.LastErrorMessage: string;
begin
  if FLastError = 0 then
    Result := 'OK'
  else
    Result := 'что-то пошло не так';
end;

function TQuarkCompiler.GetCmdColor(cmd: integer): cardinal;
begin
  case cmd of
    cmdNOP: Result := $C0C0C0;
    cmdRET: Result := $00B0FF;
    cmdJMP, cmdRJMP: Result := $2090FF;
    cmdRIF: Result := $4070FF;
    cmdCALL: Result := $6050FF;
    $20..$3F: Result := $FF6050;
    else
      Result := $000000;
  end;
end;

end.
