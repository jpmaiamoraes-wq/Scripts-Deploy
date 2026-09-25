-- Rollback pareado do Card 09 - Notas sem Financeiro.
-- Parametrize com os mesmos ID_EXECUCAO e TBL_INS usados no 32B.
-- O rollback remove somente TGFFIN auditados neste ID; nunca usa NUNOTA isoladamente.
-- TGFNUM so e reduzido quando a sequencia auditada e continua e ainda esta no topo.

SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DEFINE ID_EXECUCAO = 'BASE_YYYYMMDD_FIN_DUP_01'
DEFINE TBL_INS = 'BKP_RMD_FDUP_BASE_YYYYMMDD_INS'
DEFINE CONFIRMA_ROLLBACK = 'NAO'

PROMPT === ROLLBACK CARD 09 - TGFFIN ===
DECLARE
  v_confirm VARCHAR2(3) := UPPER('&&CONFIRMA_ROLLBACK');
  v_audit NUMBER;
  v_fin NUMBER;
  v_min NUMBER;
  v_max NUMBER;
  v_num NUMBER;
  v_current NUMBER;
  v_deleted NUMBER;
BEGIN
  SELECT COUNT(*), MIN(NUFIN), MAX(NUFIN)
    INTO v_audit, v_min, v_max
    FROM &TBL_INS
   WHERE ID_EXECUCAO='&ID_EXECUCAO';
  SELECT COUNT(*) INTO v_fin
    FROM TGFFIN F
   WHERE EXISTS (SELECT 1 FROM &TBL_INS A
                  WHERE A.ID_EXECUCAO='&ID_EXECUCAO'
                    AND A.NUNOTA=F.NUNOTA AND A.NUFIN=F.NUFIN);
  DBMS_OUTPUT.PUT_LINE('AUDITADOS='||v_audit||'; TGFFIN_ENCONTRADOS='||v_fin);
  IF v_confirm <> 'SIM' THEN
    DBMS_OUTPUT.PUT_LINE('STATUS=NAO_EXECUTADO; altere CONFIRMA_ROLLBACK para SIM apos revisar.');
    RETURN;
  END IF;
  IF v_fin <> v_audit THEN
    RAISE_APPLICATION_ERROR(-20340,'A quantidade auditada nao coincide com TGFFIN; rollback interrompido.');
  END IF;
  DELETE FROM TGFFIN F
   WHERE EXISTS (SELECT 1 FROM &TBL_INS A
                  WHERE A.ID_EXECUCAO='&ID_EXECUCAO'
                    AND A.NUNOTA=F.NUNOTA AND A.NUFIN=F.NUFIN);
  v_deleted := SQL%ROWCOUNT;
  SELECT COUNT(*) INTO v_num FROM TGFNUM WHERE ARQUIVO='TGFFIN';
  IF v_num=1 AND v_audit>0 AND v_max-v_min+1=v_audit THEN
    SELECT ULTCOD INTO v_current FROM TGFNUM WHERE ARQUIVO='TGFFIN' FOR UPDATE WAIT 5;
    IF v_current=v_max THEN
      UPDATE TGFNUM SET ULTCOD=v_min-1 WHERE ARQUIVO='TGFFIN';
      DBMS_OUTPUT.PUT_LINE('TGFNUM_RESTAURADO='||(v_min-1));
    ELSE
      DBMS_OUTPUT.PUT_LINE('TGFNUM_NAO_ALTERADO; ULTCOD atual diferente do topo auditado.');
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('TGFNUM_NAO_ALTERADO; sequencia auditada nao continua ou cadastro inconsistente.');
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('TGFFIN_REMOVIDOS='||v_deleted);
  DBMS_OUTPUT.PUT_LINE('STATUS=ROLLBACK_EXECUTADO');
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/
