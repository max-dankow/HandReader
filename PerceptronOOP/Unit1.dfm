object Form1: TForm1
  Left = 279
  Top = 178
  BorderStyle = bsSingle
  Caption = #1055#1077#1088#1089#1077#1087#1090#1088#1086#1085
  ClientHeight = 631
  ClientWidth = 744
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
  object img1: TImage
    Left = 32
    Top = 16
    Width = 257
    Height = 201
  end
  object lbl1: TLabel
    Left = 80
    Top = 344
    Width = 102
    Height = 13
    Caption = #1053#1077#1090' '#1085#1077#1081#1088#1086#1085#1085#1086#1081' '#1089#1077#1090#1080
  end
  object lblDelta: TLabel
    Left = 392
    Top = 144
    Width = 35
    Height = 13
    Caption = 'lblDelta'
  end
  object lblAnswer: TLabel
    Left = 392
    Top = 240
    Width = 45
    Height = 13
    Caption = 'lblAnswer'
  end
  object lbl2: TLabel
    Left = 472
    Top = 360
    Width = 3
    Height = 13
  end
  object lbl3: TLabel
    Left = 80
    Top = 368
    Width = 115
    Height = 13
    Caption = #1057#1093#1077#1084#1072' '#1085#1077#1081#1088#1086#1085#1085#1086#1081' '#1089#1077#1090#1080
  end
  object lblMissN: TLabel
    Left = 472
    Top = 384
    Width = 3
    Height = 13
  end
  object Label1: TLabel
    Left = 40
    Top = 224
    Width = 51
    Height = 13
    Caption = 'BMPName'
  end
  object lblTeachTime: TLabel
    Left = 344
    Top = 312
    Width = 82
    Height = 13
    Caption = #1042#1088#1077#1084#1103' '#1086#1073#1091#1095#1077#1085#1080#1103
  end
  object btnNewNet: TButton
    Left = 80
    Top = 248
    Width = 177
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1085#1086#1074#1086#1081' '#1089#1077#1090#1080
    TabOrder = 0
    OnClick = btnNewNetClick
  end
  object btnReadNet: TBitBtn
    Left = 80
    Top = 280
    Width = 177
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1085#1077#1081#1088#1086#1085#1085#1091#1102' '#1089#1077#1090#1100
    TabOrder = 1
    OnClick = btnReadNetClick
  end
  object btnSaveNet: TButton
    Left = 80
    Top = 312
    Width = 177
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1085#1077#1081#1088#1086#1085#1085#1091#1102' '#1089#1077#1090#1100
    Enabled = False
    TabOrder = 2
    OnClick = btnSaveNetClick
  end
  object btnOpenPicture: TButton
    Left = 384
    Top = 24
    Width = 345
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1082#1072#1088#1090#1080#1085#1082#1091
    Enabled = False
    TabOrder = 3
    OnClick = btnOpenPictureClick
  end
  object btnRecognize: TButton
    Left = 384
    Top = 64
    Width = 177
    Height = 25
    Caption = #1056#1072#1089#1087#1086#1079#1085#1072#1090#1100
    Enabled = False
    TabOrder = 4
    OnClick = btnRecognizeClick
  end
  object btnTeach: TButton
    Left = 568
    Top = 64
    Width = 161
    Height = 25
    Caption = #1056#1072#1089#1087#1086#1079#1085#1072#1090#1100' '#1080' '#1086#1073#1091#1095#1080#1090#1100
    TabOrder = 5
    OnClick = Button1Click
  end
  object Chart1: TChart
    Left = 16
    Top = 408
    Width = 721
    Height = 202
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    LeftWall.Brush.Color = clWhite
    LeftWall.Brush.Style = bsClear
    LeftWall.Color = clSilver
    Title.Text.Strings = (
      #1056#1077#1079#1091#1083#1100#1090#1072#1090' '#1088#1072#1089#1087#1086#1079#1085#1072#1074#1072#1085#1080#1103)
    Chart3DPercent = 20
    View3DOptions.Elevation = 347
    View3DOptions.HorizOffset = -4
    View3DOptions.Perspective = 17
    View3DOptions.Zoom = 106
    TabOrder = 6
    object Series1: TBarSeries
      Marks.ArrowLength = 20
      Marks.Visible = True
      SeriesColor = clRed
      XValues.DateTime = False
      XValues.Name = 'X'
      XValues.Multiplier = 1.000000000000000000
      XValues.Order = loAscending
      YValues.DateTime = False
      YValues.Name = 'Bar'
      YValues.Multiplier = 1.000000000000000000
      YValues.Order = loNone
    end
  end
  object trckbrDelta: TTrackBar
    Left = 384
    Top = 104
    Width = 353
    Height = 41
    Max = 100
    Min = 1
    Position = 1
    TabOrder = 7
    OnChange = trckbrDeltaChange
  end
  object trackBarAnswer: TTrackBar
    Left = 384
    Top = 192
    Width = 353
    Height = 45
    TabOrder = 8
    OnChange = trackBarAnswerChange
  end
  object btnMainTeach: TButton
    Left = 440
    Top = 256
    Width = 257
    Height = 73
    Caption = #1054#1073#1091#1095#1080#1090#1100' '#1074#1089#1077#1084#1091' '#1084#1085#1086#1078#1077#1089#1090#1074#1091
    TabOrder = 9
    OnClick = btnMainTeachClick
  end
  object btn1: TButton
    Left = 576
    Top = 344
    Width = 145
    Height = 25
    Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100' '#1057#1050#1054
    TabOrder = 10
    OnClick = btn1Click
  end
  object seSKONormal: TSpinEdit
    Left = 392
    Top = 160
    Width = 65
    Height = 22
    MaxValue = 100000
    MinValue = 0
    TabOrder = 11
    Value = 200
  end
  object seKTime: TSpinEdit
    Left = 488
    Top = 160
    Width = 73
    Height = 22
    MaxValue = 99
    MinValue = 0
    TabOrder = 12
    Value = 0
  end
  object SaveDialog1: TSaveDialog
    Filter = #1053#1077#1081#1088#1086#1085#1085#1072#1103' '#1089#1077#1090#1100'|*.nnet'
    InitialDir = '/Data'
    Left = 368
    Top = 16
  end
  object dlgOpenNeuroNet: TOpenDialog
    Filter = #1053#1077#1081#1088#1086#1085#1085#1072#1103' '#1089#1077#1090#1100'|*.nnet'
    InitialDir = '/Data'
    Left = 320
    Top = 16
  end
  object dlgOpenBMP: TOpenDialog
    Filter = #1050#1072#1088#1090#1080#1085#1082#1072' BitMap|*.bmp'
    InitialDir = '/Data'
    Left = 344
    Top = 16
  end
  object xpmnfst1: TXPManifest
    Left = 296
    Top = 16
  end
end
