-- Reversao autocontida do merge MOVE 29/30; nao e entrada do lote normal.
-- Restaura somente pais obsoletos e referencias persistidas nesta execucao.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := 'MOVE_MRG_20260922_01';
  v_map VARCHAR2(128) := 'RMD_MVE_MRG_20260922';
  v_bkp_bai VARCHAR2(128) := 'BKP_RMD_MVE_20260922_BAI';
  v_bkp_end VARCHAR2(128) := 'BKP_RMD_MVE_20260922_END';
  v_dep VARCHAR2(128) := 'RMD_MVE_MRG_20260922_DEP';
  v_exc VARCHAR2(128) := 'RMD_MVE_MRG_20260922_EXC';
  v_sql VARCHAR2(32767);
  v_cols VARCHAR2(32767);
  v_select_cols VARCHAR2(32767);
  v_n NUMBER;
  v_map_bai NUMBER;
  v_map_end NUMBER;
  v_bkp_bai_count NUMBER;
  v_bkp_end_count NUMBER;
  v_exc_count NUMBER;
  v_live_bai NUMBER;
  v_live_end NUMBER;
  v_restored NUMBER;
  v_expected NUMBER;
  v_table VARCHAR2(128);
  v_column VARCHAR2(128);
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR'
     OR v_owner <> 'SANKHYA'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MOVEENERGIAPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20410,'Identidade MOVE divergente; reversao bloqueada.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI''' INTO v_map_bai USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END''' INTO v_map_end USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_bkp_bai_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_bkp_end_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_exc_count USING v_id;

  IF v_map_bai=0 OR v_map_end=0 OR v_map_bai<>v_bkp_bai_count OR v_map_end<>v_bkp_end_count THEN
    RAISE_APPLICATION_ERROR(-20411,'Mapa ou backup ausente/divergente; reversao bloqueada.');
  END IF;
  IF v_exc_count<>0 THEN
    RAISE_APPLICATION_ERROR(-20412,'Excecoes do merge exigem analise antes da reversao.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIBAI WHERE CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' INTO v_live_bai USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIEND WHERE CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' INTO v_live_end USING v_id;
  IF v_live_bai NOT IN (0,v_bkp_bai_count) OR v_live_end NOT IN (0,v_bkp_end_count) THEN
    RAISE_APPLICATION_ERROR(-20413,'Estado parcial dos pais obsoletos; reversao requer analise.');
  END IF;

  IF v_live_bai=0 THEN
    SELECT LISTAGG('"'||COLUMN_NAME||'"',',') WITHIN GROUP (ORDER BY COLUMN_ID),
           LISTAGG('b."'||COLUMN_NAME||'"',',') WITHIN GROUP (ORDER BY COLUMN_ID)
      INTO v_cols,v_select_cols
      FROM ALL_TAB_COLUMNS
     WHERE OWNER=v_owner AND TABLE_NAME='TSIBAI';
    v_sql := 'INSERT INTO TSIBAI ('||v_cols||') SELECT '||v_select_cols||' FROM '||v_bkp_bai||' b WHERE b.ID_EXECUCAO=:1 AND b.CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')';
    EXECUTE IMMEDIATE v_sql USING v_id,v_id;
    v_restored:=SQL%ROWCOUNT;
    IF v_restored<>v_bkp_bai_count THEN
      RAISE_APPLICATION_ERROR(-20414,'Quantidade restaurada em TSIBAI diverge do backup.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('PAIS_RESTAURADOS|TSIBAI|'||v_restored);
  ELSE
    DBMS_OUTPUT.PUT_LINE('PAIS_JA_PRESENTES|TSIBAI|'||v_live_bai);
  END IF;

  IF v_live_end=0 THEN
    SELECT LISTAGG('"'||COLUMN_NAME||'"',',') WITHIN GROUP (ORDER BY COLUMN_ID),
           LISTAGG('b."'||COLUMN_NAME||'"',',') WITHIN GROUP (ORDER BY COLUMN_ID)
      INTO v_cols,v_select_cols
      FROM ALL_TAB_COLUMNS
     WHERE OWNER=v_owner AND TABLE_NAME='TSIEND';
    v_sql := 'INSERT INTO TSIEND ('||v_cols||') SELECT '||v_select_cols||' FROM '||v_bkp_end||' b WHERE b.ID_EXECUCAO=:1 AND b.CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')';
    EXECUTE IMMEDIATE v_sql USING v_id,v_id;
    v_restored:=SQL%ROWCOUNT;
    IF v_restored<>v_bkp_end_count THEN
      RAISE_APPLICATION_ERROR(-20415,'Quantidade restaurada em TSIEND diverge do backup.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('PAIS_RESTAURADOS|TSIEND|'||v_restored);
  ELSE
    DBMS_OUTPUT.PUT_LINE('PAIS_JA_PRESENTES|TSIEND|'||v_live_end);
  END IF;

  FOR r IN (
    SELECT TABLE_NAME,COLUMN_NAME,COUNT(*) QTD
      FROM RMD_MVE_MRG_20260922_DEP
     WHERE ID_EXECUCAO=v_id
     GROUP BY TABLE_NAME,COLUMN_NAME
     ORDER BY TABLE_NAME,COLUMN_NAME
  ) LOOP
    v_table:=DBMS_ASSERT.SIMPLE_SQL_NAME(r.TABLE_NAME);
    v_column:=DBMS_ASSERT.SIMPLE_SQL_NAME(r.COLUMN_NAME);
    v_sql := 'UPDATE '||v_table||' t SET t.'||v_column||'=(SELECT d.OLD_VALUE FROM '||v_dep||' d WHERE d.ID_EXECUCAO=:1 AND d.TABLE_NAME=:2 AND d.COLUMN_NAME=:3 AND d.RID=ROWIDTOCHAR(t.ROWID) AND d.NEW_VALUE=t.'||v_column||') WHERE EXISTS (SELECT 1 FROM '||v_dep||' d WHERE d.ID_EXECUCAO=:1 AND d.TABLE_NAME=:2 AND d.COLUMN_NAME=:3 AND d.RID=ROWIDTOCHAR(t.ROWID) AND d.NEW_VALUE=t.'||v_column||')';
    EXECUTE IMMEDIATE v_sql USING v_id,r.TABLE_NAME,r.COLUMN_NAME,v_id,r.TABLE_NAME,r.COLUMN_NAME;
    v_restored:=SQL%ROWCOUNT;
    v_expected:=r.QTD;
    IF v_restored<>v_expected THEN
      RAISE_APPLICATION_ERROR(-20416,'Referencias restauradas divergem da auditoria em '||v_table||'.'||v_column||'.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('REFERENCIAS_RESTaurADAS|'||v_table||'|'||v_column||'|'||v_restored);
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('STATUS=ROLLBACK_MOVE_MERGE_CONCLUIDO; ID_EXECUCAO='||v_id);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
