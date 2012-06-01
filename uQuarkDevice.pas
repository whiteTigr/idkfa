unit uQuarkDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfQuarkDevice = class(TForm)
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  published
    procedure ShowDevice;
  end;

var
  fQuarkDevice: TfQuarkDevice;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfQuarkDevice.ShowDevice;
begin

end;

end.
