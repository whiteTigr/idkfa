program idKFa;

{$R *.dres}

uses
  Forms,
  uMain in 'uMain.pas' {fMain},
  uDownload in 'uDownload.pas' {FormDownload},
  AboutWindow in 'AboutWindow.pas' {fAbout},
  uStyleEditor in 'uStyleEditor.pas' {fStyleEditor},
  uSimulator in 'uSimulator.pas' {fSimulator},
  uLed in 'uLed.pas' {fLed},
  uComModel in 'uComModel.pas' {fComModel},
  uGlobal in 'uGlobal.pas',
  uDownloadCom in 'uDownloadCom.pas',
  uCompilerCore in 'uCompilerCore.pas',
  uForthCompiler in 'uForthCompiler.pas',
  uForthDevice in 'uForthDevice.pas' {fForthDevice},
  uForthDeviceCore in 'uForthDeviceCore.pas',
  uForthSoftDebuger in 'uForthSoftDebuger.pas',
  uForthHardDebuger in 'uForthHardDebuger.pas',
  uBrainfuckCompiler in 'uBrainfuckCompiler.pas',
  uBrainfuckDevice in 'uBrainfuckDevice.pas' {fBrainfuckDevice},
  uBrainfuckDeviceCore in 'uBrainfuckDeviceCore.pas',
  uProteusDeviceCore in 'uProteusDeviceCore.pas',
  uProteusDevice in 'uProteusDevice.pas' {fProteusDevice},
  uCommonFunctions in 'uCommonFunctions.pas',
  uProteusSoftDebuger in 'uProteusSoftDebuger.pas',
  uProteusCompiler in 'uProteusCompiler.pas',
  UnitSyntaxMemo in 'UnitSyntaxMemo.pas',
  uRecordList in 'uRecordList.pas',
  uQuarkCompiler in 'uQuarkCompiler.pas',
  uQuarkDeviceCore in 'uQuarkDeviceCore.pas',
  uQuarkDevice in 'uQuarkDevice.pas' {fQuarkDevice};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Forth cross-compiler';
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TFormDownload, FormDownload);
  Application.CreateForm(TfAbout, fAbout);
  Application.CreateForm(TfStyleEditor, fStyleEditor);
  Application.CreateForm(TfSimulator, fSimulator);
  Application.CreateForm(TfBrainfuckDevice, fBrainfuckDevice);
  Application.CreateForm(TfProteusDevice, fProteusDevice);
  Application.CreateForm(TfQuarkDevice, fQuarkDevice);
  Application.Run;
end.






