# Relatório de Entrega Técnica — Deploy Agent

## Produtos Macalé LTDA

**Gerente de Projetos:** Marcelo Renato Fialho Thaisen  
**E-mail:** marcelo.thaisen@sankhya.com.br  
**Base:** MACALEPRD.SANKHYACLOUD.COM.BR  
**Schema:** SANKHYA  
**Usuário da execução:** FRANCISCO_JUNIOR  
**Data da revisão:** 09/09/2026  

## Resumo executivo

Este relatório registra os resultados comprovados da revisão da base Produtos Macalé LTDA, realizada pelas etapas 01 a 31 do Deploy Agent. A volumetria foi coletada após a execução, priorizando os critérios do dashboard **Volumetria Deploy Agent**. As etapas são classificadas como concluídas, concluídas parcialmente, ignoradas ou com ponto de atenção conforme os logs e validações disponíveis.

| Indicador | Quantidade | Fonte |
|---|---:|---|
| Notas/cabeçalhos na TGFCAB | 30.648 | Dashboard |
| Itens na TGFITE | 67.786 | Dashboard |
| Registros financeiros na TGFFIN | 45.039 | Dashboard |
| Contas a receber | 36.633 | TGFFIN.RECDESP = 1 |
| Contas a pagar | 8.406 | TGFFIN.RECDESP = -1 |
| Produtos cadastrados | 1.948 | CODPROD diferente de zero |
| Parceiros cadastrados | 2.372 | TGFPAR |
| Produtos com custo zero | 1.143 | Dashboard |

## Volumetria e qualidade

| Seção | Indicador | Resultado |
|---|---|---:|
| Financeiro | Notas sem financeiro | 159 |
| Produtos | Referências duplicadas | 2 grupos |
| Produtos | Descrições/NCM/origem duplicados | 8 grupos |
| Produtos | Vendidos sem entrada correspondente | 555 |
| Parceiros | CNPJ/CPF repetidos | 2 grupos |
| Fiscal | Classificação fiscal divergente | 0 |
| Custos | Produtos sem registro de custo | 0 |

Os quantitativos acima representam a situação observada na coleta de volumetria. Eles não significam, isoladamente, falha de execução: cada indicador deve ser interpretado junto do resultado da etapa correspondente e dos critérios do dashboard.

## Resultado técnico das etapas

| Etapas | Status | Resultado comprovado |
|---|---|---|
| 01 a 11 | Concluídas | Rotinas executadas com backups e IDs registrados no log. |
| 12 | Concluída | Tratamento isolado concluído; ID `RMD_RUPE_20260909090955021`; nenhuma empresa alterada. |
| 13 a 16 | Concluídas | Etapa 13 ajustou 1.448 TOPs; etapa 15 ajustou 443 produtos; etapa 16 preservou backup de 889 registros em TSICFG. |
| 17 | Concluída | ID `RMD_UNID_20260909091500000`; 1 backup; 1 descrição convertida para maiúsculas; 122 mapeamentos atualizados e 11 inválidos removidos. |
| 18 a 28 | Concluídas com observação | Rotinas executadas até o encerramento do script. A etapa 19 registrou erro na criação preventiva do backup, mas o ajuste principal foi concluído com 1 parceiro ajustado. |
| 29 | Concluída parcialmente | 45.046 registros de bairros normalizados; 429 grupos de colisão foram preservados para evitar exclusão indevida. |
| 30 | Concluída parcialmente | 646.157 registros de endereços normalizados; 6.962 grupos de colisão foram preservados para evitar exclusão indevida. |
| 29 e 30 — merge controlado | Concluídas | 437 bairros obsoletos e 7.302 endereços obsoletos mapeados; 18 dependências em TGFCPL respaldadas e atualizadas, incluindo CODBAIENTREGA e CODENDENTREGA. ID `MACALE_20260909_153000`. Validação final sem referências remanescentes e sem duplicidades normalizadas. |
| 31 | Ignorada por privilégio | 31 funções inválidas identificadas. O usuário FRANCISCO_JUNIOR não possui ALTER ANY PROCEDURE. Tratativa registrada no ticket #70636. |

## Execuções e rastreabilidade

| Rotina | ID de execução | Quantidade/resultado |
|---|---|---|
| TOPs de devolução | `RMD_TOPG_20260909084353011` | 1.448 registros alterados |
| Análise de giro 848 | `RMD_G848_20260909084354212` | Configuração atualizada |
| Produtos com rastro | `RMD_RAST_20260909084355073` | 443 registros alterados |
| Classificação ICMS | `CLASSICMS_20260909084627942` | 52 parceiros avaliados |
| Ajuste de nomes de parceiros | `AJNP_20260909084629866` | 27 backups e 27 alterações |
| Padronização de parceiros | `RMD_PAR_20260909084631629` | 86 registros |
| Bairros | `RMD_BAI_20260909084635985` | 45.046 registros; 429 colisões preservadas |
| Endereços | `RMD_END_20260909084643412` | 646.157 registros; 6.962 colisões preservadas |
| Merge bairros/endereços | `MACALE_20260909_153000` | Concluído com validação final |

## Objetos inválidos e encaminhamento

A etapa 31 foi registrada como **IGNORADO_SEM_PRIVILEGIO**. Os objetos inválidos identificados no schema SANKHYA são:

- `ACL_GET_ALIQPART`, `FSP_DATA_DIA_UTIL`, `FSP_RETURN_DATAS_UTEIS`, `F_OBTEMPRECO_DATA`, `F_OBTEM_SALDO_INDEN`
- `GET_CODPROD_REF`, `GET_INDICE_AJUSTE_NOTA`, `GET_PREVISAO_CREDITO_DEBITO`, `GET_PROXIMO_DIA_UTIL`, `QTDEVOLPADRAO`
- `QTDEVOLPADRAO2`, `SNK_GETCODPRODALT`, `SNK_GETDTBAIXABEM`, `SNK_GETMESESSEMPIS`, `SNK_GETPRODUTOAGRUPADOGIRO`
- `SNK_GETVLRREA`, `SNK_GET_CENTROCUSTO_EFD`, `SNK_GET_CFO_NOTA`, `SNK_GET_CODCFO`, `SNK_GET_CODIGO_PRODUTO`
- `SNK_GET_CONTACONTABIL_EFD`, `SNK_GET_CONTACONTABIL_IMOB_EFD`, `SNK_GET_CTACTB_CADASTROS_EFD`, `SNK_GET_ICMS_ESPECIAL_CAB`, `SNK_GET_INDITENS`
- `SNK_GET_NUNOTA`, `SNK_GET_SATUSCONFERENCIA`, `SNK_GET_ST_RECUPERAR`, `SNK_MATGIR_GET_MULTCPA`, `SNK_MATGIR_GET_QTDTOTALMULTCPA`, `SNK_PRECO`

Solicita-se a análise e recompilação/correção dessas funções pelo time responsável, incluindo a verificação de dependências e dos erros de compilação, conforme ticket [#70636](https://ajuda.sankhya.com.br/hc/pt-br/requests/706365).

## Artefatos da revisão

- [Pasta de entrega no Google Drive](https://drive.google.com/drive/folders/1xqDdSegbJ9wW73H7j6hhhAwLDtxlk0-D)
- [Precheck das etapas](file:///Users/spadarojr/Documents/Trabalho/Sankhya/Deploy%20Agent/Scripts-Deploy/7%20-%20QA2/Clientes/PRODUTOS%20MACALE%20LTDA/Precheck_Revisao_20260909.md)
- [Coleta de volumetria do relatório](file:///Users/spadarojr/Documents/Trabalho/Sankhya/Deploy%20Agent/Scripts-Deploy/7%20-%20QA2/Clientes/PRODUTOS%20MACALE%20LTDA/Coletar_Volumetria_Relatorio.sql)
- [Execução das etapas 13 a 31](file:///Users/spadarojr/Documents/Trabalho/Sankhya/Deploy%20Agent/Scripts-Deploy/7%20-%20QA2/Clientes/PRODUTOS%20MACALE%20LTDA/Executar_Etapas_13_31.sql)
- [Merge controlado de bairros e endereços](file:///Users/spadarojr/Documents/Trabalho/Sankhya/Deploy%20Agent/Scripts-Deploy/7%20-%20QA2/Clientes/PRODUTOS%20MACALE%20LTDA/Merge_Bairros_Enderecos_PRODUTOS_MACALE_LTDA.sql)
- [Log principal da revisão](file:///Users/spadarojr/Documents/Trabalho/Sankhya/Deploy%20Agent/Scripts-Deploy/7%20-%20QA2/Clientes/PRODUTOS%20MACALE%20LTDA/Logs/Revisao_Master_20260909_080135.log)
- [Log da continuação e validações](file:///Users/spadarojr/Documents/Trabalho/Sankhya/Deploy%20Agent/Scripts-Deploy/7%20-%20QA2/Clientes/PRODUTOS%20MACALE%20LTDA/Logs/Continuacao_13_31_20260909.log)

## Pontos de atenção

- As etapas 29 e 30 preservaram grupos de colisão e exigem acompanhamento funcional caso seja necessário decidir uma regra de unificação posterior.
- A etapa 19 deve ser revisitada para regularizar o backup preventivo antes de qualquer nova alteração relacionada.
- A etapa 31 depende do atendimento do ticket #70636 para recompilação e validação das funções inválidas.
- A pasta de entrega foi criada em `Revisões Deploy Agent/PRODUTOS MACALE LTDA`; os arquivos publicados receberam acesso de leitura para o domínio `sankhya.com.br`, sem listagem pública ou pesquisa por domínio.

## Consideração final

A revisão da base foi executada com rastreabilidade por IDs, preservação de backups e registro das exceções. As etapas 01 a 30 possuem resultado registrado, com conclusão parcial nas rotinas de bairros e endereços por causa das colisões preservadas. A etapa 31 permanece encaminhada para correção de privilégios e recompilação das funções inválidas.
