SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Logs/Card09_Compilacao_Funcao_T14_retry.log"
PROMPT CARD09_T14_RETRY
ALTER SESSION SET CURRENT_SCHEMA=SANKHYA;
@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Scripts Originais/FNC_BUSCA_TAG_XML_GERAL.sql"
SELECT OWNER,OBJECT_NAME,OBJECT_TYPE,STATUS FROM ALL_OBJECTS WHERE OBJECT_NAME='FNC_BUSCA_TAG_XML_GERAL';
SPOOL OFF
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Logs/Card09_Preflight_Mapa_T15_retry.log"
PROMPT CARD09_T15_RETRY
DEFINE ID_EXECUCAO = 'IMPORTUDO_20260910_FDUP_04'
DEFINE TBL_BASE = 'BKP_RMD_FDUP_IMPORTUDO_04'
@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Artefatos_Revisao/Scripts/32_Card09_Preflight_Notas_Sem_Financeiro_DUP.sql"
SPOOL OFF
