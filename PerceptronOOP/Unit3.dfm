object Form3: TForm3
  Left = 500
  Top = 147
  Width = 386
  Height = 385
  Caption = 'Form3'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lstNames: TValueListEditor
    Left = 16
    Top = 19
    Width = 345
    Height = 254
    TabOrder = 0
    TitleCaptions.Strings = (
      #1053#1086#1084#1077#1088' '#1074#1099#1093#1086#1076#1085#1086#1075#1086' '#1085#1077#1081#1088#1086#1085#1072
      #1053#1072#1079#1074#1072#1085#1080#1077)
    ColWidths = (
      150
      189)
  end
  object btn1: TButton
    Left = 32
    Top = 304
    Width = 313
    Height = 25
    Caption = 'C'#1086#1079#1076#1072#1090#1100
    TabOrder = 1
    OnClick = btn1Click
  end
  object dlgSave1: TSaveDialog
    Filter = #1053#1077#1081#1088#1086#1085#1085#1072#1103' '#1089#1077#1090#1100'|*.nnet'
    Left = 8
    Top = 216
  end
end