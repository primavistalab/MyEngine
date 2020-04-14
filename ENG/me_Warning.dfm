object fmWarning: TfmWarning
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'fmWarning'
  ClientHeight = 323
  ClientWidth = 527
  Color = clGrayText
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 233
    Height = 58
    Caption = 'Warning!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -48
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 16
    Top = 80
    Width = 489
    Height = 169
    AutoSize = False
    Caption = 
      'Do not operate the program while driving. All risks are carrying' +
      ' themselves.'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object Button1: TButton
    Left = 16
    Top = 280
    Width = 233
    Height = 30
    Caption = 'I agree - continute'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 272
    Top = 280
    Width = 233
    Height = 30
    Caption = 'I disagree - close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button2Click
  end
end
