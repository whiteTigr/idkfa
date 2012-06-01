object fProteusDevice: TfProteusDevice
  Left = 192
  Top = 114
  Width = 203
  Height = 504
  Align = alClient
  Caption = 'fProteusDevice'
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
    Top = 308
    Width = 195
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
  end
  object PanelInout: TPanel
    Left = 0
    Top = 311
    Width = 195
    Height = 159
    Align = alBottom
    Caption = 'inout'
    TabOrder = 0
  end
  object tabStacks: TTabControl
    Left = 0
    Top = 0
    Width = 195
    Height = 308
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
    object sgStack: TStringGrid
      Left = 4
      Top = 24
      Width = 187
      Height = 209
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
      Top = 233
      Width = 187
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
