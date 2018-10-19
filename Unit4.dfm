object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Tracker'
  ClientHeight = 377
  ClientWidth = 792
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  DesignSize = (
    792
    377)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 74
    Top = 1
    Width = 14
    Height = 30
    Color = clLime
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = 30
    Font.Name = 'Consolas'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Memo1: TMemo
    Left = 8
    Top = 35
    Width = 369
    Height = 291
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Edit2: TEdit
    Left = 8
    Top = 8
    Width = 60
    Height = 21
    NumbersOnly = True
    TabOrder = 1
    Text = '20488'
  end
  object Memo2: TMemo
    Left = 400
    Top = 35
    Width = 384
    Height = 291
    Anchors = [akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnExecute = IdTCPServer1Execute
    Left = 664
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 704
  end
  object NetHTTPClient1: TNetHTTPClient
    AllowCookies = True
    HandleRedirects = True
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 752
  end
end
