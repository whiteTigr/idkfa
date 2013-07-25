unit uComTerminal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ToolWin, Buttons;

type
  TfComTerminal = class(TForm)
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    mTerminal: TMemo;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ToolButton1: TToolButton;
    BitBtn1: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fComTerminal: TfComTerminal;

implementation

{$R *.dfm}

end.
