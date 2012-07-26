object fForthDevice: TfForthDevice
  Left = 390
  Top = 344
  Align = alClient
  Caption = 'fForthDevice'
  ClientHeight = 436
  ClientWidth = 220
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
    Top = 274
    Width = 220
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
    ExplicitTop = 244
    ExplicitWidth = 230
  end
  object PanelInout: TPanel
    Left = 0
    Top = 277
    Width = 220
    Height = 159
    Align = alBottom
    Caption = 'inout'
    TabOrder = 0
    ExplicitTop = 247
    ExplicitWidth = 230
  end
  object tabStacks: TTabControl
    Left = 0
    Top = 0
    Width = 220
    Height = 274
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
    ExplicitWidth = 230
    ExplicitHeight = 244
    object sgStack: TStringGrid
      Left = 4
      Top = 24
      Width = 212
      Height = 175
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
      ExplicitWidth = 222
      ExplicitHeight = 145
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
      Top = 199
      Width = 212
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
      ExplicitTop = 169
      ExplicitWidth = 222
    end
  end
end
