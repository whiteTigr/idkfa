unit uDownloadCom;

interface

uses uGlobal, Windows, SysUtils;

type
  TDownloaderCom = class(TDownloader)
  private
    FHCom: cardinal;
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

    procedure GetByte(var buf: byte); override;
    procedure Get(var buf: array of byte); overload; override;
  end;

implementation

{ TDownloaderCom }

procedure TDownloaderCom.Close;
begin
  CloseHandle(FHCom);
  FHCom := 0;
end;

// dcb flags
//  DWORD fBinary  :1;
//  DWORD fParity  :1;
//  DWORD fOutxCtsFlow  :1;
//  DWORD fOutxDsrFlow  :1;
//
//  DWORD fDtrControl  :2;
//  DWORD fDsrSensitivity  :1;
//  DWORD fTXContinueOnXoff  :1;
//
//  DWORD fOutX  :1;
//  DWORD fInX  :1;
//  DWORD fErrorChar  :1;
//  DWORD fNull  :1;
//
//  DWORD fRtsControl  :2;
//  DWORD fAbortOnError  :1;
//  DWORD fDummy2  :17;

procedure TDownloaderCom.Open;
var
  DCB: _DCB;
  TimeOuts: COMMTIMEOUTS;
begin
  FHCom := CreateFile(PChar('\\.\' + ComName), GENERIC_READ + GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if integer(FHCom) = -1 then
    raise Exception.Create('Cannot open selected port (createFile error ¹' + IntToStr(GetLastError) + ')');

  GetCommState(FHCom, dcb);
  dcb.Parity:= NOPARITY;
  dcb.BaudRate:= baudrate;
  dcb.XonLim:= 1024;
  dcb.XoffLim:= 1024;
  dcb.wReserved:= 0;
  dcb.ByteSize:= 8;
  dcb.StopBits:= ONESTOPBIT;
  dcb.Flags := dcb.Flags and not $300; // disable xon/xoff flow control
  if not SetCommState(FHCom, dcb) then
  begin
    Close;
    raise Exception.Create('Cannot open selected port (setCommState error ¹' + IntToStr(GetLastError) + ')');
  end;

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
begin
  WriteFile(FHCom, buf, sizeof(buf), writted, nil);
end;

procedure TDownloaderCom.Send(const buf: array of byte; size: integer);
var
  writted: cardinal;
begin
  WriteFile(FHCom, buf, size, writted, nil);
end;

procedure TDownloaderCom.SendByte(buf: byte);
var
  written: cardinal;
begin
  WriteFile(FHCom, buf, sizeof(buf), written, nil);
end;

procedure TDownloaderCom.Get(var buf: array of byte);
var
  readen: cardinal;
begin
  ReadFile(FHCom, buf, sizeof(buf), readen, nil);
end;

procedure TDownloaderCom.GetByte(var buf: byte);
var
  readen: cardinal;
begin
  ReadFile(FHCom, buf, sizeof(buf), readen, nil);
end;

function TDownloaderCom.isOpen: boolean;
begin
  Result := integer(FHCom) > 0;
end;

constructor TDownloaderCom.Create;
begin
  inherited;
  FHCom := 0;
  ComName := 'COM1';
  baudrate := 115200;
end;

end.
