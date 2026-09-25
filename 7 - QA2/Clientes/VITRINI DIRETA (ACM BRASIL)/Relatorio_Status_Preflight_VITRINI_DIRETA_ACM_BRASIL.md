# Status do preflight — VITRINI DIRETA (ACM BRASIL)

ID da execução: `RMD_VDA_20260918080832`  
Data: 2026-09-18  
Status: **MASTER 01–31 CONCLUÍDO — CARDS 29/30 CONSOLIDADOS — CARD 09 CONCLUÍDO**

## Evidência Oracle

- `SESSION_USER`: `FRANCISCO_JUNIOR`
- `CURRENT_SCHEMA`: `SANKHYA` — registrado como informação operacional, não como falha de login.
- `SERVICE_NAME`: `vitrinediretaprd.sankhyacloud.com.br`, correspondente ao serviço esperado.
- `TSIEMP.RAZAOSOCIAL = 'VITRINI DIRETA (ACM BRASIL)'`: **0 linhas**.
- `QTD_EMPRESA_EXATA`: **0** — resultado `BLOQUEAR_IDENTIDADE_EMPRESA`.
- `TSIPAR.CHAVE = 'VERSAOSKWBIN'`: versão `4.36b126`, compilação `126`, em `11/08/2026 11:20`.

## Complemento de identidade por variação de nomes

O diagnóstico somente leitura confirmou que `TSIEMP` possui os campos `NOMEFANTASIA` e `RAZAOSOCIAL` e encontrou as seguintes variações no cadastro:

- `ACM BRASIL` / `ACM BRASIL LTDA`;
- `VITRINE DIRETA` / `VITRINE DIRETA S.A.`.

Foram retornadas 6 linhas em `TSIEMP` (e não 7 como informado inicialmente); uma linha adicional aparece como `ACMINAS`. Essa diferença foi preservada como observação, sem impedir a execução porque o solicitante confirmou que as variações pertencem à mesma empresa/grupo e autorizou expressamente o Master.

## Decisão

O bloqueio anterior era uma regra textual conservadora que exigia a razão social exata `VITRINI DIRETA (ACM BRASIL)`. Após o diagnóstico de `NOMEFANTASIA`/`RAZAOSOCIAL` e a autorização expressa do solicitante, a execução do Master foi liberada.

## Resultado do Master

- `ID_MASTER`: `RMD_RUN_20260918083819561`.
- Início: `18/09/2026 08:38:18`; fim: `18/09/2026 08:46:38`.
- Atividades `01–31`: processadas e encerradas sem erro SQL não tratado.
- Atividade `31`: não recompilou 49 objetos inválidos por ausência do privilégio `ALTER ANY PROCEDURE`; não foi tratado como sucesso de recompilação.
- O Master encerrou encaminhando o Card 09 para preflight 32, modelo 32A, revisão do mapa e confirmação separada do modelo 32B.

## Ticket Sankhya Cloud — objetos inválidos

- Chamado aberto: [#711178](https://ajuda.sankhya.com.br/hc/pt-br/requests/711178), status inicial `ABERTO`.
- Organização utilizada: `ACM BRASIL-81357`; a organização padrão `SANKHYA JIVA` não foi utilizada.
- Formulário: prioridade `Normal`, categoria `Personalizar Objeto de Banco de Dados`, ambiente `Produção`, banco `Oracle`.
- Escopo: análise de dependências, erros de compilação e recompilação/correção dos 49 objetos nativos inválidos.
- Não foram anexados logs, credenciais ou outros arquivos.

## Consolidação controlada dos Cards 29/30

O status parcial original de 29/30 foi tratado com um follow-up específico, após preflight somente leitura que identificou as tabelas físicas, as FKs para `TSIBAI`/`TSIEND`, os nomes customizados e a ausência de quota/auditoria prévia.

- `ID_EXECUCAO`: `RMD_VDA_2930_20260918085910599`.
- Mapa: 428 bairros obsoletos e 7.283 endereços obsoletos.
- Backup qualificado: 848 linhas de `TSIBAI` e 14.226 linhas de `TSIEND`.
- Referências remapeadas: `TGFPAR`, `TSICEP`, `TGFCPL` e demais ramos/FKs elegíveis; nenhum ramo terminou em exceção.
- Exclusões finais: 428 pais em `TSIBAI` e 7.283 pais em `TSIEND`.
- Resultado: `EXCECOES=0` e `REFERENCIAS_REMANESCENTES=0`.
- Pós-validação: 0 grupos de colisão remanescentes em bairros e 0 em endereços.
- Rollback autocontido criado com o mesmo ID, restaurando pais a partir dos backups e referências pela trilha de dependências.

O resumo de onboarding contém referência a `VITRINE DIRETA S.A.`, que não substitui a confirmação exigida pela razão social exata no `TSIEMP`. Não foi feita correção automática nem inferência entre os nomes.

## Execução controlada do Card 09

O Card 09 foi executado em etapa separada, usando leitura direta de `TGFNFE.XML`
com `XMLTABLE`, após a redução da massa pela volumetria do dashboard. A
function `FNC_BUSCA_TAG_XML_GERAL` não foi necessária.

- ID: `VDA_ACM_FDUP_20260918_02`.
- Mapa: 21 notas; 6 `APTO_PARA_VALIDACAO_FINAL` e 15 `SEM_VDUP_XML` preservadas.
- Inclusões efetivas: 6 `TGFFIN`, com auditoria persistente.
- `NUFIN`: 35861 a 35866; `TGFNUM.ULTCOD` validado em 35866.
- Pós-validação: aptos sem financeiro = 0; duplicidades por `NUNOTA` = 0.
- Rollback pronto e preservado para o mesmo ID.

## Evidência persistida

- [Log completo do preflight](Logs/Preflight_RMD_VDA_20260918080832.log)
- [Gate executado](00_Preflight_Gate_VITRINI_DIRETA_ACM_BRASIL.sql)
- [Metadados da revisão](Dados_Revisao.json)
- [Registro do ticket Sankhya Cloud](Ticket_Sankhya_Cloud_Objetos_Invalidos_VITRINI_DIRETA_ACM_BRASIL.md)
- [Diagnóstico de identidade por variação de nomes](Logs/Identidade_Empresas_ReadOnly_RMD_VDA_20260918080832.log)
- [Log completo do Master](Logs/Revisao_Master_20260918_080832.log)
- [Preflight read-only dos Cards 29/30](Logs/29_30_Preflight_FK_ReadOnly_RMD_VDA_20260918080832.log)
- [Log da consolidação 29/30](Logs/29_30_Merge_Antifragil_RMD_VDA_20260918080832.log)
- [Script da consolidação 29/30](29_30_Merge_Antifragil_VITRINI_DIRETA_ACM_BRASIL.sql)
- [Rollback da consolidação 29/30](Artefatos_Revisao/Rollback/Reverter_29_30_Merge_Antifragil_RMD_VDA_2930_20260918085910599.sql)
- [Comprovante da execução do Card 09](Card09_Execucao_VDA_20260918_02.md)
- [Detalhe final limpo do Card 09](Logs/Card09_PosValidacao_Detalhe_VDA_20260918_02_FINAL.log)
- [Mapa direto por XML do Card 09](32A_Card09_Mapear_Direto_XML_VITRINI_DIRETA_ACM_BRASIL.sql)
- [Executor do Card 09](32B_Card09_Inserir_VITRINI_DIRETA_ACM_BRASIL.sql)
- [Pós-validação do Card 09](32D_Card09_PosValidacao_VITRINI_DIRETA_ACM_BRASIL.sql)
- [Rollback do Card 09](32C_Card09_Rollback_VITRINI_DIRETA_ACM_BRASIL.sql)

## Observação de controle

O preflight original permanece preservado com `QTD_EMPRESA_EXATA = 0`; esse resultado não foi apagado nem alterado. A exceção de nomenclatura foi autorizada pelo solicitante e está registrada acima. A base foi alterada pelo Master, pela consolidação controlada de 29/30 e pelo tratamento do Card 09, com logs, mapas, backups e rollback persistidos. Permanecem como pendências reais a recompilação dos 49 objetos inválidos (privilégio ausente) e o onboarding. O Card 09 está concluído para os seis candidatos aptos identificados nesta execução; novas notas exigirão novo mapa, auditoria, confirmação e rollback próprios.
