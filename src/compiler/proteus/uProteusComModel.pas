unit uProteusComModel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, uGlobal, uProteusSoftDebuger;

type
  TfProteusComModel = class(TForm)
    eByteToSend: TEdit;
    bSend: TBitBtn;
    StaticText1: TStaticText;
    eReceivedByte: TEdit;
    procedure bSendClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fProteusComModel: TfProteusComModel;

procedure Outport(addr, data: integer);
function Inport(addr: integer): integer;

implementation

{$R *.dfm}

procedure Outport(addr, data: integer);
begin
  if addr = -1 then
    fProteusComModel.eReceivedByte.Text := IntToStr(data and $FF);
end;

function Inport(addr: integer): integer;
begin
  // состояние ком-порта в Proteus'е завязано на системных регистрах
  Result := not addr;
end;

procedure TfProteusComModel.bSendClick(Sender: TObject);
var
  value: integer;
begin
  value := StrToIntDef(eByteToSend.Text, -1);
  if (value < 0) or (value > 255) then
  begin
    MessageBox(0, 'Неверное значение байта', 'Ошибка', MB_OK or MB_ICONERROR);
    Exit;
  end;

  (debuger as TProteusSoftDebuger).TransmitToCom(value);
end;

procedure TfProteusComModel.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  Hide;
end;

end.
