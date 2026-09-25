# Comparação de usuários do onboarding — JCLM INDUSTRIA E COMERCIO LTDA

## Fonte considerada

Foi considerada a versão mais recente exibida no site Onboarding Deploy:

- Arquivo: `USUARIOS_MODELO_VAL_2026_06_V2.xls`
- Envio: `11/09/2026 18:55`
- Registros no arquivo: `27`
- Critério da base: somente `TSIUSU.CODGRUPO > 0`

O arquivo apresenta 27 usuários, todos com grupo preenchido. Na base existem 33 usuários no total: 25 com grupo preenchido e 8 classificados como usuários de modelo sem grupo, excluídos conforme o critério solicitado.

## Diferenças objetivas

| Situação | E-mail | Nome no onboarding | Empresa no onboarding | Grupo |
|---|---|---|---|---:|
| Ausente na base | `comercial@sumobrasil.com.br` | Jeferson Costa | SUMO | 15 |
| Ausente na base | `controle@sumobrasil.com.br` | Vanessa Oliveira Sandes | SUMO | 13 |

Os dois e-mails não foram encontrados em `TSIUSU`, inclusive entre os usuários sem grupo.

Não foram identificados usuários extras na base quando a comparação é feita por e-mail contra os 27 registros do arquivo.

## Grupos

Os 25 usuários localizados possuem `CODGRUPO` correspondente ao grupo informado no onboarding. Não foi identificada divergência de grupo nos registros encontrados.

## Nomes

Os e-mails encontrados correspondem, mas vários nomes do Oracle estão abreviados, truncados ou formatados de modo diferente do arquivo. Exemplos para conferência: `JOACIR.SANTOS` versus `Joacir Santos de Arruda`, `ANDREIA.BENO` versus `Andreia Benoni`, `DIEGO.SOUZA` versus `Diego de Souza Santos`, `JOSE.WEVERTON` versus `José Weverto dos Santos Souza` e `MILLENA.SILVA` versus `Millena Silva Macedo`. Essas diferenças foram classificadas como diferença nominal, não como usuário ausente.

## Empresa atribuída

Nos 25 registros Oracle com grupo preenchido, `CODEMP=1` em todos. O arquivo do onboarding identifica 10 usuários como JCLM, 5 como FUTURA e 12 como SUMO; após retirar os 2 usuários ausentes, permanecem 15 usuários rotulados como FUTURA/SUMO, mas ainda com `CODEMP=1` no Oracle. Esse ponto deve ser confirmado com o colega responsável pela etapa anterior antes de qualquer ajuste.

## Evidências

- `Artefatos_Revisao/Preflight/57_Onboarding_Usuarios_Grupo_READONLY.sql`
- `Artefatos_Revisao/Preflight/58_Onboarding_Usuarios_Resumo_READONLY.sql`
- `Artefatos_Revisao/Preflight/59_Onboarding_Usuarios_Ausentes_READONLY.sql`
- `Logs/Verificacao_Onboarding_ReadOnly_JCLM_20260921.json`

Todas as consultas foram somente leitura; não houve DML ou DDL.
