-- Modelo de wrapper do Card 09.
-- Execute a partir da pasta 7 - QA2, depois de revisar o mapa direto por XML.
-- Copie este arquivo para a pasta da base e substitua todos os parametros.
-- O valor SIM e uma confirmacao operacional imediatamente anterior ao DML.

SET DEFINE ON

DEFINE CARD09_ID_EXECUCAO = 'BASE_YYYYMMDD_FDUP_01'
DEFINE CARD09_TBL_BASE = 'BKP_RMD_FDUP_BASE_YYYYMMDD'
DEFINE CARD09_TBL_PPG = 'BKP_RMD_FDUP_BASE_YYYYMMDD_PPG'
DEFINE CARD09_TBL_INS = 'BKP_RMD_FDUP_BASE_YYYYMMDD_INS'
DEFINE CARD09_CONFIRMA_INSERCAO = 'NAO'

@32B_Card09_Inserir_Notas_Sem_Financeiro_DUP.sql
