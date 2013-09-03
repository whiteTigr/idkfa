unit uDownloadCom;

interface

uses uGlobal, Windows, Messages, SysUtils, Classes, MMSystem, Math, StdCtrls;

const
  BufferSize = 4096; // 2^N

type
  TComBuffer = record
    data: array[0..BufferSize-1] of byte;
    write: integer;
    read: integer;
  end;

  TComOutputThread = class(TThread)
  protected
    procedure Execute; override;
  end;

  TOutputType = (otCharsOnly, otCharsWithHex);

  TComInputThread = class(TThread)
  protected
    procedure Execute; override;
  public
    procedure CopyInputBuffer(buf: PByteArray; out size: integer);
    constructor Create;
  end;

  TDownloaderCom = class(TDownloader)
  private
    FHCom: cardinal;

    FOutputBuffer: TComBuffer;
    FOutputThread: TComOutputThread;

    FInputBuffer: TComBuffer;
    FInputThread: TComInputThread;
    FInputCritical: TRTLCriticalSection;
  public
    ComName: string;
    baudrate: integer;

    constructor Create;

    function isOpen: boolean; override;
    procedure Open; override;
    procedure Close; override;

    procedure SendByte(buf: byte); override;
     
    procedure Send(const buf: array of byte); overload; override;
    procedure Send(const buf: array of byte; size: integer); overload; override;

    procedure GetByte(var buf: byte); overload; override;
    procedure Get(var buf: array of byte; size: integer); overload; override;
    procedure Get(var buf: array of byte); overload; override;

    function InputCount: integer;
    function OutputCount: integer;
  end;

implementation

uses
  uMain;

{ TDownloaderCom }

function TDownloaderCom.InputCount: integer;
var
  Errors: DWORD;
  ComStat: TComStat;
begin
  if isOpen then
  begin
    ClearCommError(FHCom, Errors, @ComStat);
    Result := ComStat.cbInQue;
  end
  else
    Result := 0;
end;

function TDownloaderCom.OutputCount: integer;
var
  Errors: DWORD;
  ComStat: TComStat;
begin
  if isOpen then
  begin
    ClearCommError(FHCom, Errors, @ComStat);
    Result := ComStat.cbOutQue;
  end
  else
    Result := 0;
end;

procedure TDownloaderCom.Close;
begin
  CloseHandle(FHCom);
  FHCom := 0;
end;

procedure TDownloaderCom.Open;
var
  DCB: _DCB;
  TimeOuts: COMMTIMEOUTS;
begin
  FHCom := CreateFile(pchar('\.\\' + ComName), GENERIC_READ + GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);

  GetCommState(FHCom, dcb);
  dcb.Parity:= NOPARITY;
  dcb.BaudRate:= baudrate;
  dcb.XonLim:= 1024;
  dcb.XoffLim:= 1024;
  dcb.wReserved:= 0;
  dcb.ByteSize:= 8;
  dcb.StopBits:= ONESTOPBIT;
  if not SetCommState(FHCom, dcb) then
    raise Exception.Create('Cannot open selected port');

  TimeOuts.ReadIntervalTimeout := 100;
  TimeOuts.ReadTotalTimeoutMultiplier := 100;
  TimeOuts.ReadTotalTimeoutConstant := 100;
  TimeOuts.WriteTotalTimeoutMultiplier := 100;
  TimeOuts.WriteTotalTimeoutConstant := 100;
  SetCommTimeOuts(FHCom, TimeOuts);
end;

procedure TDownloaderCom.Send(const buf: array of byte);
var
  writted: cardinal;
  i: integer;
begin
  WriteFile(FHCom, buf, sizeof(buf), writted, nil);
//  for i := Low(buf) to High(buf) do
//    SendByte(buf[i]);
end;

procedure TDownloaderCom.Send(const buf: array of byte; size: integer);
var
  writted: cardinal;
  i: integer;
begin
  WriteFile(FHCom, buf, size, writted, nil);
//  for i := Low(buf) to Low(buf) + size - 1 do
//    SendByte(buf[i]);
end;

procedure TDownloaderCom.SendByte(buf: byte);
var
  written: cardinal;
begin
//  with FOutputBuffer do
//    if (write - read) and (BufferSize - 1) < (BufferSize - 1) then
//    begin
//      data[write] := buf;
//      inc(write);
//    end
//    else
//      raise Exception.Create('Output buffer overflow');
  WriteFile(FHCom, buf, sizeof(buf), written, nil);
end;

procedure TDownloaderCom.Get(var buf: array of byte);
//var
//  readen: cardinal;
begin
//  ReadFile(FHCom, buf, sizeof(buf), readen, nil);
  Get(buf, sizeof(buf));
end;

procedure TDownloaderCom.Get(var buf: array of byte; size: integer);
var
  DataCount: integer;
begin
  with FInputBuffer do
  begin
    try
      EnterCriticalSection(FInputCritical);
      DataCount := (write - read) and (BufferSize - 1);
      if DataCount < size then
        raise Exception.Create('Input buffer underflow');
      CopyMemory(@buf, @FInputBuffer.data[FInputBuffer.read], sizeof(buf));
      inc(read, sizeof(buf));
    finally
      LeaveCriticalSection(FInputCritical);
    end;
  end;
end;

procedure TDownloaderCom.GetByte(var buf: byte);
//var
//  readen: cardinal;
type
  tinyArr = array[0..0] of byte;
begin
//  ReadFile(FHCom, buf, sizeof(buf), readen, nil);
  Get(tinyArr(buf), 1);
end;

function TDownloaderCom.isOpen: boolean;
begin
  Result := (FHCom > 0);
end;

constructor TDownloaderCom.Create;
begin
  inherited;
  FHCom := 0;
  ComName := 'COM1';
  baudrate := 115200;
  FInputBuffer.write := 0;
  FInputBuffer.read := 0;
  FOutputBuffer.write := 0;
  FOutputBuffer.read := 0;
  InitializeCriticalSection(FInputCritical)
end;

var
  LastLoopTimeBegin: int64;
  ns: int64;
  hTimer: THandle;
  NeededFreq: real = 512;
  TimeBeetwenLoops: real;
  LoopFreq: real;
  LoopTime: real;
  CPUFreq: int64;
  IsFreqCorrection: boolean = false;
  MainTimerTerminated: boolean = false;

procedure MainTimer;
var
  TimeBegin, TimeEnd: int64;
  delta: int64;
  downloadCom: TDownloaderCom absolute downloader;
  readen: Cardinal;
  buf: array[0..4095] of byte;
  BufferLastSize: integer;
begin
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_NORMAL);
  QueryPerformanceFrequency(CPUFreq);
  // time = - ns / 100 нс
	ns := - round(1 / NeededFreq * 1E+7);
	hTimer := CreateWaitableTimer(nil, false, nil);
  SetWaitableTimer(hTimer, ns, 10, nil, nil, true);
  while not MainTimerTerminated do
  begin
    timeBeginPeriod(1);
    WaitForSingleObject(hTimer, 1000);
    if ns <> 0 then
      SetWaitableTimer(hTimer, ns, 0, nil, nil, true);

    QueryPerformanceCounter(TimeBegin);
    TimeBeetwenLoops := (TimeBegin - LastLoopTimeBegin) / CPUFreq;
    LoopFreq := 1 / TimeBeetwenLoops;
    LastLoopTimeBegin := TimeBegin;

    if not IsFreqCorrection or
      ((NeededFreq / LoopFreq) < 0.2) or ((NeededFreq / LoopFreq) > 5) then
    begin
      ns := - round(1 / NeededFreq * 1E+7);
    end
    else if IsFreqCorrection then
    begin
      delta := round((NeededFreq - LoopFreq)  * 10000000 / (NeededFreq * NeededFreq));
      delta := delta div 10;
      ns := ns + delta;
    end;
    if ns > -10000 then ns := -10000;
    if ns < -10000000 then ns := -10000000;

    // ProcTimer(nil);

    if downloadCom.InputCount > 0 then
    begin
      ReadFile(downloadCom.FHCom, buf, downloadCom.InputCount, readen, nil);
      try
        EnterCriticalSection(downloadCom.FInputCritical);
        with downloadCom.FInputBuffer do
        begin
          BufferLastSize := BufferSize - write;
          if readen > BufferLastSize then
          begin
            CopyMemory(@data[write], @buf, BufferLastSize);
            CopyMemory(@data[0], @buf[BufferLastSize], readen - BufferLastSize);
          end
          else
          begin
            CopyMemory(@data[write], @buf, readen);
          end;
          write := (write + readen) and (BufferSize - 1);
        end;
      finally
        LeaveCriticalSection(downloadCom.FInputCritical);
      end;
    end;

    PulseEvent(hTakt);

    QueryPerformanceCounter(TimeEnd);
    LoopTime := (TimeEnd - TimeBegin) / CPUFreq;
	  timeEndPeriod(1);
  end;
end;

{ TComOutputThread }

procedure TComOutputThread.Execute;
begin
  Priority := tpNormal;
  repeat
//    WaitForSingleObject(hTakt, 100);
  until Terminated;
end;

{ TComInputThread }

procedure TComInputThread.CopyInputBuffer(buf: PByteArray; out size: integer);
var
  downloadCom: TDownloaderCom absolute downloader;
begin
  try
    EnterCriticalSection(downloadCom.FInputCritical);
    with downloadCom.FInputBuffer do
    begin
      size := 0;
      if write > read then
      begin
        size := write - read;
        CopyMemory(buf, @data[read], size);
      end
      else if write < read then
      begin
        size := BufferSize + write - read;
        CopyMemory(buf, @data[read], BufferSize - read);
        CopyMemory(pointer(integer(buf) + (BufferSize - read)), @data[0], write);
      end;
      read := write;
    end;
  finally
    LeaveCriticalSection(downloadCom.FInputCritical);
  end;
end;

constructor TComInputThread.Create;
begin
  inherited Create(false);
end;

procedure TComInputThread.Execute;
var
  TimeBegin, TimeEnd: int64;
  delta: int64;
  downloadCom: TDownloaderCom absolute downloader;
  readen: Cardinal;
  buf: array[0..4095] of byte;
  BufferLastSize: integer;
begin
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_NORMAL);
  QueryPerformanceFrequency(CPUFreq);
  // time = - ns / 100 нс
	ns := - round(1 / NeededFreq * 1E+7);
	hTimer := CreateWaitableTimer(nil, false, nil);
  SetWaitableTimer(hTimer, ns, 10, nil, nil, true);
  while not Terminated do
  begin
    timeBeginPeriod(1);
    WaitForSingleObject(hTimer, 1000);
    if ns <> 0 then
      SetWaitableTimer(hTimer, ns, 0, nil, nil, true);

    QueryPerformanceCounter(TimeBegin);
    TimeBeetwenLoops := (TimeBegin - LastLoopTimeBegin) / CPUFreq;
    LoopFreq := 1 / TimeBeetwenLoops;
    LastLoopTimeBegin := TimeBegin;

    if not IsFreqCorrection or
      ((NeededFreq / LoopFreq) < 0.2) or ((NeededFreq / LoopFreq) > 5) then
    begin
      ns := - round(1 / NeededFreq * 1E+7);
    end
    else if IsFreqCorrection then
    begin
      delta := round((NeededFreq - LoopFreq)  * 10000000 / (NeededFreq * NeededFreq));
      delta := delta div 10;
      ns := ns + delta;
    end;
    if ns > -10000 then ns := -10000;
    if ns < -10000000 then ns := -10000000;

    // ProcTimer(nil);

    if downloadCom.isOpen and (downloadCom.InputCount > 0) then
    begin
      ReadFile(downloadCom.FHCom, buf, downloadCom.InputCount, readen, nil);
      try
        EnterCriticalSection(downloadCom.FInputCritical);
        with downloadCom.FInputBuffer do
        begin
          BufferLastSize := BufferSize - write;
          if readen > BufferLastSize then
          begin
            CopyMemory(@data[write], @buf, BufferLastSize);
            CopyMemory(@data[0], @buf[BufferLastSize], readen - BufferLastSize);
          end
          else
          begin
            CopyMemory(@data[write], @buf, readen);
          end;
          write := (write + readen) and (BufferSize - 1);
        end;
      finally
        LeaveCriticalSection(downloadCom.FInputCritical);
      end;
      PostMessage(fMain.Handle, WM_TerminalShow, 0, 0);
    end;

    QueryPerformanceCounter(TimeEnd);
    LoopTime := (TimeEnd - TimeBegin) / CPUFreq;
	  timeEndPeriod(1);
  end;
end;

end.
