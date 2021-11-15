unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.StdCtrls,

  i9Bot;

type
  TMainForm = class(TForm)
    Panel2: TPanel;
    pgcGeral: TPageControl;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    memChat: TMemo;
    TabSheet2: TTabSheet;
    memConfig: TMemo;
    Button3: TButton;
    Panel1: TPanel;
    grpMensagem: TGroupBox;
    edtMensagem: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FChat: TChat;
    procedure Iniciar;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

const
  INTENCAO_INDEFINIDA  = -1;
  INTENCAO_CUMPRIMENTO = 1;
  INTENCAO_CARDAPIO    = 2;
  INTENCAO_COMPRAR     = 3;

implementation
  uses
    System.Generics.Collections;

{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
const
  INTENCAO = 'Intencao: %s Prioridade: %s';
  RESPOSTA = 'Resposta: %s ';
var
  FIntencao: TIntencao;
begin
  memChat.Lines.Clear;

  FChat.Processar(edtMensagem.Text);

  for FIntencao in FChat.Intencoes do
  begin
    memChat.Lines.Add('------------------------------------------------------------------------');
    memChat.Lines.Add(Format(INTENCAO, [FIntencao.Codigo.ToString + ' - ' + FIntencao.Descricao , FIntencao.Prioridade.ToString] ));
  end;

  if FChat.Intencao.Respondido then
  begin
    FChat.FinalizarPergunta;

    memChat.Lines.Add('Resposta:');
    memChat.Lines.Add('Código: '    + FChat.RespostaPergunta.Codigo.ToString);
    memChat.Lines.Add('Item: '      + FChat.RespostaPergunta.Item);
    memChat.Lines.Add('Descrição:'  + FChat.RespostaPergunta.Descricao);

  end
  else
  if FChat.Intencao.Perguntar then
    memChat.Lines.Add(FChat.Intencao.ObterPergunta);

  if FChat.AtributoDetectado then
  begin
    memChat.Lines.Add('------------------------------------------------------------------------');
    memChat.Lines.Add('ID: '          + FChat.Atributos.Last.ID);
    memChat.Lines.Add('NOME: '        + FChat.Atributos.Last.Nome);
    memChat.Lines.Add('CONTEUDO: '    + FChat.Atributos.Last.Conteudo);
    memChat.Lines.Add('COMPLEMENTO: ' + FChat.Atributos.Last.Complemento);
    memChat.Lines.Add('VALOR: '       + FChat.Atributos.Last.Valor);
  end
  else
    memChat.Lines.Add(Format(RESPOSTA, [FChat.Intencao.RespostaAleatoria] ));

  if FChat.ObterProximaIntencao then
  begin
    if FChat.Intencao.Perguntar then
      memChat.Lines.Add(FChat.Intencao.ObterPergunta);
  end;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  memConfig.Text := FChat.AsJson;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Iniciar;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FChat);
end;

procedure TMainForm.Iniciar;
var
  FIntencao: TIntencao;
begin
  FChat := TChat.Create;
  FChat.RespostaIndefinida :=  'Ops, não entendi';

  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := INTENCAO_CUMPRIMENTO;
  FIntencao.Descricao := 'Cumprimento';
  FIntencao.Prioridade:= 1;

  FIntencao.Palavras.AddRange(['BOM',
                               'BOM?',
                               'BEM',
                               'BEM?',
                               'BOA',
                               'DIA',
                               'TARDE',
                               'NOITE',
                               'OI',
                               'OLA',
                               'HI',
                               'blz?',
                               'E ai blz?']);

  FIntencao.Respostas.AddRange(['Seja bem vindo(a)!',
                                'Olá tudo bem!',
                                'Bom dia, que bom que você nos contactou, temos ótimos produtos hoje',
                                'Oi! tudo bom? Em que posso ajudar?',
                                'Oi, prazer em ter você em nosso canal']);

  FChat.AdicionarIntencao(FIntencao);

  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := INTENCAO_COMPRAR;
  FIntencao.Descricao := 'Fazer Pedido';
  FIntencao.Prioridade:= 3;
  FIntencao.Palavras.AddRange(['QUERO',
                               'PRETENDO',
                               'PRECISO',
                               'ENTREGUE',
                               'ENTREGAR',
                               'FAZER',
                               'COMPRAR',
                               'PEDIDO']);

  FIntencao.Respostas.AddRange(['Oi, o que você gostaria de comprar hoje?',
                                'Olá, o que vai pedir?',
                                'E ai, tudo bem? Qual o produto você quer?']);

  FChat.AdicionarIntencao(FIntencao);

  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := INTENCAO_CARDAPIO;
  FIntencao.Descricao := 'Ver Cardápio';
  FIntencao.Prioridade:= 2;
  FIntencao.Palavras.AddRange(['MENU',
                               'CARDAPIO',
                               'ALMOÇO',
                               'JANTAR',
                               'COMIDA']);

  FIntencao.Respostas.AddRange(['Certo, vou lhe enviar as opções do dia',
                                'Legal, veja a seguir nosso cardápio',
                                'Ótimo, irei lhe passar as opções']);


  FChat.AdicionarIntencao(FIntencao);  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := 4;
  FIntencao.Descricao := 'Executar Comando';
  FIntencao.Prioridade:= 4;
  FIntencao.Palavras.AddRange(['!',
                               '?']);

  FIntencao.Respostas.AddRange(['Comando será executado',
                                'OK, processando',
                                'Vamos lá!!!']);

  FChat.AdicionarIntencao(FIntencao);  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := 5;
  FIntencao.Descricao := 'Executar Comando Avançado';
  FIntencao.Prioridade:= 5;
  FIntencao.Palavras.AddRange(['!',
                               '?']);

  FIntencao.Respostas.AddRange(['Agora vai',
                                'Vamos em frente!!!!']);

  FChat.AdicionarIntencao(FIntencao);

  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := 6;
  FIntencao.Descricao := 'Comprar Pizza Grande';
  FIntencao.Prioridade:= 6;
  FIntencao.Palavras.AddRange(['GDE',
                               'GRANDE',
                               'MAIOR']);

  FIntencao.Respostas.AddRange(['Você quer uma pizza grande?']);

  FChat.AdicionarIntencao(FIntencao);

  FChat.AdicionarAtributos('Pizza',
                           'Mussarela, Portuguesa, Calabreza, Frango Catupiry, Brócolis',
                           'Pequena, Média, Grande',
                           '25.00, 35.00, 45.00',
                           '1000,  1001,  1002');

  FChat.AdicionarAtributos('Refrigerante',
                           'Coca cola, Sprite, Fanta, Guaraná',
                           'Lata, Litro, Familia',
                           '3.50, 6.50, 10.00',
                           '2000, 2001, 2002');

  FChat.AdicionarPergunta(10, ['OPCAO'],  'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 11);
  FChat.AdicionarPergunta(11, ['OPCAO2'], 'Escolha OUTRA opção abaixo:', 'D,E,F','Outra Opção D,Outra Opção E,Outra Opção F', 0);
end;

end.
