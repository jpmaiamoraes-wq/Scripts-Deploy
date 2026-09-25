# Automatizacao assistida

Esta automacao reduz o trabalho repetitivo sem armazenar senha. O caminho
principal usa o executor Oracle direto, com confirmação de identidade,
consultas somente leitura e lote aprovado para alterações. A abordagem anterior
continua preservada como fallback operacional pelo wrapper do VS Code, sem
duplicar ou alterar os scripts SQL da revisão.

## 1. Preparar uma revisao

```bash
python3 revisao_deploy.py prepare \
  --client "NOME DO CLIENTE" \
  --hostname "10.100.0.1" \
  --port 1521 \
  --service "SERVICOPRD.SANKHYACLOUD.COM.BR" \
  --username "francisco_junior" \
  --gp "Nome do GP <gp@sankhya.com.br>"
```

O comando verifica os dados, consulta a ferramenta de rotas, testa a porta do
Oracle e cria em `Clientes/<CLIENTE>`:

O argumento `--gp` registra o Gerente de Projetos. A assistente de projetos
não precisa ser informada: o comando pergunta no terminal (`1` = Ana Paula
Rodrigues, `2` = Gabriela Stabile Lemos). Também é possível passar
`--assistente 1` ou `--assistente 2`. O resultado fica em
`Dados_Revisao.json` (`analista_projetos` e `plano_destinatarios`):

- 1 (Ana): e-mail somente para ela, sem o GP;
- 2 (Gabriela): e-mail para o GP, com ela em cópia (informe o e-mail do GP em
  `--gp`; sem ele o plano fica `GP_EMAIL_PENDENTE`).

Em execução não interativa sem `--assistente`, o plano fica
`ASSISTENTE_PENDENTE` e a pergunta é feita no chat antes do encerramento.

- `Dados_Revisao.json`, sem senha;
- `Executar_Revisao_<CLIENTE>.sql`, wrapper legado para execução manual pelo
  VS Code;
- `ROTEIRO_FALLBACK_LEGADO_VSCODE.md`, com o procedimento rápido e os gates
  para troca de rota;
- `00_Precheck_Unidades.sql`, para revisar a TGFVOL antes da unica execucao de alteracao;
- `00_Precheck_Etapas_18_31.sql`, para validar objetos, volumes e colisoes antes do lote final;
- `Logs/`, com o caminho esperado do `SPOOL`;
- `Artefatos_Revisao/Limpar_Objetos_Revisao.sql`;
- `Artefatos_Revisao/Rollback/`, com as reversoes disponíveis.

Por padrão, o preparo executa `--check` e, quando a ferramenta retorna
`ROTA_NECESSARIA` para um IP cadastrado no catálogo versionado
`Automacao/ips-roteamento-vpn.txt`, aplica automaticamente somente a rota de
host daquele IP. A ferramenta pode solicitar a senha administrativa do macOS;
essa senha não é lida, armazenada ou exibida pelo executor. Use
`--no-auto-route` para apenas diagnosticar ou `--apply-route` para forçar uma
tentativa explícita dentro do catálogo.

O catálogo usa somente IPs, não nomes de clientes. A VPN FortiClient continua
sendo ativada manualmente. Depois da aplicação, o preparo testa novamente a
porta Oracle e registra a checagem inicial, a ação e o resultado em
`Dados_Revisao.json`. A ferramenta de rotas mantém outras rotas da VPN e só
altera o host informado.

## 1.1 Fallback rápido para a abordagem atual

Se o executor direto falhar antes de qualquer alteração, preserve o log e use o
arquivo `ROTEIRO_FALLBACK_LEGADO_VSCODE.md` da pasta da base. Ele aponta para o
wrapper `Executar_Revisao_<CLIENTE>.sql`, que deve ser aberto no VS Code,
conectado ao perfil Oracle correto e executado como script (`F5`).

Se a falha ocorrer depois de uma possível alteração, não troque de rota
automaticamente. Primeiro reconfirme a identidade, consulte o estado da
execução e escolha entre retomada segura ou reversão específica. O fallback não
serve para repetir uma fase parcialmente executada sem análise.

## 2. Executar pelo executor Oracle direto

1. Confirmar a VPN FortiClient e a identidade da base.
2. Usar `oracle_direct.py identity` para confirmar usuário, schema, serviço e a correspondência segura da base. A quantidade de empresas não é gate; a revisão é `BASE_INTEIRA`.
3. Usar `oracle_direct.py query-jrxml` para executar a volumetria em modo somente leitura, com `--include-excluded` para incluir os quatro indicadores de integridade.
4. Executar os complementos necessários do `Volumetria Deploy Agent.xml` e persistir o resultado na pasta da base.
5. Usar somente entradas aprovadas pelo executor de lote para alterações; não transformar o executor read-only em terminal SQL genérico.
6. Executar `oracle_batch.py preflight` para cada entrada aprovada e corrigir todos os bloqueios antes do `apply`. O preflight não acessa o Oracle e valida includes, binds, `DEFINE`, instruções incompletas, dependências estáticas, CTAS/XMLTABLE dinâmico e riscos de colunas duplicadas.
7. Executar `oracle_29_30_preflight.py` antes de qualquer aplicação das atividades 29/30 e salvar o JSON na pasta da base. Se houver colisões, usar mapa persistente e a fase antifrágil; não aplicar exclusão genérica.
8. Confirmar a identidade novamente após qualquer queda de sessão ou erro de transporte.

Quando a base possuir credencial no Vault corporativo, o executor pode usar o
provedor aprovado com `--credential-source vault`, informando somente o
namespace, mount e caminho KV não sensíveis. O fluxo OIDC deve ser autenticado
previamente pelo comando `oracle_direct.py vault-login`; a senha é lida em
memória, validada contra a conexão e nunca aparece em logs ou no chat. O modo
`auto` mantém o Keychain como fallback quando o cliente Vault não estiver
disponível, mas bloqueia divergências ou falhas de autorização do segredo para
evitar troca silenciosa de identidade.

Antes de iniciar o Card 09, o executor deve preferir
`32A_Card09_Mapear_Direto_XML.sql`: aplicar a volumetria do dashboard em
`TGFCAB`/`TGFTOP`, excluir notas que já possuem `TGFFIN` e somente então ler
`TGFNFE.XML` com `XMLTABLE`. O mapa e a classificação devem ser persistidos por
DDL direto, sem `EXECUTE IMMEDIATE` envolvendo o CTAS com XMLTABLE. Falta de
`<Dup>`, XML inválido, ausência de `TGFPPG` ou duplicidade deve ser classificada
no mapa, não tratada como falha global.

O caminho com `FNC_BUSCA_TAG_XML_GERAL` é fallback. Se for necessário, validar
`ALL_OBJECTS`/`ALL_ERRORS` e usar a fonte versionada somente com autorização;
falta de privilégio, fonte indisponível ou erro de compilação deve ser
registrado e isolado como pendência do Card 09, sem interromper atividades
independentes. Em qualquer caminho, o DML em `TGFFIN` exige mapa revisado,
`CONFIRMA_INSERCAO=SIM`, auditoria persistente e pós-validação.

O comando `prepare` disponibiliza na pasta da base os modelos de diagnóstico de
identidade, inventário de estado, mapa direto, wrapper, executor, rollback e
pós-validação. Antes de continuar uma execução, usar o inventário de estado;
isso evita `ORA-00942` por consultar uma fase ainda não criada e evita repetir
CTAS protegido por `ORA-20340`.

A etapa 17 incorpora automaticamente apenas candidatos sem numerais que tenham
um unico destino canonico por codigo sem pontuacao ou descricao equivalente.
Casos ambiguos continuam no precheck para decisao assistida. Na mesma execucao,
`DESCRVOL` e convertido para maiusculas com backup das linhas alteradas.

O arquivo recusa a execucao se o `SERVICE_NAME` da sessao for diferente do
servico informado na preparacao.

## 2.1 Conferência automática do onboarding

No início da revisão, executar automaticamente a skill
`.agents/skills/sankhya-onboarding-readonly` e o diagnóstico read-only na mesma
conexão da base; não esperar uma solicitação posterior do usuário. Usar primeiro
a versão mais recente exibida no site Onboarding Deploy, preservando o log da
saída em `Clientes/<CLIENTE>/Logs/`. O Drive é apenas fonte complementar quando
o site não expuser um dado necessário. Confrontar:

- dados da empresa com `TSIEMP`/`TSICID`;
- SMTP com `TSIPAR`, exibindo somente metadados e nunca credenciais;
- planilhas de contas e usuários com `TSICTA` e `TSIUSU`;
- planilhas adicionais, quando existirem, com `TGFVEN`, `TGFGRU`, `TSICUS`,
  `TGFNAT` e `TGFLOC`.

Registrar fonte, arquivo, data, quantidade comparada, correspondências,
divergências comprovadas e registros de modelo/extra. Para usuários, comparar
somente `TSIUSU.CODGRUPO > 0`, separando os usuários de modelo sem grupo e
usando o arquivo mais recente quando houver versões repetidas. Para empresas,
comparar CNPJs e registrar adicionais/ausentes sem usar a quantidade como gate
e sem incluir/remover empresa automaticamente. A ausência de arquivo aplicável
não é divergência automática; a falha da conferência deve ser registrada e não
interromper as atividades independentes.

## 3. Analisar o log

```bash
python3 revisao_deploy.py analyze --log "/caminho/Logs/Revisao_Master_DATA.log"
```

Sao gerados um `.resultado.json` e um `.resumo.md`. A analise procura conclusao
do Master, IDs de execucao, colisoes controladas e erros `ORA-`/`SP2-`.

Uma conclusao encontrada nao dispensa a conferencia do log na primeira
homologacao desta nova suite.

## Diagnostico de rede em ambiente restrito

Se `prepare` indicar porta inacessível dentro do ambiente restrito, repetir o
TCP no contexto autorizado e solicitar o acesso de rede necessário. Registrar
ambos os resultados; uma restrição do ambiente não comprova indisponibilidade
do banco. O VS Code só deve ser acionado como fallback conforme o roteiro da
base, não para encobrir uma falha de identidade, estado ou reversibilidade.

## Volumetria obrigatória antes do relatório

Ler `../Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml` e consultar a
`queryString` com os indicadores ocultos incluídos. Consultar também
`../Base Relatório de Entrega/Volumetria Deploy Agent.xml` para os cards
complementares. Os quantitativos atuais devem aparecer na prévia TXT e no PDF.
Os quatro indicadores de integridade — financeiros sem nota, itens sem
cabeçalho, cabeçalhos sem itens e códigos fiscais de cidades duplicados —
precisam retornar zero; qualquer valor acima de zero bloqueia o PDF até análise.

## Lições incorporadas na execução assistida

- Quando uma etapa cria uma tabela de backup e a usa no mesmo bloco PL/SQL, os `INSERT` e `UPDATE` devem ser dinâmicos; referências estáticas podem gerar `ORA-00942` antes de a tabela ficar visível para o compilador. Essa correção foi aplicada às etapas 12 e 17.
- Runners que reutilizam identificadores entre etapas devem declarar e inicializar explicitamente os binds SQL*Plus; a ausência de `RMD_ID_MASTER` causou `SP2-0552` e foi corrigida no runner da base.
- O lote pode declarar vários binds SQL*Plus para etapas diferentes. Ao executar um bloco, o executor deve enviar somente os binds presentes naquele bloco; passar o dicionário completo provoca `DPY-4008` antes da execução. A correção foi aplicada em `oracle_batch.py` e exige novo plano e novo `ID_EXECUCAO` antes da retomada.
- Em bases em que os privilégios de DML chegam pela role operacional, DML estático dentro de PL/SQL pode retornar `ORA-01031`; a correção deve preservar a regra original e usar `EXECUTE IMMEDIATE` somente no DML da atividade afetada, com o mesmo backup, conferência de contagens e novo plano/hash.
- O caminho padrão do Card 09 é o mapa direto por XML, limitado pela volumetria do dashboard e persistido por CTAS direto. Não exigir function válida para esse caminho.
- Se a leitura direta não for viável, o fallback deve usar somente `Scripts Originais/FNC_BUSCA_TAG_XML_GERAL.sql`, registrar `ID_EXECUCAO`, DDL, status e `ALL_ERRORS`, e isolar o Card se a função não ficar `VALID`.
- Card09: o preflight genérico contém DEFINE de exemplo que sobrescreve valores fornecidos por wrapper. Em execuções por base, usar cópia parametrizada do script (ou remover os DEFINE internos) antes de executar; preservar ORA-20320 como colisão de mapa conhecida e nunca prosseguir com INSERT sem tabela/mapa base-específico.
- Card09: status não apto permanece no mapa para auditoria; o executor e todos os guards devem filtrar somente `APTO_PARA_VALIDACAO_FINAL`.
- Card09: não selecionar `M.*` e repetir no cursor uma coluna que já existe no mapa, para evitar `PLS-00402`; usar apenas colunas adicionais sem nome duplicado.
- Card09: antes de consultar ou repetir uma fase, executar `32_Card09_Estado_Execucao_MODELO.sql` e seguir o estado persistido; erro de guarda por tabela existente e consulta a tabela ausente não devem ocorrer na onda normal.
- Card09: o spool definitivo deve ser separado dos diagnósticos e rejeitado se contiver `ORA-`, `PLS-` ou `SP2-`, ainda que métricas posteriores pareçam corretas.
- Card09: múltiplos registros `TGFNFE` por `NUNOTA` devem ser classificados como `REVISAR_MULTIPLOS_XML`, sem seleção silenciosa por `ROWID`.
- Card09 32B: não fixar CODCTABCOINT. Usar o valor do mapa quando existente; quando nulo, selecionar uma conta ATIVA da TSICTA para a CODEMP e abortar se não houver. Se o trigger rejeitar CODTIPOPER inativo, preservar o ORA-20101, respaldar as versões vigentes, ativá-las temporariamente durante a inclusão autorizada e restaurar o ATIVO original.
- Etapas 29/30: o tratamento deve ser genérico e orientado por metadados para todas as bases. Colisões normalizadas devem gerar mapa persistente menor_codigo -> codigo_obsoleto, inventariar FKs e colunas candidatas, respaldar pais e dependentes, redirecionar referências, remover obsoletos e validar duplicidades=0. FK/UK composta ou dependência nova não encerra a revisão: a rotina deve isolá-la em mapa de exceção, concluir os ramos já conhecidos com segurança, registrar o caso reproduzível e incorporá-lo ao catálogo/script genérico para a próxima execução. Nunca excluir por tentativa.

### Correção antifrágil incorporada em 2026-09-11 — colisões 29/30 IMPORTUDO
O primeiro executor de colisões falhou com ORA-00942 porque os artefatos de backup foram referenciados sob o schema corrente enquanto a sessão efetiva é FRANCISCO_JUNIOR com CURRENT_SCHEMA=SANKHYA. A rotina genérica foi ajustada para criar e referenciar backups com proprietário explícito FRANCISCO_JUNIOR, consultar tabelas físicas via ALL_TABLES e qualificar as tabelas operacionais em SANKHYA. A execução de produção deve ser considerada concluída somente após log com MAPA_BAI/MAPA_END, referências redirecionadas, validação de duplicidades e COMMIT.

### Correção antifrágil incorporada em 2026-09-11 — quota de auditoria
A tentativa 08 confirmou que a resolução de proprietário estava correta, mas falhou com ORA-01950 ao inserir o mapa persistente no tablespace USERS. A rotina deve tentar primeiro o proprietário e o artefato persistente já disponíveis, sem aguardar ou solicitar provisão de quota. Se nenhuma persistência segura existir, isolar o ramo antes do DML operacional; não substituir por INSERT/UPDATE avulso nem por mapa apenas em memória.

### Correção antifrágil incorporada em 2026-09-14 — inventário físico na fase de exclusão
A validação de referências obsoletas deve repetir o inventário físico usando `ALL_TAB_COLUMNS JOIN ALL_TABLES`. Consultar apenas `ALL_TAB_COLUMNS` pode incluir views e produzir bloqueios falsos; a fase de exclusão deve ser separada, abortar com qualquer referência física, manter backup/mapa persistentes e executar pos-validação antes do `COMMIT`.

### Correção antifrágil incorporada em 2026-09-14 — dependências por FK
Além do inventário por nomes `CODBAI`/`CODEND`, a atualização e a exclusão percorrem `ALL_CONSTRAINTS`/`ALL_CONS_COLUMNS` para descobrir FKs que apontam para `TSIBAI`/`TSIEND`. Isso cobre colunas específicas da base, como `TGFCPL.CODENDENTREGA`, sem depender de convenção de nomenclatura. A descoberta é genérica; cada nova exceção real deve ser preservada no log e convertida em regra reutilizável.

### Padrão obrigatório a partir de 2026-09-11 — scripts de reversão autocontidos
Toda rotina que produzir alteração persistente deve gerar, antes do encerramento, um script de reversão autocontido na pasta local da base e uma cópia publicada no Google Drive. O script deve conter o ID_EXECUCAO, nomes dos backups/mapas e validações de pré-condição embutidos; não pode exigir parâmetros, DEFINEs ou edição manual do consultor. A execução deve abortar se o ID ou os objetos de auditoria não coincidirem, registrar o resultado em spool e preservar transação/rollback seguro. O relatório deve informar os dois caminhos e o ID exato utilizado.

### Dependência funcional registrada em 2026-09-11 — Etapa 21 / Card 16
A Etapa 21 deve ser tratada como execução diretamente dependente do Card 16 (Classificação Fiscal/ICMS). O preflight, a validação de elegibilidade, o ID_EXECUCAO, o backup e o rollback devem ser compartilhados ou explicitamente vinculados ao Card 16; não classificar a etapa como independente nem encerrar o card sem validar o resultado da etapa 21.

### Correção antifrágil 2026-09-11 — dicionário Oracle sem VIRTUAL_COLUMN
A rotina TGFCGM não deve depender das colunas VIRTUAL_COLUMN/IDENTITY_COLUMN de ALL_TAB_COLUMNS, pois versões da base podem não expô-las. A seleção dinâmica deve usar apenas metadados compatíveis e validar a inserção/rollback.

### Regra permanente 2026-09-21 — quota não é gate universal

`USER_TS_QUOTAS` deve ser registrado como diagnóstico. Quota somente impede o
ramo que precisa criar ou ampliar mapa, backup ou auditoria persistente no
tablespace sem espaço; ela não bloqueia a revisão inteira, a conferência
read-only ou atividades que não dependem desse armazenamento. O ganho da quota
é preservar evidência e reversão duráveis. Não provisionar quota durante a
revisão nem substituir artefato persistente por memória ou DML avulso.

### Regra permanente 2026-09-21 — primeira onda do lote

Antes do primeiro `apply`, expandir includes, validar binds por bloco,
qualificar proprietário/schema, testar guards de estado, verificar ordem de
criação/consulta de backups e mapas e rejeitar colunas duplicadas. As correções
já incorporadas cobrem `ORA-00942` em backup criado no mesmo bloco,
`SP2-0552`, `DPY-4008`, `ORA-01031`, `PLS-00103` em CTAS/XMLTABLE,
`PLS-00402`, `ORA-01950`, `ORA-20340`, conflitos de `DEFINE` e dependências
físicas/FK. Cada erro deve permanecer no log, bloquear somente o ramo afetado
e gerar novo plano/hash/ID antes da retomada; não repetir o Master inteiro após
commit parcial.

### Regra permanente 2026-09-21 — autorização e continuidade

`EXECUTAR <BASE>` é a autorização prévia para a onda aprovada. O agente deve
autorizar as confirmações nativas repetidas do banco e não solicitar a mesma
autorização por instrução. O mesmo critério vale para o envio do ticket de
objetos inválidos quando a organização estiver confirmada, não houver
duplicidade e o rascunho estiver `PRONTO`; erro, ambiguidade ou impedimento
externo exige pausa e decisão.

### Diretrizes permanentes para o prompt de cada nova base — padrão antifrágil

1. O prompt deve carregar todo o conhecimento acumulado: estrutura SQL/PLSQL compatível com o ambiente, qualificações de proprietário e schema, metadados Oracle portáveis, binds inicializados, IDs base-específicos, preflight, auditoria, validação e reversão. Cada novo impedimento deve ser incorporado ao script genérico, ao README ou ao registro permanente de lições antes da próxima base.
2. Um erro em uma atividade não deve interromper as atividades independentes e seguras. Devem ser preservados o erro completo e o log original, adiando somente a atividade afetada e suas dependências. Após o fluxo independente, a atividade pendente deve ser tratada, validada e assimilada ao padrão antifrágil.
3. A execução deve ser autônoma e exigir interação somente quando indispensável. Autorizações equivalentes já concedidas permanecem válidas; alterações ou deleções podem prosseguir quando houver backup validado, mapa persistente, validação de pré-condição e reversão segura. Nenhuma senha deve ser armazenada, exibida ou registrada.

### Regra operacional permanente — pós-tratamento obrigatório das atividades 29/30 e Card 09

- `CONCLUIDO_PARCIAL` nas atividades 29/30 significa que a etapa de
  padronização terminou, mas não encerra o tratamento: os grupos de colisão
  devem entrar automaticamente em uma fase posterior de merge controlado na
  mesma revisão.
- O merge deve criar ID_EXECUCAO próprio, mapa persistente obsoleto -> mantido,
  backups de pais e dependentes, inventário de PK/UK/FK (inclusive compostas),
  redirecionamento, validação de referências obsoletas e duplicidades
  normalizadas, além de rollback autocontido. Dependência nova ou conflito de
  chave deve ser isolado em mapa de exceção, permitindo executar os ramos
  mapeados e incorporando o caso ao script genérico; somente ausência de
  backup/mapa, quota insuficiente ou risco de perda de referência impede o
  commit do ramo afetado.
- O Card 09 deve preferir o mapa direto por XML, com limite da volumetria,
  classificação persistente e DML somente para aptos. A validação/compilação de
  `FNC_BUSCA_TAG_XML_GERAL` fica restrita ao fallback autorizado quando a
  leitura direta não for viável.
- Divergência entre nome informado e `TSIEMP` deve usar diagnóstico read-only
  de variações, com contagem, lista de nomes, exceções e autorização separada;
  não alterar o gate textual genérico nem confundir essa autorização com a do
  DML financeiro.
- O INSERT financeiro só pode ocorrer após mapa TGFPPG validado, XML com
  `<Dup>` e `<dVenc>` válidos, preservação de notas já financeiras, seleção
  segura de `CODTIPTITPAD`/`TGFNUM` e rollback persistente.
- Depois de qualquer `ORA-17002` ou encerramento de sessão, reconectar a
  planilha, executar uma consulta de identidade (`USER`, `CURRENT_SCHEMA`,
  `SERVICE_NAME`) e somente então repetir DDL/DML; o erro de transporte não
  pode ser confundido com sucesso ou falha lógica da rotina.
