-- Fase generica para referencias FK que nao seguem os nomes CODBAI/CODEND.
-- Reaproveita o mapa, backups e trilha da execucao 29/30 ja realizada.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := 'DCOMMERCE_20260911_MERGE_01';
  v_map VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911';
  v_bkp_bai VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_BAI';
  v_bkp_end VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_END';
  v_dep VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_DEP';
  v_exc VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_EXC';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_total NUMBER := 0;
  v_exc_before NUMBER;
  v_exc_after NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  IF v_n=0 THEN RAISE_APPLICATION_ERROR(-20360,'Mapa 29/30 ausente para o ID_EXECUCAO'); END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  IF v_n=0 THEN RAISE_APPLICATION_ERROR(-20361,'Backup BAI ausente para o ID_EXECUCAO'); END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  IF v_n=0 THEN RAISE_APPLICATION_ERROR(-20362,'Backup END ausente para o ID_EXECUCAO'); END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_exc_before USING v_id;
  IF v_exc_before<>0 THEN RAISE_APPLICATION_ERROR(-20363,'Excecoes anteriores impedem a fase FK'); END IF;

  FOR r IN (
    SELECT DISTINCT c.table_name,c.constraint_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
     WHERE c.owner=v_owner AND c.constraint_type='R'
       AND p.owner=v_owner AND p.table_name IN ('TSIBAI','TSIEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc)
     ORDER BY c.table_name,c.constraint_name,cc.column_name
  ) LOOP
    SAVEPOINT RMD_FK_BRANCH;
    BEGIN
      IF r.referenced_table='TSIBAI' THEN
        v_sql := 'INSERT INTO '||v_dep||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.'||r.column_name||',m.COD_MANTIDO,SYSTIMESTAMP FROM '||r.table_name||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name;
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET t.'||r.column_name||'=(SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||') WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
      ELSE
        v_sql := 'INSERT INTO '||v_dep||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.'||r.column_name||',m.COD_MANTIDO,SYSTIMESTAMP FROM '||r.table_name||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name;
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET t.'||r.column_name||'=(SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||') WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
      END IF;
      EXECUTE IMMEDIATE v_sql USING v_id,v_id;
      v_total := v_total + SQL%ROWCOUNT;
      DBMS_OUTPUT.PUT_LINE('FK_OK|'||r.table_name||'|'||r.column_name||'|'||SQL%ROWCOUNT);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_FK_BRANCH;
      EXECUTE IMMEDIATE 'INSERT INTO '||v_exc||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,MENSAGEM,DTLOG) VALUES (:1,:2,:3,:4,SYSTIMESTAMP)'
        USING v_id,r.table_name,r.column_name,SUBSTR(SQLERRM,1,1000);
      DBMS_OUTPUT.PUT_LINE('FK_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_exc_after USING v_id;
  IF v_exc_after<>v_exc_before THEN
    RAISE_APPLICATION_ERROR(-20364,'A fase FK gerou excecoes; transacao revertida');
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_FK_CORRIGIDAS='||v_total);
  DBMS_OUTPUT.PUT_LINE('STATUS=REFERENCIAS_FK_CORRIGIDAS_COM_BACKUP; ID_EXECUCAO='||v_id||'; EXCECOES='||v_exc_after);
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/
