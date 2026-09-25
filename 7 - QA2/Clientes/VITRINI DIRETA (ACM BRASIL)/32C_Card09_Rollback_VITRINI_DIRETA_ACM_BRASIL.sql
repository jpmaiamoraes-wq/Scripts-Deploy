-- Card 09 - rollback condicional e autocontido.
-- Nao executar sem decisao explicita de reversao.

SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DEFINE ID_EXECUCAO = 'VDA_ACM_FDUP_20260918_02'
DEFINE TBL_INS = 'BKP_RMD_VDA_FDUP_20260918_02_INS'

PROMPT === CARD 09 - ROLLBACK CONDICIONAL ===
PROMPT ID_EXECUCAO=&ID_EXECUCAO

DECLARE
  v_audit NUMBER;
  v_fin NUMBER;
  v_num_rows NUMBER;
  v_ultcod TGFNUM.ULTCOD%TYPE;
  v_min_nufin TGFFIN.NUFIN%TYPE;
  v_max_nufin TGFFIN.NUFIN%TYPE;
BEGIN
  SELECT COUNT(*), MIN(NUFIN), MAX(NUFIN)
    INTO v_audit, v_min_nufin, v_max_nufin
    FROM &TBL_INS WHERE ID_EXECUCAO='&ID_EXECUCAO';
  IF v_audit <> 6 OR v_min_nufin IS NULL OR v_max_nufin-v_min_nufin+1 <> v_audit THEN
    RAISE_APPLICATION_ERROR(-20360,'Auditoria divergente; rollback interrompido.');
  END IF;
  SELECT COUNT(*) INTO v_fin
    FROM TGFFIN F JOIN &TBL_INS I ON I.NUFIN=F.NUFIN AND I.NUNOTA=F.NUNOTA
   WHERE I.ID_EXECUCAO='&ID_EXECUCAO';
  IF v_fin <> v_audit THEN
    RAISE_APPLICATION_ERROR(-20361,'TGFFIN nao corresponde integralmente a auditoria; rollback interrompido.');
  END IF;
  SELECT COUNT(*), MIN(ULTCOD) INTO v_num_rows, v_ultcod
    FROM TGFNUM WHERE ARQUIVO='TGFFIN';
  IF v_num_rows <> 1 OR v_ultcod <> v_max_nufin THEN
    RAISE_APPLICATION_ERROR(-20362,'TGFNUM mudou desde o insert; rollback interrompido.');
  END IF;
  DELETE FROM TGFFIN F
   WHERE EXISTS (SELECT 1 FROM &TBL_INS I
                  WHERE I.ID_EXECUCAO='&ID_EXECUCAO'
                    AND I.NUFIN=F.NUFIN AND I.NUNOTA=F.NUNOTA);
  UPDATE TGFNUM SET ULTCOD=v_min_nufin-1 WHERE ARQUIVO='TGFFIN';
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ROLLBACK_EXECUTADO='||SQL%ROWCOUNT||'; ULTCOD_RESTAURADO='||(v_min_nufin-1));
END;
/
