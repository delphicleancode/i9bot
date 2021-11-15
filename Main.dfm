object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 448
  ClientWidth = 647
  Color = clBtnFace
  DockSite = True
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 647
    Height = 429
    Align = alClient
    TabOrder = 0
    object pgcGeral: TPageControl
      Left = 1
      Top = 1
      Width = 645
      Height = 427
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Chat'
        object memChat: TMemo
          AlignWithMargins = True
          Left = 3
          Top = 44
          Width = 631
          Height = 352
          Align = alClient
          Lines.Strings = (
            '')
          TabOrder = 0
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 637
          Height = 41
          Align = alTop
          TabOrder = 1
          object grpMensagem: TGroupBox
            Left = 1
            Top = 1
            Width = 635
            Height = 39
            Align = alClient
            Caption = 'Mensagem'
            TabOrder = 0
            object edtMensagem: TEdit
              AlignWithMargins = True
              Left = 5
              Top = 16
              Width = 550
              Height = 20
              Margins.Top = 1
              Margins.Bottom = 1
              Align = alClient
              TabOrder = 0
              ExplicitHeight = 21
            end
            object Button1: TButton
              Left = 558
              Top = 15
              Width = 75
              Height = 22
              Align = alRight
              Caption = '>>'
              TabOrder = 1
              OnClick = Button1Click
            end
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Export'
        ImageIndex = 1
        ExplicitLeft = 8
        ExplicitTop = 23
        ExplicitWidth = 0
        ExplicitHeight = 0
        object memConfig: TMemo
          Left = 3
          Top = 40
          Width = 631
          Height = 356
          Lines.Strings = (
            '')
          TabOrder = 0
        end
        object Button3: TButton
          Left = 3
          Top = 9
          Width = 75
          Height = 25
          Caption = 'Get JSON'
          TabOrder = 1
          OnClick = Button3Click
        end
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 429
    Width = 647
    Height = 19
    Panels = <>
  end
end
