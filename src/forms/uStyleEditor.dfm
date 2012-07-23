object fStyleEditor: TfStyleEditor
  Left = 468
  Top = 293
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Style editor'
  ClientHeight = 271
  ClientWidth = 254
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 241
    Height = 57
    Caption = 'Files'
    TabOrder = 0
    object bLoadFromFile: TButton
      Left = 132
      Top = 19
      Width = 97
      Height = 25
      Caption = 'Load from file'
      TabOrder = 0
      OnClick = bLoadFromFileClick
    end
    object bSaveToFile: TButton
      Left = 12
      Top = 19
      Width = 97
      Height = 25
      Caption = 'Save to file'
      TabOrder = 1
      OnClick = bSaveToFileClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 56
    Width = 241
    Height = 169
    Caption = 'Editor'
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 27
      Width = 67
      Height = 13
      Caption = 'Element name'
    end
    object Label2: TLabel
      Left = 16
      Top = 72
      Width = 44
      Height = 13
      Caption = 'Forecolor'
    end
    object Label3: TLabel
      Left = 16
      Top = 112
      Width = 48
      Height = 13
      Caption = 'Backcolor'
    end
    object imgFore: TImage
      Left = 77
      Top = 67
      Width = 26
      Height = 25
      OnClick = imgForeClick
    end
    object imgBack: TImage
      Left = 77
      Top = 107
      Width = 26
      Height = 25
      OnClick = imgBackClick
    end
    object cbElementName: TComboBox
      Left = 80
      Top = 24
      Width = 145
      Height = 21
      TabOrder = 0
      Text = 'cbElementName'
      OnChange = cbElementNameChange
    end
    object GroupBox3: TGroupBox
      Left = 120
      Top = 56
      Width = 113
      Height = 105
      Caption = 'Text attributes'
      TabOrder = 1
      object chkBold: TCheckBox
        Left = 8
        Top = 24
        Width = 97
        Height = 17
        Caption = 'Bold'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = chkBoldClick
      end
      object chkItalic: TCheckBox
        Left = 8
        Top = 48
        Width = 97
        Height = 17
        Caption = 'Italic'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = chkItalicClick
      end
      object chkUnderline: TCheckBox
        Left = 8
        Top = 72
        Width = 97
        Height = 17
        Caption = 'Underline'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = chkUnderlineClick
      end
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 224
    Width = 241
    Height = 41
    TabOrder = 2
    object BitBtn1: TBitBtn
      Left = 13
      Top = 10
      Width = 97
      Height = 25
      DoubleBuffered = True
      Kind = bkOK
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object BitBtn2: TBitBtn
      Left = 125
      Top = 10
      Width = 97
      Height = 25
      DoubleBuffered = True
      Kind = bkCancel
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object ColorDialog1: TColorDialog
    Left = 16
    Top = 192
  end
  object SaveDialog1: TSaveDialog
    Filter = 'kf styles|*.kfs|All files|*.*'
    FilterIndex = 0
    Left = 48
    Top = 192
  end
  object OpenDialog1: TOpenDialog
    Filter = 'kf styles|*.kfs|All files|*.*'
    FilterIndex = 0
    Left = 80
    Top = 192
  end
end
