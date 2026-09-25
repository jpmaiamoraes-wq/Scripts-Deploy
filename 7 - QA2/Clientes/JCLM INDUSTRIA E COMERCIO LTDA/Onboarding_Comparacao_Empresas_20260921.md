# Comparação de empresas do onboarding — JCLM INDUSTRIA E COMERCIO LTDA

## Fonte considerada

Foi considerada a composição exibida no site Onboarding Deploy para a base JCLM: CNPJ principal `33.649.134/0002-78` e mais duas empresas. A base Oracle foi consultada em modo somente leitura em 21/09/2026.

## Resultado

O onboarding possui 3 empresas; a base Oracle possui 6 empresas. As três empresas do onboarding estão cadastradas na base. Portanto, não há CNPJ do onboarding ausente no Oracle; há três CNPJs adicionais na base, que precisam ser confirmados com o colega responsável pela etapa anterior.

### Empresas presentes no onboarding e localizadas na base

| CNPJ | Razão social | Oracle CODEMP |
|---|---|---:|
| `33.649.134/0002-78` | JCLM INDUSTRIA E COMERCIO LTDA | 1 |
| `37.008.355/0001-37` | FUTURA PRODUTOS ALIMENTICIOS LTDA | 2 |
| `07.056.520/0001-65` | INDUSTRIA DE SUCOS SUMO INDUSTRIAL LTDA | 3 |

### CNPJs adicionais na base, sem correspondência no conjunto de 3 empresas do onboarding

| CNPJ | Razão social | Oracle CODEMP |
|---|---|---:|
| `33.649.134/0001-97` | JCLM INDUSTRIA E COMERCIO LTDA | 4 |
| `05.334.986/0001-50` | JULIO CESAR MOMESSO LTDA | 5 |
| `04.816.115/0001-00` | JAF DISTRIBUIDORA DE BEBIDAS LTDA | 6 |

## Encaminhamento

Reportar os três CNPJs adicionais para confirmação de escopo. Não remover, incluir ou alterar empresa automaticamente. A divergência é documental/de escopo e permanece sem DML ou DDL.

## Evidência

- `Artefatos_Revisao/Preflight/52_Onboarding_Identidade_Empresas_READONLY.sql`
- `Logs/Verificacao_Onboarding_ReadOnly_JCLM_20260921.json`

