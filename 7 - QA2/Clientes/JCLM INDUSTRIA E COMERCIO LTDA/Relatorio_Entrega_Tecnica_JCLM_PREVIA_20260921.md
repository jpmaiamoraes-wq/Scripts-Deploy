**Usuário da execução:** FRANCISCO_JUNIOR

**Data da revisão:** 21/09/2026

---

# RELATÓRIO TÉCNICO — REVISÃO MASTER DEPLOY

## JCLM INDUSTRIA E COMERCIO LTDA

## Resumo executivo

As atividades aplicáveis da revisão Master Deploy foram executadas e validadas com preservação de cópias de segurança, mapas de auditoria e artefatos de reversão. A padronização de bairros e endereços foi concluída com validação posterior; a verificação de objetos nativos inválidos foi encaminhada ao Sankhya Cloud.

A análise de notas sem financeiro (Card 09) identificou 2 ocorrências. As duas são do tipo **V — Venda**, foram classificadas como `SEM_VDUP_XML` e não passaram para `APTO_PARA_VALIDACAO_FINAL`. Não houve inclusão em `TGFFIN`.

A verificação do onboarding foi concluída em modo somente leitura. Foram registradas divergências documentais e cadastrais para conferência, sem alteração na base.

A volumetria direta atual retornou 68.403 cabeçalhos, 318.639 itens, 54.645 registros financeiros, 5.564 produtos e 2.205 parceiros. Os quatro indicadores estruturais obrigatórios retornaram zero. As 2 notas sem financeiro permanecem registradas como pendência controlada do Card 09, sem inserção automática; o relatório final registra essa condição para acompanhamento.

## Resultado técnico das atividades

| Atividade | Propósito | Último estado comprovado | Resultado, quantidade ou rastreabilidade |
|---|---|---|---|
| 01 | Preparar o controle dos objetos temporariamente alterados pela revisão. | Concluída | `RMD_CONTROLE_OBJETOS` validado com 3 registros de controle. |
| 02 | Liberar filtros dos portais conforme a regra aprovada. | Concluída | `BKP_RMD_01_TSIPAR`; cópia de segurança e alterações: 4 registros. |
| 03 | Padronizar parâmetros de DANFE entre empresas. | Concluída e pós-validada | `BKP_RMD_02_TGFEMP`; 5 registros preservados e tratados. |
| 04 | Desativar o cálculo de custo na TOP de devolução. | Concluída | Registros alterados: 136. |
| 05 | Habilitar o cálculo de giro dos produtos. | Concluída | Registros alterados: 161. |
| 06 | Zerar parcelas dos tipos de negociação elegíveis. | Concluída | Registros alterados: 17. |
| 07 | Preencher a data de movimento dos documentos elegíveis. | Concluída | Registros alterados: 0. |
| 08 | Preencher protocolos de documentos legados. | Concluída | Registros alterados: 0. |
| 09 | Liberar itens de documentos legados, preservando o estado das triggers. | Concluída | Registros alterados: 0; 2 triggers `TGFITE` habilitadas na validação final. |
| 10 | Habilitar ICMS gerencial nos produtos elegíveis. | Concluída | Registros alterados: 3. |
| 11 | Habilitar ruptura de produtos. | Concluída | Registros alterados: 4. |
| 12 | Habilitar ruptura de empresas elegíveis. | Concluída e pós-validada | Registros alterados: 0; backup `BKP_RMD_11_TGFEMP` sem registros alvo. |
| 13 | Configurar TOPs usados na análise de giro/GOL. | Concluída e pós-validada | `BKP_RMD_12_TGFTOP`; 1.434 registros tratados. |
| 14 | Configurar a análise de giro do relatório 848. | Concluída e pós-validada | `BKP_RMD_13_TSIIMP`; 1 backup e 1 atualização em `CODREL=848`. |
| 15 | Desativar rastro de produtos sem controle. | Concluída e pós-validada | `BKP_RMD_14_TGFPRO`; 230 registros preservados e tratados. |
| 16 | Higienizar `TSICFG` preservando a configuração anterior. | Concluída e pós-validada | `BKP_RMD_TSICFG` com 876 registros; execução registrada com 349 alterações. |
| 17 | Normalizar unidades e referências relacionadas. | Concluída e pós-validada | `RMD_MAP_UNIDADES=110`, `BKP_RMD_UNID_MAP=110` e backup de `TGFVOL=0`. |
| 18 | Ajustar preferências do Gerente On Line e preparar cópias de segurança para as etapas seguintes. | Concluída | Backups `BKP_RMD_GOL_TSIPAR`, `BKP_RMD_GOL_TGFCGM`, `BKP_RMD_GOL_TGFCMV`, `BKP_RMD_PAR_MATRIZ`, `BKP_RMD_CARD_TTKINDAGT` e backups de padronização preservados. |
| 19 | Ajustar o parceiro matriz. | Concluída | Parceiros ajustados: 1. |
| 20 | Atualizar a configuração dos Cards do Deploy Agent. | Concluída | Cards atualizados: 1. |
| 21 | Classificar ICMS dos parceiros elegíveis. | Concluída | Parceiros classificados: 24. |
| 22 | Ajustar nomes de parceiros com cópia de segurança. | Concluída | Backups: 19; registros alterados: 19. |
| 23 | Validar e reabilitar objetos temporariamente desabilitados. | Concluída | `OBJETOS_DA_REVISAO_PENDENTES=0`; nenhuma pendência de reabilitação permaneceu. |
| 24 | Padronizar parceiros. | Concluída | Registros tratados: 160. |
| 25 | Padronizar produtos. | Concluída | Registros tratados: 0. |
| 26 | Padronizar tipos de título. | Concluída | Registros tratados: 0. |
| 27 | Padronizar cidades. | Concluída | Registros tratados: 0. |
| 28 | Padronizar tipos de venda. | Concluída | Registros tratados: 0. |
| 29 | Padronizar bairros e consolidar referências obsoletas. | Concluída — consolidação controlada final | Mapa de 422 bairros; cópia de segurança de 835 linhas; exceções: 0. |
| 30 | Padronizar endereços e consolidar referências obsoletas. | Concluída — consolidação controlada final | Mapa de 7.096 endereços; cópia de segurança de 13.894 linhas; exceções: 0. |
| 31 | Verificar objetos Oracle inválidos e encaminhar a tratativa externa. | Encaminhada ao Sankhya Cloud | 50 objetos inválidos; ausência de `ALTER ANY PROCEDURE`; ticket `711447` aberto. |

## Notas sem Financeiro (Card 09)

A consulta identificou duas notas de venda sem registro correspondente na `TGFFIN`. O tratamento foi mantido separado da alteração financeira porque o XML não apresentou elemento `<Dup>` válido para validação automática.

| Estado técnico | Quantidade | Interpretação |
|---|---:|---|
| `BASE_TOTAL` / ocorrências identificadas | 2 | Resultado amplo do diagnóstico. |
| `APTO_PARA_VALIDACAO_FINAL` | 0 | Nenhuma ocorrência passou pelos critérios para alteração. |
| `SEM_VDUP_XML` | 2 | Preservadas sem alteração por ausência de `<Dup>` válido no XML. |
| Inserções efetivadas em `TGFFIN` | 0 | Nenhum financeiro foi incluído. |
| `TGFFIN_NUNOTA_MAPA` | 0 | Nenhuma nota do mapa possui financeiro inserido por esta etapa. |

As duas ocorrências são do movimento **V — Venda**. O mapa `BKP_RMD_JCLM_FDUP_20260919`, o mapa de classificação `BKP_RMD_JCLM_FDUP_20260919_PPG` e o roteiro `32C_Card09_Rollback_Notas_Sem_Financeiro_DUP.sql` permanecem preservados.

---

## Padronização de bairros e endereços (Cards 29 e 30)

| Card | Escopo | Mapa | Cópia de segurança | Estado final validado |
|---|---|---:|---:|---|
| 29 | Bairros obsoletos e referências relacionadas | 422 bairros | 835 linhas | 0 exceções; 0 bairros aguardando exclusão; dependências atualizadas dentro do mapa compartilhado. |
| 30 | Endereços obsoletos e referências relacionadas | 7.096 endereços | 13.894 linhas | 0 exceções; 0 endereços aguardando exclusão; dependências atualizadas dentro do mapa compartilhado. |

O mapa compartilhado totaliza 7.518 registros, sendo 422 bairros e 7.096 endereços. Foram registradas 59.340 dependências atualizadas. A validação final confirmou `delete_tsibai_rowcount=0` e `delete_tsiend_rowcount=0` na última etapa, sem pais aguardando exclusão. O roteiro autocontido `29_30_Merge_Antifragil_JCLM_Rollback.sql` permanece preservado.

## Cards de volumetria e orientação aos consultores

Os quantitativos abaixo foram obtidos em consultas somente leitura na base Oracle em 21/09/2026. A tabela apresenta o resultado atual e a interpretação operacional de cada indicador; ela substitui um resumo limitado apenas aos totais gerais.

| Card | Indicador | Propósito e interpretação | Último resultado comprovado |
|---:|---|---|---:|
| 01 | Financeiro | Apresenta os títulos financeiros existentes para conferência da posição financeira. | 54.645 registros; 50.084 a receber e 4.561 a pagar. |
| 02 | Entradas e Saídas | Apresenta a movimentação documental para validação do histórico de entradas e saídas. | 68.403 cabeçalhos e 318.639 itens. |
| 03 | Produtos por uso | Mostra o universo de produtos cadastrados para conferência de classificação de uso. | 5.564 produtos cadastrados. |
| 04 | Produtos por grupo | Apoia a conferência dos grupos de produtos; o detalhamento por grupo não foi exposto na consulta principal. | Universo cadastral: 5.564 produtos. |
| 05 | Referências duplicadas | Relaciona referências associadas a mais de um produto; a duplicidade exige validação funcional antes de unificação. | 5 referências, envolvendo 10 produtos. |
| 06 | Descrições duplicadas | Relaciona descrições duplicadas considerando critérios complementares; não presume erro cadastral. | 135 descrições, envolvendo 278 produtos. |
| 07 | CNPJ/CPF repetidos | Relaciona grupos de parceiros com o mesmo documento para conferência cadastral. | 1 grupo, envolvendo 2 parceiros. |
| 08 | Financeiros sem Nota | Identifica registros em `TGFFIN` sem cabeçalho correspondente; resultado acima de zero exige análise de integridade. | 0. |
| 09 | Notas sem Financeiro | Diagnostica notas com TOP que atualiza financeiro sem linha correspondente em `TGFFIN`; separa aptos de `SEM_VDUP_XML`. | 2 ocorrências; 0 aptos; 2 `SEM_VDUP_XML`; 0 inserções. |
| 10 | Produtos vendidos sem entrada | Relaciona produtos com saída identificada e sem entrada correspondente; pode exigir validação de equivalência ou duplicidade. | 659 produtos. |
| 11 | Produtos com custo zero | Mostra produtos de revenda/venda com custo médio sem ICMS igual a zero. | 1.604 produtos. |
| 12 | Produtos sem custo | Mostra produtos de revenda/venda sem registro em `TGFCUS`. | 0 produtos. |
| 13 | Itens sem Cabeçalho | Relaciona itens de `TGFITE` sem cabeçalho em `TGFCAB`; resultado esperado: zero. | 0. |
| 14 | Cabeçalho sem Itens | Relaciona notas de `TGFCAB` sem itens em `TGFITE`; resultado esperado: zero. | 0. |
| 15 | Cidades Duplicadas | Relaciona códigos fiscais vinculados a mais de uma cidade; resultado esperado: zero. | 0 códigos fiscais duplicados. |
| 16 | Classificação Fiscal | Relaciona divergências de classificação fiscal dos parceiros em relação ao critério esperado. | 0 divergências. |
| 17 | Itens sem Tabela de Preço | Relaciona produtos vendidos sem registro correspondente em `TGFEXC`; requer avaliação no refinamento. | 291 produtos. |
| 18 | Itens com Descrição Similar | Lista pares de produtos com similaridade de descrição superior a 85%; não conclui duplicidade automaticamente. | 198 pares. |
| 19 | CNPJ Matrizes | Agrupa pessoas jurídicas por raiz de CNPJ e identifica matrizes com filiais. | 42 matrizes. |
| 20 | Produtos Comprados sem Saída | Apresenta produtos com entrada e sem saída correspondente; pode ser coerente para matéria-prima, uso e consumo. | 4.204 produtos. |
| 21 | Regras Tributárias | Compila o universo de regras tributárias persistidas em `TTKPITI` para conferência fiscal. | 48.623 regras. |
| 29 | Colisões de Bairros | Apoia a análise de bairros normalizados e a decisão sobre referências obsoletas, sempre com mapa e reversão. | Mapa: 422; backup: 835; exceções: 0. |
| 30 | Colisões de Endereços | Apoia a análise de endereços normalizados e a decisão sobre referências obsoletas, sempre com mapa e reversão. | Mapa: 7.096; backup: 13.894; exceções: 0. |

### Verificação final dos indicadores de integridade

| Indicador obrigatório | Resultado | Situação |
|---|---:|---|
| Financeiros sem nota | 0 | Conforme |
| Itens sem cabeçalho | 0 | Conforme |
| Cabeçalhos sem itens | 0 | Conforme |
| Códigos fiscais de cidades duplicados | 0 | Conforme |
| Notas sem financeiro | 2 | **Pendência controlada do Card 09; sem inserção automática** |

## Objetos inválidos e ticket relacionado

Foram identificados 50 objetos nativos Oracle com `STATUS=INVALID` no schema `SANKHYA`. A conexão `FRANCISCO_JUNIOR` não possui o privilégio `ALTER ANY PROCEDURE`; nenhuma recompilação foi realizada.

O ticket Sankhya Cloud **711447** está aberto para a organização **JCLM INDUSTRIA E COMERCIO LTDA**, com prioridade Normal, categoria `Cloud/SaaS → Solicitação Cloud → Personalizar Objeto de Banco de Dados`, ambiente Produção e banco Oracle. Não foram anexados logs, credenciais ou outros artefatos internos.

Objetos inválidos identificados:

`ACL_GET_ALIQPART`, `FSP_DATA_DIA_UTIL`, `FSP_RETURN_DATAS_UTEIS`, `FTIM_EXECUTAR`, `F_OBTEMPRECO_DATA`, `F_OBTEM_SALDO_INDEN`, `F_WMS_GETESTOQUEDOCA_PARC`, `GET_CODPROD_REF`, `GET_INDICE_AJUSTE_NOTA`, `GET_PREVISAO_CREDITO_DEBITO`, `GET_PROXIMO_DIA_UTIL`, `QTDEVOLPADRAO`, `QTDEVOLPADRAO2`, `RECEBIMENTO_M3_TOTAL`, `RECEBIMENTO_PESO_TOTAL`, `SNK_GETCODPRODALT`, `SNK_GETDTBAIXABEM`, `SNK_GETMESESSEMPIS`, `SNK_GETPRODUTOAGRUPADOGIRO`, `SNK_GETSOMAPARTILHA2`, `SNK_GETSOMAVLRTGFDIN`, `SNK_GETVLRREA`, `SNK_GETVLRTGFDIN`, `SNK_GET_CENTROCUSTO_EFD`, `SNK_GET_CFO_NOTA`, `SNK_GET_CODCFO`, `SNK_GET_CODIGO_PRODUTO`, `SNK_GET_COD_LEGAL`, `SNK_GET_CONTACONTABIL_EFD`, `SNK_GET_CONTACONTABIL_IMOB_EFD`, `SNK_GET_CTACTB_CADASTROS_EFD`, `SNK_GET_DENTRO_FORA_ESTADO`, `SNK_GET_ICMS_ESPECIAL_CAB`, `SNK_GET_INDITENS`, `SNK_GET_NUNOTA`, `SNK_GET_SATUSCONFERENCIA`, `SNK_GET_ST_RECUPERAR`, `SNK_GET_VLRITENS`, `SNK_GET_VLRTOT_SERVICO`, `SNK_MATGIR_GET_MULTCPA`, `SNK_MATGIR_GET_QTDTOTALMULTCPA`, `SNK_PRECO`, `TIM_ASSINAFIADOR`, `TIM_ASSINAINQUILINO`, `TIM_ASSINALOCADOR`, `TIM_DNORM_ENDERECO`, `TIM_MONTAFIADOR`, `TIM_MONTAFORMAREPASSE`, `TIM_MONTAINQUILINO`, `TIM_MONTAPROPRIETARIOS`.

---

## Onboarding — verificação Oracle e comparação documental

| Componente | Estado comprovado |
|---|---|
| Fonte mais recente de usuários | `USUARIOS_MODELO_VAL_2026_06_V2.xls`, exibida no site em 11/09/2026 às 18:55. |
| Empresas no onboarding | 3; todas encontradas no Oracle. |
| Empresas cadastradas no Oracle | 6; a quantidade não foi usada como bloqueio de escopo. |
| CNPJs adicionais no Oracle | `33.649.134/0001-97`, `05.334.986/0001-50` e `04.816.115/0001-00`, para confirmação documental. |
| Usuários no onboarding | 27, todos com grupo preenchido no arquivo considerado. |
| Usuários Oracle comparáveis | 25 com `CODGRUPO > 0`; 8 usuários sem grupo foram tratados como usuários padrão da base modelo. |
| Usuários ausentes no Oracle | `comercial@sumobrasil.com.br` e `controle@sumobrasil.com.br`. |
| Divergências de grupo | 0 entre os usuários comparáveis. |
| Observação de empresa dos usuários | Os 25 usuários com grupo possuem `CODEMP=1`; 15 estão rotulados como FUTURA/SUMO no onboarding, ponto documental para conferência. |
| Execução Oracle do onboarding | Somente leitura; DML e DDL não executados. |

As divergências de SMTP, contas bancárias e composição documental de empresas permanecem registradas para conferência das fontes vigentes. A comparação não incluiu alteração cadastral automática.

## Inventário resumido de objetos e artefatos persistidos

| Objeto ou artefato | Propósito e evidência |
|---|---|
| `RMD_CONTROLE_OBJETOS` | Controlar o estado anterior, o estado posterior e a reabilitação dos objetos temporariamente alterados; 3 registros validados. |
| `BKP_RMD_01_TSIPAR` e `BKP_RMD_02_TGFEMP` | Preservar os dados utilizados nas atividades de filtros e DANFE; 4 e 5 registros, respectivamente. |
| `BKP_RMD_11_TGFEMP`, `BKP_RMD_12_TGFTOP`, `BKP_RMD_13_TSIIMP` e `BKP_RMD_14_TGFPRO` | Cópias de segurança das atividades 12 a 15; quantidades validadas: 0, 1.434, 1 e 230. |
| `BKP_RMD_TSICFG` | Preservar a configuração anterior da higienização de `TSICFG`; 876 registros. |
| `RMD_MAP_UNIDADES` e `BKP_RMD_UNID_MAP` | Mapa e cópia de segurança da normalização de unidades; 110 registros em cada. |
| `BKP_RMD_GOL_*`, `BKP_RMD_PAR_MATRIZ` e `BKP_RMD_CARD_TTKINDAGT` | Preservar preferências do Gerente On Line, parceiro matriz e configuração de cards. |
| `BKP_RMD_PAD_TGFPAR`, `BKP_RMD_PAD_TGFPRO`, `BKP_RMD_PAD_TSIBAI` e `BKP_RMD_PAD_TSIEND` | Preservar dados cadastrais das atividades de padronização; quantidades validadas: 160, 0, 45.044 e 646.115. |
| `BKP_RMD_JCLM_FDUP_20260919` | Mapa persistente das 2 notas sem financeiro do Card 09. |
| `BKP_RMD_JCLM_FDUP_20260919_PPG` | Classificação dos casos do Card 09, incluindo os 2 casos `SEM_VDUP_XML`. |
| `29_30_Merge_Antifragil_JCLM_Rollback.sql` | Reversão autocontida do tratamento controlado de bairros e endereços. |
| `32C_Card09_Rollback_Notas_Sem_Financeiro_DUP.sql` | Reversão pareada do Card 09; nenhum financeiro foi inserido nesta execução. |
| `Artefatos_Revisao/Rollback/` | Roteiros de reversão das atividades aplicáveis, do Card 09 e dos Cards 29/30. |

## Índice de reversão

Os artefatos abaixo relacionam cada atividade ou card ao respectivo roteiro de reversão ou controle persistente.

| Código | Atividade ou card | Artefato de reversão ou controle |
|---:|---|---|
| 01 | Controle das alterações temporárias | `RMD_CONTROLE_OBJETOS`; controle persistente validado. |
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
| 23 | Validação e reabilitação de objetos temporários | Validação `OBJETOS_DA_REVISAO_PENDENTES=0`; sem DML adicional de reversão. |
| 24 | Padronização de parceiros | `Artefatos_Revisao/Rollback/Reverter_24_Padronizacao_Parceiros.sql` |
| 25 | Padronização de produtos | `Artefatos_Revisao/Rollback/Reverter_25_Padronizacao_Produtos.sql` |
| 26 | Padronização de tipos de título | `Artefatos_Revisao/Rollback/Reverter_26_Padronizacao_Tipos_Titulo.sql` |
| 27 | Padronização de cidades | `Artefatos_Revisao/Rollback/Reverter_27_Padronizacao_Cidades.sql` |
| 28 | Padronização de tipos de venda | `Artefatos_Revisao/Rollback/Reverter_28_Padronizacao_Tipos_Venda.sql` |
| 29 | Padronização de bairros e consolidação de referências | `Artefatos_Revisao/Rollback/Reverter_29_Padronizacao_Bairros.sql` e `29_30_Merge_Antifragil_JCLM_Rollback.sql` |
| 30 | Padronização de endereços e consolidação de referências | `Artefatos_Revisao/Rollback/Reverter_30_Padronizacao_Enderecos.sql` e `29_30_Merge_Antifragil_JCLM_Rollback.sql` |
| 31 | Verificação de objetos Oracle inválidos | Ticket `711447`; não há reversão aplicável no banco. |
| 32 — Card 09 | Notas sem Financeiro | `32C_Card09_Rollback_Notas_Sem_Financeiro_DUP.sql`; sem inserções nesta execução. |

Os artefatos de reversão de DDL/DML não representam um `ROLLBACK` automático de alterações já confirmadas; cada roteiro deve ser executado somente após validação do mapa, da auditoria e do estado atual.

## Pendências e pontos de atenção

- Analisar as 2 notas de venda classificadas como `SEM_VDUP_XML`; nenhuma alteração financeira deve ser feita sem evidência XML e autorização da etapa correspondente.
- Reexecutar a volumetria completa após o tratamento ou decisão formal do Card 09.
- Manter as 2 ocorrências do Card 09 em acompanhamento e não inserir financeiro sem evidência XML e validação específica.
- Confirmar documentalmente os 3 CNPJs adicionais, os 2 usuários ausentes e a divergência de `CODEMP`/rótulo dos usuários do onboarding.
- O ticket `711447` permanece aberto para a tratativa dos 50 objetos inválidos.
- Antes do envio do PDF final, confirmar o nome completo e o e-mail da analista de projetos.

## Fontes finais consultadas

- `Dados_Revisao.json`
- `Logs/Validacao_Final_RMD_JCLM_20260919.json`
- `Logs/Validacao_Merge_Delete_RMD_JCLM_20260919230139.json`
- `Logs/Preflight_Card09_Resumo_20260919.json`
- `Logs/Preflight_Invalidos_20260920.json`
- `Logs/Verificacao_Onboarding_ReadOnly_JCLM_20260921.json`
- `Logs/Volumetria_Relatorio_ReadOnly_JCLM_20260921.json`
- `REL_ENTEGA_NOVO_05.jrxml` — fonte local da volumetria principal.
- `Volumetria Deploy Agent.xml` — fonte local dos indicadores complementares.
- `Onboarding_Status_20260921.md`
- `Onboarding_Comparacao_Empresas_20260921.md`
- `Onboarding_Comparacao_Usuarios_20260921.md`
- Consultas complementares `65_Relatorio_Card17_Itens_Sem_Tabela_READONLY.sql` a `69_Relatorio_Card21_Regras_Tributarias_READONLY.sql`
- Roteiros em `Artefatos_Revisao/Rollback/`

## Consideração final

A revisão Master Deploy da base JCLM INDUSTRIA E COMERCIO LTDA possui as atividades técnicas executadas e os artefatos de cópia de segurança, auditoria e reversão preservados. Os Cards 29 e 30 foram validados sem exceções pendentes; os quatro indicadores estruturais obrigatórios da volumetria retornaram zero; e os 50 objetos inválidos foram encaminhados ao ticket Sankhya Cloud `711447`.

O Card 09 permanece com 2 ocorrências `SEM_VDUP_XML` em acompanhamento. Como não há candidato `APTO_PARA_VALIDACAO_FINAL` e não houve inserção em `TGFFIN`, a condição foi registrada sem alteração financeira. Os quatro indicadores obrigatórios de integridade estão conformes, permitindo a emissão deste relatório final com a pendência controlada explicitada.
