-- Remove somente os mapas persistentes desta execucao 32A.
-- Nao remove nem altera registros da TGFFIN.

SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DEFINE ID_EXECUCAO = 'MOVE_FDUP_20260922_01'
DEFINE TBL_BASE = 'BKP_RMD_FDUP_20260922'
DEFINE TBL_PPG = 'BKP_RMD_FDUP_20260922_PPG'
DEFINE CONFIRMA_ROLLBACK = 'NAO'

DECLARE
  v_total NUMBER;
  v_correspondentes NUMBER;
  v_existe NUMBER;
  v_confirm VARCHAR2(3) := UPPER('&&CONFIRMA_ROLLBACK');
  PROCEDURE validar_mapa(p_tabela VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_existe FROM USER_TABLES WHERE TABLE_NAME=p_tabela;
    IF v_existe>0 THEN
      EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||p_tabela INTO v_total;
      IF v_total=0 THEN
        RAISE_APPLICATION_ERROR(-20341,'Mapa vazio sem ID verificavel; preservado: '||p_tabela);
      END IF;
      EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||p_tabela||' WHERE ID_EXECUCAO=:1'
        INTO v_correspondentes USING '&&ID_EXECUCAO';
      IF v_correspondentes<>v_total THEN
        RAISE_APPLICATION_ERROR(-20342,'Mapa contem linhas de outra execucao; preservado: '||p_tabela);
      END IF;
    END IF;
  END;
BEGIN
  IF v_confirm <> 'SIM' THEN
    DBMS_OUTPUT.PUT_LINE('STATUS=NAO_EXECUTADO; confirme a reversao apos revisar os mapas.');
    RETURN;
  END IF;

  -- Validar os dois mapas antes de remover qualquer um.
  validar_mapa('&&TBL_PPG');
  validar_mapa('&&TBL_BASE');

  SELECT COUNT(*) INTO v_existe FROM USER_TABLES WHERE TABLE_NAME='&&TBL_PPG';
  IF v_existe>0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE &&TBL_PPG PURGE';
    DBMS_OUTPUT.PUT_LINE('MAPA_REMOVIDO=&&TBL_PPG');
  END IF;
  SELECT COUNT(*) INTO v_existe FROM USER_TABLES WHERE TABLE_NAME='&&TBL_BASE';
  IF v_existe>0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE &&TBL_BASE PURGE';
    DBMS_OUTPUT.PUT_LINE('MAPA_REMOVIDO=&&TBL_BASE');
  END IF;
  DBMS_OUTPUT.PUT_LINE('STATUS=REVERSAO_MAPAS_CONCLUIDA; TGFFIN_NAO_ALTERADA');
END;
/
