SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Logs/Merge_Colisoes_ANTIFRAGIL_07.log"
@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Merge_Colisoes_29_30_ANTIFRAGIL_07.sql"
SPOOL OFF
