object fmTermSet: TfmTermSet
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Terminal settings'
  ClientHeight = 166
  ClientWidth = 298
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TBitBtn
    Left = 64
    Top = 135
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    DoubleBuffered = True
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    ModalResult = 1
    NumGlyphs = 2
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object btnCancel: TBitBtn
    Left = 161
    Top = 135
    Width = 75
    Height = 25
    DoubleBuffered = True
    Kind = bkCancel
    ParentDoubleBuffered = False
    TabOrder = 1
  end
  object btnFont: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Font'
    TabOrder = 2
    OnClick = btnFontClick
  end
  object btnBGcolor: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'BG color'
    TabOrder = 3
    OnClick = btnBGcolorClick
  end
  object edTestTerm: TEdit
    Left = 170
    Top = 8
    Width = 121
    Height = 24
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clLime
    Font.Height = -13
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 4
    Text = 'Text example'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 48
    Width = 283
    Height = 81
    Caption = 'Output'
    TabOrder = 5
    object rbCharsOnly: TRadioButton
      Left = 16
      Top = 24
      Width = 162
      Height = 17
      Caption = 'Chars only with string len ='
      TabOrder = 0
    end
    object rbCharsWithHex: TRadioButton
      Left = 16
      Top = 47
      Width = 162
      Height = 17
      Caption = 'Chars with HEX code. Bytes = '
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object seStrLen: TSpinEdit
      Left = 184
      Top = 24
      Width = 81
      Height = 22
      MaxValue = 256
      MinValue = 1
      TabOrder = 2
      Value = 80
    end
    object cbHexLen: TComboBox
      Left = 184
      Top = 47
      Width = 81
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = '8'
      Items.Strings = (
        '8'
        '16')
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 120
    Top = 24
  end
  object dlgColor: TColorDialog
    Left = 160
    Top = 24
  end
end
