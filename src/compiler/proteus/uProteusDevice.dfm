object fProteusDevice: TfProteusDevice
  Left = 192
  Top = 114
  Align = alClient
  Caption = 'fProteusDevice'
  ClientHeight = 470
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 341
    Width = 234
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitTop = 308
    ExplicitWidth = 195
  end
  object PanelInout: TPanel
    Left = 0
    Top = 344
    Width = 234
    Height = 126
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 343
    object SpeedButton2: TSpeedButton
      Left = 119
      Top = 6
      Width = 108
      Height = 33
      Caption = #1044#1080#1086#1076#1080#1082#1080
      OnClick = SpeedButton2Click
    end
    object SpeedButton3: TSpeedButton
      Left = 5
      Top = 45
      Width = 108
      Height = 33
      Caption = #1058#1077#1082#1089#1090#1086#1074#1099#1081' '#1084#1086#1085#1080#1090#1086#1088
      OnClick = SpeedButton3Click
    end
    object SpeedButton1: TSpeedButton
      Left = 5
      Top = 6
      Width = 108
      Height = 33
      Caption = 'COM-'#1087#1086#1088#1090
      OnClick = SpeedButton1Click
    end
    object eCommandsCount: TLabeledEdit
      Left = 132
      Top = 90
      Width = 91
      Height = 21
      EditLabel.Width = 120
      EditLabel.Height = 25
      EditLabel.Caption = #1050#1086#1084#1072#1085#1076' '#1079#1072' '#1087#1086#1089#1083#1077#1076#1085#1080#1081' StepOver'
      EditLabel.WordWrap = True
      LabelPosition = lpLeft
      TabOrder = 0
    end
  end
  object tabStacks: TTabControl
    Left = 0
    Top = 0
    Width = 234
    Height = 341
    Align = alClient
    MultiLine = True
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    Tabs.Strings = (
      'Data'
      'Ret')
    TabIndex = 0
    OnChange = tabStacksChange
    ExplicitHeight = 308
    object sgStack: TStringGrid
      Left = 4
      Top = 24
      Width = 226
      Height = 242
      Align = alClient
      Color = 16774388
      ColCount = 4
      Ctl3D = True
      DefaultColWidth = 49
      DefaultRowHeight = 16
      RowCount = 17
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      ExplicitHeight = 209
      RowHeights = (
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16
        16)
    end
    object rgStackBase: TRadioGroup
      Left = 4
      Top = 266
      Width = 226
      Height = 71
      Align = alBottom
      Caption = #1056#1072#1079#1088#1103#1076#1085#1086#1089#1090#1100
      ItemIndex = 0
      Items.Strings = (
        'Dec'
        'Hex'
        'Char')
      TabOrder = 1
      OnClick = rgStackBaseClick
      ExplicitTop = 233
    end
  end
end
