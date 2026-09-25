-- Wrapper de execucao do Card 09 para o Instituto Moreira Salles.
-- O executor permanece com CONFIRMA_INSERCAO=NAO ate haver confirmacao operacional.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Logs/Card09_32B_Insert_20260915.log"

PROMPT === CARD 09 - EXECUTOR IMS ===
@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Artefatos_Revisao/Scripts/32B_Card09_Inserir_INSTITUTO_MOREIRA_SALLES_EXECUTOR.sql"

SPOOL OFF
