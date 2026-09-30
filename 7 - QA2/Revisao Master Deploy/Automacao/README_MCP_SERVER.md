# Servidor MCP da Revisão Master Deploy

Wrapper fino sobre `oracle_direct.py` e `oracle_batch.py`, expondo 4 ferramentas
tipadas: `status`, `consultar`, `planejar`, `aplicar`. Nenhuma trava de
segurança foi reimplementada — cada ferramenta só monta o comando equivalente
e chama o script correspondente via `subprocess`. `aplicar` nunca passa
`--preauthorized`/`--authorization`: a confirmação nativa do macOS continua
obrigatória, decidida sempre por uma pessoa no teclado. `consultar` continua
bloqueando DML/DDL/COMMIT/ROLLBACK por regex antes de tentar login. `aplicar`
só executa lotes já aprovados e versionados no repositório (checado pelo
próprio `oracle_batch.py`) — não aceita instrução solta digitada em um chat.

## O que já foi validado

- Sintaxe e imports corretos (testado com `mcp` 2.x, `MCPServer`/`Context`).
- Ambiente Python funcional dentro desta pasta: `.venv` (oracledb 26.0.1) e
  `.mcp-venv` (mcp 2.2.0). `self-check` (`oracle_direct.py self-check`)
  retorna `AMBIENTE_PYTHON_OK`, modo `thin` (não precisa de Oracle Instant
  Client), DML/DDL desabilitados por padrão.
- **Registro confirmado no Claude Code** (28/09/2026) — ver seção abaixo.
  `claude mcp list` mostra `sankhya-revisao-master-deploy` com "✔ Connected";
  dentro do `claude`, `/mcp` lista as 4 ferramentas.
- **`status()` validado contra banco real** (30/09/2026, base `GOYAAGUAPRD`) —
  primeiro teste de ponta a ponta com credencial real, via Keychain (primeira
  autenticação salva automaticamente, sem repetir prompt depois). Retornou
  `AMBIENTE_PYTHON_OK`; identidade `FRANCISCO_JUNIOR` / schema `SANKHYA`;
  `service_compativel: true`; DB name `GOYAAGUAPRD`; 1 empresa em `TSIEMP`
  (GOYA INDUSTRIA E COMERCIO DE AGUA MINERA); `dml_executado=false`,
  `ddl_executado=false`.
- `planejar()` rodou de verdade contra `Revisao_Master_Deploy.sql` (entrypoint
  real: 33 arquivos expandidos, 1.085 instruções — 1.004 INSERT, 59 blocos
  PL/SQL ou DDL, 7 UPDATE, 4 DELETE, 4 ALTER, 4 SELECT, 2 MERGE, 1 COMMIT),
  sem tocar no Oracle, e sinalizou corretamente o COMMIT embutido em
  `17_Normalizar_Unidades.sql` (linha 306).
- Erros de caminho (`script_path` inexistente) são detectados antes de
  qualquer tentativa de conexão, tanto em `planejar()` quanto em `aplicar()`.
- Detecção automática do interpretador certo para falar com o Oracle
  (`.venv` local, `ORACLE_PYTHON`, ou o interpretador que roda o próprio
  servidor, nessa ordem).

## O que ainda não foi testado

- `consultar()` e `aplicar()` contra um banco de verdade — `status()` já foi
  validado de ponta a ponta em 30/09/2026 (ver seção acima); falta o mesmo
  teste para `consultar()`/`aplicar()`, com credencial real (Keychain ou
  Vault).
- Login OIDC do Vault (`vault-login`) está bloqueado por um problema de
  configuração externo a este repositório — ver aviso mais abaixo.

## Instalação (rodar no Terminal do seu Mac — não pela ponte remota)

Dois ambientes Python, propósitos diferentes:

```bash
cd "7 - QA2/Revisao Master Deploy/Automacao"

# 1) o venv que roda o servidor MCP em si (só precisa do pacote mcp)
python3 -m venv .mcp-venv
.mcp-venv/bin/pip install "mcp[cli]"

# 2) o venv que fala com o Oracle (oracledb) — normalmente já existe (.venv);
#    se não existir:
python3 -m venv .venv
.venv/bin/pip install -r requirements-oracle-direct.txt
```

O servidor detecta o `.venv` acima automaticamente (ou a variável de ambiente
`ORACLE_PYTHON`, se você preferir apontar para outro interpretador) para
chamar `oracle_direct.py`/`oracle_batch.py` — não precisa ser o mesmo
interpretador que roda `mcp_server.py`.

## Registro no Claude Code (caminho validado — não use o Cowork para isto)

O Cowork (chat/GUI, incluindo sessões com ponte remota pro Mac) **não** é o
lugar certo para registrar este servidor: a tela Personalizar → Conectores →
"Adicionar conector personalizado" é bloqueada por permissão de owner da
organização, e mesmo liberada não está confirmado que ela aceite um servidor
local por comando+args (parece voltada a conectores remotos via URL). Além
disso, a ponte remota (`device_bash`) roda dentro de uma VM Linux isolada no
Mac — não é o Terminal nativo —, então nem Keychain nem o navegador para
login OIDC do Vault funcionam por ali.

O caminho que funciona de verdade é o **Claude Code**, rodando nativamente no
Terminal do Mac (sem VM isolada no meio, sem gate de admin):

```bash
# instalar (uma vez por Mac)
npm install -g @anthropic-ai/claude-code

# registrar o servidor MCP (uma vez por clone do repositório)
cd "<raiz do repositório, ex.: ~/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy>"
claude mcp add sankhya-revisao-master-deploy -- \
  "<caminho absoluto>/7 - QA2/Revisao Master Deploy/Automacao/.mcp-venv/bin/python3" \
  "<caminho absoluto>/7 - QA2/Revisao Master Deploy/Automacao/mcp_server.py"
```

Isso grava a configuração em `~/.claude.json` (escopo `local`, associado a
este projeto) — persiste automaticamente para as próximas vezes que você
rodar `claude` dentro desta pasta; não precisa repetir o `claude mcp add`.
Validar com `claude mcp list` (deve aparecer "✔ Connected") e, dentro do
chat do Claude Code, com `/mcp` (deve listar as 4 ferramentas).

Como o Claude Code roda direto no sistema operacional real do Mac, um
subprocesso disparado por ele (por exemplo `oracle_direct.py` pedindo a
senha) consegue acionar o Keychain nativamente ou abrir o navegador padrão
para OIDC do Vault — ao contrário da ponte remota do Cowork.

## ⚠️ Bloqueio conhecido: login OIDC do Vault (redirect_uri_mismatch)

Registrado em 25/09/2026, ainda sem solução: `oracle_direct.py vault-login`
(ou `vault login -method=oidc` direto) falha com **Erro 400:
redirect_uri_mismatch** do Google. A porta padrão do callback (8250) estava
livre no Mac — não é conflito de porta nem nada do lado do consultor. A causa
é que a URL `http://localhost:8250/oidc/callback` não está cadastrada nas
"Authorized redirect URIs" do client OAuth do Google usado por essa
integração (`client_id
25985837215-rcvpcrb8clqeel9c5hmkmu8btalu9b8i.apps.googleusercontent.com`).
Só quem administra esse client no Google Cloud Console consegue corrigir,
adicionando essa URL à lista. Isso é **independente de rodar pela ponte do
Cowork ou pelo Terminal/Claude Code** — o problema é do lado do Google Cloud,
não do ambiente local.

E-mail formalizando o pedido foi enviado em 25/09/2026 para o supervisor
(Paulo Henrique Silva Rabelo). Enquanto não resolvido, use
`--credential-source keychain` (funciona nativamente no Mac/Claude Code, não
pela ponte remota) em vez de `vault`.

## Ferramentas expostas

| Ferramenta | Conecta no Oracle? | O que faz |
|---|---|---|
| `status` | Sim (identity/vault-check) | self-check do ambiente + identidade da conexão + checagem do segredo Vault, sem DML/DDL |
| `consultar` | Sim | consulta read-only (SELECT/WITH); DML/DDL/COMMIT/ROLLBACK bloqueado pelo próprio `oracle_direct.py` |
| `planejar` | Não | preflight estático de um entrypoint (`oracle_batch.py plan`) |
| `aplicar` | Sim | executa lote aprovado (`oracle_batch.py apply`); sempre com confirmação nativa do macOS |

Todos os parâmetros de Vault (`credential_source`, `vault_namespace`,
`vault_mount`, `vault_path`) são opcionais e passados adiante tal como o
`oracle_direct.py`/`oracle_batch.py` já esperam.
