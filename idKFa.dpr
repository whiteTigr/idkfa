program idKFa;

{$R *.dres}

uses
  Forms,
  uMain in 'src\forms\uMain.pas' {fMain},
  uDownload in 'src\forms\uDownload.pas' {FormDownload},
  AboutWindow in 'src\forms\AboutWindow.pas' {fAbout},
  uStyleEditor in 'src\forms\uStyleEditor.pas' {fStyleEditor},
  uSimulator in 'src\forms\uSimulator.pas' {fSimulator},
  uGlobal in 'src\core\uGlobal.pas',
  uDownloadCom in 'src\core\uDownloadCom.pas',
  uCompilerCore in 'src\core\uCompilerCore.pas',
  uForthCompiler in 'src\compiler\forth\uForthCompiler.pas',
  uForthDevice in 'src\compiler\forth\uForthDevice.pas' {fForthDevice},
  uForthDeviceCore in 'src\compiler\forth\uForthDeviceCore.pas',
  uForthSoftDebuger in 'src\compiler\forth\uForthSoftDebuger.pas',
  uForthHardDebuger in 'src\compiler\forth\uForthHardDebuger.pas',
  uBrainfuckCompiler in 'src\compiler\brainfuck\uBrainfuckCompiler.pas',
  uBrainfuckDevice in 'src\compiler\brainfuck\uBrainfuckDevice.pas' {fBrainfuckDevice},
  uBrainfuckDeviceCore in 'src\compiler\brainfuck\uBrainfuckDeviceCore.pas',
  uProteusDeviceCore in 'src\compiler\proteus\uProteusDeviceCore.pas',
  uProteusDevice in 'src\compiler\proteus\uProteusDevice.pas' {fProteusDevice},
  uCommonFunctions in 'src\core\uCommonFunctions.pas',
  uProteusSoftDebuger in 'src\compiler\proteus\uProteusSoftDebuger.pas',
  uProteusCompiler in 'src\compiler\proteus\uProteusCompiler.pas',
  uProteusComModel in 'src\compiler\proteus\uProteusComModel.pas' {fProteusComModel},
  UnitSyntaxMemo in 'src\core\UnitSyntaxMemo.pas',
  uRecordList in 'src\core\uRecordList.pas',
  uQuarkCompiler in 'src\compiler\quark\uQuarkCompiler.pas',
  uQuarkDeviceCore in 'src\compiler\quark\uQuarkDeviceCore.pas',
  uQuarkDevice in 'src\compiler\quark\uQuarkDevice.pas' {fQuarkDevice},
  uSimVga in 'src\simforms\uSimVga.pas' {fSimVga},
  uLed in 'src\simforms\uLed.pas' {fLed},
  uComModel in 'src\simforms\uComModel.pas' {fComModel},
  uProteusDownloader in 'src\compiler\proteus\uProteusDownloader.pas' {fProteusDownloader};

// {fProteusDownloader},
//  uComTerminal in 'src\forms\uComTerminal.pas' {fComTerminal};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Forth cross-compiler';
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TFormDownload, FormDownload);
  Application.CreateForm(TfAbout, fAbout);
  Application.CreateForm(TfStyleEditor, fStyleEditor);
  Application.CreateForm(TfSimulator, fSimulator);
  Application.CreateForm(TfSimVga, fSimVga);
  Application.CreateForm(TfComModel, fComModel);
  Application.CreateForm(TfProteusComModel, fProteusComModel);
  Application.CreateForm(TfLed, fLed);
  Application.Run;
end.






