-- Reversao autocontida da atividade 33 (caracteres corrompidos em cadastros) - MEDCHAP (MEDCHAPPRD).
-- ID_EXECUCAO=MEDCHAP_CAR_20260925_02; mapa=RMD_MDCH_CAR_20260925_02; backups BKP_RMD_MDCH_CAR02_<TABELA>.
-- Restaura VALOR_ANTES somente nos registros com STATUS=APLICADO, por ROWID e somente se o valor atual ainda for o gravado pela atividade.
-- Nao e entrada do lote normal (fila/allowlist); executar somente com decisao explicita.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  c_id  CONSTANT VARCHAR2(40) := 'MEDCHAP_CAR_20260925_02';
  c_map CONSTANT VARCHAR2(30) := 'RMD_MDCH_CAR_20260925_02';
  c_bkp CONSTANT VARCHAR2(30) := 'BKP_RMD_MDCH_CAR02_';
  TYPE t_row IS RECORD (tabela VARCHAR2(30), coluna VARCHAR2(30), rid VARCHAR2(30), antes VARCHAR2(4000), depois VARCHAR2(4000));
  TYPE t_rows IS TABLE OF t_row;
  v_rows t_rows; v_n NUMBER; v_bkp NUMBER; v_ok NUMBER := 0;
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR'
     OR SYS_CONTEXT('USERENV','CURRENT_SCHEMA') <> 'SANKHYA'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MEDCHAPPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20460,'Identidade MEDCHAPPRD divergente; reversao da atividade 33 bloqueada.');
  END IF;
  EXECUTE IMMEDIATE 'SELECT TABELA, COLUNA, RID, VALOR_ANTES, VALOR_DEPOIS FROM '||c_map||' WHERE ID_EXECUCAO=:1 AND STATUS=''APLICADO'' ORDER BY TABELA, COLUNA, RID'
    BULK COLLECT INTO v_rows USING c_id;
  IF v_rows.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20461,'Nenhum registro APLICADO para o ID; nada a reverter.');
  END IF;
  FOR i IN 1..v_rows.COUNT LOOP
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||c_bkp||v_rows(i).tabela||' WHERE ID_EXECUCAO=:1 AND RID_ORIGINAL=:2' INTO v_bkp USING c_id, v_rows(i).rid;
    IF v_bkp <> 1 THEN
      RAISE_APPLICATION_ERROR(-20462,'Backup ausente para '||v_rows(i).tabela||' '||v_rows(i).rid||'; reversao bloqueada.');
    END IF;
    EXECUTE IMMEDIATE 'UPDATE '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_rows(i).tabela)||' SET '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_rows(i).coluna)||'=:1 WHERE ROWID=CHARTOROWID(:2) AND '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_rows(i).coluna)||'=:3'
      USING v_rows(i).antes, v_rows(i).rid, v_rows(i).depois;
    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20463,'Registro '||v_rows(i).tabela||'.'||v_rows(i).coluna||' foi alterado depois da atividade; reversao abortada sem mudancas.');
    END IF;
    EXECUTE IMMEDIATE 'UPDATE '||c_map||' SET STATUS=''REVERTIDO'' WHERE ID_EXECUCAO=:1 AND TABELA=:2 AND COLUNA=:3 AND RID=:4'
      USING c_id, v_rows(i).tabela, v_rows(i).coluna, v_rows(i).rid;
    v_ok := v_ok + 1;
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('STATUS=REVERSAO_ATIVIDADE_33_CONCLUIDA; ID_EXECUCAO='||c_id||'; REVERTIDOS='||v_ok);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
