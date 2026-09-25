-- Entrada exata e revisada para a fase financeira 32B da MOVE.
-- A confirmacao interna SIM somente e consumida dentro do lote aprovado,
-- que ainda exige plano/hash, identidade e confirmacao nativa antes do DML.

SET DEFINE ON

DEFINE CARD09_ID_EXECUCAO = 'MOVE_FDUP_20260922_01'
DEFINE CARD09_TBL_BASE = 'BKP_RMD_FDUP_20260922'
DEFINE CARD09_TBL_PPG = 'BKP_RMD_FDUP_20260922_PPG'
DEFINE CARD09_TBL_INS = 'BKP_RMD_FDUP_20260922_INS'
DEFINE CARD09_CONFIRMA_INSERCAO = 'SIM'

@32B_Card09_Inserir_Notas_Sem_Financeiro_DUP.sql
