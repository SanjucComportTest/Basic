object Form1: TForm1
  Left = 778
  Top = 238
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'TEST MIC'
  ClientHeight = 252
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #46027#50880#52404
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 91
    Height = 13
    Caption = #53685#49888#54252#53944'(COM)'
  end
  object Button1: TButton
    Left = 112
    Top = 32
    Width = 89
    Height = 33
    Caption = #54252#53944#50676#44592
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 112
    Top = 112
    Width = 89
    Height = 33
    Caption = #45936#51060#53552#51204#49569
    TabOrder = 1
    OnClick = Button2Click
  end
  object SpinEdit1: TSpinEdit
    Left = 16
    Top = 40
    Width = 89
    Height = 22
    MaxLength = 2
    MaxValue = 20
    MinValue = 1
    TabOrder = 2
    Value = 1
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 104
    Width = 81
    Height = 17
    Caption = 'MIC #1'
    TabOrder = 3
  end
  object CheckBox2: TCheckBox
    Left = 16
    Top = 128
    Width = 81
    Height = 17
    Caption = 'MIC #2'
    TabOrder = 4
  end
  object Button3: TButton
    Left = 112
    Top = 192
    Width = 89
    Height = 33
    Caption = #49345#53468#52404#53356
    TabOrder = 5
    OnClick = Button3Click
  end
end
