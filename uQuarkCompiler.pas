unit uQuarkCompiler;

interface

uses
  Forms, Windows, Messages, Sysutils, uGlobal;

type
  TQuarkCompiler = class(TTargetCompiler)
  private
  public
    constructor Create;

    procedure EvaluateFile(fileName: string); override;
  end;

implementation

{ TQuarkCompiler }

function ExecAndWait(const FileName: ShortString;
                     const WinState: Word): boolean; export;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
  created: boolean;
begin
  CmdLine := '"' + Filename + '" ';
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

constructor TQuarkCompiler.Create;
begin
  inherited;

  hasEvaluate := false;
end;

procedure TQuarkCompiler.EvaluateFile(fileName: string);
begin
  ExecAndWait('quark.exe ' + fileName, SW_SHOW);
end;

end.
