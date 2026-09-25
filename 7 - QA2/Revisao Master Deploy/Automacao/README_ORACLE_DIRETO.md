# Executor Oracle direto e execução controlada em lote

Este diretório define o executor Oracle direto como caminho padrão para as
revisões. Ele realiza `self-check`, validação de identidade Oracle e consultas
somente leitura sem depender de VS Code, SQL Developer ou outro aplicativo
externo. Alterações continuam restritas a entradas aprovadas e aos gates do
projeto.

## Preparação

Na raiz do repositório:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r \
  "7 - QA2/Revisao Master Deploy/Automacao/requirements-oracle-direct.txt"
```

O ambiente virtual não deve ser versionado. A instalação não cria nem altera
conexões Oracle e não armazena senha.

## Credencial corporativa pelo Vault (opcional)

O executor pode obter a senha Oracle de um segredo KV aprovado no HashiCorp
Vault. A integração não usa cookies do navegador, não recebe token no chat e
não grava o valor do segredo em arquivo, variável de ambiente, log ou saída.
O cliente oficial `vault` administra a sessão OIDC; o executor somente chama o
cliente, lê a resposta JSON em memória e valida host, porta, serviço e usuário
antes de tentar o login Oracle.

O cliente ainda precisa ser instalado uma vez no Mac. Em instalações Homebrew:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

Depois, iniciar a sessão OIDC sem exibir o token:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  vault-login \
  --vault-addr "https://vault-external.sankhyacloud.com.br" \
  --vault-namespace "francisco.junior"
```

Se a configuração exigir uma role OIDC, acrescentar `--vault-role`. O comando
retorna apenas o estado da autenticação; o token não é mostrado pelo executor.
O callback padrão da CLI é `http://localhost:8250/oidc/callback`. Se a role
corporativa usar outra porta previamente autorizada, informar
`--vault-oidc-port <PORTA>`; essa URL precisa estar liberada simultaneamente na
role OIDC do Vault e no aplicativo Google configurado pelo administrador.

Validar o segredo sem exibir nenhum valor:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  vault-check \
  --vault-addr "https://vault-external.sankhyacloud.com.br" \
  --vault-namespace "francisco.junior" \
  --vault-mount "kv" \
  --vault-path "solidamerica/prd"
```

O segredo deve possuir `hostname`, `port`, `servicename`, `username` e
`password` (há aliases seguros para `host`, `service_name`, `user` e `senha`).
Os quatro primeiros campos precisam corresponder aos argumentos da conexão;
uma divergência bloqueia o login Oracle.

Para usar o Vault na consulta ou no lote, acrescente a configuração e indique
`--credential-source vault`:

```bash
... identity \
  --host "10.100.0.1" --port 1521 \
  --service "SERVICOPRD.SANKHYACLOUD.COM.BR" \
  --username "francisco_junior" \
  --credential-source vault \
  --vault-namespace "francisco.junior" \
  --vault-mount "kv" \
  --vault-path "cliente/prd"
```

O padrão é `--credential-source auto`: quando `--vault-mount` e
`--vault-path` estão configurados, tenta o Vault; se o cliente `vault` não
estiver instalado, conserva o Keychain como fallback. Uma falha de
autenticação, permissão, caminho ou correspondência no Vault bloqueia a
execução, sem trocar silenciosamente para outra credencial. Para manter o
fluxo anterior, use `--credential-source keychain`.

## Teste inicial sem banco

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  self-check
```

Resultado esperado: `AMBIENTE_PYTHON_OK`, com `dml_habilitado=false` e
`ddl_habilitado=false`.

## Teste inicial read-only em uma base

Somente depois de confirmar a base, a rota/VPN e os dados de conexão:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  identity \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE"
```

O programa testa a porta, solicita a senha de forma interativa e confirma
`SESSION_USER`, `CURRENT_SCHEMA`, `SERVICE_NAME`, `DB_NAME` e lista `TSIEMP`
em modo somente leitura. No primeiro acesso sem item no Keychain, a janela
nativa solicita a senha uma vez. Somente depois de o Oracle aceitar a
autenticação, o executor grava a credencial no Keychain antes de executar
consultas; se a gravação falhar, fecha a sessão e não executa consultas. Nas
execuções seguintes, lê o item já cadastrado. Quando o Vault fornece a senha,
ela não é copiada para o Keychain. Em todos os casos, a senha nunca deve ser
passada na linha de comando, variável, arquivo ou mensagem.

## Credencial no Keychain

O item é criado no Keychain de login do usuário macOS, com uma chave derivada
dos dados da conexão. O valor da senha não é escrito no projeto e não aparece
em logs. A conexão lê o item apenas em memória. Para preparar ou administrar o
item sem executar uma consulta:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  credential set \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE"
```

Na primeira conexão sem item salvo, a janela nativa protegida solicita a senha
uma vez e o executor a grava somente após o Oracle aceitar o login. Isso vale
para consultas read-only e para o lote controlado, que compartilham o mesmo
fluxo de conexão. `credential set` continua disponível para cadastrar ou
atualizar o item antes de uma execução; `credential status` informa apenas se
ele existe; `credential delete` remove-o. Se a senha Oracle for trocada,
execute `credential set` novamente. A opção explícita `--prompt terminal`
continua sem persistir a senha, e uma senha obtida do Vault nunca é copiada
para o Keychain.

Regra de reutilização entre tarefas: antes de abrir qualquer diálogo de senha,
consulte `credential status` com os mesmos host, porta, service e usuário da
conexão. Quando Keychain for a fonte escolhida e o resultado for
`CREDENCIAL_KEYCHAIN_PRESENTE`, não execute `credential set` nem solicite
novamente a senha Oracle; deixe o executor recuperá-la do Keychain em memória.
Se estiver configurada uma fonte Vault aprovada, use o cliente/OIDC documentado;
credenciais Vault nunca são copiadas para o Keychain. Sem Vault e sem item
Keychain, faça a conexão normal: a janela protegida aparece uma vez e a
credencial é salva após autenticação Oracle bem-sucedida. O item é específico a
essa combinação e à conta macOS local, portanto outra base/conexão pode exigir o
primeiro cadastro. Eventual aviso do macOS para desbloquear ou autorizar o
Keychain não é a senha Oracle. Em falha de autenticação, não repita a solicitação
em ciclo: pare e diagnostique a conexão/credencial; use `credential set` somente
para senha nova, rotacionada ou correção explícita do item.

O armazenamento é local ao usuário e ao Mac. Outro chat pode reutilizá-lo se
executar o mesmo projeto no mesmo computador e conta macOS; a senha não é
compartilhada com a IA nem com outros computadores.

## Execução em lote com confirmação única ou autorização prévia

Para eliminar confirmações repetidas por instrução, a camada usa uma única
sessão Oracle e uma confirmação nativa antes do lote inteiro. Quando o usuário
já autorizou a onda com `EXECUTAR <BASE>`, o agente pode passar
`--preauthorized --authorization "EXECUTAR <BASE>"`; nesse modo não abre a
janela nativa, mas mantém identidade, serviço, allowlist, plano, hash, logs,
backup, auditoria, pós-validação e reversão.

Primeiro valide o plano, sem acessar a base:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_batch.py" \
  plan \
  --script "7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql"
```

`plan` agora executa o preflight expandido antes de retornar sucesso. O alias
`preflight` pode ser usado para tornar essa intenção explícita:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_batch.py" \
  preflight \
  --script "7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql"
```

Essa etapa não abre conexão Oracle e não executa DML/DDL. Ela expande os
includes e verifica, entre outros pontos, binds por bloco, redefinições de
`DEFINE`, referências `&` não resolvidas, instruções não classificadas,
`CTAS/XMLTABLE` dentro de `EXECUTE IMMEDIATE`, risco de coluna duplicada em
cursores e referências estáticas a artefatos criados posteriormente. O JSON
retorna `PREFLIGHT_APROVADO` ou `PREFLIGHT_BLOQUEADO`, com arquivo, linha,
código e mensagem para cada bloqueio ou aviso.

O `apply` executa o mesmo preflight novamente e recusa o lote quando houver
qualquer bloqueio. Avisos ficam registrados no log; não são tratados como
sucesso silencioso. Depois de qualquer correção, é obrigatório gerar novo
plano, novo hash e novo `ID_EXECUCAO` antes da retomada.

Depois, o modo `apply` faz a verificação da conexão, privilégios e quota. Sem
autorização prévia, exibe o resumo e solicita confirmação uma única vez. Com
`EXECUTAR <BASE>`, a confirmação nativa é dispensada pelo marcador explícito:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_batch.py" \
  apply \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE" \
  --script "7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql" \
  --execution-id "RMD_DIRETO_YYYYMMDD_HHMMSS" \
  --preauthorized \
  --authorization "EXECUTAR NOME DA BASE" \
  --log "Clientes/NOME DO CLIENTE/Logs/Oracle_Direto_RMD.log"
```

O lote só aceita entradas versionadas e homologadas dentro da raiz `7 - QA2`,
expande includes locais `@`/`@@`, aceita somente parâmetros `DEFINE` simples e
controlados, rejeita `ACCEPT`, `HOST` e conexões externas, registra a
identidade, a impressão digital dos arquivos e o resultado de cada instrução.
Ao concluir todas as instruções, o executor registra e realiza um `COMMIT`
explícito antes da pós-validação. Se houver erro antes desse ponto, executa
`ROLLBACK` da transação ainda aberta; DDL já confirmado pelo Oracle continua
dependendo de reversão estrutural própria.
Em caso de erro, interrompe o lote e registra o erro; não declara reversão
automática de DDL já confirmado pelo Oracle. A reversão continua sendo feita
pelos scripts autocontidos da revisão.

Além do Master e do mapa compartilhado, são reconhecidas como entradas de
alteração as fases versionadas por cliente com os prefixos
`29_30_Merge_Antifragil_` e `32A_Card09_Mapear_Direto_XML_`. O executor
financeiro `32B` não entra na allowlist normal e continua dependendo de uma
validação específica do mapa e da fase. Quando a fase estiver dentro do escopo
do `EXECUTAR <BASE>`, essa autorização pode ser aplicada sem nova interação,
mas os guards, auditoria e pós-validação continuam obrigatórios.

Quando houver um script de pós-validação contendo somente `SELECT` ou `WITH`,
ele pode ser associado ao mesmo lote. Ele roda depois da execução, sem nova
confirmação, e registra as colunas e linhas retornadas no mesmo log:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_batch.py" \
  apply \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE" \
  --script "Clientes/NOME DO CLIENTE/29_30_Merge_Antifragil_NOME.sql" \
  --post-script "Clientes/NOME DO CLIENTE/32D_Card09_PosValidacao_NOME.sql" \
  --execution-id "RMD_DIRETO_YYYYMMDD_HHMMSS" \
  --log "Clientes/NOME DO CLIENTE/Logs/Oracle_Direto_RMD.log"
```

O Master 01–31 e o mapa inicial do Card 09 são entradas aprovadas. O executor
financeiro do Card 09 permanece uma fase separada, pois depende da revisão do
mapa e de uma validação específica antes do `INSERT` em `TGFFIN`; essa
validação é por fase, não por instrução, e pode usar a autorização prévia da
base sem abrir novas telas quando os guards estiverem satisfeitos.

## Preflight read-only das atividades 29 e 30

Antes de aplicar a padronização de bairros e endereços, execute o diagnóstico
específico abaixo. Ele usa a conexão direta apenas para `SELECT`, aplica a
mesma normalização das atividades 29/30, conta grupos que permanecerão únicos,
grupos que colidirão e referências a códigos candidatos à substituição. A
amostra de grupos é limitada a 100 itens e o JSON pode ser salvo como
evidência na pasta da base:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_29_30_preflight.py" \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE" \
  --output "Clientes/NOME DO CLIENTE/Artefatos_Revisao/Preflight_29_30.json"
```

O resultado classifica a base como `PADRONIZACAO_UNICA_SEM_COLISOES`,
`MERGE_ANTIFRAGIL_OBRIGATORIO` ou `SEM_CANDIDATOS_DE_ALTERACAO`. Colisões
não são falhas globais, mas impedem tratar a atividade como uma simples
padronização: o mapa persistente, a descoberta de dependências e a fase
antifrágil passam a ser obrigatórios. Falha ao contar qualquer dependência
bloqueia o diagnóstico. O comando nunca cria objetos, atualiza dados,
exclui registros ou substitui a revisão do mapa.

A regra de conversão de acentos foi alinhada entre o diagnóstico, os scripts
29/30 e `29_30_Merge_Antifragil.sql`; divergência nessa regra pode alterar a
classificação de uma colisão e por isso possui teste automatizado.

Quando um Master parar após uma alteração confirmada, a retomada deve usar um
novo lote, novo hash e novo `ID_EXECUCAO`, preservando o `ID_MASTER` e pulando
somente as atividades comprovadamente concluídas. As continuações
base-específicas homologadas usam o prefixo `Continuacao_Master_Deploy_`; a
autorização textual `EXECUTAR <BASE>` pode continuar válida para o mesmo
escopo, mas nunca substitui o novo plano/hash, o inventário de estado ou a
análise de reversibilidade.

## Consulta read-only de volumetria

Depois de validar a identidade, o executor pode rodar um arquivo que contenha
uma única instrução `SELECT` ou `WITH`. O programa rejeita DML/DDL, múltiplas
instruções e comandos de transação antes de abrir a sessão Oracle:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  query \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE" \
  --sql-file "consulta_read_only.sql"
```

Para um relatório Jasper, `query-jrxml` extrai a `queryString` do arquivo
local. A opção `--include-excluded` é específica do modelo de volumetria e
inclui os indicadores de integridade que o relatório normalmente não imprime:

```bash
.venv/bin/python \
  "7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py" \
  query-jrxml \
  --host "HOST_ORACLE" \
  --port 1521 \
  --service "SERVICE_NAME" \
  --username "USUARIO_ORACLE" \
  --jrxml-file "REL_ENTEGA_NOVO_05.jrxml" \
  --include-excluded
```

O retorno registra identidade, fonte da consulta, colunas, linhas e as
marcações `dml_executado=false` e `ddl_executado=false`. A senha é recuperada
do Keychain quando já cadastrada; caso contrário, é solicitada na janela nativa
uma vez e salva após autenticação Oracle bem-sucedida.

## Limites atuais

- o comando `oracle_direct.py` continua limitado a consultas explicitamente
  read-only;
- o comando `oracle_batch.py` executa somente os lotes aprovados e versionados;
- a pós-validação automatizada aceita somente `SELECT`/`WITH` e não substitui a
  análise do resultado pelo responsável;
- não substitui a validação do Master nem o histórico de execução do processo;
- não reutiliza senhas salvas no SQL Developer;
- não armazena senhas em arquivos, variáveis de ambiente, histórico do shell ou
  contexto do chat; a senha Oracle pode permanecer no Vault corporativo ou no
  Keychain local, conforme a fonte escolhida;
- não lê `VAULT_TOKEN` do ambiente do executor; a sessão deve ser administrada
  pelo cliente oficial Vault e seu mecanismo local de autenticação;
- não declara sucesso se a porta, serviço ou identidade divergirem;
- não pede confirmação por instrução durante um lote aprovado nem quando o
  marcador `EXECUTAR <BASE>` foi informado;
- não executa qualquer arquivo arbitrário como se fosse parte da revisão.

O lote não deve ser convertido em um comando SQL genérico da IA. Novas entradas
ou fases precisam ser homologadas e acrescentadas explicitamente à lista de
entradas aprovadas, mantendo logs, `ID_EXECUCAO`, backup, auditoria,
confirmação única ou autorização prévia explícita por lote e pós-validação.
