# Índice de reversão — Produtos Macalé LTDA

Este índice relaciona cada etapa ao roteiro de reversão correspondente e ao objetivo do roteiro. Os scripts devem ser executados somente com o ID de execução correto e após validação do backup persistente.

| Etapa | Arquivo | Propósito |
|---:|---|---|
| 01 | Não aplicável | Preparação/validação, sem alteração persistente própria. |
| 02 | `Reverter_02_Liberar_Filtros_Portais.sql` | Restaurar parâmetros de filtros dos portais. |
| 03 | `Reverter_03_Padronizar_DANFE_Empresas.sql` | Restaurar configurações DANFE das empresas. |
| 04 | `Reverter_04_Desativar_Custo_TOP_Devolucao.sql` | Restaurar configuração de custo das TOPs de devolução. |
| 05 | `Reverter_05_Habilitar_Calculo_Giro_Produtos.sql` | Restaurar parâmetros de cálculo de giro dos produtos. |
| 06 | `Reverter_06_Zerar_Parcelas_Tipos_Negociacao.sql` | Restaurar parcelas dos tipos de negociação. |
| 07 | `Reverter_07_Preencher_Data_Movimento.sql` | Restaurar datas de movimento originais. |
| 08 | `Reverter_08_Preencher_Protocolos_Documentos_Legados.sql` | Restaurar protocolos dos documentos legados. |
| 09 | `Reverter_09_Liberar_Itens_Documentos_Legados.sql` | Restaurar a situação dos itens de documentos legados. |
| 10 | `Reverter_10_Habilitar_ICMS_Gerencial.sql` | Restaurar parâmetros de ICMS gerencial dos produtos. |
| 11 | `Reverter_11_Habilitar_Ruptura_Produtos.sql` | Restaurar parâmetros de ruptura dos produtos. |
| 12 | `Reverter_12_Habilitar_Ruptura_Empresas.sql` | Restaurar parâmetros de ruptura das empresas. |
| 13 | `Reverter_13_Configurar_TOPs_Giro_GOL.sql` | Restaurar configurações de giro das TOPs. |
| 14 | `Reverter_14_Configurar_Analise_Giro_848.sql` | Restaurar a configuração da análise de giro 848. |
| 15 | `Reverter_15_Desativar_Rastro_Sem_Controle.sql` | Restaurar o controle de rastro dos produtos. |
| 16 | `Reverter_16_Aplicar_Higienizacao_TSICFG.sql` | Restaurar registros de configuração higienizados. |
| 17 | `Reverter_17_Normalizacao_Unidades.sql` | Restaurar unidades, mapeamentos e objetos temporariamente desabilitados. |
| 18 | `Reverter_18_Preferencias_GOL.sql` | Restaurar preferências do cálculo GOL. |
| 19 | `Reverter_19_Parceiro_Matriz.sql` | Restaurar vínculos de parceiro matriz. |
| 20 | `Reverter_20_Cards_Deploy.sql` | Restaurar os cards de acompanhamento do Deploy Agent. |
| 21 | `Reverter_21_Classificacao_ICMS_Parceiros.sql` | Restaurar a classificação ICMS dos parceiros. |
| 22 | `Reverter_22_Ajuste_Nomes_Parceiros.sql` | Restaurar nomes e razões sociais dos parceiros. |
| 23 | Não aplicável | Validação/reabilitação de objetos; sem alteração de dados própria. |
| 24 | `Reverter_24_Padronizacao_Parceiros.sql` | Restaurar textos padronizados da TGFPAR. |
| 25 | `Reverter_25_Padronizacao_Produtos.sql` | Restaurar descrições e complementos dos produtos. |
| 26 | `Reverter_26_Padronizacao_Tipos_Titulo.sql` | Restaurar descrições dos tipos de título. |
| 27 | `Reverter_27_Padronizacao_Cidades.sql` | Restaurar nomes e descrições de cidades. |
| 28 | `Reverter_28_Padronizacao_Tipos_Venda.sql` | Restaurar descrições dos tipos de venda. |
| 29 | `Reverter_29_Padronizacao_Bairros.sql` | Restaurar nomes e descrições de bairros pelo ID da execução. |
| 30 | `Reverter_30_Padronizacao_Enderecos.sql` | Restaurar endereços padronizados pelo ID da execução. |
| 31 | Não aplicável | Recompilação não executada por falta de privilégio; ticket #70636. |

Os arquivos estão na subpasta `Artefatos_Revisao/Rollback` da base e devem ser publicados no Drive junto com este índice. O arquivo `Limpar_Objetos_Revisao.sql` é separado dos rollbacks: ele elimina os objetos de suporte e os backups, não desfaz alterações de dados.
