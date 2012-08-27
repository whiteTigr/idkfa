unit uDownload;
// todo: ужасный код. Ќужен рефакторинг

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList, ComCtrls, ExtCtrls, Gauges, StrUtils, Math, CommCtrl, uGlobal, uDownloadCom;

type
  TFormDownload = class(TForm)
    bClose: TBitBtn;
    cbComName: TComboBox;
    cbBaudrate: TComboBox;
    bDownload: TSpeedButton;
    ProgressBar1: TProgressBar;
    bCancel: TBitBtn;
    ActionList1: TActionList;
    ProcessDownload: TAction;
    labelStatus: TLabel;
    mLog: TMemo;
    eByteToSend: TEdit;
    bSendByte: TBitBtn;
    bSelectFile: TBitBtn;
    eFileName: TEdit;
    rgGrouping: TRadioGroup;
    eGroupedByBytes: TEdit;
    Label3: TLabel;
    cbWaitingForEcho: TCheckBox;
    cbSendPacketNumber: TCheckBox;
    cbSendCRC: TCheckBox;
    bSendFile: TBitBtn;
    Bevel1: TBevel;
    OpenDialog2: TOpenDialog;
    cbSendBeforePacket: TCheckBox;
    eHowMany: TEdit;
    bSaveToFile: TBitBtn;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    cbCore: TComboBox;
    Label5: TLabel;
    Label8: TLabel;
    eCountPackage: TEdit;
    eWaitingCoef: TEdit;
    cbPrepareProc: TComboBox;
    procedure bCloseClick(Sender: TObject);
    procedure ProcessDownloadExecute(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bSendByteClick(Sender: TObject);
    procedure bSelectFileClick(Sender: TObject);
    procedure bSendFileClick(Sender: TObject);
    procedure bSaveToFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  SendCountPackageDefault: integer = 16;
  SendWaitingCoefDefault: real = 5;

var
  FormDownload: TFormDownload;

  SendCountPackage: integer = 16; // размер пакета при посылке
  SendWaitingCoef: double = 5; // на сколько больше необходимого времени ждать после посылки пакета

procedure Load_v3(data: integer; web: integer);
procedure ToSend(buf: byte); overload;
procedure ToSend(buf: array of byte); overload;

implementation

uses
  uMain;

{$R *.dfm}

const
  CoreA = 0;
  CoreB = 1;

  CodeWECmd: array[0..1] of integer = ($F2, $F8);
  DataWECmd: array[0..1] of integer = ($F3, $F9);
  ClearResetCmd: array[0..1] of integer = ($F4, $FA);
  SetResetCmd: array[0..1] of integer = ($F5, $FB);
  clearDatabufCmd: integer = $F0;
  clearAddrbufCmd: integer = $F1;
  incAddrCmd: integer = $F7;

var
    UserBreak : boolean;
    FileSend : file of byte;
    SendBuf : array of byte;
    SendSize : integer;

//-------
function  IntToBin(int, Len: int64): string;
var
  tmpInt: int64;
  Rez: string;
begin
  tmpInt := int;
  Rez := '';
  while tmpInt <> 0 do
  begin
    Rez := Rez + IntToStr(tmpInt mod 2);
    tmpInt := tmpInt div 2;
  end;

  while Length(Rez) < Len do
    Rez := Rez + '0';

  Result := ReverseString(Rez);
end;

//-------
function  BinToInt(bin: string): int64;
var
  i: integer;
  Rez: int64;
  tmpBin: string;
begin
  Rez := 0;
  for i := 1 to Length(tmpBin) do
    Rez := Rez * 2 + StrToInt(bin[i]);

  Result := Rez;
end;

procedure TFormDownload.bCloseClick(Sender: TObject);
begin
  Close;
end;

var
  gauge: TGauge;
  DownloadLog: TextFile;

procedure BufToLog(buf: array of byte; count: integer); overload;
var
  i: integer;
begin
  for i := 0 to count-1 do
    writeln(DownloadLog, #9, 'receive <= ''1''; d <= "', IntToBin(buf[i], 8), '"; wait for clk_period; receive <= ''0''; wait for receive_period - clk_period;');
end;

procedure BufToLog(buf: byte); overload;
begin
  BufToLog([buf], 1);
end;

var
  SendBuffer: array[0..1048575] of byte; // 1 mb
  SendBufferPtr: integer;
  SendPtr: integer;
  DataStart: integer;

procedure ToSend(buf: byte); overload;
begin
  SendBuffer[SendBufferPtr] := buf;
  inc(SendBufferPtr);
end;

procedure ToSend(buf: array of byte; count: integer); overload;
var
  i: integer;
begin
  for i := Low(buf) to Low(buf) + count - 1 do
    ToSend(buf[i]);
end;

procedure ToSend(buf: array of byte); overload;
begin
  ToSend(buf, Length(buf));
end;

type
  PBuffer = ^TBuffer;
  TBuffer = record
    data: array[0..255] of byte;
    ptr: integer;
  end;

var
  Buffer: array[0..1] of TBuffer;
  databuf: integer;
  webCmd: integer;

procedure ToBuffer(value: byte; buffer: PBuffer);
begin
  buffer.data[buffer.ptr] := value;
  inc(buffer.ptr);
end;

procedure PrepareData(dataOld, dataNew: integer; buffer: PBuffer);
var
  mask: integer;
  i: integer;
  dataNewToSend: integer;
begin
  mask := $F;
  dataNewToSend := dataNew;

  for i := 0 to 7 do
  begin
    if (dataOld and mask) <> (dataNew and mask) then
      ToBuffer((dataNewToSend and $F) + i * 16, buffer);
    mask := mask shl 4;
    dataNewToSend := dataNewToSend shr 4;
  end;

  ToBuffer(webCmd, buffer);
  ToBuffer(incAddrCmd, buffer);
end;

procedure ClearBuffers;
var
  i: integer;
begin
  for i := Low(Buffer) to High(Buffer) do
    Buffer[i].ptr := 0;
end;

function SelectMinBuffer: PBuffer;
var
  i: integer;
  min: integer;
  lowIndex: integer;
begin
  lowIndex := Low(Buffer);

  min := lowIndex;

  for i := lowIndex + 1 to High(Buffer) do
    if Buffer[i].ptr <= Buffer[min].ptr then
      min := i;

  Result := @Buffer[min];
end;

procedure Load_v3(data: integer; web: integer);
var
  minBuffer: PBuffer;
begin
  webCmd := web;

  ClearBuffers;

  PrepareData(databuf, data, @Buffer[0]);

  ToBuffer(clearDatabufCmd, @Buffer[1]);
  PrepareData(0, data, @Buffer[1]);

  databuf := data;

  minBuffer := SelectMinBuffer;
  ToSend(minBuffer.data, minBuffer.ptr);
end;

procedure PrepareToSend;
var
  i: integer;
  coreIndex: integer;
begin
  CoreIndex := FormDownload.cbCore.ItemIndex;
  SendBufferPtr := 0;
  ToSend(SetResetCmd[CoreIndex]);
  databuf := 0;
  ToSend(clearDatabufCmd);
  ToSend(clearAddrbufCmd);
  for i := 0 to compiler.CodeCount-1 do
    Load_v3(compiler.Code(i), CodeWECmd[CoreIndex]);
  databuf := 0;
  DataStart := SendBufferPtr;
  ToSend(clearDatabufCmd);
  ToSend(clearAddrbufCmd);
  for i := 0 to compiler.DataCount-1 do
    Load_v3(compiler.Data(i), DataWECmd[CoreIndex]);
  ToSend(ClearResetCmd[CoreIndex]);
end;

procedure ProgrammByte(value: byte);
begin
  ToSend([value and $F, ((value shr 4) and $F) or $10, 241, 242]);
end;

procedure PrepareToSend_Proteus;
var
  i: integer;
begin
  SendBufferPtr := 0;
  ToSend([243, 240]); // reset, addr=0
  for i := 0 to compiler.CodeCount - 1 do
  begin
    ProgrammByte(compiler.Code(i));
  end;
  ToSend(244);
end;

procedure SetReset;
begin
  downloader.SendByte(SetResetCmd[FormDownload.cbCore.ItemIndex]);
end;

procedure ClearReset;
begin
  downloader.SendByte(ClearResetCmd[FormDownload.cbCore.ItemIndex]);
end;

procedure PrepareVisualElements;
begin
  FormDownload.mLog.Clear;

  if gauge = nil then
  begin
    gauge := TGauge.Create(fMain.StatusBar1);
    gauge.Parent := fMain.StatusBar1;
    gauge.Height := fMain.StatusBar1.Height - 4;
    gauge.Width := 195;
    gauge.Left := 2;
    gauge.Top := 2;
    gauge.MinValue := 0;
    gauge.MaxValue := 100;
  end;

  FormDownload.ProgressBar1.Show;
  gauge.Show;
  FormDownload.labelStatus.Hide;
  FormDownload.bCancel.Show;
  FormDownload.bCancel.Enabled := true;
end;

procedure HideVisualElements;
begin
  FormDownload.ProgressBar1.Hide;
  gauge.hide;
  fMain.Hide;
  fMain.Show;
  if FormDownload.Visible then FormDownload.Show;
  FormDownload.bCancel.Hide;
  FormDownload.bCancel.Enabled := false;
  FormDownload.labelStatus.Show;
end;

procedure ReadSendCountPackage;
begin
  if not TryStrToInt(FormDownload.eCountPackage.Text, SendCountPackage) then
  begin
    MessageBox(0, '"Package size" is not integer number. Setted to default value.', 'Error', MB_OK or MB_ICONERROR);
    SendCountPackage := SendCountPackageDefault;
  end;
end;

procedure ReadSendWaitingCoef;
begin
  if not TryStrToFloat(FormDownload.eWaitingCoef.Text, SendWaitingCoef) then
  begin
    MessageBox(0, '"Waiting coef" is not float number. Setted to default value.', 'Error', MB_OK or MB_ICONERROR);
    SendWaitingCoef := SendWaitingCoefDefault;
  end;
end;

// todo: слишком больша€ процедура
procedure TFormDownload.ProcessDownloadExecute(Sender: TObject);
var
  StopPtr: integer;
  time: real;
  f: TextFile;
  i: integer;
  needToWait: real;
  downloadCom: TDownloaderCom absolute downloader;
label finishit;
begin
  time := Now;

  PrepareVisualElements;
  ReadSendCountPackage;
  ReadSendWaitingCoef;

  downloadCom.ComName := cbComName.Text;
  downloadCom.baudrate := StrToInt(cbBaudrate.Text);
  downloader.Open;

  Application.ProcessMessages;

  UserBreak := false;

  case cbPrepareProc.ItemIndex of
    0: PrepareToSend;
    1: PrepareToSend_Proteus;
  end;

  if fMain.Createdownloadlog1.Checked then
  begin
    AssignFile(f, 'download.log');
    Rewrite(f);
    for i := 0 to SendBufferPtr-1 do
      writeln(f, SendBuffer[i], #9, IntToHex(SendBuffer[i], 2));
    CloseFile(f);
  end;

  SendPtr := 0;
  gauge.Progress := 0;
  ProgressBar1.Position := 0;
  if fMain.Downloaddatamemory1.Checked then
    StopPtr := SendBufferPtr
  else
    StopPtr := DataStart;
  fMain.Console.Lines.Add('Bytes to send: ' + inttostr(StopPtr) + ' b (' + floattostr(round(StopPtr/1024*100)/100) + ' kb)');
  fMain.Console.Lines.Add('Estimated download time: ' + floattostr(round(StopPtr * 8 / 115200 * SendWaitingCoef * 180)/100) + ' s');
  ProgressBar1.Max := StopPtr;
  gauge.MaxValue := StopPtr;
  while ((SendPtr + SendCountPackage) < StopPtr) do
  begin
    if SendPtr < DataStart then
      gauge.ForeColor := $3FFF3F
    else
      gauge.ForeColor := $FF3F3F;

    downloader.Send(SendBuffer[SendPtr], SendCountPackage);
    Application.ProcessMessages;
    needToWait := needToWait + SendCountPackage * 8 / 115200 * SendWaitingCoef * 1000;
    if trunc(needToWait) > 0 then
    begin
      sleep(trunc(needToWait));
      needToWait := frac(needToWait);
    end;
    gauge.AddProgress(SendCountPackage);
    ProgressBar1.StepBy(SendCountPackage);

    inc(SendPtr, SendCountPackage);

    if UserBreak then GOTO FinishIt;
  end;
  downloader.Send(SendBuffer[SendPtr], StopPtr - SendPtr);
  gauge.AddProgress(StopPtr - SendPtr);
  ProgressBar1.StepBy(StopPtr - SendPtr);
  Application.ProcessMessages;

  ClearReset;

FinishIt:
  downloader.Close;

  if UserBreak then labelStatus.Caption := 'Cancelled.'
               else labelStatus.Caption := 'Successfully.';
  fMain.Console.Lines.Add('Real download time: ' + floattostr(Round((Now - time) * 24 * 60 * 60 * 100) / 100) + ' s');

  HideVisualElements;
end;

procedure TFormDownload.bCancelClick(Sender: TObject);
begin
  UserBreak := true;
end;

procedure TFormDownload.bSendByteClick(Sender: TObject);
var
  downloadCom: TDownloaderCom absolute downloader;
begin
  downloadCom.ComName := PChar(cbComName.Items[cbComName.ItemIndex]);
  downloadCom.baudrate := StrToInt(cbBaudrate.Text);
  downloader.Open;
  downloader.Send(Byte(StrToInt(eByteToSend.Text)));
  downloader.Close;
end;

procedure TFormDownload.bSelectFileClick(Sender: TObject);
begin
  if OpenDialog2.Execute then
   begin
    eFileName.Text := OpenDialog2.FileName;
   end;
end;

procedure TFormDownload.bSendFileClick(Sender: TObject);
var
  Buf : byte;
  i : integer;
  NumBlocks, BytesInBlock, index : integer;
  downloadCom: TDownloaderCom absolute downloader;
begin
  mLog.Clear;

  AssignFile(FileSend, eFileName.Text);
  Reset(FileSend);

  SendSize := FileSize(FileSend);

  SetLength(SendBuf, SendSize);
  for i := 0 to SendSize - 1 do
    read(FileSend, SendBuf[i]);
  CloseFile(FileSend);

  downloadCom.ComName := cbComName.Text;
  downloadCom.baudrate := StrToInt(cbBaudrate.Text);
  downloader.Open;

  if rgGrouping.ItemIndex = 0 then
  begin
    NumBlocks := 1;
    BytesInBlock := SendSize;
  end
  else
  begin
    BytesInBlock := StrToInt(eGroupedByBytes.Text);
    NumBlocks := Trunc(SendSize / BytesInBlock);
    if BytesInBlock * NumBlocks < SendSize then
      Inc(NumBlocks);
  end;

  index := 0;
  mLog.Lines.Clear;
  mLog.Lines.Add('Blocks: ' + IntToStr(NumBlocks));
  Application.ProcessMessages;

  for i := 1 to NumBlocks do
  begin

    if cbSendBeforePacket.Checked then
    begin
      downloader.SendByte(StrToInt(eByteToSend.Text));
      mLog.Lines.Add(eByteToSend.Text);
    end;

    downloader.Send(SendBuf[index], BytesInBlock);
    mLog.Lines.Add('Sending block: ' + IntToStr(i));
    if cbWaitingForEcho.Checked then
    begin
      downloader.GetByte(buf);
      mLog.Lines.Add('Answer: ' + IntToStr(Buf));
    end;
    Inc(index, BytesInBlock);
    Application.ProcessMessages;
  end;

  downloader.Close;
  mLog.Lines.Add('Completed');
end;

procedure TFormDownload.bSaveToFileClick(Sender: TObject);
var
  i: integer;
  HowMany: integer;
  fSave: file of byte;
  downloadCom: TDownloaderCom absolute downloader;
begin
  HowMany := StrToInt(eHowMany.Text);
  SetLength(SendBuf, HowMany);

  downloadCom.ComName := cbComName.Text;
  downloadCom.baudrate := StrToInt(cbBaudrate.Text);
  downloader.Open;

  downloader.SendByte(StrToInt(eByteToSend.Text));
  downloader.Get(SendBuf, HowMany);
  // todo: добавить LastWriten и LastReaden в downloader
  //Memo1.Lines.Add('Saved ' + IntToStr(HowMany) + '/' + IntToStr(written)+' bytes.');
  mLog.Lines.Add('Saved ' + IntToStr(HowMany) + ' bytes.');
  downloader.Close;

  AssignFile(fSave, eFileName.Text);
  Rewrite(fSave);
  for i := 1 to HowMany do
    Write(fSave, SendBuf[i-1]);
  CloseFile(fSave);
end;

end.
