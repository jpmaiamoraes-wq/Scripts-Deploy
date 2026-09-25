-- Card 09 - executor controlado desta base.
-- Somente as linhas APTO_PARA_VALIDACAO_FINAL do mapa persistente entram em TGFFIN.
-- O executor compartilhado cria a auditoria; o rollback usa os registros auditados.

SET DEFINE ON
DEFINE CARD09_ID_EXECUCAO = 'VDA_ACM_FDUP_20260918_02'
DEFINE CARD09_TBL_BASE = 'BKP_RMD_VDA_FDUP_20260918_02'
DEFINE CARD09_TBL_PPG = 'BKP_RMD_VDA_FDUP_20260918_02_PPG'
DEFINE CARD09_TBL_INS = 'BKP_RMD_VDA_FDUP_20260918_02_INS'
DEFINE CARD09_CONFIRMA_INSERCAO = 'SIM'

@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/32B_Card09_Inserir_Notas_Sem_Financeiro_DUP.sql"
