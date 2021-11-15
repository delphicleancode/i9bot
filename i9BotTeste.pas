unit i9BotTeste;

interface
uses
  System.SysUtils,
  DUnitX.TestFramework,
  i9Bot;

type

  [TestFixture]
  TChatTest = class(TObject)
  public
    FChat: TChat;

    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('Cumprimentar', 'Olá')]
    [TestCase('Cumprimentar', 'oLá')]
    [TestCase('Cumprimentar', 'olá')]
    [TestCase('Cumprimentar', 'OLA')]
    [TestCase('Cumprimentar', 'oi')]
    [TestCase('Cumprimentar', 'Hi')]
    [TestCase('Cumprimentar', 'opa')]
    [TestCase('Cumprimentar', 'oPA')]
    procedure IntencaoCumprimentoTest(const AMensagem: string);

    [Test]
    [TestCase('Cumprimentar2', 'Bom dia')]
    [TestCase('Cumprimentar2', 'Boa tARDE')]
    [TestCase('Cumprimentar2', 'Boa NOITE')]
    procedure IntencaoCumprimento2Test(const AMensagem: string);

    [Test]
    [TestCase('Comprar', 'Oi quero comprar um produto')]
    [TestCase('Comprar', 'Olá preciso que me entregue')]
    [TestCase('Comprar', 'oi quero fazer um pedido')]
    procedure IntencaoComprarTest(const AMensagem: string);

    [Test]
    [TestCase('Intencoes', 'Oi quero comprar um jantar, 3, 3')]
    [TestCase('Intencoes', 'Olá preciso que me entregue comida, 3, 3')]
    [TestCase('Intencoes', 'oi quero fazer um pedido, 2, 3')]
    [TestCase('Intencoes', 'pedido, 1, 3')]
    [TestCase('Intencoes', 'oi por favor o menu, 2, 2')]
    [TestCase('Intencoes', 'Oi tudo bem?, 1, 1')]
    [TestCase('Intencoes', 'tudo bem, 1, 1')]
    [TestCase('Intencoes', 'tudo bom?, 1, 1')]
    [TestCase('Intencoes', 'nada não, 0, 0')]
    procedure IntencoesTest(const AMensagem: string; const AIntencoesCount: Integer; const AIntencaoPrincipal: Integer);

    [Test]
    [TestCase('Indefinido', 'Blá')]
    [TestCase('Indefinido', '123')]
    [TestCase('Indefinido', 'testando')]
    [TestCase('Indefinido', 'uhuuu')]
    [TestCase('Indefinido', 'XYZ')]
    procedure IntencaoIndefinidaTest(const AMensagem: string);

    [Test]
    [TestCase('Cardapio', 'comida')]
    [TestCase('Cardapio', 'jantar')]
    [TestCase('Cardapio', 'menu')]
    procedure IntencaoCardapioTest(const AMensagem: string);

    [Test]
    procedure RespostaAleatoriaTest;

    [Test]
    procedure IntencoesOrdemPrioridadeTest;

    [Test]
    procedure AtributoDetectadoTest;

    [Test]
    procedure AtributoNaoDetectadoTest;

    [Test]
    procedure AtributoSimplesTest;

    [Test]
    procedure AtributoCompostoTest;

    [Test]
    procedure DialogoIndefinidoTest;

    [Test]
    procedure IntencaoComPerguntaTest;

    [Test]
    procedure IntencaoObterPerguntaTest;

    [Test]
    procedure IntencaoRespostaPerguntaTest;

    [Test]
    procedure IntencaoPerguntaRespondidaTest;

    [Test]
    procedure IntencaoPerguntaNaoRespondidaTest;

    [Test]
    procedure IntencaoRepetirPerguntaNaoRespondidaTest;

    [Test]
    procedure IntencaoFinalizarPerguntaTest;

    [Test]
    procedure IntencaoJaRespondidaTest;
  end;

const
  INTENCAO_INDEFINIDA  = -1;
  INTENCAO_CUMPRIMENTO = 1;
  INTENCAO_CARDAPIO    = 2;
  INTENCAO_COMPRAR     = 3;

implementation

procedure TChatTest.Setup;
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
                               'OPA',
                               'E ai blz?']);

  FIntencao.Respostas.AddRange(['Seja bem vindo(a)!',
                                'Olá tudo bem!',
                                'Bom dia, que bom que você nos contactou, temos ótimos produtos hoje',
                                'Oi! tudo bom? Em que posso ajudar?',
                                'Olá sou o assistente virtual da loja max',
                                'Boa tarde, estou aqui para ajudar você',
                                'Grande dia para fazer comprar não?',
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

  FChat.AdicionarIntencao(FIntencao);
end;

procedure TChatTest.TearDown;
begin
  FChat.Free;
  FChat := nil;
end;

procedure TChatTest.IntencaoCumprimento2Test(const AMensagem: string);
begin
  FChat.Processar(AMensagem);
  Assert.AreEqual(2, FChat.Intencao.Ocorrencias(AMensagem));
  Assert.AreEqual(INTENCAO_CUMPRIMENTO, FChat.Intencao.Codigo);
end;

procedure TChatTest.IntencaoCumprimentoTest(const AMensagem: string);
begin
  FChat.Processar(AMensagem);
  Assert.AreEqual(INTENCAO_CUMPRIMENTO, FChat.Intencao.Codigo);
end;

procedure TChatTest.IntencaoFinalizarPerguntaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');

  FChat.Processar('B');
  Assert.IsTrue(FChat.Intencao.Respondido);
  Assert.IsFalse(FChat.Intencao.Finalizada);

  FChat.FinalizarPergunta;

  Assert.IsFalse(FChat.Intencao.Respondido);
  Assert.IsTrue(FChat.Intencao.Finalizada);
end;

procedure TChatTest.IntencaoIndefinidaTest(const AMensagem: string);
begin
  FChat.Processar(AMensagem);
  Assert.AreEqual(INTENCAO_INDEFINIDA, FChat.Intencao.Codigo);
  Assert.AreEqual(FChat.Intencao.RespostaAleatoria, FChat.RespostaIndefinida);
end;

procedure TChatTest.IntencaoJaRespondidaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');

  Assert.IsFalse(FChat.Intencao.Respondido);

  FChat.Processar('B');
  FChat.FinalizarPergunta;
  FChat.Processar('B');
  Assert.AreEqual(FChat.RespostaIndefinida, 'ok, já estou verificando');
end;

procedure TChatTest.IntencaoObterPerguntaTest;
const
  PERGUNTA =  LINE_BREAK
            + 'Escolha uma opção abaixo:'
            + LINE_BREAK
            + ' A) - Opção A' + LINE_BREAK
            + ' B) - Opção B' + LINE_BREAK
            + ' C) - Opção C' + LINE_BREAK;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');
  Assert.AreEqual(FChat.Intencao.ObterPergunta, PERGUNTA);
end;

procedure TChatTest.IntencaoPerguntaNaoRespondidaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');

  Assert.IsFalse(FChat.Intencao.Respondido);

  FChat.Processar('D');
  Assert.IsFalse(FChat.Intencao.Respondido);
end;

procedure TChatTest.IntencaoPerguntaRespondidaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');

  Assert.IsFalse(FChat.Intencao.Respondido);

  FChat.Processar('B');
  Assert.IsTrue(FChat.Intencao.Respondido);
end;

procedure TChatTest.IntencaoRepetirPerguntaNaoRespondidaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');

  Assert.IsFalse(FChat.Intencao.Respondido);

  FChat.Processar('D');
  Assert.IsFalse(FChat.Intencao.Respondido);
  Assert.AreEqual(FChat.RespostaIndefinida, 'Resposta inválida');
end;

procedure TChatTest.IntencaoRespostaPerguntaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);

  FChat.Processar('OPCAO');
  FChat.Processar('B');
  Assert.AreEqual(FChat.RespostaPergunta.Codigo,     2);
  Assert.AreEqual(FChat.RespostaPergunta.Item,      'B');
  Assert.AreEqual(FChat.RespostaPergunta.Descricao, 'Opção B');
end;

procedure TChatTest.IntencaoComPerguntaTest;
begin
  FChat.AdicionarPergunta(1, ['OPCAO'], 'Escolha uma opção abaixo:', 'A,B,C','Opção A,Opção B,Opção C', 1);
  FChat.Processar('OPCAO');
  Assert.IsTrue(FChat.Intencao.Perguntar);
end;

procedure TChatTest.IntencaoComprarTest(const AMensagem: string);
begin
  FChat.Processar(AMensagem);
  Assert.AreEqual(INTENCAO_COMPRAR, FChat.Intencao.Codigo, AMensagem);
end;

procedure TChatTest.IntencoesOrdemPrioridadeTest;
begin
  FChat.Processar('Oi quero comprar um jantar');

  Assert.AreEqual(1, FChat.Intencoes.Items[0].Prioridade);
  Assert.AreEqual(2, FChat.Intencoes.Items[1].Prioridade);
  Assert.AreEqual(3, FChat.Intencoes.Items[2].Prioridade);
end;

procedure TChatTest.IntencoesTest(const AMensagem: string; const AIntencoesCount: Integer; const AIntencaoPrincipal: Integer);
begin
  FChat.Processar(AMensagem);
  Assert.AreEqual(AIntencoesCount, FChat.Intencoes.count, AMensagem);

  if AIntencaoPrincipal > 0 then
    Assert.AreEqual(AIntencaoPrincipal, FChat.Intencao.Codigo, AMensagem);
end;

procedure TChatTest.AtributoCompostoTest;
begin
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

  FChat.Processar('Quero 1 pizza pequena de Frango Catupiry');
  Assert.AreEqual(FChat.Atributos.Last.Conteudo, 'FRANGO CATUPIRY');
end;

procedure TChatTest.AtributoDetectadoTest;
begin
  FChat.AdicionarAtributos('Pizza',
                           'Mussarela, Portuguesa, Calabreza, Frango Catupiry, Brócolis',
                           'Pequena, Média, Grande',
                           '25.00, 35.00, 45.00',
                           '1000,  1001,  1002');

  FChat.Processar('Pizza');
  Assert.IsTrue(FChat.AtributoDetectado);
end;

procedure TChatTest.AtributoNaoDetectadoTest;
begin
  FChat.AdicionarAtributos('Pizza',
                           'Mussarela, Portuguesa, Calabreza, Frango Catupiry, Brócolis',
                           'Pequena, Média, Grande',
                           '25.00, 35.00, 45.00',
                           '1000,  1001,  1002');

  FChat.Processar('Bla Bla Bla');
  Assert.IsFalse(FChat.AtributoDetectado);
end;

procedure TChatTest.AtributoSimplesTest;
begin
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

  FChat.Processar('Quero 1 pizza grande de calabreza');

  Assert.AreEqual(FChat.Atributos.First.ID,          '1002');
  Assert.AreEqual(FChat.Atributos.First.Nome,        'PIZZA');
  Assert.AreEqual(FChat.Atributos.First.Conteudo,    'CALABREZA');
  Assert.AreEqual(FChat.Atributos.First.Complemento, 'GRANDE');
  Assert.AreEqual(FChat.Atributos.First.Valor,       '45.00');

  FChat.Processar('me entrega 2 pizza media de brocolis');

  Assert.AreEqual(FChat.Atributos.Last.ID,          '1001');
  Assert.AreEqual(FChat.Atributos.Last.Nome,        'PIZZA');
  Assert.AreEqual(FChat.Atributos.Last.Conteudo,    'BROCOLIS');
  Assert.AreEqual(FChat.Atributos.Last.Complemento, 'MEDIA');
  Assert.AreEqual(FChat.Atributos.Last.Valor,       '35.00');
end;

procedure TChatTest.DialogoIndefinidoTest;
begin
  FChat.Processar('bla');
  Assert.AreEqual(FChat.Intencao.RespostaAleatoria, FChat.RespostaIndefinida);
end;

procedure TChatTest.IntencaoCardapioTest(const AMensagem: string);
begin
  FChat.Processar(AMensagem);
  Assert.AreEqual(INTENCAO_CARDAPIO, FChat.Intencao.Codigo);
end;

procedure TChatTest.RespostaAleatoriaTest;
var
  FResposta1,
  FResposta2: string;
begin
  FChat.Processar('OLA');
  FResposta1 := FChat.Intencao.RespostaAleatoria;

  FChat.Processar('OLA');
  FResposta2 := FChat.Intencao.RespostaAleatoria;

  Assert.AreNotEqual(FResposta1, FResposta2);
end;

initialization
  TDUnitX.RegisterTestFixture(TChatTest);

end.
