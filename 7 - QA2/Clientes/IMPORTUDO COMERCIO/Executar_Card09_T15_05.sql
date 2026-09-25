SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET ECHO ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Logs/Card09_Preflight_Mapa_T15_05.log"
PROMPT CARD09_T15_05
ALTER SESSION SET CURRENT_SCHEMA=SANKHYA;
@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Artefatos_Revisao/Scripts/32_Card09_Preflight_Notas_Sem_Financeiro_DUP_IMPORTUDO_05.sql"
SPOOL OFF
