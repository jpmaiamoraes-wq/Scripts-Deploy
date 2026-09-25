# Revisao Master Deploy

## Estado

Reescrita concluida e validada estaticamente. A primeira execucao deve ser
tratada como homologacao assistida em uma base controlada, pois os arquivos
ainda nao foram compilados nem executados contra um Oracle nesta versao.

## Objetivos da nova versao

- um arquivo por responsabilidade funcional;
- pre-validacao antes de qualquer DML ou DDL;
- backup persistente das linhas efetivamente afetadas, separado por tabela;
- identificador exclusivo por execucao;
- conferencia entre quantidade salva e quantidade alterada;
- `COMMIT` somente depois das validacoes;
- script de reversao pareado para cada rotina mutavel;
- interrupcao do Master no primeiro erro nao tratado;
- nenhuma referencia a nomes de clientes nos arquivos genericos;
- referencias técnicas externas devem usar nomes neutros, como `MODELO`, tanto
  nos objetos auxiliares quanto nos documentos de entrega;
- nenhuma senha ou credencial nos scripts.

## Estrutura adotada

- `Revisao_Master_Deploy.sql`: orquestrador principal com 31 etapas.
- arquivos `.sql` de execucao: diretamente nesta pasta, um por
  responsabilidade funcional, numerados de `01_` a `31_` conforme a ordem
  exata de execucao no Master.
- `Rollback/`: reversoes pareadas por identificador de execucao; o numero no
  nome corresponde a etapa que o rollback desfaz.
- `Automacao/revisao_deploy.py`: preparacao segura da pasta do cliente,
  verificacao de rota, geracao do executor com `SPOOL` e analise do log.

As subpastas tematicas inicialmente criadas foram eliminadas porque haveria
apenas um ou poucos arquivos em cada uma, sem ganho pratico de organizacao.

Para novas bases com divergencia entre o nome informado e o cadastro, usar
`00_Identidade_Empresa_Variacoes_ReadOnly_MODELO.sql` antes do gate textual.
Esse diagnóstico somente leitura lista `NOMEFANTASIA`/`RAZAOSOCIAL`, preserva a
contagem encontrada e não substitui a confirmação explícita do solicitante.

## Entregas materializadas

- 14 arquivos correspondentes aos blocos antes agrupados em
  `Scripts_Variados.sql`;
- 8 rotinas funcionais revisadas: TSICFG, padronizacao, unidades, preferencias
  GOL, parceiro matriz, cards, classificacao ICMS e nomes de parceiros;
- diagnostico e tentativa de recompilacao de objetos invalidos;
- 28 rollbacks, um para cada rotina que altera dados;
- `Revisao_Master_Deploy.sql`, chamando os 31 arquivos na ordem definida;
- controle dos objetos temporariamente desabilitados em
  `RMD_CONTROLE_OBJETOS` e verificacao final por
  `23_Validar_Reabilitar_Objetos.sql`.

`31_Recompilar_Objetos_Invalidos.sql` nao possui rollback: recompilacao nao altera
dados e nao existe operacao segura para tornar novamente um objeto invalido.

## Observacoes de execucao

- executar o Master como script (F5), estando o arquivo ativo dentro desta
  pasta, para que os includes relativos `@@` sejam resolvidos;
- guardar todos os valores `ID_EXECUCAO` exibidos no log; cada rollback exige o
  identificador exato de sua rotina;
- os comandos `ALTER TRIGGER` de normalizacao de unidades e itens provocam
  commits implicitos no Oracle. Os scripts restauram o estado anterior das
  triggers mesmo em excecao, mas a reversao dos dados depende dos backups
  persistentes;
- objetos que estavam habilitados e foram temporariamente desabilitados pela
  revisao sao registrados. A ultima etapa tenta reabilita-los novamente e faz
  o Master falhar se algum continuar desabilitado. Objetos que ja estavam
  desabilitados antes da revisao sao apenas apresentados no log e nao sao
  ativados automaticamente;
- se o preflight de bairros ou enderecos encontrar colisao, a respectiva tabela
  e ignorada com `STATUS=IGNORADO_COLISAO`, sem backup vazio nem alteracao. As
  demais etapas continuam; o merge permanece separado e aprovado por base;
- a padronizacao cadastral foi separada por tabela nas etapas 24 a 30. Parceiros,
  produtos, tipos de titulo, cidades e tipos de venda sao concluídos antes dos
  preflights de bairros (29) e enderecos (30);
- a verificacao dos objetos temporariamente desabilitados ocorre na etapa 23,
  antes da padronizacao. A padronizacao nao desabilita objetos. A tentativa de
  recompilacao permanece como etapa 31;
- o Master interrompe no primeiro erro nao tratado. Uma conclusao visivel no
  final do arquivo significa somente ausencia de erro SQL detectado pelo
  cliente; o log completo ainda deve ser conferido.

## Etapa regular 32: Card 09 - Notas sem Financeiro

A partir da revisao da Produtos Macale LTDA, o tratamento de notas sem financeiro passa a integrar o fluxo regular, executado depois das etapas 1 a 31 do Master e antes da entrega tecnica. Ela nao deve ser incluida automaticamente no Master, porque exige revisao do mapa e confirmacao explicita antes de qualquer `INSERT` em `TGFFIN`.

### Mapa direto do XML — caminho preferencial

O caminho preferencial para novas bases nao depende de `FNC_BUSCA_TAG_XML_GERAL`:
primeiro reduz a massa pela mesma query de volumetria do dashboard e depois le
diretamente `TGFNFE.XML` com `XMLTABLE`. Assim, a identificacao de `<Dup>`,
`vDup`, `dVenc` e `nDup` nao exige compilacao de function nem uma nova
autorizacao de objeto. O mapa e persistido antes de qualquer DML, e a function
fica somente como fallback para bases que nao permitam a leitura direta.

Use os modelos parametrizados na raiz de `7 - QA2`:

- `32_Card09_Estado_Execucao_MODELO.sql`: inventário read-only dos objetos e
  linhas da execução; evita consultar uma tabela ainda inexistente e orienta a
  retomada segura de uma tentativa parcial;
- `32A_Card09_Mapear_Direto_XML.sql`: cria o mapa base e a classificacao
  `TGFPPG` por DDL direto; usa o filtro do dashboard antes de tocar em
  `TGFNFE.XML`, classifica múltiplos XMLs por `NUNOTA` e nao altera `TGFFIN`;
- `32B_Card09_Executor_Wrapper_MODELO.sql`: modelo de wrapper com os nomes da
  execucao e `CONFIRMA_INSERCAO`;
- `32B_Card09_Inserir_Notas_Sem_Financeiro_DUP.sql`: insert controlado,
  protegido por `CONFIRMA_INSERCAO` e filtrado exclusivamente por
  `STATUS_MAPA='APTO_PARA_VALIDACAO_FINAL'`;
- `32C_Card09_Rollback_Notas_Sem_Financeiro_DUP.sql`: reversao pareada,
  protegida por `CONFIRMA_ROLLBACK`;
- `32D_Card09_PosValidacao_MODELO.sql`: modelo de conferencias read-only da
  base, auditoria, `TGFFIN` e `TGFNUM`; copie-o para a pasta base e preencha os
  nomes da execução.

A classificacao pode conter linhas inelegiveis (`SEM_VDUP_XML`, XML invalido,
ausencia de `TGFPPG` ou duplicidade de condicao). Isso e esperado e preserva a
trilha de auditoria: somente as linhas `APTO_PARA_VALIDACAO_FINAL` entram no
insert. O wrapper deve usar um `ID_EXECUCAO` novo e nomes novos para cada
tentativa; os nomes de `TBL_BASE`, `TBL_PPG` e `TBL_INS` devem coincidir entre
mapa, executor, pos-validacao e rollback.

A ordem segura e: identidade/schema/service, inventário do estado, mapa direto,
revisao do mapa, confirmacao operacional imediatamente antes do `INSERT`,
executor, pos-validacao e rollback pronto. O caminho direto elimina a etapa de autorizacao
para compilar function, mas nao elimina a confirmacao da alteracao financeira
nem as travas de `TGFNUM`, o backup/mapa persistente, a auditoria e a
reversibilidade.

O log definitivo deve ser produzido por um spool novo e dedicado. Consultas
exploratórias, tentativas de reexecução e diagnósticos de objetos inexistentes
devem usar logs separados; qualquer `ORA-`, `PLS-` ou `SP2-` no spool definitivo
exige revisão manual, mesmo que uma métrica posterior pareça correta.

O caminho legado permanece documentado em
`32_Card09_Preflight_Notas_Sem_Financeiro_DUP.sql` e
`32A_Card09_Mapear_Notas_Sem_Financeiro_DUP.sql`. Use-o somente quando a
leitura direta do XML nao for viavel e houver function valida ou autorizacao
formal para provisiona-la. O procedimento detalhado e as licoes de
compatibilidade estao em
[ETAPA_32_CARD09_NOTAS_SEM_FINANCEIRO.md](ETAPA_32_CARD09_NOTAS_SEM_FINANCEIRO.md)
e [LECOES_CARD09_EXECUCAO_DIRETA_XML.md](LECOES_CARD09_EXECUCAO_DIRETA_XML.md).

## Encerramento e publicacao por cliente

- `Limpar_Objetos_Revisao.sql` e um artefato opcional de pos-entrega e nunca
  deve ser incluido no Master;
- copiar esse arquivo para a pasta local do cliente e para
  `Revisoes Deploy Agent/<base>` no Drive corporativo;
- manter no Drive a mesma restricao de compartilhamento dos demais artefatos:
  leitura apenas para `sankhya.com.br`, sem publicacao aberta;
- inserir no relatorio o link clicavel do arquivo com a descricao:
  "Limpeza opcional dos objetos tecnicos criados na revisao";
- informar no relatorio que sua execucao remove os backups e torna indisponiveis
  os rollbacks da revisao;
- publicar o arquivo, mas nao executa-lo automaticamente.

## Transparencia tecnica no relatorio de entrega

Quando a etapa 31 registrar `STATUS=IGNORADO_SEM_PRIVILEGIO` com objetos inválidos remanescentes, a geração do relatório final fica pendente do número do chamado aberto junto ao Sankhya Cloud. O relatório deve incluir o texto de [Modelo_Chamado_Sankhya_Cloud_Objetos_Invalidos.md](Modelo_Chamado_Sankhya_Cloud_Objetos_Invalidos.md), a lista de objetos e o ticket informado; sem esse número, o resultado deve permanecer como pendência de atendimento.

### Padrão operacional para tickets de objetos inválidos

Ao abrir um ticket decorrente da etapa 31, revisar o formulário antes do envio:

- selecionar a organização efetiva do cliente; nunca aceitar `SANKHYA JIVA` como organização para esse motivo;
- usar prioridade `Normal` por padrão;
- usar `Cloud/SaaS` → `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`;
- usar ambiente `Produção` e banco `Oracle`;
- manter a descrição enxuta, com a contagem, o schema, a ausência de `ALTER ANY PROCEDURE`, o status `IGNORADO_SEM_PRIVILEGIO` e a lista dos objetos;
- não anexar logs, credenciais ou outros artefatos por padrão;
- somente após o envio, registrar o número e a URL efetivamente retornados pelo portal.

O texto reutilizável está em [Modelo_Chamado_Sankhya_Cloud_Objetos_Invalidos.md](Modelo_Chamado_Sankhya_Cloud_Objetos_Invalidos.md).

Nos proximos relatorios, registrar o impacto efetivamente confirmado pelo log
da revisao, e nao apenas o comportamento previsto nos arquivos. Para cada
rotina executada, informar:

- nome funcional da rotina e respectivo script;
- tabela, view, trigger, function, procedure ou outro objeto envolvido;
- operacao realizada (`INSERT`, `UPDATE`, `DELETE`, `MERGE`, `CREATE`, `ALTER`
  ou tentativa de recompilacao);
- campos e parametros alterados, incluindo os de `TGFEMP`, `TGFTOP`, `TGFPRO`,
  `TGFCAB`, `TGFITE`, `TGFCGM` e quaisquer outras tabelas atingidas;
- criterio e escopo da alteracao, evitando sugerir que toda a tabela foi
  atualizada quando o tratamento foi pontual;
- quantidade de registros efetivamente afetados, quando disponibilizada pelo
  log ou confirmada por consulta posterior;
- `ID_EXECUCAO`, tabela de backup e script de rollback correspondente;
- objetos criados exclusivamente pela revisao e sua finalidade;
- estado final: concluido, sem registros elegiveis, ignorado por colisao,
  executado com alerta ou interrompido por erro;
- pendencias, limitacoes conhecidas e necessidade de merge ou atuacao do
  consultor nas etapas posteriores.

Quando houver alteracao de parametros, apresentar de forma legivel o nome do
parametro ou campo, o valor anterior e o valor aplicado, desde que o backup ou
o log permita comprovar esses valores. Dados extensos ou sensiveis nao devem
ser reproduzidos integralmente no PDF; nesses casos, indicar o artefato de
auditoria publicado na pasta restrita do cliente.

## Decisoes funcionais confirmadas

1. A substituicao integral da `TSICFG` faz parte da higienizacao aprovada. A nova versao manterá o `DELETE`, mas somente depois de snapshot completo, validacao e geracao do ID de execucao.
2. A regra atual de TOPs para giro e Gerente On-Line deve ser mantida mesmo com cobertura parcial. O log registrara explicitamente essa limitacao conhecida.
3. O modelo da analise de giro 848 foi retirado de uma base de referencia e deve ser preservado. A nova versao fara backup pontual da `TSIIMP` antes da aplicacao.
4. `29_Padronizar_Bairros.sql` e `30_Padronizar_Enderecos.sql` fazem preflight
   antes de criar backups ou executar updates; para enderecos, `TIPO` integra o
   criterio. Havendo colisao, apenas a tabela correspondente e ignorada e o
   merge controlado deve ser executado separadamente com aprovacao.
5. O Master anterior usa `WHENEVER SQLERROR CONTINUE`; isso permite terminar com erros intermediarios. A nova versao usara parada controlada e resumo explicito.
6. Diversos scripts possuem `COMMIT` entre blocos. Isso impede reversao transacional do conjunto e sera substituido por commit posterior a backup e validacao de cada rotina.
7. Para insercoes controladas, como a regularizacao da `TGFCGM` por empresa, usar mapa enxuto com ID fixo, chaves e `ROWID` dos registros inseridos. A reversao deve executar `DELETE` somente sobre esse mapa; backup integral da tabela nao e necessario. Validar dependencias antes da reversao.
8. Padrao geral de persistencia: rotinas que somente inserem registros devem manter mapa de execucao com ID fixo, chaves e `ROWID`, gerando reversao por `DELETE` controlado. Backup dos valores originais e obrigatorio para rotinas que alteram ou excluem registros. Toda rotina deve validar quantidade, idempotencia e dependencias antes do commit.
9. Antes de aprovar qualquer relatório ou gerar PDF, executar a camada read-only de conferência do onboarding com `Verificacao_Onboarding_ReadOnly.sql`: localizar a pasta do cliente no Drive, priorizar o arquivo mais recente quando houver repetição, confrontar o PDF de dados da empresa com `TSIEMP`/`TSICID`, o PDF de SMTP com `TSIPAR` sem expor credenciais e as planilhas com `TSICTA`, `TSIUSU`, `TGFVEN`, `TGFGRU`, `TSICUS`, `TGFNAT` e `TGFLOC`. A execução deve preservar log e resumo por base, registrar fonte/arquivo/data/quantidade comparada e classificar linhas de modelo ou registros adicionais sem tratá-los como erro automático. Se a conferência não estiver comprovada, a geração do PDF deve ser bloqueada e o solicitante alertado explicitamente.
10. O relatorio de entrega deve apresentar somente o resultado final aprovado: finalidade de cada etapa, status de exito, objetos de auditoria criados, finalidade de cada objeto e arquivo de reversao com ID fixo. Nao incluir historico de tentativas, erros transitorios ou secao separada de correcoes. Na pasta compartilhada do consultor, disponibilizar os rollbacks de cada etapa e o script consciente de limpeza/drop dos objetos de revisao.

## Organizacao

- `../Scripts Originais`: fontes preservadas, acompanhadas de hashes SHA-256.
- `../Clientes`: artefatos exclusivos de cada base revisada.
- scripts genericos nao vinculados ao Master permanecem temporariamente na raiz de `7 - QA2` ate revisao de escopo posterior.

## Impedimento histórico registrado em 2026-09-11 — caminho legado do Card 09 D-COMMERCE LTDA

O preflight legado do Card 09 foi interrompido com `ORA-00904: "FNC_BUSCA_TAG_XML_GERAL": invalid identifier` no schema `SANKHYA`. Esse bloqueio permanece válido para o caminho que depende da function, mas nao bloqueia o caminho direto documentado acima: o XML pode ser lido em `TGFNFE.XML` com `XMLTABLE`, depois da reducao pela volumetria do dashboard. Nao criar a funcao a partir de arquivo local sem autorizacao; se o fallback for necessario, solicitar provisionamento ou autorizacao explicita, validar o objeto e repetir o preflight legado.

## Padrao obrigatorio para novas bases — pos-tratamento das atividades 29/30 e Card 09

1. As atividades 29 e 30 nao terminam no status `CONCLUIDO_PARCIAL`. Quando houver grupos de colisao, executar na mesma revisao uma fase posterior obrigatoria de merge controlado.
2. Antes do merge, materializar um ID_EXECUCAO novo, mapas persistentes `obsoleto -> mantido`, inventario de todas as colunas `CODBAI`/`CODEND` reais por `ALL_TAB_COLUMNS` e diagnostico de PK/UK/FK, incluindo chaves compostas.
3. Fazer backup persistente dos registros mantidos, obsoletos e dependentes; aplicar precedencia documentada por tabela; redirecionar referencias; validar referencias obsoletas remanescentes=0 e duplicidades normalizadas=0; somente entao excluir obsoletos e fazer COMMIT.
4. Gerar antes do encerramento um rollback autocontido com o ID, mapas, backups e pre-condicoes. O motor deve ser generico e antifragil: dependencia nova ou conflito de chave deve ser isolado em mapa de excecao, permitindo executar os ramos ja mapeados, registrar o caso reproduzivel e incorporar o aprendizado ao script/catalogo para a proxima base. Somente ausencia de backup/mapa, quota insuficiente ou risco de perda de referencia impede o commit do ramo afetado.
5. A exclusao dos pais deve ser uma fase separada, com script proprio, backup validado, excecoes=0 e inventario `ALL_TAB_COLUMNS JOIN ALL_TABLES` complementado por FKs reais em `ALL_CONSTRAINTS`/`ALL_CONS_COLUMNS`; views nunca podem ser contadas como dependencias fisicas. O script deve abortar com qualquer referencia obsoleta e executar pos-validacao antes do `COMMIT`.
6. Em grupos com mais de dois registros, o mapa tera varias linhas para o mesmo codigo mantido; qualquer atualizacao do pai deve consolidar o valor (`MAX`/`MIN`) antes de executar, evitando `ORA-30926`. A varredura de dependencias deve excluir tabelas de backup e auditoria (`BKP_%`/`RMD_%`) para preservar evidencias historicas.
7. Se o DML mutavel confirmar `COMMIT_LOTE=OK` e a consulta de pos-validacao falhar, nao repetir o lote: corrigir e executar a pos-validacao diretamente em modo read-only, registrando separadamente o erro e a evidencia final.
8. No Card 09, preferir `32A_Card09_Mapear_Direto_XML.sql`: aplicar primeiro a volumetria do dashboard, extrair os campos diretamente de `TGFNFE.XML` com `XMLTABLE`, persistir o mapa e classificar cada linha. Nao exigir function nem autorizacao de compilacao para esse caminho.
9. Depois do mapa direto, considerar apenas `<Dup>` presente e `<dVenc>` no formato valido; preservar notas com `TGFFIN`; usar `CODTIPTITPAD`, `TGFNUM` com `FOR UPDATE`, mapa/auditoria persistentes e rollback. O INSERT somente ocorre apos a revisao do mapa e confirmacao operacional imediatamente anterior ao DML.
10. Se a leitura direta nao for viavel, usar o caminho legado com `FNC_BUSCA_TAG_XML_GERAL`: validar assinatura/status/erros, tentar somente a fonte versionada quando autorizado e isolar o Card 09 se faltar privilegio ou a function permanecer invalida. Nao misturar uma tentativa parcial de function com o mapa da nova execucao.
11. Se houver mais de um registro em `TGFNFE` para a mesma `NUNOTA`, classificar `REVISAR_MULTIPLOS_XML` e não escolher silenciosamente um XML por `ROWID`.

## Correcao de compatibilidade registrada em 2026-09-16

O preflight desta revisao inicialmente consultou `ALL_DEPENDENCIES.OBJECT_TYPE`,
coluna inexistente nessa visao. A consulta foi corrigida para usar as colunas
catalogadas `NAME` e `TYPE`, sem alterar o banco, e o preflight deve ser
reexecutado antes de qualquer DML.
