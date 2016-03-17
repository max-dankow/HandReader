object Form2: TForm2
  Left = 473
  Top = 172
  Width = 502
  Height = 194
  BorderIcons = [biSystemMenu]
  Caption = 'Form2'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblVolume: TLabel
    Left = 8
    Top = 16
    Width = 85
    Height = 13
    Caption = #1043#1088#1086#1084#1082#1086#1089#1090#1100' '#1079#1074#1091#1082#1072
  end
  object lblRate: TLabel
    Left = 8
    Top = 56
    Width = 75
    Height = 13
    Caption = #1057#1082#1086#1088#1086#1089#1090#1100' '#1088#1077#1095#1080
  end
  object lblTembr: TLabel
    Left = 8
    Top = 96
    Width = 67
    Height = 13
    Caption = #1058#1077#1084#1073#1088' '#1075#1086#1083#1086#1089#1072
  end
  object trckBarVolume: TTrackBar
    Left = 112
    Top = 16
    Width = 369
    Height = 25
    Max = 100
    Frequency = 5
    TabOrder = 0
    OnChange = trckBarVolumeChange
  end
  object chkEnabled: TCheckBox
    Left = 8
    Top = 128
    Width = 97
    Height = 17
    Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1079#1074#1091#1082
    TabOrder = 1
    OnClick = chkEnabledClick
  end
  object trckBarRate: TTrackBar
    Left = 112
    Top = 56
    Width = 369
    Height = 25
    Min = -10
    TabOrder = 2
    OnChange = trckBarRateChange
  end
  object cbbTembr: TComboBox
    Left = 112
    Top = 91
    Width = 145
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = 'cbbTembr'
    OnChange = cbbTembrChange
  end
  object btnTry: TButton
    Left = 272
    Top = 88
    Width = 201
    Height = 25
    Caption = #1055#1088#1086#1073#1086#1074#1072#1090#1100
    TabOrder = 4
    OnClick = btnTryClick
  end
  object btnOK: TButton
    Left = 144
    Top = 128
    Width = 153
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 5
    OnClick = btnOKClick
  end
  object btnClose: TButton
    Left = 312
    Top = 128
    Width = 163
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    TabOrder = 6
    OnClick = btnCloseClick
  end
  object SpVoice1: TSpVoice
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 32
    Top = 40
  end
end
