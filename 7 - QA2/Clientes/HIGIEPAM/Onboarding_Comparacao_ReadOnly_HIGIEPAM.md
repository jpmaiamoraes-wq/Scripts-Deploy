# Conferência de onboarding — HIGIEPAM

## Resultado

A conferência foi realizada em modo somente leitura usando o registro mais recente exibido no Onboarding Deploy. O projeto HIGIEPAM aparece como concluído e a planilha de usuários mais recente foi enviada em 15/09/2026 às 11:38.

O escopo permanece `BASE_INTEIRA`. A quantidade de empresas não foi usada como gate.

## Empresas

Os três CNPJs exibidos no onboarding foram localizados na base Oracle:

| CNPJ | Código | Onboarding | Razão social Oracle | Resultado |
|---|---:|---|---|---|
| 27.492.179/0001-06 | 1 | HIGIEPAM | GPD SOLUCOES EM LIMPEZA E MANUTENCAO LTD | CNPJ correspondente, nome apresentado diferente |
| 36.646.530/0001-59 | 2 | L. PORFIRIO DOS SANTOS | L PORFIRIO DOS SANTOS LTDA | CNPJ correspondente, variação de apresentação |
| 59.138.402/0001-08 | 3 | CELAYA PAPEIS LTDA | CELAYA PAPEIS LTDA | Correspondente |

Não há CNPJ do onboarding ausente no Oracle e não há empresa Oracle adicional fora do conjunto exibido.

## Usuários

A comparação Oracle considerou somente `TSIUSU.CODGRUPO > 0`, conforme o procedimento da revisão. A base retornou 17 registros de usuário, todos com `CODGRUPO=0`. Eles foram mantidos como usuários-modelo e excluídos da população ativa.

Na planilha existem 17 linhas e 7 e-mails distintos. Seis e-mails aparecem na base apenas em registros-modelo. O e-mail `compras.higiepam@gmail.com` não foi localizado no Oracle. Assim, nenhum dos 17 registros do onboarding possui correspondência ativa com grupo preenchido.

As empresas informadas no onboarding são `1,2,3`; os registros-modelo localizados no Oracle possuem `CODEMP=1`. Nenhuma alteração foi feita para resolver essa divergência.

## Identidade e segurança

Consulta direta concluída com `SESSION_USER=FRANCISCO_JUNIOR`, `CURRENT_SCHEMA=SANKHYA`, serviço `higiepamprd.sankhyacloud.com.br` e base `HIGIEPAMPRD`. As consultas foram `SELECT`/`WITH` read-only. `dml_executado=false` e `ddl_executado=false`.

## Evidências

- Fonte do site e comparação consolidada: `Onboarding_Comparacao_ReadOnly_HIGIEPAM.json`.
- Consulta Oracle e retorno integral: `Logs/Consulta_Onboarding_Oracle_ReadOnly_20260921.log`.
- Planilha local usada para leitura: `Downloads/(MODELO SANKHYA) Usuarios__51233-1789472279075-yesgs80q.xlsx`.

