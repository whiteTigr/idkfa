object fForthDevice: TfForthDevice
  Left = 390
  Top = 344
  Align = alClient
  Caption = 'fForthDevice'
  ClientHeight = 406
  ClientWidth = 230
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
    Top = 244
    Width = 230
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
  end
  object PanelInout: TPanel
    Left = 0
    Top = 247
    Width = 230
    Height = 159
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 246
    object SpeedButton1: TSpeedButton
      Left = 5
      Top = 6
      Width = 108
      Height = 33
      Caption = 'COM-'#1087#1086#1088#1090
      OnClick = SpeedButton1Click
    end
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
  end
  object tabStacks: TTabControl
    Left = 0
    Top = 0
    Width = 230
    Height = 244
    Align = alClient
    MultiLine = True
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    Tabs.Strings = (
      'Data'
      'Ret'
      'Loop')
    TabIndex = 0
    OnChange = tabStacksChange
    object sgStack: TStringGrid
      Left = 4
      Top = 24
      Width = 222
      Height = 145
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
      Top = 169
      Width = 222
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
    end
  end
end
