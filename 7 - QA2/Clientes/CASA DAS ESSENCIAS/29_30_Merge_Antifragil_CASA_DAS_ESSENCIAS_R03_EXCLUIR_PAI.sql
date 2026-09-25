-- CASA DAS ESSENCIAS - fase 29/30 R03: exclusao protegida dos pais obsoletos.
-- Somente executa se mapa, auditoria e referencias operacionais estiverem consistentes.
-- Mantem os objetos de mapa, backups, auditoria e rollback.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(50) := 'RMD_CASA_2930_MRG_20260923_R03';
  v_sql VARCHAR2(32767);
  v_map VARCHAR2(128) := 'RMD_CASA_2930_R03_MAP';
  v_bkp_bai VARCHAR2(128) := 'RMD_CASA_2930_R03_BAI_BKP';
  v_bkp_end VARCHAR2(128) := 'RMD_CASA_2930_R03_END_BKP';
  v_dep VARCHAR2(128) := 'RMD_CASA_2930_R03_DEP';
  v_exc VARCHAR2(128) := 'RMD_CASA_2930_R03_EXC';
  v_del VARCHAR2(128) := 'RMD_CASA_2930_R03_DEL';
  v_map_bai NUMBER;
  v_map_end NUMBER;
  v_bkp_bai_qtd NUMBER;
  v_bkp_end_qtd NUMBER;
  v_dep_qtd NUMBER;
  v_exc_qtd NUMBER;
  v_dup NUMBER;
  v_ref NUMBER := 0;
  v_n NUMBER;
  v_del_bai NUMBER;
  v_del_end NUMBER;

  PROCEDURE count_refs(p_tab VARCHAR2,p_col VARCHAR2,p_tipo VARCHAR2) IS
  BEGIN
    v_sql := 'SELECT COUNT(*) FROM '||p_tab||' t WHERE EXISTS ('||
      'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=:2 '||
      'AND m.COD_OBSOLETO=t.'||p_col||')';
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id,p_tipo;
    v_ref := v_ref + v_n;
  EXCEPTION WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20386,'Falha na verificacao de referencias em '||p_tab||'.'||p_col||': '||SQLERRM);
  END;
BEGIN
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI''' INTO v_map_bai USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END''' INTO v_map_end USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_bkp_bai_qtd USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_bkp_end_qtd USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_dep||' WHERE ID_EXECUCAO=:1' INTO v_dep_qtd USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_exc_qtd USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||
    'SELECT TIPO,COD_OBSOLETO,COUNT(*) QTD FROM '||v_map||
    ' WHERE ID_EXECUCAO=:1 GROUP BY TIPO,COD_OBSOLETO HAVING COUNT(*)>1)'
    INTO v_dup USING v_id;

  IF v_map_bai=0 OR v_map_end=0 THEN
    RAISE_APPLICATION_ERROR(-20387,'Mapa R03 incompleto; exclusao bloqueada.');
  END IF;
  IF v_bkp_bai_qtd<v_map_bai OR v_bkp_end_qtd<v_map_end THEN
    RAISE_APPLICATION_ERROR(-20388,'Backup R03 menor que o mapa; exclusao bloqueada.');
  END IF;
  IF v_dep_qtd=0 THEN
    RAISE_APPLICATION_ERROR(-20389,'Auditoria de referencias vazia; exclusao bloqueada.');
  END IF;
  IF v_exc_qtd<>0 THEN
    RAISE_APPLICATION_ERROR(-20390,'Existem excecoes R03; exclusao bloqueada.');
  END IF;
  IF v_dup<>0 THEN
    RAISE_APPLICATION_ERROR(-20391,'Mapa R03 duplicado; exclusao bloqueada.');
  END IF;

  FOR r IN (
    SELECT DISTINCT c.TABLE_NAME,c.COLUMN_NAME
      FROM ALL_TAB_COLUMNS c
      JOIN ALL_TABLES t ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME
     WHERE c.OWNER=v_owner AND t.TEMPORARY='N'
       AND c.COLUMN_NAME IN ('CODBAI','CODEND')
       AND c.DATA_TYPE IN ('NUMBER','FLOAT','BINARY_FLOAT','BINARY_DOUBLE')
       AND c.TABLE_NAME NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc,v_del)
       AND c.TABLE_NAME NOT LIKE 'BKP\_%' ESCAPE '\'
       AND c.TABLE_NAME NOT LIKE 'RMD\_%' ESCAPE '\'
     ORDER BY c.TABLE_NAME,c.COLUMN_NAME
  ) LOOP
    IF r.COLUMN_NAME='CODBAI' THEN
      count_refs(r.TABLE_NAME,r.COLUMN_NAME,'BAI');
    ELSE
      count_refs(r.TABLE_NAME,r.COLUMN_NAME,'END');
    END IF;
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.TABLE_NAME,cc.COLUMN_NAME,p.TABLE_NAME REFERENCED_TABLE
      FROM ALL_CONSTRAINTS c
      JOIN ALL_CONS_COLUMNS cc ON cc.OWNER=c.OWNER AND cc.CONSTRAINT_NAME=c.CONSTRAINT_NAME
      JOIN ALL_CONSTRAINTS p ON p.OWNER=c.R_OWNER AND p.CONSTRAINT_NAME=c.R_CONSTRAINT_NAME
      JOIN ALL_TABLES t ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME
     WHERE c.OWNER=v_owner AND c.CONSTRAINT_TYPE='R'
       AND p.OWNER=v_owner AND p.TABLE_NAME IN ('TSIBAI','TSIEND')
       AND t.TEMPORARY='N' AND cc.COLUMN_NAME NOT IN ('CODBAI','CODEND')
       AND c.TABLE_NAME NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc,v_del)
       AND c.TABLE_NAME NOT LIKE 'BKP\_%' ESCAPE '\'
       AND c.TABLE_NAME NOT LIKE 'RMD\_%' ESCAPE '\'
     ORDER BY c.TABLE_NAME,cc.COLUMN_NAME
  ) LOOP
    IF r.REFERENCED_TABLE='TSIBAI' THEN
      count_refs(r.TABLE_NAME,r.COLUMN_NAME,'BAI');
    ELSE
      count_refs(r.TABLE_NAME,r.COLUMN_NAME,'END');
    END IF;
  END LOOP;

  IF v_ref<>0 THEN
    RAISE_APPLICATION_ERROR(-20392,'Ainda existem referencias operacionais a pais obsoletos: '||v_ref);
  END IF;

  EXECUTE IMMEDIATE 'DELETE FROM '||v_del||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'INSERT INTO '||v_del||'(ID_EXECUCAO,TABLE_NAME,CODIGO,DTLOG) '||
    'SELECT :1,''TSIBAI'',COD_OBSOLETO,SYSTIMESTAMP FROM '||v_map||
    ' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI''' USING v_id,v_id;
  EXECUTE IMMEDIATE 'INSERT INTO '||v_del||'(ID_EXECUCAO,TABLE_NAME,CODIGO,DTLOG) '||
    'SELECT :1,''TSIEND'',COD_OBSOLETO,SYSTIMESTAMP FROM '||v_map||
    ' WHERE ID_EXECUCAO=:1 AND TIPO=''END''' USING v_id,v_id;

  EXECUTE IMMEDIATE 'DELETE FROM TSIBAI b WHERE EXISTS ('||
    'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
    'AND m.COD_OBSOLETO=b.CODBAI)' USING v_id;
  v_del_bai := SQL%ROWCOUNT;
  EXECUTE IMMEDIATE 'DELETE FROM TSIEND e WHERE EXISTS ('||
    'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
    'AND m.COD_OBSOLETO=e.CODEND)' USING v_id;
  v_del_end := SQL%ROWCOUNT;

  IF v_del_bai<>v_map_bai OR v_del_end<>v_map_end THEN
    RAISE_APPLICATION_ERROR(-20393,'Exclusao divergente do mapa: BAI='||v_del_bai||'/'||v_map_bai||', END='||v_del_end||'/'||v_map_end);
  END IF;

  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO='||v_id);
  DBMS_OUTPUT.PUT_LINE('PAIS_BAI_EXCLUIDOS='||v_del_bai||'; PAIS_END_EXCLUIDOS='||v_del_end);
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_OPERACIONAIS_REVALIDADAS='||v_ref||'; EXCECOES='||v_exc_qtd);
  DBMS_OUTPUT.PUT_LINE('STATUS=PAIS_OBSOLETOS_EXCLUIDOS_COM_BACKUP_MAPA_AUDITORIA');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/
