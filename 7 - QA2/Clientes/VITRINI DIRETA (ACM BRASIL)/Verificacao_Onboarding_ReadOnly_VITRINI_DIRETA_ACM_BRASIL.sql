-- Wrapper especifico da base para preservar o snapshot de onboarding.
-- Somente leitura: o roteiro incluido nao possui DML, DDL ou COMMIT.
SET DEFINE OFF
SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 240
SET LONG 2000
SET PAGESIZE 1000
SET TAB OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/VITRINI DIRETA (ACM BRASIL)/Logs/Verificacao_Onboarding_ReadOnly_VDA_20260918_R02.log"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/Verificacao_Onboarding_ReadOnly.sql"
SPOOL OFF
