-- Nova execucao da Revisao Master Deploy da Andorinha Comercial.
-- Os objetos de controle e backups anteriores nao existem mais.
-- Execute conectado a ANDORINHA COMERCIAL como SCRIPT (F5).
SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/ANDORINHA COMERCIAL/Logs/Nova_Revisao_Master_20260908.log"

PROMPT === IDENTIDADE DA CONEXAO ===
SELECT SYS_CONTEXT('USERENV','SESSION_USER') USUARIO,
       SYS_CONTEXT('USERENV','CURRENT_SCHEMA') SCHEMA_ATUAL,
       SYS_CONTEXT('USERENV','SERVICE_NAME') SERVICO
  FROM DUAL;
SELECT CODEMP, RAZAOSOCIAL FROM TSIEMP WHERE CODEMP=1;

ACCEPT P_CONFIRMA CHAR PROMPT 'Digite EXECUTAR ANDORINHA COMERCIAL para confirmar a base: '
BEGIN
  IF UPPER(TRIM('&&P_CONFIRMA')) <> 'EXECUTAR ANDORINHA COMERCIAL' THEN
    RAISE_APPLICATION_ERROR(-20500,'Execucao cancelada: confirmacao da base divergente.');
  END IF;
  IF UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'ANDORINHABRPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20501,'Execucao cancelada: SERVICE_NAME diferente do esperado.');
  END IF;
END;
/
UNDEFINE P_CONFIRMA

@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql"

SPOOL OFF
