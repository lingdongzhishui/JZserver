object Form1: TForm1
  Left = 237
  Top = 206
  Width = 979
  Height = 563
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 105
    Width = 971
    Height = 424
    Align = alClient
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = GB2312_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = #23435#20307
    TitleFont.Style = []
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 971
    Height = 105
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 1
    object Label1: TLabel
      Left = 27
      Top = 18
      Width = 47
      Height = 13
      Caption = 'SQL'#35821#21517
    end
    object Button1: TButton
      Left = 696
      Top = 17
      Width = 75
      Height = 25
      Caption = #26597#35810
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 782
      Top = 17
      Width = 75
      Height = 25
      Caption = #21333#19968#26657#39564
      TabOrder = 1
      OnClick = Button2Click
    end
    object Memo1: TMemo
      Left = 101
      Top = 13
      Width = 588
      Height = 73
      Lines.Strings = (
        'Memo1')
      TabOrder = 2
    end
    object Button3: TButton
      Left = 865
      Top = 17
      Width = 75
      Height = 25
      Caption = #20840#37096#26657#39564
      TabOrder = 3
      OnClick = Button3Click
    end
  end
  object ADOQuery1: TADOQuery
    Parameters = <>
    Left = 253
    Top = 101
  end
  object DataSource1: TDataSource
    DataSet = ADOQuery1
    Left = 217
    Top = 232
  end
end
