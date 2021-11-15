unit i9Bot;

interface
uses
  System.StrUtils,
  System.SysUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.RegularExpressions,
  REST.Json;

const
  LINE_BREAK = #13 + #10;

type

  TQuestao = class
  private
    FItem     : string;
    FDescricao: string;
    FCodigo   : Integer;
  public
    constructor Create(const ACodigo: Integer; const AItem: string; const ADescricao: string); overload;

    property Codigo   : Integer read FCodigo    write FCodigo;
    property Item     : string  read FItem      write FItem;
    property Descricao: string  read FDescricao write FDescricao;
  end;

  TPergunta = class
  private
    FTitulo   : string;
    FQuestoes : TObjectList<TQuestao>;
    FResposta : TQuestao;
  public
    constructor Create;
    destructor Destroy; override;

    property Titulo   : string                read FTitulo    write FTitulo;
    property Questoes : TObjectList<TQuestao> read FQuestoes  write FQuestoes;

    function Resposta : TQuestao;

    procedure AdicionarQuestoes(const AItens: string; const ADescricoes: string);
    procedure Processar(const AResposta: string);
  end;

  TIntencao = class
  private
    FRespostas : TList<string>;
    FPalavras  : TList<string>;
    FCodigo    : Integer;
    FProxima   : Integer;
    FDescricao : string;
    FPrioridade: Integer;
    FPergunta  : TPergunta;
    FRespondido: Boolean;
    FFinalizada: Boolean;
    function GetPerguntar: Boolean;
  public
    constructor Create; overload;
    constructor Create(const ACodigo    : Integer;
                       const ADescricao : string;
                       const APrioridade: Integer;
                       const ARespostas : TList<string>;
                       const APalavras  : TList<string>); overload;

    destructor Destroy; override;

    property Codigo    : Integer       read FCodigo       write FCodigo;
    property Descricao : string        read FDescricao    write FDescricao;
    property Prioridade: Integer       read FPrioridade   write FPrioridade;
    property Palavras  : TList<string> read FPalavras     write FPalavras;
    property Respostas : TList<string> read FRespostas    write FRespostas;
    property Perguntar : Boolean       read GetPerguntar;
    property Respondido: Boolean       read FRespondido   write FRespondido;
    property Finalizada: Boolean       read FFinalizada   write FFinalizada;
    property Proxima   : Integer       read FProxima      write FProxima;

    function Contem(APalavra: string): Boolean;
    function Ocorrencias(AMensagem: string): Integer;
    function RespostaAleatoria: string;

    function Pergunta: TPergunta;

    function ObterPergunta: string;
  end;

  TParametroItem = class
  private
    FNome        : string;
    FID          : TList<string>;
    FConteudo    : TList<string>;
    FComplemento : TList<string>;
    FValor       : TList<string>;
  public
    constructor Create;
    destructor Destroy; override;

    property Nome       : string        read FNome        write FNome;
    property ID         : TList<string> read FID          write FID;
    property Conteudo   : TList<string> read FConteudo    write FConteudo;
    property Complemento: TList<string> read FComplemento write FComplemento;
    property Valor      : TList<string> read FValor       write FValor;
  end;

  TParametro = class
  private
    FID          : string;
    FNome        : string;
    FValor       : string;
    FConteudo    : string;
    FComplemento : string;
  public
    property ID         : string read FID          write FID;
    property Nome       : string read FNome        write FNome;
    property Valor      : string read FValor       write FValor;
    property Conteudo   : string read FConteudo    write FConteudo;
    property Complemento: string read FComplemento write FComplemento;
  end;

  TChat = class
  private
    FMensagens    : TList<string>;
    FRespostas    : TList<string>;
    FIntencoesBot : TObjectList<TIntencao>;
    FIntencoes    : TObjectList<TIntencao>;
    FAtributos    : TObjectList<TParametro>;
    FParametrosBot: TObjectList<TParametroItem>;

    FResposta     : string;
    FIntencao     : TIntencao;
    FRespostaIndefinida: string;
    FAtributoDetectado : boolean;

    FRespostaPergunta: TQuestao;
    function GetRespostaIndefinida: string;

    property IntencoesBot : TObjectList<TIntencao>      read FIntencoesBot  write FIntencoesBot;
    property ParametrosBot: TObjectList<TParametroItem> read FParametrosBot write FParametrosBot;

    function Mensagens: TList<string>;
    function Respostas: TList<string>;

    procedure ObterIntencoes(AMensagem: string);
    procedure ObterAtributos(AMensagem: string);

    procedure SetIntencao(const AIntencao: TIntencao);
    procedure OrdenarIntencoes;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Processar(AMensagem: string);

    function Responder: string;
    function RespostaPergunta: TQuestao;
    procedure FinalizarPergunta;
    function ObterProximaIntencao: Boolean;

    function Intencoes: TObjectList<TIntencao>;
    function Atributos: TObjectList<TParametro>;

    function Intencao: TIntencao;

    procedure AdicionarIntencao(AIntencao: TIntencao);
    procedure AdicionarAtributos(ANome, AConteudos, AComplementos, AValores, AIDs: string);

    procedure AdicionarPergunta(const ACodigo: Integer;
                                const APalavrasChave: array of string;
                                const ATitulo : string;
                                const AOpcoes, AValores: string;
                                const AProxima: Integer;
                                AMensagemRespostaInvalida: string = 'Resposta inválida');

    property RespostaIndefinida: string  read GetRespostaIndefinida write FRespostaIndefinida;
    property AtributoDetectado : boolean read FAtributoDetectado    write FAtributoDetectado;

    function AsJson: string;
  end;

implementation
  uses
    System.JSON;

function AjustarTexto(ATexto: string): string;
type
  USASCIIString = type AnsiString(20127);
begin
  Result := Trim(UpperCase(string(USASCIIString(ATexto))));
end;

function TChat.Responder: string;
begin
  Result := FResposta;
  Respostas.Add(FResposta);
end;

function TChat.RespostaPergunta: TQuestao;
begin
  if not Assigned(FRespostaPergunta) then
    FRespostaPergunta := TQuestao.Create;

  Result := FRespostaPergunta;
end;

function TChat.Respostas: TList<string>;
begin
  if not Assigned(FRespostas) then
    FRespostas := TList<string>.Create;

  Result := FRespostas;
end;

procedure TChat.SetIntencao(const AIntencao: TIntencao);
begin
  Self.Intencao.FRespostas  := AIntencao.Respostas;
  Self.Intencao.FPalavras   := AIntencao.Palavras;
  Self.Intencao.FCodigo     := AIntencao.Codigo;
  Self.Intencao.FDescricao  := AIntencao.Descricao;
  Self.Intencao.FPrioridade := AIntencao.Prioridade;
  Self.Intencao.FPergunta   := AIntencao.Pergunta;
  Self.Intencao.FFinalizada := AIntencao.Finalizada;
  Self.Intencao.Proxima     := AIntencao.Proxima;
end;

procedure TChat.AdicionarAtributos(ANome, AConteudos, AComplementos, AValores, AIDs: string);
var
  FAtributoItem : TParametroItem;
  FTextoIndex   : Integer;
  FConteudos    : TArray<string>;
  FComplementos : TArray<string>;
  FValores      : TArray<string>;
  FIDs          : TArray<string>;
begin
  FAtributoItem       := TParametroItem.Create;
  FAtributoItem.Nome  := ANome;

  if (Trim(AConteudos) <> '') then
  begin
    FConteudos := TRegEx.Split(AConteudos, ',');
    for FTextoIndex := 0 to Length(FConteudos) -1 do
      FAtributoItem.Conteudo.Add(AjustarTexto(FConteudos[FTextoIndex]));

    FAtributoItem.Conteudo.TrimExcess;
    FAtributoItem.Conteudo.Sort;
  end;

  if (Trim(AComplementos) <> '') then
  begin
    FComplementos := TRegEx.Split(AComplementos, ',');
    for FTextoIndex := 0 to Length(FComplementos) -1 do
      FAtributoItem.Complemento.Add(AjustarTexto(FComplementos[FTextoIndex]));
  end;

  if (Trim(AValores) <> '') then
  begin
    FValores := TRegEx.Split(AValores, ',');
    for FTextoIndex := 0 to Length(FValores) -1 do
      FAtributoItem.Valor.Add(AjustarTexto(FValores[FTextoIndex]));
  end;

  if (Trim(AIDs) <> '') then
  begin
    FIDs := TRegEx.Split(AIDs, ',');
    for FTextoIndex := 0 to Length(FIDs) -1 do
      FAtributoItem.ID.Add(AjustarTexto(FIDs[FTextoIndex]));
  end;

  ParametrosBot.Add(FAtributoItem);
end;

procedure TChat.AdicionarIntencao(AIntencao: TIntencao);
begin
  AIntencao.Palavras.TrimExcess;
  AIntencao.Palavras.Sort;

  Self.IntencoesBot.Add(AIntencao);
end;

procedure TChat.AdicionarPergunta(const ACodigo: Integer;
                                  const APalavrasChave: array of string;
                                  const ATitulo: string;
                                  const AOpcoes, AValores: string;
                                  const AProxima: Integer;
                                  AMensagemRespostaInvalida: string = 'Resposta inválida');
var
  FIntencao: TIntencao;
begin
  FIntencao := TIntencao.Create;
  FIntencao.Codigo    := ACodigo;
  FIntencao.Descricao := 'Pergunta' + FIntencao.Codigo.ToString;
  FIntencao.Prioridade:= 1;
  FIntencao.Palavras.AddRange(APalavrasChave);
  FIntencao.Pergunta.Titulo := ATitulo;
  FIntencao.Pergunta.AdicionarQuestoes(AOpcoes,AValores);
  FIntencao.Respostas.Add(AMensagemRespostaInvalida);
  FIntencao.Proxima := AProxima;

  Self.AdicionarIntencao(FIntencao);
end;

function TChat.AsJson: string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

function TChat.Atributos: TObjectList<TParametro>;
begin
  if not Assigned(FAtributos) then
    FAtributos := TObjectList<TParametro>.Create;

  Result := FAtributos;
end;

constructor TChat.Create;
begin
  FMensagens     := TList<string>.Create;
  FRespostas     := TList<string>.Create;
  FIntencoes     := TObjectList<TIntencao>.Create;
  FIntencoesBot  := TObjectList<TIntencao>.Create;
  FParametrosBot := TObjectList<TParametroItem>.Create;
end;

destructor TChat.Destroy;
begin
  FreeAndNil(FMensagens);
  FreeAndNil(FRespostas);
  FreeAndNil(FIntencoesBot);
  FreeAndNil(FParametrosBot);

  if Assigned(FIntencoes) then
    FreeAndNil(FIntencoes);

  inherited;
end;

procedure TChat.FinalizarPergunta;
begin
  Self.Intencao.Respondido := False;
  Self.Intencao.Finalizada := True;
  Self.RespostaIndefinida  := 'ok, já estou verificando';
end;

function TChat.GetRespostaIndefinida: string;
begin
  Result := FRespostaIndefinida;

  if Self.Intencao.Perguntar and (not Self.Intencao.Respondido) then
    Result := Self.Intencao.RespostaAleatoria;
end;

function TChat.Intencao: TIntencao;
begin
  if not Assigned(FIntencao) then
  begin
    FIntencao := TIntencao.Create;
    FIntencao.Codigo := -1;
    FIntencao.Respostas.Add(Self.RespostaIndefinida);
  end;

  Result := FIntencao;
end;

function TChat.Intencoes: TObjectList<TIntencao>;
begin
  if not Assigned(FIntencoes) then
    FIntencoes := TObjectList<TIntencao>.Create;

  Result := FIntencoes;
end;

function TChat.Mensagens: TList<string>;
begin
  if not Assigned(FMensagens) then
    FMensagens := TList<string>.Create;

  Result := FMensagens;
end;

procedure TChat.ObterIntencoes(AMensagem: string);
var
  FIntencaoIndex,
  FIntencao  : TIntencao;
  FOcorrencias,
  FPrioridade: Integer;
begin
  FResposta := '';
  Mensagens.Add(AMensagem);
  FPrioridade := 0;

  Intencoes.Clear;
  for FIntencaoIndex in IntencoesBot do
  begin
    FOcorrencias := FIntencaoIndex.Ocorrencias(AMensagem);
    if FOcorrencias > 0 then
    begin
      FIntencao := TIntencao.Create;
      FIntencao.Codigo     := FIntencaoIndex.Codigo;
      FIntencao.Descricao  := FIntencaoIndex.Descricao;
      FIntencao.Prioridade := FIntencaoIndex.Prioridade;
      FIntencao.Respostas.AddRange(FIntencaoIndex.Respostas);
      FIntencao.Palavras.AddRange(FIntencaoIndex.Palavras);
      FIntencao.Pergunta.Questoes.AddRange(FIntencaoIndex.Pergunta.Questoes);
      Intencoes.Add(FIntencao);

      if FIntencaoIndex.Prioridade > FPrioridade then
      begin
        FPrioridade := FIntencaoIndex.Prioridade;
        Self.SetIntencao(FIntencaoIndex);
      end;
    end;
  end;
  Intencoes.TrimExcess;
  OrdenarIntencoes;
end;

function TChat.ObterProximaIntencao: Boolean;
var
  FIntencaoIndex,
  FIntencao  : TIntencao;
begin
  if Self.Intencao.Proxima <= 0 then
    Exit(False);

  for FIntencaoIndex in IntencoesBot do
  begin
    if FIntencaoIndex.Codigo = Self.Intencao.Proxima then
    begin
      FIntencao := TIntencao.Create;
      FIntencao.Codigo     := FIntencaoIndex.Codigo;
      FIntencao.Descricao  := FIntencaoIndex.Descricao;
      FIntencao.Prioridade := FIntencaoIndex.Prioridade;
      FIntencao.Respostas.AddRange(FIntencaoIndex.Respostas);
      FIntencao.Palavras.AddRange(FIntencaoIndex.Palavras);
      FIntencao.Pergunta.Questoes.AddRange(FIntencaoIndex.Pergunta.Questoes);
      Intencoes.Add(FIntencao);

      Self.SetIntencao(FIntencaoIndex);
      Break;
    end;
  end;
  Intencoes.TrimExcess;
  OrdenarIntencoes;

  Result := Assigned(Self.FIntencao);
end;

procedure TChat.OrdenarIntencoes;
var
  Comparison      : TComparison<TIntencao>;
  DelegateComparer: TDelegatedComparer<TIntencao>;
begin
  Comparison := function(const IntencaoA, IntencaoB: TIntencao): Integer
                begin
                  Result := CompareText(IntencaoA.Prioridade.ToString, IntencaoB.Prioridade.ToString);
                end;

  DelegateComparer := TDelegatedComparer<TIntencao>.Create(Comparison);
  try
    Intencoes.Sort(DelegateComparer);
  finally
    DelegateComparer.Free;
  end;
end;

procedure TChat.Processar(AMensagem: string);
begin
  if Self.Intencao.Perguntar and (not Self.Intencao.Respondido) and (not Self.Intencao.Finalizada) then
  begin
    Self.Intencao.Pergunta.Processar(AMensagem);
    if Self.Intencao.Pergunta.Resposta.Codigo > 0 then
    begin
      Self.RespostaPergunta.Codigo    := Self.Intencao.Pergunta.Resposta.Codigo;
      Self.RespostaPergunta.Item      := Self.Intencao.Pergunta.Resposta.Item;
      Self.RespostaPergunta.Descricao := Self.Intencao.Pergunta.Resposta.Descricao;
      Self.Intencao.Respondido        := True;
    end;
  end
  else
  begin
    Self.ObterIntencoes(AMensagem);
    Self.ObterAtributos(AMensagem);
  end;
end;

procedure TChat.ObterAtributos(AMensagem: string);
var
  FAtributoItem : TParametroItem;
  FAtributo     : TParametro;
  FMensagem     : TArray<string>;
  FTextoCount,
  FTextoIndex,
  FResultIndex  : Integer;
  FAtributoNome : string;

  function BuscaLista(AMensagem: TArray<string>; AItems: TList<string>; var AResultIndex: Integer): string;
  var
    FIndex,
    FCount,
    FResultIndex2: Integer;
    FItem,
    FItem2,
    FItem3: string;
  begin
    Result := '';
    FCount := Length(FMensagem) -1;
    for FIndex := 0 to FCount do
    begin
      FItem        := AjustarTexto(FMensagem[FIndex]);
      FResultIndex := AItems.IndexOf(FItem);

      if FIndex < FCount then
        FItem2        := AjustarTexto(FMensagem[FIndex+1]);

      FItem3 := FItem + ' ' + FItem2;
      FResultIndex2 := AItems.IndexOf(FItem3);

      if FResultIndex2 > -1 then
      begin
        AResultIndex := FResultIndex2;
        Result := FItem3;
        Break;
      end
      else if AResultIndex > -1 then
      begin
        AResultIndex := FResultIndex;
        Result := AItems[FResultIndex];
        Break;
      end;
    end;
  end;

begin
  FMensagem   := TRegEx.Split(AMensagem, ' ');
  FTextoCount := Length(FMensagem) -1;

  AtributoDetectado := False;
  for FTextoIndex := 0 to FTextoCount do
  begin
    FAtributoNome := AjustarTexto(FMensagem[FTextoIndex]);

    for FAtributoItem in Self.ParametrosBot do
      if UpperCase(FAtributoItem.Nome) = FAtributoNome then
      begin
        AtributoDetectado := True;

        FAtributo := TParametro.Create;
        FAtributo.Nome        := FAtributoNome;
        FAtributo.Conteudo    := BuscaLista(FMensagem, FAtributoItem.Conteudo,    FResultIndex);
        FAtributo.Complemento := BuscaLista(FMensagem, FAtributoItem.Complemento, FResultIndex);

        if FResultIndex > -1 then
        begin
          FAtributo.ID    := FAtributoItem.ID[FResultIndex];
          FAtributo.Valor := FAtributoItem.Valor[FResultIndex];
        end;

        Self.Atributos.Add(FAtributo);
      end;
  end;
end;

{ TIntencao }
constructor TIntencao.Create;
begin
  FPalavras   := TList<string>.Create;
  FRespostas  := TList<string>.Create;
  FPrioridade := 0;
  FFinalizada := False;
end;

destructor TIntencao.Destroy;
begin
  FreeAndNil(FPalavras);
  FreeAndNil(FRespostas);

  inherited;
end;

function TIntencao.GetPerguntar: Boolean;
begin
  Result := (Self.Pergunta.Questoes.Count > 0) and (not Self.Respondido) and (not Self.Finalizada);
end;

function TIntencao.ObterPergunta: string;
var
  FQuestao : TQuestao;
begin
  Result := LINE_BREAK;
  for FQuestao in Self.Pergunta.Questoes do
    Result := Result  + ' ' + FQuestao.FItem + ') - ' + FQuestao.FDescricao + LINE_BREAK;

  Result := LINE_BREAK + Self.Pergunta.Titulo + Result;
end;

function TIntencao.Ocorrencias(AMensagem: string): Integer;
var
  FMensagem: TArray<string>;
  FIndex   : Integer;
begin
  Result     := 0;
  FMensagem  := TRegEx.Split(AMensagem, ' ');
  for FIndex := 0 to Length(FMensagem) -1 do
    if Self.Contem(FMensagem[FIndex]) then
      Inc(Result);
end;

function TIntencao.Pergunta: TPergunta;
begin
  if not Assigned(FPergunta) then
    FPergunta := TPergunta.Create;

  Result := FPergunta;
end;

function TIntencao.Contem(APalavra: string): Boolean;
var
  FIndex : Integer;
begin
  if Length(Trim(APalavra)) <= 0 then
    Exit(False);

  Result := Self.Palavras.BinarySearch(AjustarTexto(APalavra), FIndex);
end;

constructor TIntencao.Create(const ACodigo    : Integer;
                             const ADescricao : string;
                             const APrioridade: Integer;
                             const ARespostas : TList<string>;
                             const APalavras  : TList<string>);
var
  FValue: string;
begin
  inherited Create;

  Self.Codigo     := ACodigo;
  Self.Descricao  := ADescricao;
  Self.Prioridade := APrioridade;
  Self.Finalizada := False;
  FPalavras       := TList<string>.Create;
  FRespostas      := TList<string>.Create;

  for FValue in APalavras do
    Self.Palavras.Add(FValue);

  for FValue in ARespostas do
    Self.Respostas.Add(FValue);
end;

function TIntencao.RespostaAleatoria: string;
begin
  Result := '';

  if Self.Respostas.Count > 1 then
  begin
    Randomize;
    Result := Self.Respostas[Random(Self.Respostas.Count)];
  end
  else if Self.Respostas.Count = 1 then
    Result := Self.Respostas[0];
end;

{ TAtributoItem }

constructor TParametroItem.Create;
begin
  FID          := TList<string>.Create;
  FConteudo    := TList<string>.Create;
  FComplemento := TList<string>.Create;
  FValor       := TList<string>.Create;
end;

destructor TParametroItem.Destroy;
begin
  FreeAndNil(FConteudo);
  FreeAndNil(FComplemento);
  FreeAndNil(FValor);
  FreeAndNil(FID);

  inherited;
end;

{ TPergunta }

procedure TPergunta.AdicionarQuestoes(const AItens, ADescricoes: string);
var
  FItens,
  FDescricoes: TArray<string>;
  FIndex     : Integer;
begin
  FItens      := TRegEx.Split(AItens, ',');
  FDescricoes := TRegEx.Split(ADescricoes, ',');

  if Length(FDescricoes) <> Length(FItens) then
    Exit;

  for FIndex := 0 to Length(FItens) -1 do
    Self.Questoes.Add(TQuestao.Create(FIndex, FItens[FIndex], FDescricoes[FIndex]));

  Self.Questoes.TrimExcess;
end;

constructor TPergunta.Create;
begin
  FQuestoes := TObjectList<TQuestao>.Create;
end;

destructor TPergunta.Destroy;
begin
  FreeAndNil(FQuestoes);

  inherited;
end;

procedure TPergunta.Processar(const AResposta: string);
var
  FQuestao: TQuestao;
begin
  for FQuestao in Self.Questoes do
    if FQuestao.Item = AjustarTexto(AResposta) then
    begin  
      Self.Resposta.Codigo    := FQuestao.Codigo;
      Self.Resposta.Item      := FQuestao.Item;
      Self.Resposta.Descricao := FQuestao.Descricao;

      Break;
    end;
end;

function TPergunta.Resposta: TQuestao;
begin
  if not Assigned(FResposta) then
  begin
    FResposta := TQuestao.Create;
    FResposta.Codigo := 0;
  end;

  Result := FResposta;
end;

{ TQuestao }

constructor TQuestao.Create(const ACodigo: Integer; const AItem, ADescricao: string);
begin
  Self.FCodigo    := ACodigo + 1;
  Self.FItem      := Trim(AItem);
  Self.FDescricao := Trim(ADescricao);
end;

end.

