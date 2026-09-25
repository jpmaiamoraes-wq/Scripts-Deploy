# Inventário de objetos da revisão — Produtos Macalé LTDA

Os objetos abaixo são de suporte à execução, auditoria, backup ou reversão. O inventário deve acompanhar o relatório técnico.

| Grupo | Objetos | Propósito |
|---|---|---|
| Controle | `RMD_CONTROLE_OBJETOS` | Registrar estado anterior, desabilitação e reabilitação de objetos temporariamente afetados. |
| Unidades | `RMD_MAP_UNIDADES` | Manter o mapa de conversão de códigos de unidade. |
| Unidades | `BKP_RMD_UNID_MAP`, `BKP_RMD_UNID_TGFPRO`, `BKP_RMD_UNID_TGFITE`, `BKP_RMD_UNID_TGFPAP`, `BKP_RMD_UNID_TGFCOI2`, `BKP_RMD_UNID_TGFGIR1`, `BKP_RMD_UNID_TGFVOL` | Preservar o mapa e os registros das tabelas atingidas pela normalização de unidades. |
| Etapas 01–12 | `BKP_RMD_01_TSIPAR` a `BKP_RMD_13_TSIIMP` | Backups específicos das etapas iniciais, identificados pelo sufixo da tabela de origem. |
| Etapas 13–15 | `BKP_RMD_12_TGFTOP`, `BKP_RMD_14_TGFPRO` | Preservar TOPs de giro e produtos com rastro. |
| Etapa 16 | `BKP_RMD_TSICFG`, `RMD_REF_TSICFG_MODELO` | Preservar a configuração original e manter referência para higienização controlada. |
| Preferências GOL | `BKP_RMD_GOL_TSIPAR`, `BKP_RMD_GOL_TGFCGM`, `BKP_RMD_GOL_TGFCMV` | Preservar parâmetros e configurações do cálculo GOL. |
| Parceiro matriz | `BKP_RMD_PAR_MATRIZ` | Preservar vínculos de matriz dos parceiros. |
| Cards e ICMS | `BKP_RMD_CARD_TTKINDAGT`, `BKP_CLASSICMS_TGFPAR`, `BKP_AJNP_TGFPAR` | Preservar cards, classificação ICMS e nomes ajustados de parceiros. |
| Padronizações | `BKP_RMD_PAD_TGFPAR`, `BKP_RMD_PAD_TGFPRO`, `BKP_RMD_PAD_TGFTIT`, `BKP_RMD_PAD_TSICID`, `BKP_RMD_PAD_TGFTPV`, `BKP_RMD_PAD_TSIBAI`, `BKP_RMD_PAD_TSIEND` | Backups persistentes por ID para reversão das padronizações de texto e endereço. |
| Merge 29/30 | `BKP_MBE_MAP_BAI`, `BKP_MBE_MAP_END`, `BKP_MBE_TSIBAI`, `BKP_MBE_TSIEND`, `BKP_MBE_TGFPAR`, `BKP_MBE_TSICEP`, `BKP_MBE_TGFCPL` | Preservar mapas, registros substituídos e dependências tratadas no merge de bairros e endereços. |

Os nomes de execução (`RMD_*`) identificam cada tentativa e devem ser mantidos no relatório e nos scripts de reversão. O inventário não substitui a validação de existência, proprietário e quantidade dos objetos na base.
