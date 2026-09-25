-- Fase separada e protegida para exclusao dos pais apos o merge 29/30.
-- Nao executa redirecionamento: exige mapa, backups e referencias fisicas=0.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := 'DCOMMERCE_20260911_MERGE_01';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_ref NUMBER := 0;
  v_bai NUMBER;
  v_end NUMBER;
  v_exc NUMBER;
  v_del_bai NUMBER;
  v_del_end NUMBER;
  v_map VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911';
  v_bkp_bai VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_BAI';
  v_bkp_end VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_END';
  v_dep VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_DEP';
  v_exc_tab VARCHAR2(128) := 'BKP_RMD_MRG_DCOM_20260911_EXC';
BEGIN
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_bai USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_end USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc_tab||' WHERE ID_EXECUCAO=:1' INTO v_exc USING v_id;
  IF v_bai=0 OR v_end=0 THEN
    RAISE_APPLICATION_ERROR(-20350,'Backup persistente ausente para o ID_EXECUCAO');
  END IF;
  IF v_exc<>0 THEN
    RAISE_APPLICATION_ERROR(-20351,'Excecoes persistentes impedem a exclusao dos pais');
  END IF;

  FOR r IN (
    SELECT DISTINCT c.table_name,c.column_name
      FROM all_tab_columns c
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.column_name IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc_tab)
     ORDER BY c.table_name,c.column_name
  ) LOOP
    IF r.column_name='CODBAI' THEN
      v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
               'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI)';
    ELSE
      v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
               'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND)';
    END IF;
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref := v_ref + v_n;
    IF v_n>0 THEN
      DBMS_OUTPUT.PUT_LINE('REMANESCENTE|'||r.table_name||'|'||r.column_name||'|'||v_n);
    END IF;
  END LOOP;

  -- Dependencias reais tambem podem usar nomes sem o sufixo CODBAI/CODEND.
  -- Neste caso, a FK contra TSIBAI/TSIEND e a fonte de verdade.
  FOR r IN (
    SELECT DISTINCT c.table_name,c.constraint_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
     WHERE c.owner=v_owner AND c.constraint_type='R'
       AND p.owner=v_owner AND p.table_name IN ('TSIBAI','TSIEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc_tab)
     ORDER BY c.table_name,c.constraint_name,cc.column_name
  ) LOOP
    IF r.referenced_table='TSIBAI' THEN
      v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
               'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
    ELSE
      v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
               'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
    END IF;
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref := v_ref + v_n;
    IF v_n>0 THEN
      DBMS_OUTPUT.PUT_LINE('REMANESCENTE_FK|'||r.table_name||'|'||r.column_name||'|'||v_n);
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_FISICAS_REMANESCENTES='||v_ref);
  IF v_ref<>0 THEN
    RAISE_APPLICATION_ERROR(-20352,'Referencias fisicas obsoletas ainda existem; exclusao abortada');
  END IF;

  EXECUTE IMMEDIATE 'DELETE FROM TSIBAI WHERE CODBAI IN ('||
                    'SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' USING v_id;
  v_del_bai := SQL%ROWCOUNT;
  EXECUTE IMMEDIATE 'DELETE FROM TSIEND WHERE CODEND IN ('||
                    'SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' USING v_id;
  v_del_end := SQL%ROWCOUNT;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIBAI WHERE CODBAI IN ('||
                    'SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' INTO v_n USING v_id;
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20353,'Pos-validacao BAI falhou'); END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIEND WHERE CODEND IN ('||
                    'SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' INTO v_n USING v_id;
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20354,'Pos-validacao END falhou'); END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('PAIS_OBSOLETOS_EXCLUIDOS=SIM; BAI='||v_del_bai||'; END='||v_del_end);
  DBMS_OUTPUT.PUT_LINE('STATUS=PAIS_OBSOLETOS_EXCLUIDOS_COM_BACKUP; ID_EXECUCAO='||v_id||'; BACKUP_BAI='||v_bai||'; BACKUP_END='||v_end||'; EXCECOES='||v_exc);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
