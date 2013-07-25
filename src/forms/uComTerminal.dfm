object fComTerminal: TfComTerminal
  Left = 0
  Top = 0
  Caption = 'Com terminal'
  ClientHeight = 505
  ClientWidth = 697
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 697
    Height = 25
    ButtonHeight = 21
    Caption = 'ToolBar1'
    TabOrder = 0
    object ComboBox2: TComboBox
      Left = 0
      Top = 0
      Width = 97
      Height = 21
      TabOrder = 1
      Text = 'ComboBox1'
    end
    object ComboBox1: TComboBox
      Left = 97
      Top = 0
      Width = 97
      Height = 21
      TabOrder = 0
      Text = 'ComboBox1'
    end
    object ToolButton1: TToolButton
      Left = 194
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object BitBtn1: TBitBtn
      Left = 202
      Top = 0
      Width = 75
      Height = 21
      Caption = 'BitBtn1'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 2
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 486
    Width = 697
    Height = 19
    Panels = <>
  end
  object Panel1: TPanel
    Left = 0
    Top = 25
    Width = 697
    Height = 461
    Align = alClient
    TabOrder = 2
    object mTerminal: TMemo
      Left = 1
      Top = 1
      Width = 695
      Height = 459
      Align = alClient
      Lines.Strings = (
        'mTerminal')
      TabOrder = 0
    end
  end
end
