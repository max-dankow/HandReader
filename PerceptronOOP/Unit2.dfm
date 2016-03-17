object Form2: TForm2
  Left = 951
  Top = 481
  Width = 377
  Height = 306
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1085#1077#1081#1088#1086#1085#1085#1086#1081' '#1089#1077#1090#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 98
    Height = 13
    Caption = #1050#1086#1083#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1083#1086#1105#1074
  end
  object SpinEdit1: TSpinEdit
    Left = 168
    Top = 24
    Width = 121
    Height = 22
    EditorEnabled = False
    MaxValue = 5
    MinValue = 2
    TabOrder = 0
    Value = 2
    OnChange = SpinEdit1Change
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 72
    Width = 337
    Height = 105
    MultiLine = True
    TabOrder = 1
  end
  object btnCreateNNet: TButton
    Left = 64
    Top = 192
    Width = 217
    Height = 65
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1077#1081#1088#1086#1085#1085#1091#1102' '#1089#1077#1090#1100
    TabOrder = 2
    OnClick = btnCreateNNetClick
  end
end
