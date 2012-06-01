unit uComModel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfComModel = class(TForm)
    eByteToSend: TEdit;
    bSend: TBitBtn;
    StaticText1: TStaticText;
    eReceivedByte: TEdit;
    procedure bSendClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fComModel: TfComModel;

procedure Outport(addr, data: integer);
function Inport(addr: integer): integer;

implementation

{$R *.dfm}

var
  comData: integer;
  comCount: integer = 0;
  lastComCount: integer = 0;

procedure DoNothing;
begin
end;

procedure Outport(addr, data: integer);
begin
  case addr of
    1100: fComModel.eReceivedByte.Text := IntToStr(data and $FF);
    1101: DoNothing; // we=data; не требуется в модели
    1102: inc(lastComCount);
    1104: lastComCount := comCount;
  else
    DoNothing;
  end;
end;

function Inport(addr: integer): integer;
begin
  case addr of
    1101: Result := comData;
    1102: Result := integer(comCount <> lastComCount);
  else
    Result := not addr;
  end;
end;

procedure TfComModel.bSendClick(Sender: TObject);
var
  value: integer;
begin
  value := StrToIntDef(eByteToSend.Text, -1);
  if (value < 0) or (value > 255) then
  begin
    MessageBox(0, 'Неверное значение байта', 'Ошибка', MB_OK or MB_ICONERROR);
    Exit;
  end;

  comData := value;
  inc(comCount);
end;

end.
