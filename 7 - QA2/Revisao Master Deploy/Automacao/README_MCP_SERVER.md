# Servidor MCP da Revisão Master Deploy

Wrapper fino sobre `oracle_direct.py` e `oracle_batch.py`, expondo 4 ferramentas
tipadas: `status`, `consultar`, `planejar`, `aplicar`. Nenhuma trava de
segurança foi reimplementada — cada ferramenta só monta o comando equivalente
e chama o script correspondente via `subprocess`. `aplicar` nunca passa
`--preauthorized`/`--authorization`: a confirmação nativa do macOS continua
obrigatória, decidida sempre por uma pessoa no teclado.

## O que já foi validado

- Sintaxe e imports corretos (testado com `mcp` 2.x, `MCPServer`/`Context`).
- `planejar()` roda de verdade contra `Revisao_Master_Deploy.sql` (entrypoint
  real, 33 arquivos, sem tocar no Oracle).
- Erros de caminho (`script_path` inexistente) são detectados antes de
  qualquer tentativa de conexão, tanto em `planejar()` quanto em `aplicar()`.
- Detecção automática do interpretador certo para falar com o Oracle
  (`.venv` local, `ORACLE_PYTHON`, ou o interpretador que roda o próprio
  servidor, nessa ordem).

O que **não pôde ser testado por aqui** (ponte remota, sem credencial real):
`consultar()` e `aplicar()` contra um banco de verdade, e o self-check com o
driver `oracledb` instalado (esse teste só faz sentido com o `.venv` real do
Mac, que já existe e funciona conforme o README_ORACLE_DIRETO.md).

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

## ⚠️ Ressalva importante sobre o registro no Cowork

Fui checar a documentação oficial antes de escrever este passo, e encontrei
uma informação relevante: servidores MCP locais configurados via
`claude_desktop_config.json` são descritos pela Anthropic como "uma
mecânica separada" dos conectores remotos, e a documentação afirma
textualmente que eles usam a rede local, mas **"não estão disponíveis no
Cowork ou no claude.ai"**. Ou seja: pelo que a documentação diz hoje, pode
ser que este servidor não fique acessível para mim dentro de uma sessão
Cowork como esta, mesmo depois de registrado.

Não tenho como confirmar isso com certeza sem você testar no seu Mac. Os
dois caminhos possíveis, então:

### Opção A — editar claude_desktop_config.json (o caminho "clássico")

Local típico no macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
(confirme no seu Mac — o caminho pode variar por versão do app). Adicione:

```json
{
  "mcpServers": {
    "sankhya-revisao-master-deploy": {
      "command": "/CAMINHO/COMPLETO/PARA/.mcp-venv/bin/python3",
      "args": [
        "/CAMINHO/COMPLETO/PARA/7 - QA2/Revisao Master Deploy/Automacao/mcp_server.py"
      ]
    }
  }
}
```

Substitua os dois `/CAMINHO/COMPLETO/PARA/...` pelos caminhos reais no seu
Mac (caminho absoluto, não relativo). Depois, reinicie o Claude Desktop.

### Opção B — verificar em Settings > Extensions/Connectors

Antes de editar o JSON manualmente, vale checar direto no app: Settings >
Extensions (ou Connectors) > "Advanced settings" > se existir alguma opção
de instalar um servidor local (geralmente como pacote `.mcpb`). Essa pode
ser a via oficialmente suportada para o seu app/versão, e não tenho como ver
essa tela a partir daqui.

**Se, depois de registrado, as ferramentas `status`/`consultar`/`planejar`/
`aplicar` não aparecerem numa sessão Cowork como esta**, o wrapper continua
com valor: dá pra usá-lo em conversas normais do Claude Desktop (fora do
Cowork), ou eu continuo acionando `oracle_direct.py`/`oracle_batch.py`
diretamente como já fazia antes — nada se perde, só não ganha a conveniência
extra da chamada tipada dentro do Cowork.

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
