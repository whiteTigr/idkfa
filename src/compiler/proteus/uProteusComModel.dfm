object fComModel: TfComModel
  Left = 192
  Top = 114
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'fComModel'
  ClientHeight = 87
  ClientWidth = 179
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object eByteToSend: TEdit
    Left = 88
    Top = 16
    Width = 73
    Height = 24
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = '0'
  end
  object bSend: TBitBtn
    Left = 8
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Send'
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 1
    OnClick = bSendClick
  end
  object StaticText1: TStaticText
    Left = 8
    Top = 53
    Width = 76
    Height = 17
    Caption = 'Received byte:'
    TabOrder = 2
  end
  object eReceivedByte: TEdit
    Left = 88
    Top = 49
    Width = 73
    Height = 24
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 3
  end
end
