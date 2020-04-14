object fmSettings: TfmSettings
  Left = 554
  Top = 224
  BorderStyle = bsDialog
  Caption = 'MyEngine settings'
  ClientHeight = 421
  ClientWidth = 477
  Color = clBtnFace
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
  object Image1: TImage
    Left = 32
    Top = 16
    Width = 105
    Height = 105
  end
  object Button1: TButton
    Left = 262
    Top = 383
    Width = 97
    Height = 31
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 372
    Top = 383
    Width = 97
    Height = 31
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button2Click
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 477
    Height = 377
    ActivePage = TabSheet1
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Generally'
      object GroupBox7: TGroupBox
        Left = 3
        Top = 3
        Width = 462
        Height = 118
        Caption = 'Connection'
        TabOrder = 0
        object Label1: TLabel
          Left = 11
          Top = 36
          Width = 103
          Height = 25
          Caption = 'COM-port:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object cb_ports: TComboBox
          Left = 144
          Top = 27
          Width = 185
          Height = 33
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -21
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 25
          ParentFont = False
          TabOrder = 0
        end
        object btUpdateCOMs: TButton
          Left = 335
          Top = 28
          Width = 105
          Height = 33
          Caption = 'Update'
          TabOrder = 1
          OnClick = btUpdateCOMsClick
        end
        object cb_invert: TCheckBox
          Left = 11
          Top = 77
          Width = 307
          Height = 24
          Caption = 'Inverse adapter'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
      end
      object GroupBox8: TGroupBox
        Left = 4
        Top = 128
        Width = 462
        Height = 137
        Caption = 'Startup settings'
        TabOrder = 1
        object cbRunMinimize: TCheckBox
          Left = 10
          Top = 69
          Width = 318
          Height = 24
          Caption = 'Start minimized'
          TabOrder = 0
        end
        object cbAutoRun: TCheckBox
          Left = 10
          Top = 39
          Width = 222
          Height = 24
          Caption = 'Autorun'
          TabOrder = 1
        end
        object cbHideMinimized: TCheckBox
          Left = 10
          Top = 99
          Width = 238
          Height = 23
          Caption = 'Hide when minimized'
          TabOrder = 2
        end
      end
      object cbAskOnExit: TCheckBox
        Left = 14
        Top = 271
        Width = 283
        Height = 23
        Caption = 'Ask before exit'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Conversion'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ImageIndex = 1
      ParentFont = False
      object GroupBox1: TGroupBox
        Left = 3
        Top = 3
        Width = 225
        Height = 110
        Caption = 'IAC valve'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object rb_xx_proc: TRadioButton
          Left = 16
          Top = 32
          Width = 145
          Height = 24
          Caption = '% from 255'
          TabOrder = 0
        end
        object rb_xx_step: TRadioButton
          Left = 16
          Top = 62
          Width = 145
          Height = 24
          Caption = 'Step'
          TabOrder = 1
        end
      end
      object GroupBox2: TGroupBox
        Left = 3
        Top = 119
        Width = 225
        Height = 106
        Caption = 'Temperature'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        object rb_temp_dir: TRadioButton
          Left = 16
          Top = 32
          Width = 113
          Height = 24
          Caption = 'Direct'
          TabOrder = 0
        end
        object rb_temp_nondir: TRadioButton
          Left = 16
          Top = 62
          Width = 137
          Height = 24
          Caption = 'Inverse'
          TabOrder = 1
        end
      end
      object GroupBox3: TGroupBox
        Left = 3
        Top = 231
        Width = 225
        Height = 97
        Caption = 'Throttle body'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object rb_thr_grad: TRadioButton
          Left = 16
          Top = 32
          Width = 113
          Height = 24
          Caption = 'Degrees'
          TabOrder = 0
        end
        object rb_thr_proc: TRadioButton
          Left = 16
          Top = 62
          Width = 137
          Height = 24
          Caption = 'Percentages'
          TabOrder = 1
        end
      end
      object GroupBox4: TGroupBox
        Left = 234
        Top = 3
        Width = 226
        Height = 222
        Caption = 'Measuring airflow'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        object rb_air_0: TRadioButton
          Left = 17
          Top = 32
          Width = 160
          Height = 24
          Caption = 'MAP, kPa'
          TabOrder = 0
        end
        object rb_air_1: TRadioButton
          Left = 17
          Top = 62
          Width = 160
          Height = 24
          Caption = 'MAP, mm Hg'
          TabOrder = 1
        end
        object rb_air_2: TRadioButton
          Left = 17
          Top = 92
          Width = 160
          Height = 24
          Caption = 'MAP-Turbo, kPa'
          TabOrder = 2
        end
        object rb_air_3: TRadioButton
          Left = 17
          Top = 122
          Width = 206
          Height = 24
          Caption = 'MAP-Turbo, mm Hg'
          TabOrder = 3
        end
        object rb_air_4: TRadioButton
          Left = 17
          Top = 152
          Width = 160
          Height = 24
          Caption = 'MAF, gr/s'
          TabOrder = 4
        end
        object rb_air_5: TRadioButton
          Left = 17
          Top = 182
          Width = 160
          Height = 24
          Caption = 'VAF, V'
          TabOrder = 5
        end
      end
      object GroupBox5: TGroupBox
        Left = 234
        Top = 231
        Width = 226
        Height = 97
        Caption = 'Long Fuel Trim'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
        object rb_corr_proc: TRadioButton
          Left = 17
          Top = 34
          Width = 145
          Height = 24
          Caption = 'Percentages'
          TabOrder = 0
        end
        object rb_corr_v: TRadioButton
          Left = 17
          Top = 64
          Width = 113
          Height = 24
          Caption = 'Volts'
          TabOrder = 1
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Consumption'
      ImageIndex = 2
      object Label8: TLabel
        Left = 3
        Top = 24
        Width = 137
        Height = 23
        Caption = 'Template:'
      end
      object GroupBox6: TGroupBox
        Left = 3
        Top = 61
        Width = 369
        Height = 190
        Caption = 'Injection settings'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object Label2: TLabel
          Left = 16
          Top = 40
          Width = 90
          Height = 23
          Caption = 'Number of injectors:'
        end
        object Label3: TLabel
          Left = 16
          Top = 93
          Width = 98
          Height = 23
          Caption = 'Performance of inj.:'
        end
        object Label4: TLabel
          Left = 283
          Top = 40
          Width = 30
          Height = 23
          Caption = 'pcs'
        end
        object Label5: TLabel
          Left = 283
          Top = 93
          Width = 78
          Height = 23
          Caption = 'l/15 sec'
        end
        object Label6: TLabel
          Left = 283
          Top = 144
          Width = 54
          Height = 23
          Caption = 'times'
        end
        object Label7: TLabel
          Left = 16
          Top = 144
          Width = 134
          Height = 23
          Caption = 'Workings inj.:'
        end
        object edInjCnt: TEdit
          Left = 215
          Top = 32
          Width = 62
          Height = 31
          TabOrder = 0
          Text = '6'
        end
        object edInjPower: TEdit
          Left = 215
          Top = 85
          Width = 62
          Height = 31
          TabOrder = 1
          Text = '0,0785'
        end
        object edInjFire: TEdit
          Left = 215
          Top = 136
          Width = 62
          Height = 31
          TabOrder = 2
          Text = '1'
        end
      end
      object cbEngineDef: TComboBox
        Left = 162
        Top = 16
        Width = 210
        Height = 31
        Style = csDropDownList
        ItemHeight = 23
        TabOrder = 1
        OnChange = cbEngineDefChange
        Items.Strings = (
          '1JZ,2JZ-GE (1992-1996)'
          '1JZ-GTE (1992-1996)'
          '2JZ-GTE (1992-1996)'
          '1JZ-GE (1996-2000)'
          '2JZ-GE (1996-2000)'
          '1JZ-GTE (1996-2000)'
          '5S-FE'
          '5A-FE'
          '4E-FE, 5E-FE'
          '4E-FE (after 1995)'
          '7M-GE'
          '7M-GTE'
          '1G-E'
          '1G-FE'
          '1G-GE'
          '1G-GZE,-GTE ('#1088#1072#1085'.)'
          '1G-GZE,-GTE ('#1087#1086#1079#1076#1085'.)')
      end
      object cbInjTruncate: TCheckBox
        Left = 3
        Top = 264
        Width = 361
        Height = 57
        Caption = 'TEST: Include forced idle'
        TabOrder = 2
        WordWrap = True
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'About'
      ImageIndex = 3
      object Label10: TLabel
        Left = 11
        Top = 64
        Width = 428
        Height = 46
        Caption = 'MyEngine Internet page:'
        WordWrap = True
      end
      object lbVersion: TLabel
        Left = 11
        Top = 19
        Width = 76
        Height = 23
        Caption = 'lbVersion'
      end
      object Label9: TLabel
        Left = 11
        Top = 119
        Width = 206
        Height = 23
        Cursor = crHandPoint
        Caption = 'http://primavistalab.com'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = Label9Click
      end
    end
  end
end
