# RELATÓRIO TÉCNICO - REVISÃO MASTER DEPLOY

## VITRINI DIRETA (ACM BRASIL)

**Gerente de Projetos:** Gabriel Chaves — gabriel.chaves@sankhya.com.br

**Usuário da execução:** FRANCISCO_JUNIOR

**Data da revisão:** 19/09/2026

## Resumo executivo

Os artefatos finais registram as atividades 01 a 30 como concluídas. A verificação dos objetos nativos inválidos identificou 49 objetos, relacionados no ticket Sankhya Cloud `#711178` para análise e correção.

A padronização de bairros e a consolidação de referências obsoletas (Card 29), bem como a padronização de endereços e a consolidação de referências obsoletas (Card 30), foram concluídas com mapa, cópia de segurança, remapeamento e auditoria. O resultado final registrado foi `EXCECOES=0` e `REFERENCIAS_REMANESCENTES=0`. A verificação de notas sem financeiro (Card 09) foi concluída em etapa regular, com mapeamento direto por XML, 6 inserções auditadas, saldo elegível restante igual a zero e pós-validação OK.

O onboarding possui verificação Oracle em modo somente leitura concluída. A comparação documental está parcial, com pontos de conferência para a empresa adicional, produtos, contas bancárias e SMTP.

Em 19/09/2026, a volumetria foi atualizada diretamente na base, em modo somente leitura: 18.555 documentos/cabeçalhos, 63.636 itens, 35.868 registros financeiros, 2.346 produtos e 2.353 parceiros. Os quatro indicadores de integridade — financeiros sem nota, itens sem cabeçalho, cabeçalhos sem itens e códigos fiscais de cidades duplicados — retornaram zero.

## Resultado técnico das atividades

| Atividade | Propósito | Último status comprovado | Resultado, quantidade ou rastreabilidade |
|---|---|---|---|
| 01 | Preparar o controle dos objetos temporariamente alterados pela revisão. | Concluída | `RMD_CONTROLE_OBJETOS` criado; `ID_MASTER=RMD_RUN_20260918083819561`. |
| 02 | Liberar filtros dos portais conforme a regra aprovada. | Concluída | `ID_EXECUCAO=RMD_PORT_20260918083823041`; registros alterados: 0. |
| 03 | Padronizar parâmetros de DANFE entre empresas. | Concluída | `ID_EXECUCAO=RMD_DANF_20260918083824632`; registros alterados: 5. |
| 04 | Desativar o cálculo de custo na TOP de devolução conforme regra aprovada. | Concluída | `ID_EXECUCAO=RMD_TOPC_20260918083826130`; registros alterados: 135. |
| 05 | Habilitar o cálculo de giro dos produtos. | Concluída | `ID_EXECUCAO=RMD_GIRO_20260918083827939`; registros alterados: 11. |
| 06 | Zerar parcelas dos tipos de negociação elegíveis. | Concluída | `ID_EXECUCAO=RMD_PARC_20260918083829333`; registros alterados: 17. |
| 07 | Preencher a data de movimento dos documentos elegíveis. | Concluída | `ID_EXECUCAO=RMD_DTMV_20260918083831063`; registros alterados: 0. |
| 08 | Preencher protocolos de documentos legados. | Concluída | `ID_EXECUCAO=RMD_PROT_20260918083832686`; registros alterados: 0. |
| 09 | Liberar itens de documentos legados, preservando o estado da trigger. | Concluída | `ID_EXECUCAO=RMD_ITEM_20260918083834665`; itens alterados: 0; validação de reabilitação posterior sem pendências. |
| 10 | Habilitar ICMS gerencial nos produtos elegíveis. | Concluída | `ID_EXECUCAO=RMD_ICMG_20260918083836363`; registros alterados: 0. |
| 11 | Habilitar ruptura de produtos. | Concluída | `ID_EXECUCAO=RMD_RUPP_20260918083837479`; registros alterados: 1. |
| 12 | Habilitar ruptura de empresas elegíveis. | Concluída | `ID_EXECUCAO=RMD_RUPE_20260918083838138`; empresas alteradas: 0. |
| 13 | Configurar TOPs usados na análise de giro/GOL. | Concluída | `ID_EXECUCAO=RMD_TOPG_20260918083839503`; registros alterados: 1.402. |
| 14 | Configurar a análise de giro do relatório 848. | Concluída | `ID_EXECUCAO=RMD_G848_20260918083840812`; configuração `CODREL=848` atualizada: 1. |
| 15 | Desativar rastro de produtos sem controle. | Concluída | `ID_EXECUCAO=RMD_RAST_20260918083841772`; registros alterados: 19. |
| 16 | Higienizar `TSICFG` com registro completo para reversão. | Concluída | `ID_EXECUCAO=RMD_CFG_20260918083842780`; cópia de segurança: 860; exclusões: 46; atualizações: 104; inserções no modelo: 180; configuração final: 994. |
| 17 | Normalizar unidades e referências relacionadas. | Concluída | `ID_EXECUCAO=RMD_UNID_20260918084109473`; cópia de segurança: 0; descrições de `TGFVOL` convertidas para maiúsculas: 0; mapeamentos inválidos removidos: 22. |
| 18 | Ajustar preferências do Gerente On Line. | Concluída | `ID_EXECUCAO=RMD_GOL_20260918084120350`; alterações registradas em `TSIPAR=2`, `TGFCGM=5` e `TGFCMV=1`. |
| 19 | Ajustar parceiro matriz. | Concluída | `ID_EXECUCAO=RMD_MAT_20260918084121266`; parceiros ajustados: 3. |
| 20 | Atualizar configuração dos Cards do Deploy Agent. | Concluída | `ID_EXECUCAO=RMD_CARD_20260918084123253`; cards atualizados: 1. |
| 21 | Classificar ICMS dos parceiros elegíveis. | Concluída | Encerrada no log Master sem erro SQL não tratado; quantitativo específico não foi registrado no artefato final consultado. |
| 22 | Ajustar nomes de parceiros com cópia de segurança por execução. | Concluída | `ID_EXECUCAO=AJNP_20260918084128366`; cópias de segurança: 134; registros alterados: 134. |
| 23 | Validar e reabilitar objetos temporariamente desabilitados pela revisão. | Concluída | `OBJETOS_DA_REVISAO_PENDENTES=0`; nenhuma trigger permaneceu desabilitada no encerramento da validação. |
| 24 | Padronizar parceiros. | Concluída | `ID_EXECUCAO=RMD_PAR_20260918084132980`; registros alterados: 0. |
| 25 | Padronizar produtos. | Concluída | `ID_EXECUCAO=RMD_PRO_20260918084134795`; registros alterados: 0. |
| 26 | Padronizar tipos de título. | Concluída | `ID_EXECUCAO=RMD_TIT_20260918084136111`; registros alterados: 0. |
| 27 | Padronizar cidades. | Concluída | `ID_EXECUCAO=RMD_CID_20260918084137211`; registros alterados: 0. |
| 28 | Padronizar tipos de venda. | Concluída | `ID_EXECUCAO=RMD_TPV_20260918084138324`; registros alterados: 0. |
| 29 | Padronizar bairros e consolidar referências obsoletas. | Concluída — consolidação controlada final | `RMD_VDA_2930_20260918085910599`; mapa: 428 bairros; cópia de segurança: 848; exclusões finais: 428; exceções: 0; referências remanescentes: 0; colisões remanescentes: 0. |
| 30 | Padronizar endereços e consolidar referências obsoletas. | Concluída — consolidação controlada final | `RMD_VDA_2930_20260918085910599`; mapa: 7.283 endereços; cópia de segurança: 14.226; exclusões finais: 7.283; exceções: 0; referências remanescentes: 0; colisões remanescentes: 0. |
| 31 | Verificar objetos Oracle inválidos e encaminhar a tratativa externa. | Encaminhada ao Sankhya Cloud | 49 objetos inválidos relacionados no ticket `#711178`; a validação posterior ficará vinculada ao atendimento externo. |
| 32 — Notas sem Financeiro (Card 09) | Tratar notas sem financeiro somente após redução, mapa XML, auditoria e confirmação controlada. | Concluída | `VDA_ACM_FDUP_20260918_02`; mapa: 21 notas; aptos: 6; `SEM_VDUP_XML`: 15 preservadas; inserções auditadas: 6; aptos sem financeiro após validação: 0; duplicidades por `NUNOTA`: 0. |

O status final de 29/30 acima é o da consolidação controlada posterior, que substitui o estado intermediário do Master para fins deste relatório.

## Notas sem Financeiro (Card 09)

A verificação de notas sem financeiro (Card 09) foi tratada como etapa regular 32, com leitura direta de `TGFNFE.XML` por `XMLTABLE`. A função `FNC_BUSCA_TAG_XML_GERAL` não foi necessária.

| Item | Resultado comprovado |
|---|---:|
| Notas no mapa | 21 |
| Candidatos `APTO_PARA_VALIDACAO_FINAL` | 6 |
| Casos `SEM_VDUP_XML` preservados sem alteração | 15 |
| Financeiros inseridos | 6 |
| Linhas de auditoria persistente | 6 |
| `NUFIN` atribuídos | 35861 a 35866 |
| `TGFNUM.ULTCOD` após a execução | 35866 |
| Aptos sem financeiro após a pós-validação | 0 |
| Duplicidades por `NUNOTA` entre aptos | 0 |

Notas aptas tratadas: `2322`, `7392`, `8695`, `8700`, `8703` e `8761`.

O mapa, a classificação, a auditoria de inserção, a pós-validação e o roteiro de reversão permanecem preservados na pasta da base. A alteração efetiva ficou vinculada à auditoria `BKP_RMD_VDA_FDUP_20260918_02_INS`.

## Padronização de bairros e endereços (Cards 29 e 30)

| Card | Escopo | Mapa | Cópia de segurança | Resultado final |
|---|---|---:|---:|---|
| 29 | Bairros obsoletos | 428 | 848 | 428 pais excluídos; `EXCECOES=0`; referências remanescentes: 0; grupos de colisão remanescentes: 0. |
| 30 | Endereços obsoletos | 7.283 | 14.226 | 7.283 pais excluídos; `EXCECOES=0`; referências remanescentes: 0; grupos de colisão remanescentes: 0. |

O roteiro de reversão autocontido está associado ao ID `RMD_VDA_2930_20260918085910599`.

## Cards de volumetria e orientação aos consultores

Os quantitativos abaixo são apresentados quando comprovados nos artefatos finais da base. Para os indicadores sem quantitativo consolidado neste documento, mantém-se a descrição do indicador e sua finalidade para a conferência dos consultores.

| Card | Indicador | Propósito e interpretação padrão | Último resultado comprovado |
|---:|---|---|---|
| 01 | Financeiro | Mostra títulos extraídos dos artefatos disponibilizados. Não representa necessariamente folha ou despesas sem XML/EFD; complementações legadas devem ser avaliadas no Cadastro da Posição Financeira. | 35.868 registros financeiros; 31.512 a receber e 4.356 a pagar. |
| 02 | Entradas e Saídas | Apresenta visão analítica por TOP para validação com o cliente; a associação de TOP pode ser imprecisa em determinados cenários. | 18.555 documentos/cabeçalhos processados. |
| 03 | Produtos por Usoprod | Agrupa produtos e serviços pelo tipo de uso; a classificação deve ser validada com o cliente. | 2.346 produtos cadastrados. |
| 04 | Produtos por Grupo | Apresenta grupos enviados no onboarding; o cadastro depende de importação manual elegível e a associação dos produtos fica para o refinamento. | 2.346 produtos cadastrados considerados na distribuição por grupo. |
| 05 | Referências Duplicadas | Separa itens com a mesma referência para tratamento posterior, pois a duplicidade pode ser regra de negócio, obsolescência ou equivalência. | 348 referências duplicadas, envolvendo 700 produtos. |
| 06 | Descrições Duplicadas | Aplica a análise de duplicidade às descrições e critérios complementares, sem presumir que todo grupo seja erro cadastral. | 276 grupos de descrições duplicadas, envolvendo 671 produtos. |
| 07 | CNPJ/CPF Repetidos | Relaciona parceiros com o mesmo documento e variações cadastrais; exige validação funcional antes de unificação. | 0 grupos e 0 parceiros envolvidos. |
| 08 | Financeiros sem Nota | Relaciona financeiros sem cabeçalho associado. Resultado esperado: zero; valor acima de zero exige análise de incompletude. | 0. |
| 09 | Notas sem Financeiro | Diagnostica notas com TOP que atualiza financeiro sem linha correspondente na `TGFFIN`; exige separação entre aptos XML, casos sem `<Dup>` e XML incompleto. | 15 na consulta atual; 21 no mapa, 6 aptos tratados, 15 `SEM_VDUP_XML` (sem `<Dup>` válido), 6 inseridos, saldo apto: 0. |
| 10 | Produtos Vendidos | Mostra itens com saída e sem entrada associada; pode apontar duplicidade ou equivalência sem chave confiável. | 517 produtos vendidos sem registro de entrada. |
| 11 | Produtos com Custo Zero | Mostra itens com linha em `TGFCUS` e valor zerado; o tratamento depende da rotina de atualização de custos aplicável. | 2.161 produtos. |
| 12 | Produtos sem Custo | Mostra itens sem qualquer linha em `TGFCUS`; itens sem movimentação em `TGFITE` não são tratados pela rotina nativa de custos. | 0 produtos. |
| 13 | Itens sem Cabeçalho | Relaciona `TGFITE` sem cabeçalho correspondente. Resultado esperado: zero; valor acima de zero exige análise de integridade. | 0. |
| 14 | Cabeçalho sem Itens | Relaciona `TGFCAB` sem item em `TGFITE`. Resultado esperado: zero; valor acima de zero exige análise de integridade. | 0. |
| 15 | Cidades Duplicadas | Relaciona possíveis duplicações em cidades. Resultado esperado: zero; valor acima de zero exige análise cadastral. | 0 códigos fiscais duplicados. |
| 16 | Classificação Fiscal | Relaciona parceiros cuja classificação fiscal atual pode divergir; deve considerar completude cadastral e inscrição estadual. | 0 divergências. |
| 17 | Itens sem Tabela de Preço | Relaciona itens sem gravação de tabela por falta de saída elegível; requer avaliação no refinamento. | 15 produtos. |
| 18 | Itens com Descrições Similares | Lista pares de descrições com similaridade superior a 85% para tratamento posterior, sem concluir duplicidade automaticamente. | 1.652 pares identificados. |
| 19 | CNPJ Matrizes | Agrupa pessoas jurídicas pelo radical de oito dígitos e define o menor código como matriz para associação. | 15 matrizes. |
| 20 | Produtos Comprados | Apresenta o inverso de Produtos Vendidos: entrada sem saída, o que pode ser coerente para matéria-prima e uso/consumo. | 1.614 produtos comprados sem registro de saída. |
| 21 | Regras Tributárias Inseridas | Compila regras tributárias inseridas pelo Deploy Agent, incluindo ICMS, PIS, COFINS, IPI e ISS. | 23.030 regras. |
| 29 — Colisões de Bairros | Apoia a análise de bairros normalizados e a decisão sobre colisões; exclusões só devem ocorrer com mapa, referências e reversão. | `CONCLUIDO_COM_MAPA_BACKUP_FK`; mapa 428; cópia de segurança 848; exceções 0; referências remanescentes 0. |
| 30 — Colisões de Endereços | Apoia a análise de endereços normalizados e a decisão sobre colisões; exclusões só devem ocorrer com mapa, referências e reversão. | `CONCLUIDO_COM_MAPA_BACKUP_FK`; mapa 7.283; cópia de segurança 14.226; exceções 0; referências remanescentes 0. |

### Verificação final dos indicadores de integridade

A consulta direta de 19/09/2026 confirmou resultado zero nos quatro indicadores de integridade: Financeiros sem Nota, Itens sem Cabeçalho, Cabeçalho sem Itens e Cidades Duplicadas. A verificação quantitativa necessária para a preparação do PDF está concluída.

## Objetos inválidos e ticket relacionado

A verificação de objetos Oracle inválidos identificou 49 funções nativas no schema `SANKHYA`, relacionadas para tratamento no ticket Sankhya Cloud `#711178`.

Ticket Sankhya Cloud: `#711178`, status `ABERTO`, organização `ACM BRASIL-81357`, prioridade `Normal`, categoria `Cloud/SaaS → Solicitação Cloud → Personalizar Objeto de Banco de Dados`, ambiente `Produção`, banco `Oracle`. O registro do ticket está em `Ticket_Sankhya_Cloud_Objetos_Invalidos_VITRINI_DIRETA_ACM_BRASIL.md`.

Objetos inválidos, um por linha:

- `ACL_GET_ALIQPART`
- `FSP_DATA_DIA_UTIL`
- `FSP_RETURN_DATAS_UTEIS`
- `FTIM_EXECUTAR`
- `F_OBTEMPRECO_DATA`
- `F_OBTEM_SALDO_INDENIZ`
- `F_WMS_GETESTOQUEDOCA_PARC`
- `GET_CODPROD_REF`
- `GET_INDICE_AJUSTE_NOTA`
- `GET_PREVISAO_CREDITO_DEBITO`
- `GET_PROXIMO_DIA_UTIL`
- `QTDEVOLPADRAO`
- `QTDEVOLPADRAO2`
- `RECEBIMENTO_M3_TOTAL`
- `RECEBIMENTO_PESO_TOTAL`
- `SNK_GETCODPRODALT`
- `SNK_GETDTBAIXABEM`
- `SNK_GETMESESSEMPIS`
- `SNK_GETPRODUTOAGRUPADOGIRO`
- `SNK_GETSOMAPARTILHA2`
- `SNK_GETSOMAVLRTGFDIN`
- `SNK_GETVLRREA`
- `SNK_GETVLRTGFDIN`
- `SNK_GET_CENTROCUSTO_EFD`
- `SNK_GET_CFO_NOTA`
- `SNK_GET_CODCFO`
- `SNK_GET_CODIGO_PRODUTO`
- `SNK_GET_COD_LEGAL`
- `SNK_GET_CONTACONTABIL_EFD`
- `SNK_GET_CONTACONTABIL_IMOB_EFD`
- `SNK_GET_CTACTB_CADASTROS_EFD`
- `SNK_GET_DENTRO_FORA_ESTADO`
- `SNK_GET_ICMS_ESPECIAL_CAB`
- `SNK_GET_INDITENS`
- `SNK_GET_NUNOTA`
- `SNK_GET_SATUSCONFERENCIA`
- `SNK_GET_ST_RECUPERAR`
- `SNK_GET_VLRITENS`
- `SNK_GET_VLRTOT_SERVICO`
- `SNK_MATGIR_GET_MULTCPA`
- `SNK_MATGIR_GET_QTDTOTALMULTCPA`
- `SNK_PRECO`
- `TIM_ASSINAFIADOR`
- `TIM_ASSINAINQUILINO`
- `TIM_ASSINALOCADOR`
- `TIM_MONTAFIADOR`
- `TIM_MONTAFORMAREPASSE`
- `TIM_MONTAINQUILINO`
- `TIM_MONTAPROPRIETARIOS`

## Onboarding — verificação Oracle e comparação documental

| Componente | Estado comprovado |
|---|---|
| Verificação Oracle | Concluída em modo somente leitura, sem erro `ORA-`, `PLS-` ou `SP2-` no registro final. |
| Empresas em `TSIEMP` | 6 linhas retornadas; a razão social exata informada retornou 0 linhas. |
| SMTP global em `TSIPAR` | 1 linha; credenciais não exibidas. |
| SMTP por empresa | 6 linhas; credenciais não exibidas. |
| Contas em `TSICTA` | 5 linhas. |
| Usuários em `TSIUSU` | 24 linhas; 15 e-mails de negócio correspondentes e 1 usuário adicional preservado como observação. |
| Vendedores em `TGFVEN` | 3 linhas. |
| Grupos em `TGFGRU` | 3 linhas. |
| Centros de resultado em `TSICUS` | 1 linha. |
| Naturezas em `TGFNAT` | 209 linhas. |
| Locais de estoque em `TGFLOC` | 1 linha. |
| Comparação documental | Parcial, com pontos de conferência. |

Fontes documentais consultadas: etapas 01, 04, 05, 07, 08, 10 e 11 do onboarding. O resumo documental lista 7 empresas, enquanto o Oracle retornou 6; o CNPJ `25.300.362/0002-00` permanece para confirmação. A comparação detalhada com `TGFPRO`, o confronto de `TSICTA` com a planilha bancária e o confronto do PDF de SMTP permanecem pendentes. Certificados digitais não foram lidos.

## Inventário resumido de objetos e artefatos persistidos

| Objeto ou artefato | Propósito |
|---|---|
| `RMD_CONTROLE_OBJETOS` | Registrar estado anterior, estado posterior e reabilitação dos objetos temporariamente desabilitados. |
| `BKP_RMD_*` por atividade | Preservar valores anteriores e permitir reversão por execução. |
| `BKP_RMD_TSICFG` | Registro completo da configuração de `TSICFG`; 860 linhas na execução. |
| `RMD_REF_TSICFG_MODELO` | Armazenar o modelo de configuração usado na higienização de `TSICFG`. |
| `BKP_RMD_VDA_FDUP_20260918_02` | Mapa persistente de Notas sem Financeiro (Card 09); 21 notas. |
| `BKP_RMD_VDA_FDUP_20260918_02_PPG` | Mapa de classificação dos candidatos de Notas sem Financeiro (Card 09). |
| `BKP_RMD_VDA_FDUP_20260918_02_INS` | Auditoria persistente das 6 inserções financeiras de Notas sem Financeiro (Card 09). |
| Mapas e cópias de segurança da execução `RMD_VDA_2930_20260918085910599` | Sustentar o remapeamento e a reversão da Padronização de bairros (Card 29) e da Padronização de endereços (Card 30); 428 bairros e 7.283 endereços no mapa, com cópias de segurança de 848 e 14.226 linhas. |
| `Artefatos_Revisao/Rollback/` | Roteiros de reversão separados por etapa e pelos tratamentos controlados posteriores. |

## Índice de reversão

| Código | Atividade ou card | Artefato de reversão ou controle |
|---:|---|---|
| 01 | Controle das alterações temporárias | `RMD_CONTROLE_OBJETOS`; não há roteiro SQL de reversão separado identificado. |
| 02 | Liberação de filtros dos portais | `Artefatos_Revisao/Rollback/Reverter_02_Liberar_Filtros_Portais.sql` |
| 03 | Padronização de parâmetros de DANFE | `Artefatos_Revisao/Rollback/Reverter_03_Padronizar_DANFE_Empresas.sql` |
| 04 | Desativação de custo na TOP de devolução | `Artefatos_Revisao/Rollback/Reverter_04_Desativar_Custo_TOP_Devolucao.sql` |
| 05 | Habilitação do cálculo de giro dos produtos | `Artefatos_Revisao/Rollback/Reverter_05_Habilitar_Calculo_Giro_Produtos.sql` |
| 06 | Zeração de parcelas dos tipos de negociação | `Artefatos_Revisao/Rollback/Reverter_06_Zerar_Parcelas_Tipos_Negociacao.sql` |
| 07 | Preenchimento da data de movimento | `Artefatos_Revisao/Rollback/Reverter_07_Preencher_Data_Movimento.sql` |
| 08 | Preenchimento de protocolos de documentos legados | `Artefatos_Revisao/Rollback/Reverter_08_Preencher_Protocolos_Documentos_Legados.sql` |
| 09 | Liberação de itens de documentos legados | `Artefatos_Revisao/Rollback/Reverter_09_Liberar_Itens_Documentos_Legados.sql` |
| 10 | Habilitação do ICMS gerencial | `Artefatos_Revisao/Rollback/Reverter_10_Habilitar_ICMS_Gerencial.sql` |
| 11 | Habilitação de ruptura de produtos | `Artefatos_Revisao/Rollback/Reverter_11_Habilitar_Ruptura_Produtos.sql` |
| 12 | Habilitação de ruptura de empresas | `Artefatos_Revisao/Rollback/Reverter_12_Habilitar_Ruptura_Empresas.sql` |
| 13 | Configuração de TOPs para giro/GOL | `Artefatos_Revisao/Rollback/Reverter_13_Configurar_TOPs_Giro_GOL.sql` |
| 14 | Configuração da análise de giro do relatório 848 | `Artefatos_Revisao/Rollback/Reverter_14_Configurar_Analise_Giro_848.sql` |
| 15 | Desativação de rastro de produtos sem controle | `Artefatos_Revisao/Rollback/Reverter_15_Desativar_Rastro_Sem_Controle.sql` |
| 16 | Higienização de `TSICFG` | `Artefatos_Revisao/Rollback/Reverter_16_Aplicar_Higienizacao_TSICFG.sql` |
| 17 | Normalização de unidades e referências | `Artefatos_Revisao/Rollback/Reverter_17_Normalizacao_Unidades.sql` |
| 18 | Ajuste de preferências do Gerente On Line | `Artefatos_Revisao/Rollback/Reverter_18_Preferencias_GOL.sql` |
| 19 | Ajuste do parceiro matriz | `Artefatos_Revisao/Rollback/Reverter_19_Parceiro_Matriz.sql` |
| 20 | Atualização da configuração dos Cards do Deploy Agent | `Artefatos_Revisao/Rollback/Reverter_20_Cards_Deploy.sql` |
| 21 | Classificação de ICMS dos parceiros | `Artefatos_Revisao/Rollback/Reverter_21_Classificacao_ICMS_Parceiros.sql` |
| 22 | Ajuste de nomes de parceiros | `Artefatos_Revisao/Rollback/Reverter_22_Ajuste_Nomes_Parceiros.sql` |
| 23 | Validação e reabilitação de objetos temporários | Validação de reabilitação registrada; não há roteiro SQL de reversão separado identificado. |
| 24 | Padronização de parceiros | `Artefatos_Revisao/Rollback/Reverter_24_Padronizacao_Parceiros.sql` |
| 25 | Padronização de produtos | `Artefatos_Revisao/Rollback/Reverter_25_Padronizacao_Produtos.sql` |
| 26 | Padronização de tipos de título | `Artefatos_Revisao/Rollback/Reverter_26_Padronizacao_Tipos_Titulo.sql` |
| 27 | Padronização de cidades | `Artefatos_Revisao/Rollback/Reverter_27_Padronizacao_Cidades.sql` |
| 28 | Padronização de tipos de venda | `Artefatos_Revisao/Rollback/Reverter_28_Padronizacao_Tipos_Venda.sql` |
| 29 — Colisões de Bairros | Padronização de bairros e consolidação de referências | `Artefatos_Revisao/Rollback/Reverter_29_30_Merge_Antifragil_RMD_VDA_2930_20260918085910599.sql` |
| 30 — Colisões de Endereços | Padronização de endereços e consolidação de referências | `Artefatos_Revisao/Rollback/Reverter_29_30_Merge_Antifragil_RMD_VDA_2930_20260918085910599.sql` |
| 31 | Verificação de objetos Oracle inválidos | Encaminhamento no ticket Sankhya Cloud `#711178`; sem reversão aplicável no banco. |
| 32 — Notas sem Financeiro (Card 09) | Inclusão controlada do financeiro em notas elegíveis | `32C_Card09_Rollback_VITRINI_DIRETA_ACM_BRASIL.sql`, com índice complementar em `Artefatos_Revisao/Rollback/Reverter_32B_Insert_Direto_Financeiro_DUP.sql` |

## Pendências e pontos de atenção

- O atendimento do ticket Sankhya Cloud `#711178` permanece como referência para a validação posterior dos 49 objetos inválidos.
- A comparação documental do onboarding permanece parcial: confirmar o CNPJ `25.300.362/0002-00`, comparar produtos com `TGFPRO`, confrontar contas bancárias com `TSICTA` e concluir a conferência documental de SMTP sem expor credenciais.

## Fontes finais consultadas

- `Dados_Revisao.json`
- `Volumetria_Consulta_Direta_20260919_R01.json`
- `Volumetria_Cards_17_20_ReadOnly.sql`
- `7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml`
- Registro da verificação preliminar: `Relatorio_Status_Preflight_VITRINI_DIRETA_ACM_BRASIL.md`
- `Logs/Revisao_Master_20260918_080832.log`
- Log da verificação preliminar: `Logs/Preflight_RMD_VDA_20260918080832.log`
- `Logs/29_30_Merge_Antifragil_RMD_VDA_20260918080832.log`
- `Logs/Card09_PosValidacao_Detalhe_VDA_20260918_02_FINAL.log`
- `Card09_Execucao_VDA_20260918_02.md`
- `Onboarding_Comparacao_ReadOnly_VITRINI_DIRETA_ACM_BRASIL.md`
- `Ticket_Sankhya_Cloud_Objetos_Invalidos_VITRINI_DIRETA_ACM_BRASIL.md`
- Roteiros de reversão: `Artefatos_Revisao/Rollback/`

## Consideração final

A revisão Master Deploy da base VITRINI DIRETA (ACM BRASIL) possui as atividades 01 a 30 concluídas com rastreabilidade por IDs e artefatos de cópia de segurança e reversão. A verificação de objetos Oracle inválidos identificou 49 objetos, relacionados no ticket Sankhya Cloud `#711178`. A padronização de bairros (Card 29) e a padronização de endereços (Card 30) foram encerradas sem exceções ou referências remanescentes, e a verificação de Notas sem Financeiro (Card 09) foi encerrada para os 6 candidatos aptos, com auditoria e pós-validação OK. O onboarding possui verificação Oracle concluída e comparação documental parcial. Este documento é o primeiro artefato textual e aguarda revisão; não foi gerado PDF.
