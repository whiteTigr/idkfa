unit uQuarkDevice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfQuarkDevice = class(TForm)
    Panel1: TPanel;
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
