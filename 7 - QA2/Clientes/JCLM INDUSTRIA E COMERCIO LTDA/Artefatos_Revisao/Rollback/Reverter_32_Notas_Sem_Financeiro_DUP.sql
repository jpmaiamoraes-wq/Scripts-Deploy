-- Rollback opcional da rotina nativa executada para o mapa
-- BKP_RMD_FDUP_MCL_20260910.
-- Exige revisão do resultado e confirmação explícita: substitua NAO por SIM.
-- Execute imediatamente após a rotina nativa; não use para apagar lançamentos
-- financeiros posteriores que tenham sido incluídos legitimamente.

SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DEFINE CONFIRMA_ROLLBACK = 'NAO'

DECLARE
  v_confirm VARCHAR2(3) := UPPER('&&CONFIRMA_ROLLBACK');
  v_qtd NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_qtd
    FROM ALL_TABLES
   WHERE OWNER = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
     AND TABLE_NAME = 'BKP_RMD_FDUP_MCL_20260910';
  IF v_qtd = 0 THEN
    RAISE_APPLICATION_ERROR(-20321,'Mapa BKP_RMD_FDUP_MCL_20260910 não encontrado.');
  END IF;

  IF v_confirm <> 'SIM' THEN
    DBMS_OUTPUT.PUT_LINE('STATUS=NAO_EXECUTADO; altere CONFIRMA_ROLLBACK para SIM após revisar.');
    RETURN;
  END IF;

  DELETE FROM TGFFIN F
   WHERE EXISTS (
     SELECT 1 FROM BKP_RMD_FDUP_MCL_20260910 B
      WHERE B.NUNOTA = F.NUNOTA
   );
  DBMS_OUTPUT.PUT_LINE('FINANCEIROS_REMOVIDOS='||SQL%ROWCOUNT);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('STATUS=ROLLBACK_EXECUTADO');
END;
/

