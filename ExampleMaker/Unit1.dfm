object Form1: TForm1
  Left = 278
  Top = 92
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Example Maker'
  ClientHeight = 297
  ClientWidth = 753
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object image1: TImage
    Left = 576
    Top = 16
    Width = 169
    Height = 113
  end
  object image3: TImage
    Left = 408
    Top = 16
    Width = 161
    Height = 113
  end
  object image4: TImage
    Left = 240
    Top = 16
    Width = 161
    Height = 113
  end
  object ListBox1: TListBox
    Left = 8
    Top = 13
    Width = 217
    Height = 92
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListBox1Click
  end
  object grpSaveExample: TGroupBox
    Left = 8
    Top = 144
    Width = 217
    Height = 137
    Caption = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103
    TabOrder = 1
    object lblNeuronNumber: TLabel
      Left = 120
      Top = 112
      Width = 6
      Height = 13
      Caption = '0'
    end
    object btnSaveFrame: TButton
      Left = 8
      Top = 16
      Width = 145
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1092#1088#1077#1081#1084
      TabOrder = 0
      OnClick = btnSaveFrameClick
    end
    object txt1: TStaticText
      Left = 9
      Top = 51
      Width = 80
      Height = 17
      Caption = #1053#1086#1084#1077#1088' '#1087#1088#1080#1084#1077#1088#1072
      TabOrder = 1
    end
    object seExampleNumber: TSpinEdit
      Left = 112
      Top = 48
      Width = 41
      Height = 22
      MaxValue = 9999999
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
    object trackBarNeuron: TTrackBar
      Left = 8
      Top = 72
      Width = 201
      Height = 33
      Max = 25
      TabOrder = 3
      OnChange = trackBarNeuronChange
    end
    object txt2: TStaticText
      Left = 8
      Top = 112
      Width = 80
      Height = 17
      Caption = #1053#1086#1084#1077#1088' '#1085#1077#1081#1088#1086#1085#1072
      TabOrder = 4
    end
    object Button4: TButton
      Left = 160
      Top = 16
      Width = 49
      Height = 25
      Caption = #1055#1072#1087#1082#1072
      TabOrder = 5
      OnClick = Button4Click
    end
  end
  object grpImageOptions: TGroupBox
    Left = 240
    Top = 152
    Width = 505
    Height = 129
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1072#1088#1072#1084#1077#1090#1088#1086#1074
    TabOrder = 2
    object Label7: TLabel
      Left = 11
      Top = 25
      Width = 79
      Height = 13
      Caption = #1055#1086#1088#1086#1075' '#1082#1088#1072#1089#1085#1086#1075#1086
    end
    object TrackBar1: TTrackBar
      Left = 112
      Top = 20
      Width = 377
      Height = 37
      Max = 255
      Frequency = 5
      Position = 70
      TabOrder = 0
    end
    object TrackBar2: TTrackBar
      Left = 112
      Top = 52
      Width = 377
      Height = 45
      Max = 255
      Frequency = 5
      Position = 255
      TabOrder = 1
    end
    object TrackBar3: TTrackBar
      Left = 112
      Top = 84
      Width = 377
      Height = 37
      Max = 255
      Frequency = 5
      Position = 255
      TabOrder = 2
    end
    object txt4: TStaticText
      Left = 10
      Top = 58
      Width = 83
      Height = 17
      Caption = #1055#1086#1088#1086#1075' '#1079#1077#1083#1077#1085#1086#1075#1086
      TabOrder = 3
    end
    object txt5: TStaticText
      Left = 9
      Top = 91
      Width = 71
      Height = 17
      Caption = #1055#1086#1088#1086#1075' '#1089#1080#1085#1077#1075#1086
      TabOrder = 4
    end
  end
  object panel1: TPanel
    Left = 112
    Top = 32
    Width = 73
    Height = 49
    Caption = 'panel1'
    TabOrder = 3
    Visible = False
  end
  object btnStart: TButton
    Left = 8
    Top = 112
    Width = 217
    Height = 25
    Caption = 'btnStart'
    TabOrder = 4
    OnClick = btnStartClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 56
    Top = 56
  end
end
