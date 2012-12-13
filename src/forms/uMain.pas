unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, ComCtrls, Menus, Grids, StdCtrls, ExtCtrls,
  ToolWin, ImgList, uForthCompiler, Gauges, UnitSyntaxMemo, uStyleEditor, Buttons, uRecordList, uSimulator, uGlobal,
  ShellAPI, uBrainfuckCompiler, uDownloadCom, uCommonFunctions, uProteusCompiler, uQuarkCompiler,
  TabNotBk;

type
  TfMain = class(TForm)
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    New: TAction;
    Open: TAction;
    Save: TAction;
    Compile: TAction;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    ToolBar1: TToolBar;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Console: TMemo;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    bNew: TToolButton;
    bOpen: TToolButton;
    bSave: TToolButton;
    ToolButton4: TToolButton;
    bCompile: TToolButton;
    bCompileAndDownload: TToolButton;
    ToolButton8: TToolButton;
    eFindWhat: TEdit;
    bFind: TToolButton;
    ImageList1: TImageList;
    Run1: TMenuItem;
    Options1: TMenuItem;
    ToolButton10: TToolButton;
    bLoadCommandSystem: TToolButton;
    GotoDownload: TAction;
    bDownload: TToolButton;
    ExportCoe: TAction;
    mnExport: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    About: TAction;
    ExportRaw: TAction;
    ExportRaw1: TMenuItem;
    RunSimulator: TAction;
    ToolButton13: TToolButton;
    bRunSimulator: TToolButton;
    Font1: TMenuItem;
    FontDialog1: TFontDialog;
    ExportDataCoe1: TMenuItem;
    Optimization1: TMenuItem;
    Save2: TMenuItem;
    Saveas1: TMenuItem;
    SaveAs: TAction;
    CompileAndDownload: TAction;
    Downloaddatamemory1: TMenuItem;
    Styleeditor1: TMenuItem;
    Createdownloadlog1: TMenuItem;
    ActFindText: TAction;
    ActFind: TAction;
    N1: TMenuItem;
    Compiler1: TMenuItem;
    changeCompilerToForth: TMenuItem;
    changeCompilerToBrainfuck: TMenuItem;
    changeCompilerToProteus: TMenuItem;
    changeCompilerToQuark: TMenuItem;
    Tabs: TTabbedNotebook;
    ToolButton1: TToolButton;
    CloseCurrentTab: TAction;
    SpeedButton1: TSpeedButton;
    procedure CompileExecute(Sender: TObject);
    procedure GotoDownloadExecute(Sender: TObject);
    procedure ExportCoeExecute(Sender: TObject);
    procedure SaveExecute(Sender: TObject);
    procedure OpenExecute(Sender: TObject);
    procedure AboutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure ExportDataCoe1Click(Sender: TObject);
    procedure bLoadCommandSystemClick(Sender: TObject);
    procedure NewExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SaveAsExecute(Sender: TObject);
    procedure CompileAndDownloadExecute(Sender: TObject);

    procedure mmCodeParseWord(Sender: TObject; Word: String; Pos,
      Line: Integer; var Token: TToken);
    procedure mmCodeKeyPress(Sender: TObject; var Key: Char);
    procedure mmCodeWordInfo(Sender: TMPCustomSyntaxMemo; const X, Y, WordIndex, Row: Integer; Showing: Boolean);

    procedure Styleeditor1Click(Sender: TObject);
    procedure RunSimulatorExecute(Sender: TObject);
    procedure ActFindTextExecute(Sender: TObject);
    procedure ActFindExecute(Sender: TObject);
    procedure changeCompilerToForthClick(Sender: TObject);
    procedure changeCompilerToBrainfuckClick(Sender: TObject);
    procedure changeCompilerToProteusClick(Sender: TObject);

    procedure ChangeCompilerTo(newCompiler: TCompilerType; NeedCreateNewFile: boolean = false);
    procedure changeCompilerToQuarkClick(Sender: TObject);

    procedure ToLog(Sender: TObject; LogStr: string);
    procedure CloseTabClick(Sender: TObject);
    procedure TabsChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure CloseCurrentTabExecute(Sender: TObject);
    procedure ExportRawExecute(Sender: TObject);
    procedure CloseBtnMouseEnter(Sender: TObject);
    procedure CloseBtnMouseLeave(Sender: TObject);
  private
    procedure ForthCom;
    procedure ForthPackSize;
    procedure ForthWaitCoef;
    procedure ForthCore;

    procedure Init(Sender: TObject);
  public
    { Public declarations }
  end;

type
  TStyleCell = record
    id: integer; // -1 - not exist
    TokenStyle: TTokenStyle;
  end;

const
  StyleConsts: array[0..21] of record
    id: integer;
    str: string;
  end =
  ((id: tokString;       str: 'sString'),
   (id: tokStringEnd;    str: 'sStringEnd'),
   (id: tokChar;         str: 'sChar'),
   (id: tokCharEnd;      str: 'sCharEnd'),
   (id: tokHexValue;     str: 'sHexValue'),
   (id: tokInteger;      str: 'sInteger'),
   (id: tokFloat;        str: 'sFloat'),
   (id: tokILCompDir;    str: 'sILCompDir'),
   (id: tokMLCompDirBeg; str: 'sMLCompDirBeg'),
   (id: tokILComment;    str: 'sILComment'),
   (id: tokMLCommentBeg; str: 'sMLCommentBeg'),
   (id: tokMLCommentEnd; str: 'sMLCommentEnd'),
   (id: tokELCommentBeg; str: 'sELCommentBeg'),
   (id: tokELCommentEnd; str: 'sELCommentEnd'),
   (id: tokParenBeg;     str: 'sParenBeg'),
   (id: tokParenEnd;     str: 'sParenEnd'),
   (id: tokBrackedBeg;   str: 'sBrackedBeg'),
   (id: tokBracketEnd;   str: 'sBracketEnd'),
   (id: tokImmediate;    str: 'sImmediate'),
   (id: tokAlfaBet;      str: 'sAlfaBet'),
   (id: tokVar;          str: 'sVar'),
   (id: tokErrorDict;    str: 'sErrorDict')
  );

var
  fMain: TfMain;
  FileName : array of string;
  FileChanged: array of boolean;
  mmCode: array of TMPSyntaxMemo;
  CloseBtns: array of TSpeedButton;
  Compiled : boolean;

  TimerInit: TTimer;
  fLog: TextFile;

implementation

uses uDownload, AboutWindow, StrUtils;

{$R *.dfm}
{$R WindowsXP.res}

procedure RunOptimize; forward;
function GetVersion: string; forward;
function GetBuild: string; forward;
procedure OpenKfFile(_fileName: string); forward;

procedure RecalcCloseButtonsSize(ActiveTab: integer);
var
  i: integer;
  TabRect: TRect;
begin
  for i := 0 to Length(mmCode) - 1 do
    with CloseBtns[i] do
    begin
      TabRect := fMain.Tabs.TabRect(i);
      Width := TabRect.Bottom - TabRect.Top - 4;
      Height := Width;
      Left := TabRect.Right - Width - 4;
      Top := TabRect.Top + 2;
      if ActiveTab <> i then
        Top := Top + 2;
    end;
end;

procedure SetTabName(Index: integer);
var
  s: string;
begin
  if FileName[Index] = '' then
    s := 'New file'
  else
    s := ExtractFileName(FileName[Index]);

  if FileChanged[Index] then
    s := s + ' [*]';

  s := s + '    '; // some spaces for close button

  if fMain.Tabs.Pages.Strings[Index] <> s then;
    fMain.Tabs.Pages.Strings[Index] := s;
end;

procedure SetFileName(Index: integer; NewFileName: string);
begin
  FileName[Index] := NewFileName;
  SetTabName(Index);
  RecalcCloseButtonsSize(Index);
end;

procedure SetFileChanged(Index: integer; Value: boolean);
begin
  FileChanged[Index] := Value;
  SetTabName(Index);
  RecalcCloseButtonsSize(Index);
end;

procedure StartTimerInit;
begin
  TimerInit := TTimer.Create(fMain);
  with TimerInit do
  begin
    Enabled := false;
    Interval := 1;
    OnTimer := fMain.Init;
    Enabled := true;
  end;
end;

procedure ErrorMessage(msg: string);
begin
  MessageBox(0, pchar(msg), pchar(Application.Title), MB_OK or MB_ICONERROR);
end;

function TokenStyle(tsForeground, tsBackground: TColor; tsStyle: TFontStyles): TTokenStyle;
begin
  Result.tsForeground := tsForeground;
  Result.tsBackground := tsBackground;
  Result.tsStyle := tsStyle;
end;

function StyleCell(id: integer; TokenStyle: TTokenStyle): TStyleCell;
begin
  Result.id := id;
  Result.TokenStyle := TokenStyle;
end;

procedure SetFormName;
var
  build: string;
  s: string;
begin
  build := GetBuild;
  s := 'Cross-compiler (build ' + build + ')';

  if fMain.Caption <> s then
    fMain.Caption := s;

  s := 'kf (build ' + build + ')';

  if Application.Title <> s then
    Application.Title := s;
end;

procedure TfMain.mmCodeParseWord(Sender: TObject; Word: String; Pos,
    Line: Integer; var Token: TToken);
var
  n: integer;
begin
  if (SynLightWords <> nil) and (SynLightWords.Find(Word, n)) then
    Token := TToken(SynLightWords.Objects[n])
  else if (Copy(word, 1, 2) = '0b') or (Copy(word, 1, 2) = '0d')
       or (Copy(word, 1, 2) = '0o') or (Copy(word, 1, 2) = '0x') then
    Token := tokInteger
  else
    Token := tokErroneous;
end;

function GetTextWidth(s: string): integer;
var
  StoredFont: TFont;
begin
  Result := 0;
  if Length(mmCode) > 0 then
  begin
    StoredFont := fMain.Font;
    fMain.Font := mmCode[0].Font;
    Result := fMain.Canvas.TextWidth(s);
    fMain.Font := StoredFont;
  end;
end;

procedure SetNewGutterWidth;
begin
  with mmCode[fMain.Tabs.PageIndex] do
    GutterWidth := GetTextWidth(IntToStr(Lines.Count)) + 10;
end;

procedure ParseAll(Index: integer);
var
  i: integer;
  s: string;
begin
  if not Assigned(mmCode[Index]) then
    Exit;

  with mmCode[Index] do
  begin
    for i := 0 to Lines.Count-1 do
      Lines.Parser[i].NeedReparse := true;
    // todo: какая то заглушка :(
    s := Lines.Strings[0];
    Lines.Strings[0] := s + ' ';
    Lines.Strings[0] := s;
    NeedRedrawAll;
    SetNewGutterWidth;
  end;
end;

//-------
procedure TfMain.mmCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if not FileChanged[Tabs.PageIndex] then
  begin
    SetFileChanged(Tabs.PageIndex, true);
  end;

  if (Key = #13) or (Key = #8) then
    with mmCode[Tabs.PageIndex] do
    begin
      // todo: какая то заглушка :(
      Width := Width - 1;
      NeedRedrawAll;
      SetNewGutterWidth;
    end;
end;

function FileSaveAndReturnCanClose(Index: integer): boolean;
var
  res: integer;
  canClose: boolean;
  FileStr: string;
begin
  if FileChanged[Index] then
  begin
    if FileName[Index] <> '' then
      FileStr := '"' + FileName[Index] + '"'
    else
      FileStr := '';

    res := MessageBox(0,
      pchar('Файл ' + FileStr + ' изменен, но не сохранен. Сохранить?'),
      pchar(fMain.Caption),
      MB_YESNOCANCEL or MB_ICONQUESTION);
    if res = mrYes then
    begin
      if FileName[Index] = '' then
        fMain.SaveExecute(fMain)
      else
        mmCode[Index].Lines.SaveToFile(FileName[Index]);
    end;

    canClose := not (res = mrCancel);

    if canClose then
      FileChanged[Index] := false;

    Result := canClose;
  end
  else
    Result := true;
end;

procedure TfMain.ForthCom;
var
  comIndex: integer;
begin
  comIndex := 0;
  if currentCompiler = compilerForth then
  begin
    comIndex := (compiler as TForthCompiler).ParseInt;
    if (compiler as TForthCompiler).LastError <> 0 then
      Exit;
  end
  else if currentCompiler = compilerProteus then
    comIndex := (compiler as TProteusCompiler).ParseInt;

  if (comIndex < 1) or (comIndex > 19) then
  begin
    ShowMessage('Неверный индекс com-порта (должен быть от 1 до 19)');
    Exit;
  end;

  FormDownload.cbComName.ItemIndex := comIndex - 1;
end;

procedure TfMain.ForthPackSize;
var
  int: integer;
begin
  int := 0;
  if currentCompiler = compilerForth then
  begin
    int := (compiler as TForthCompiler).ParseInt;
    if (compiler as TForthCompiler).LastError <> 0 then
      Exit;
  end
  else if currentCompiler = compilerProteus then
    int := (compiler as TProteusCompiler).ParseInt;

  FormDownload.eCountPackage.Text := IntToStr(int);
end;

procedure TfMain.ForthWaitCoef;
var
  int: integer;
begin
  int := 0;
  if currentCompiler = compilerForth then
  begin
    int := (compiler as TForthCompiler).ParseInt;
    if (compiler as TForthCompiler).LastError <> 0 then
      Exit;
  end
  else if currentCompiler = compilerProteus then
    int := (compiler as TProteusCompiler).ParseInt;

  FormDownload.eWaitingCoef.Text := IntToStr(int);
end;

procedure TfMain.ForthCore;
var
  forthCompiler: TForthCompiler absolute compiler;
begin
  forthCompiler.ParseToken;
  if forthCompiler.LastError <> 0 then Exit;

  if (Length(forthCompiler.LastToken) > 1)
    or ((forthCompiler.LastToken[1] < 'A') or (forthCompiler.LastToken[1] > 'Z')) then
  begin
    ShowMessage('#Core. Неверный индекс ядра (должен быть буквой от A до Z)');
    Exit;
  end;
  FormDownload.cbCore.ItemIndex := ord(forthCompiler.LastToken[1]) - ord('A') ;
  AddSynlightWord(forthCompiler.LastToken, tokDict);
end;

procedure TfMain.CompileExecute(Sender: TObject);
var
  PageIndex: integer;
  LineNum : integer;
begin
  Console.Lines.Clear;
  Console.Lines.Add('Starting cross compilation');

  LineNum := 0;
  PageIndex := fMain.Tabs.PageIndex;
  uGlobal.FilePath := ExtractFilePath(FileName[PageIndex]);

  if compiler.hasEvaluate then
  begin
    compiler.BeginCompile;
    while ((LineNum < mmCode[PageIndex].Lines.Count) and (compiler.LastError = 0)) do
    begin
      compiler.Evaluate(mmCode[PageIndex].Lines[LineNum]);
      Inc(LineNum);
    end;
    compiler.EndCompile;
  end
  else
  begin
    if FileSaveAndReturnCanClose(Tabs.PageIndex) then
      compiler.EvaluateFile(FileName[Tabs.PageIndex]);
  end;

  if compiler.LastError <> 0 then
  begin
    Console.Lines.Add('Error ' + IntToStr(compiler.LastError) +
      ' (' + compiler.LastErrorMessage + ')' +
      ' in the line ' + IntToStr(LineNum) + ' ==> ' + compiler.LastToken);
    AddSynlightWord(compiler.LastToken, tokErrorDict);
    if LineNum > 0 then
      mmCode[PageIndex].Range.PosY := LineNum - 1;
  end;

  SynLightWords.Sort;
  ParseAll(Tabs.PageIndex);

  if compiler.LastError = 0 then
    Console.Lines.Add('Complete.')
  else
    Console.Lines.Add('There are errors!');

  compiled := (compiler.LastError = 0);

  if compiled and Optimization1.Checked then
    RunOptimize;

  bDownload.Enabled := compiled;
  mmCode[PageIndex].SetFocus;

  if compiled then
  uSimulator.Prepare;
end;

procedure TfMain.GotoDownloadExecute(Sender: TObject);
begin
  FormDownload.Showmodal;
end;

procedure TfMain.ExportCoeExecute(Sender: TObject);
var
  i : integer;
  f : textfile;
  fn: string;
begin
  SaveDialog1.FilterIndex := 2;
  if SaveDialog1.Execute then
  begin
    fn := SaveDialog1.FileName;
    if RightStr(fn, 3) = '.kf' then fn := LeftStr(fn, length(fn)-3);
    if RightStr(fn, 4) <> '.coe' then fn := fn + '.coe';
    if FileExists(fn) then
      if MessageBox(0, pchar('Файл "' + fn + '" уже существует. Заменить?'), pchar(fMain.Caption), MB_YESNO or MB_ICONQUESTION) = mrNo then
        Exit;
    AssignFile(f, fn);
    Rewrite(f);
    Writeln(f, 'MEMORY_INITIALIZATION_RADIX=10;');
    Writeln(f, 'MEMORY_INITIALIZATION_VECTOR=');
    for i := 0 to compiler.CodeCount-1 do
    begin
      Write(f, IntToStr(compiler.Code(i)));
      if i <> compiler.CodeCount-1 then
        Writeln(f, ',')
      else
        Writeln(f, ';');
    end;
     CloseFile(f);
  end;
end;

procedure TfMain.ExportDataCoe1Click(Sender: TObject);
var
  i : integer;
  f : textfile;
  fn: string;
begin
  SaveDialog1.FilterIndex := 2;
  if SaveDialog1.Execute then
  begin
    fn := SaveDialog1.FileName;
    if RightStr(fn, 3) = '.kf' then fn := LeftStr(fn, length(fn)-3);
    if RightStr(fn, 4) <> '.coe' then fn := fn + '.coe';
    if FileExists(fn) then
      if MessageBox(0, pchar('Файл "' + fn + '" уже существует. Заменить?'), pchar(fMain.Caption), MB_YESNO or MB_ICONQUESTION) = mrNo then
        Exit;
    AssignFile(f, fn);
    Rewrite(f);
    Writeln(f, 'MEMORY_INITIALIZATION_RADIX=10;');
    Writeln(f, 'MEMORY_INITIALIZATION_VECTOR=');
    for i := 0 to compiler.DataCount-1 do
    begin
      Write(f, IntToStr(compiler.Data(i)));
      if i <> compiler.DataCount-1 then
        Writeln(f, ',')
      else
        Writeln(f, ';');
    end;
    CloseFile(f);
  end;
end;

procedure TfMain.ExportRawExecute(Sender: TObject);
var
  i : integer;
  f : textfile;
  fn: string;
begin
  SaveDialog1.FilterIndex := 2;
  if SaveDialog1.Execute then
  begin
    fn := SaveDialog1.FileName;
    if RightStr(fn, 3) = '.kf' then fn := LeftStr(fn, length(fn)-3);
    if RightStr(fn, 4) <> '.coe' then fn := fn + '.coe';
    if FileExists(fn) then
      if MessageBox(0, pchar('Файл "' + fn + '" уже существует. Заменить?'), pchar(fMain.Caption), MB_YESNO or MB_ICONQUESTION) = mrNo then
        Exit;
    AssignFile(f, fn);
    Rewrite(f);
    Writeln(f, 'signal program : TProgramMem := (');
    for i := 0 to compiler.CodeCount-1 do
    begin
      Writeln(f, '  ', i, ' => conv_std_logic_vector(', compiler.Code(i), ', 6),');
    end;
    Writeln(f, '  others => (others => ''0''));');
    CloseFile(f);
  end;
end;

procedure TfMain.SaveExecute(Sender: TObject);
begin
  if FileName[Tabs.PageIndex] <> '' then
  begin
    mmCode[Tabs.PageIndex].Lines.SaveToFile(FileName[Tabs.PageIndex]);
    SetFileChanged(Tabs.PageIndex, false);
  end
  else
  begin
    SaveAsExecute(Sender);
  end;
  SetFormName;
end;

procedure TfMain.CloseBtnMouseEnter(Sender: TObject);
begin
  (Sender as TSpeedButton).Glyph.LoadFromResourceName(HInstance, 'CloseBtnFocusedBmp');
end;

procedure TfMain.CloseBtnMouseLeave(Sender: TObject);
begin
  (Sender as TSpeedButton).Glyph.LoadFromResourceName(HInstance, 'CloseBtnBmp');
end;

procedure TfMain.AboutExecute(Sender: TObject);
begin
  fAbout.ShowModal;
end;

procedure InitHighlight;
begin
  with mmCode[fMain.Tabs.PageIndex].SyntaxAttributes do
  begin
    FontColor[tokImmediate] := $003F7F;
    BackColor[tokImmediate] := clWhite;
    FontStyle[tokImmediate] := [fsBold];

    FontColor[tokAlfaBet] := clBlack;
    BackColor[tokAlfaBet] := clWhite;
    FontStyle[tokAlfaBet] := [];

    FontColor[tokVar] := clBlack;
    BackColor[tokVar] := clWhite;
    FontStyle[tokVar] := [];

// todo: Снести без сожаления, или раскоментировать и вынести в настройки StyleEditor'а
//    FontColor[tokDict] := RGB(100, 0, 0);
//    BackColor[tokDict] := clWhite;
//    FontStyle[tokDict] := [];

    FontColor[tokErrorDict] := clRed;
    BackColor[tokErrorDict] := clWhite;
    FontStyle[tokErrorDict] := [fsBold, fsUnderline];

    if FileExists(ExePath + 'UserStyle.kfs') then
      LoadFromFile(ExePath + 'UserStyle.kfs');
  end;
end;

procedure CreateNewTab;
var
  ix: integer;
begin
  ix := Length(mmCode);

  SetLength(mmCode, ix + 1);
  SetLength(CloseBtns, ix + 1);
  SetLength(FileName, ix + 1);
  SetLength(FileChanged, ix + 1);

  mmCode[ix] := nil;
  if ix > 0 then
    fMain.Tabs.Pages.Add('');
  SetTabName(ix);

  CloseBtns[ix] := TSpeedButton.Create(fMain.Tabs);
  with CloseBtns[ix] do
  begin
    Parent := fMain.Tabs;
    Flat := true;
    Tag := ix;
    Glyph.LoadFromResourceName(hInstance, 'CloseBtnBmp');
    OnClick := fMain.CloseTabClick;
    OnMouseEnter := fMain.CloseBtnMouseEnter;
    OnMouseLeave := fMain.CloseBtnMouseLeave;
  end;
  RecalcCloseButtonsSize(ix);
  Application.ProcessMessages;

  mmCode[ix] := TMPSyntaxMemo.Create(fMain.Tabs.Pages.Objects[ix] as TTabPage);
  with mmCode[ix] do
  begin
    Parent := fMain.Tabs.Pages.Objects[ix] as TTabPage;
    Align := alClient;
    Color := clWhite;
    OnKeyPress := fMain.mmCodeKeyPress;
    OnParseWord := fMain.mmCodeParseWord;
    OnWordInfo := fMain.mmCodeWordInfo;
  end;
  InitHighlight;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  SynLightWords := TStringList.Create;

  Compiled := false;
  bDownload.Enabled := false;
  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);

  StartTimerInit;

  uGlobal.ExePath := ExtractFilePath(Application.ExeName);
end;

procedure TfMain.Font1Click(Sender: TObject);
var
  i: integer;
begin
  if Length(mmCode) > 0 then
  begin
    FontDialog1.Font := mmCode[0].Font;
    if not FontDialog1.Execute then Exit;
    for i := 0 to Length(mmCode) - 1 do
      mmCode[i].Font := FontDialog1.Font;
  end;
end;

procedure TfMain.CompileAndDownloadExecute(Sender: TObject);
begin
  CompileExecute(fMain);
  if compiler.LastError <> 0 then Exit;
  FormDownload.ProcessDownloadExecute(fMain);
end;

procedure RunOptimize;
begin
  fMain.Console.Lines.Add('Начало оптимизации...');
  fMain.Console.Lines.Add('Размер кода до оптимизации: ' + inttostr(compiler.CodeCount));
  fMain.Console.Lines.Add('Оптимизация...');
  compiler.Optimize;
  fMain.Console.Lines.Add('Размер кода после оптимизации: ' + inttostr(compiler.CodeCount));
end;

procedure TfMain.bLoadCommandSystemClick(Sender: TObject);
var
  fileName: string;
begin
  OpenDialog1.FilterIndex := 3;
  if OpenDialog1.Execute then
    fileName := OpenDialog1.FileName
  else
    fileName := '';
  if compiler is TForthCompiler then
    (compiler as TForthCompiler).LoadCommandSystem(fileName);
end;

function GetBuild: string;
var
  pos: integer;
  s: string;
begin
  s := GetVersion;
  Result := '';
  Pos := Length(s);
  while (Pos >= 1) and (s[pos] <> '.') do
  begin
    Result := s[pos] + result;
    dec(pos);
  end;
end;

function GetVersion: string;
var
  dump: DWORD;
  size: integer;
  buffer: PChar;
  VersionPointer, TransBuffer: PChar;
  Temp: integer;
  CalcLangCharSet: string;
  NameApp: string;
begin
  NameApp := paramstr(0);

  size := GetFileVersionInfoSize(PChar(NameApp), dump);
  buffer := StrAlloc(size+1);
  try
    GetFileVersionInfo(PChar(NameApp), 0, size, buffer);

    VerQueryValue(buffer, '\VarFileInfo\Translation', pointer(TransBuffer),
    dump);
    if dump >= 4 then
    begin
      temp:=0;
      StrLCopy(@temp, TransBuffer, 2 div sizeof(char));
      CalcLangCharSet:=IntToHex(temp, 4);
      StrLCopy(@temp, TransBuffer + 2 div sizeof(char), 2 div sizeof(char));
      CalcLangCharSet := CalcLangCharSet+IntToHex(temp, 4);
    end;

    VerQueryValue(buffer, pchar('\StringFileInfo\'+CalcLangCharSet+
    '\'+'FileVersion'), pointer(VersionPointer), dump);
    if (dump > 1) then
    begin
      Result := VersionPointer;
    end
    else
      Result := '0.0.0.0';
  finally
    StrDispose(Buffer);
  end;
end;

procedure TfMain.NewExecute(Sender: TObject);
var
  linesCount: integer;
begin
  CreateNewTab;

  with mmCode[Tabs.PageIndex] do
  begin
    Lines.Clear;
    if compiler.NewFileText <> '' then
      Lines.Text := compiler.NewFileText
    else
      Lines.Add('');

    linesCount := Lines.Count;
    Navigate(length(Lines.Strings[linesCount-1]), linesCount-1);
  end;

  SetFileName(Tabs.PageIndex, '');
  SetFileChanged(Tabs.PageIndex, false);
  ParseAll(Tabs.PageIndex);
end;

procedure OpenKfFile(_fileName: string);
var
  Index: integer;
  res: integer;
begin
  Index := 0;
  while (Index < Length(FileName)) and (FileName[Index] <> _FileName) do
    inc(Index);

  if (Index < Length(FileName)) then
  begin
    if FileChanged[Index] then
    begin
      res := MessageBox(0,
        pchar('Файл "' + _FileName + '" уже открыт.' +#13#10+
              'Повторно открыть его (изменения будут утеряны)?'),
        'Вопрос',
        MB_ICONQUESTION or MB_YESNO);
      if res = mrYes then
      begin
        mmCode[Index].Lines.LoadFromFile(_fileName);
        SetFileChanged(Index, false);
      end;
    end;
    fMain.Tabs.PageIndex := Index;
  end
  else
  begin
    CreateNewTab;
    Index := fMain.Tabs.PageIndex;
    mmCode[Index].Lines.LoadFromFile(_fileName);
    SetFileName(Index, _fileName);
    SetFileChanged(Index, false);
    ParseAll(Index);
  end;
end;

procedure TfMain.OpenExecute(Sender: TObject);
begin
  OpenDialog1.FilterIndex := 1;
  if OpenDialog1.Execute then
  begin
    OpenKfFile(OpenDialog1.FileName);
  end;
end;

procedure CloseTab(Index: integer);
var
  CanClose: boolean;
  TabsCount: integer;
  i: integer;
begin
  TabsCount := Length(mmCode);

  if (Index < 0) or (Index >= TabsCount) then
    Exit;

  if (TabsCount > 1) and (fMain.Tabs.PageIndex = Index) then
  begin
    i := fMain.Tabs.PageIndex - 1;
    if (i < 0) then
      i := i + fMain.Tabs.Pages.Count;
    fMain.Tabs.PageIndex := i;
  end;

  CanClose := FileSaveAndReturnCanClose(Index);
  if CanClose then
  begin
    TabsCount := Length(mmCode);
    mmCode[Index].Free;
    CloseBtns[Index].Free;
    for i := Index to TabsCount - 2 do
    begin
      mmCode[i] := mmCode[i + 1];
      CloseBtns[i] := CloseBtns[i + 1];
      CloseBtns[i].Tag := i;
      FileName[i] := FileName[i + 1];
      FileChanged[i] := FileChanged[i + 1];
    end;
    SetLength(mmCode, TabsCount - 1);
    SetLength(CloseBtns, TabsCount - 1);
    SetLength(FileName, TabsCount - 1);
    SetLength(FileChanged, TabsCount - 1);

    if TabsCount > 1 then
      fMain.Tabs.Pages.Delete(Index)
    else
      fMain.Tabs.Pages.Strings[Index] := ':''(';
  end;

  RecalcCloseButtonsSize(fMain.Tabs.PageIndex);
end;

procedure CloseAllTabs;
var
  i: integer;
  TabsCount: integer;
begin
  TabsCount := Length(mmCode);
  for i := TabsCount - 1 downto 0 do
    CloseTab(i);
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CloseAllTabs;
  CanClose := Length(mmCode) = 0;
end;

procedure TfMain.SaveAsExecute(Sender: TObject);
var
  fn: string;
begin
  // нет ни одной вкладки
  if Length(mmCode) = 0 then
    Exit;

  SaveDialog1.FilterIndex := 1;
  if SaveDialog1.Execute then
  begin
    fn := SaveDialog1.FileName;
    SetFileChanged(Tabs.PageIndex, false);
    if RightStr(fn, 4) = '.coe' then fn := LeftStr(fn, length(fn)-4);
    if RightStr(fn, 3) <> '.kf' then fn := fn + '.kf';
    if FileExists(fn) then
      if MessageBox(0, pchar('Файл "' + fn + '" уже существует. Заменить?'), pchar(fMain.Caption), MB_YESNO or MB_ICONQUESTION) = mrNo then
        Exit;
    SetFileName(Tabs.PageIndex, fn);
    mmCode[Tabs.PageIndex].Lines.SaveToFile(fn);
  end;
end;

procedure TfMain.Styleeditor1Click(Sender: TObject);
begin
  if uStyleEditor.mmCodeP = nil then
  begin
    uStyleEditor.mmCodeP := @mmCode[Tabs.PageIndex];
    uStyleEditor.Init;
  end;
  mmCode[Tabs.PageIndex].SyntaxAttributes.SaveToFile('~temp.kfs');
  if fStyleEditor.ShowModal = mrOk then
  begin
    mmCode[Tabs.PageIndex].SyntaxAttributes.SaveToFile('UserStyle.kfs');
    ParseAll(Tabs.PageIndex);
  end
  else
  begin
    mmCode[Tabs.PageIndex].SyntaxAttributes.LoadFromFile('~temp.kfs');
  end;
  DeleteFile('~temp.kfs');
end;

procedure TfMain.TabsChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  if mmCode[NewTab] <> nil then
  begin
    ParseAll(NewTab);
    RecalcCloseButtonsSize(NewTab);
  end;
end;

procedure TfMain.ToLog(Sender: TObject; LogStr: string);
begin
  writeln(fLog, LogStr);
  Flush(fLog);
end;

procedure TfMain.CloseCurrentTabExecute(Sender: TObject);
begin
  CloseTab(Tabs.PageIndex);
end;

procedure TfMain.CloseTabClick(Sender: TObject);
begin
  CloseTab((Sender as TComponent).Tag);
end;

procedure TfMain.RunSimulatorExecute(Sender: TObject);
begin
  if not fSimulator.Showing then
    uSimulator.Prepare;
  fSimulator.Show;
end;

procedure TfMain.ActFindTextExecute(Sender: TObject);
begin
  eFindWhat.Text := mmCode[Tabs.PageIndex].Range.Text;
  eFindWhat.SetFocus;
end;

procedure TfMain.ActFindExecute(Sender: TObject);
var
  FoundAt: integer;
  StartPos: integer;
begin
  if (Length(mmCode) = 0) or (Tabs.PageIndex < 0) then
    Exit;

  if mmCode[Tabs.PageIndex].Range.SelLength <> 0 then
    StartPos := mmCode[Tabs.PageIndex].Range.Position + mmCode[Tabs.PageIndex].Range.SelLength
  else
    StartPos := 1;

  FoundAt := UniPos(eFindWhat.Text, mmCode[Tabs.PageIndex].Lines.Text, StartPos);
  if FoundAt <> -1 then
  begin
    mmCode[Tabs.PageIndex].Range.Position := FoundAt;
    mmCode[Tabs.PageIndex].Range.SelLength := Length(eFindWhat.Text)
  end
  else
  begin
    Windows.Beep(250, 100);
  end;
end;

procedure TfMain.mmCodeWordInfo(Sender: TMPCustomSyntaxMemo; const X, Y,
  WordIndex, Row: Integer; Showing: Boolean);
var
  Word, WordComment: string;
begin
  if WordIndex = -1 then
  begin
    StatusBar1.Panels[1].Text := '';
    StatusBar1.Panels[2].Text := '';
  end
  else
  begin
    if currentCompiler = compilerForth then
    begin
      with mmCode[Tabs.PageIndex].Lines.Parser[Row].Tokens[WordIndex] do
        Word := Copy(mmCode[Tabs.PageIndex].Lines[Row], stStart + 1, stLength);
      if StatusBar1.Panels[1].Text <> Word + '  ' then
      begin
        WordComment := TForthCompiler(compiler).GetTokenComment(Word);
        StatusBar1.Panels[1].Text := Word + '  ';
        StatusBar1.Panels[2].Text := WordComment;
      end;
    end;
  end;
end;

procedure ForthInit;
var
  forthCompiler: TForthCompiler absolute compiler;
begin
  forthCompiler := TForthCompiler.Create;
  with forthCompiler do
  begin
    BeginInitCommandSystem;
    AddImmWord('#COM', fMain.ForthCom);
    AddImmWord('#PACKSIZE=', fMain.ForthPackSize);
    AddImmWord('#WAITCOEF=', fMain.ForthWaitCoef);
    AddImmWord('#CORE', fMain.ForthCore);
    EndInitCommandSystem;
  end;

  ChangeDevice(devForth);
end;

procedure BrainfuckInit;
var
  brainfuckCompiler: TBrainfuckCompiler absolute compiler;
begin
  brainfuckCompiler := TBrainfuckCompiler.Create;
  ChangeDevice(devBrainfuck);
end;

procedure ProteusInit;
var
  proteusCompiler: TProteusCompiler absolute compiler;
begin
  proteusCompiler := TProteusCompiler.Create;
  with proteusCompiler do
  begin
    BeginInitCommandSystem;
    AddImmToken('#COM', fMain.ForthCom);
    AddImmToken('#PACKSIZE=', fMain.ForthPackSize);
    AddImmToken('#WAITCOEF=', fMain.ForthWaitCoef);
    EndInitCommandSystem;
  end;

  ChangeDevice(devProteus);
end;

procedure QuarkInit;
var
  quarkCompiler: TQuarkCompiler absolute compiler;
begin
  quarkCompiler := TQuarkCompiler.Create;

  ChangeDevice(devQuark);
end;

procedure CloseCurrentCompiler;
begin
  if compiler <> nil then
  begin
    compiler.Destroy;
    compiler := nil;
  end;
end;

procedure TfMain.ChangeCompilerTo(newCompiler: TCompilerType; NeedCreateNewFile: boolean = false);
begin
  if newCompiler = currentCompiler then
    Exit;

//  CloseAllTabs;
//  if Length(mmCode) > 0 then
//    Exit;

  CloseCurrentCompiler;

  if newCompiler = compilerNone then
    Exit;

  currentCompiler := newCompiler;
  case currentCompiler of
    compilerForth: ForthInit;
    compilerBrainfuck: BrainfuckInit;
    compilerProteus: ProteusInit;
    compilerQuark: QuarkInit;
  end;

  if NeedCreateNewFile then
    NewExecute(fMain);
end;

procedure TfMain.changeCompilerToForthClick(Sender: TObject);
begin
  changeCompilerToForth.Checked := true;
  ChangeCompilerTo(compilerForth);
end;

procedure TfMain.changeCompilerToBrainfuckClick(Sender: TObject);
begin
  changeCompilerToBrainfuck.Checked := true;
  ChangeCompilerTo(compilerBrainfuck);
end;

procedure TfMain.changeCompilerToProteusClick(Sender: TObject);
begin
  changeCompilerToProteus.Checked := true;
  ChangeCompilerTo(compilerProteus);
end;

procedure DownloadComInit;
var
  downloadCom: TDownloaderCom absolute downloader;
begin
  downloadCom := TDownloaderCom.Create;
end;

procedure TfMain.Init(Sender: TObject);
begin
  if TimerInit <> nil then
  begin
    TimerInit.Enabled := false;
    TimerInit.Destroy;
    TimerInit := nil;
  end;

  changeCompilerToQuark.Checked := true;
  ChangeCompilerTo(compilerQuark, true);

  if ParamCount > 0 then
    OpenKfFile(ParamStr(1));

  SetFormName;
end;

procedure TfMain.changeCompilerToQuarkClick(Sender: TObject);
begin
  changeCompilerToQuark.Checked := true;
  ChangeCompilerTo(compilerQuark);
end;

initialization
  DownloadComInit;

//  Assign(fLog, 'UnitSyntaxMemo.log');
//  Rewrite(fLog);
finalization
//  CloseFile(fLog);
end.
