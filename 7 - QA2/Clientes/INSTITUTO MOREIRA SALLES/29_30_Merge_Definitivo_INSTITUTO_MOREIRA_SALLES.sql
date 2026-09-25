-- Card 29/30 - merge definitivo e auditado para o Instituto Moreira Salles.
-- Mantem o menor identificador de cada chave normalizada, redireciona
-- dependencias declaradas e colunas fisicas, exclui os pais somente apos
-- validacao de referencias=0 e deixa trilha persistente para rollback.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 300
SET PAGESIZE 500
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Logs/29_30_Merge_Definitivo_20260914.log"

PROMPT === CARD 29/30 - MERGE DEFINITIVO INSTITUTO MOREIRA SALLES ===

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := 'RMD_2930_IMS_20260914154001';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_changed NUMBER := 0;
  v_ref NUMBER := 0;
  v_exc NUMBER := 0;
  v_del_bai NUMBER := 0;
  v_del_end NUMBER := 0;
  v_cols VARCHAR2(32767);
  v_map VARCHAR2(128) := 'BKP_RMD_MRG_IMS_20260914';
  v_bkp_bai VARCHAR2(128) := 'BKP_RMD_MRG_IMS_20260914_BAI';
  v_bkp_end VARCHAR2(128) := 'BKP_RMD_MRG_IMS_20260914_END';
  v_dep VARCHAR2(128) := 'BKP_RMD_MRG_IMS_20260914_DEP';
  v_exc_tab VARCHAR2(128) := 'BKP_RMD_MRG_IMS_20260914_EXC';

  PROCEDURE ddl(p_sql VARCHAR2) IS
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE p_sql;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE <> -955 THEN RAISE; END IF;
    END;
  END;

  FUNCTION norm(p_col VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'REGEXP_REPLACE(TRIM(TRANSLATE(UPPER('||p_col||'),'||
      '''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'''||','||
      '''AAAAAEEEEIIIIOOOOOUUUUUCAAAAAEEEEIIIIOOOOOUUUUUCAAAOOAAEIIOOUU'''||
      ')),'' {2,}'','' '')';
  END;

  PROCEDURE log_exc(p_tab VARCHAR2, p_col VARCHAR2, p_msg VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO '||v_exc_tab||
      '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,MENSAGEM,DTLOG) VALUES (:1,:2,:3,:4,SYSTIMESTAMP)'
      USING v_id, p_tab, p_col, SUBSTR(p_msg,1,1000);
    COMMIT;
  END;

  PROCEDURE add_refs(p_tab VARCHAR2, p_col VARCHAR2, p_tipo VARCHAR2) IS
  BEGIN
    IF p_tipo = 'BAI' THEN
      v_sql := 'INSERT INTO '||v_dep||
        '(ID_EXECUCAO,OWNER_NAME,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) '||
        'SELECT :1,:2,:3,:4,ROWIDTOCHAR(t.ROWID),t.'||p_col||',m.COD_MANTIDO,SYSTIMESTAMP '||
        'FROM '||p_tab||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||p_col;
      EXECUTE IMMEDIATE v_sql USING v_id,v_owner,p_tab,p_col,v_id;
      v_sql := 'UPDATE '||p_tab||' t SET t.'||p_col||
        '=(SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||p_col||') '
        ||'WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||p_col||')';
    ELSE
      v_sql := 'INSERT INTO '||v_dep||
        '(ID_EXECUCAO,OWNER_NAME,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) '||
        'SELECT :1,:2,:3,:4,ROWIDTOCHAR(t.ROWID),t.'||p_col||',m.COD_MANTIDO,SYSTIMESTAMP '||
        'FROM '||p_tab||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||p_col;
      EXECUTE IMMEDIATE v_sql USING v_id,v_owner,p_tab,p_col,v_id;
      v_sql := 'UPDATE '||p_tab||' t SET t.'||p_col||
        '=(SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||p_col||') '
        ||'WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||p_col||')';
    END IF;
    EXECUTE IMMEDIATE v_sql USING v_id,v_id;
    v_changed := v_changed + SQL%ROWCOUNT;
  END;

  PROCEDURE count_refs(p_tab VARCHAR2, p_col VARCHAR2, p_tipo VARCHAR2) IS
  BEGIN
    IF p_tipo = 'BAI' THEN
      v_sql := 'SELECT COUNT(*) FROM '||p_tab||' t WHERE EXISTS ('||
        'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||p_col||')';
    ELSE
      v_sql := 'SELECT COUNT(*) FROM '||p_tab||' t WHERE EXISTS ('||
        'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||p_col||')';
    END IF;
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref := v_ref + v_n;
    IF v_n > 0 THEN DBMS_OUTPUT.PUT_LINE('REMANESCENTE|'||p_tab||'|'||p_col||'|'||v_n); END IF;
  END;

BEGIN
  ddl('CREATE TABLE '||v_map||' (ID_EXECUCAO VARCHAR2(40),TIPO VARCHAR2(4),COD_OBSOLETO NUMBER,COD_MANTIDO NUMBER,CHAVE_NORM VARCHAR2(4000),DTLOG TIMESTAMP)');
  ddl('CREATE TABLE '||v_bkp_bai||' AS SELECT CAST(NULL AS VARCHAR2(40)) ID_EXECUCAO,b.* FROM TSIBAI b WHERE 1=0');
  ddl('CREATE TABLE '||v_bkp_end||' AS SELECT CAST(NULL AS VARCHAR2(40)) ID_EXECUCAO,e.* FROM TSIEND e WHERE 1=0');
  ddl('CREATE TABLE '||v_dep||' (ID_EXECUCAO VARCHAR2(40),OWNER_NAME VARCHAR2(128),TABLE_NAME VARCHAR2(128),COLUMN_NAME VARCHAR2(128),RID VARCHAR2(30),OLD_VALUE NUMBER,NEW_VALUE NUMBER,DTLOG TIMESTAMP)');
  ddl('CREATE TABLE '||v_exc_tab||' (ID_EXECUCAO VARCHAR2(40),TABLE_NAME VARCHAR2(128),COLUMN_NAME VARCHAR2(128),MENSAGEM VARCHAR2(1000),DTLOG TIMESTAMP)');
  ddl('CREATE INDEX IX_RMD_IMS_MAP ON '||v_map||'(ID_EXECUCAO,TIPO,COD_OBSOLETO)');

  EXECUTE IMMEDIATE 'DELETE FROM '||v_map||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'DELETE FROM '||v_dep||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'DELETE FROM '||v_exc_tab||' WHERE ID_EXECUCAO=:1' USING v_id;

  v_sql := 'INSERT INTO '||v_map||'(ID_EXECUCAO,TIPO,COD_OBSOLETO,COD_MANTIDO,CHAVE_NORM,DTLOG) '||
    'SELECT :1,''BAI'',CODBAI,KEEP_ID,NORM,SYSTIMESTAMP FROM ('||
    'SELECT CODBAI,MIN(CODBAI) OVER(PARTITION BY NORM) KEEP_ID,NORM,COUNT(*) OVER(PARTITION BY NORM) QTD FROM ('||
    'SELECT CODBAI,'||norm('NOMEBAI')||' NORM FROM TSIBAI WHERE NOMEBAI IS NOT NULL)) WHERE QTD>1 AND CODBAI<>KEEP_ID';
  EXECUTE IMMEDIATE v_sql USING v_id;

  v_sql := 'INSERT INTO '||v_map||'(ID_EXECUCAO,TIPO,COD_OBSOLETO,COD_MANTIDO,CHAVE_NORM,DTLOG) '||
    'SELECT :1,''END'',CODEND,KEEP_ID,TIPO||''|''||NORM,SYSTIMESTAMP FROM ('||
    'SELECT CODEND,TIPO,MIN(CODEND) OVER(PARTITION BY TIPO,NORM) KEEP_ID,NORM,COUNT(*) OVER(PARTITION BY TIPO,NORM) QTD FROM ('||
    'SELECT CODEND,TIPO,'||norm('NOMEEND')||' NORM FROM TSIEND WHERE NOMEEND IS NOT NULL)) WHERE QTD>1 AND CODEND<>KEEP_ID';
  EXECUTE IMMEDIATE v_sql USING v_id;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI''' INTO v_n USING v_id;
  DBMS_OUTPUT.PUT_LINE('MAPA_BAI='||v_n);
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END''' INTO v_changed USING v_id;
  DBMS_OUTPUT.PUT_LINE('MAPA_END='||v_changed);
  v_changed := 0;

  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_bai||
    ' SELECT :1,b.* FROM TSIBAI b WHERE b.CODBAI IN (SELECT COD_MANTIDO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'') OR b.CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')'
    USING v_id,v_id,v_id;
  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_end||
    ' SELECT :1,e.* FROM TSIEND e WHERE e.CODEND IN (SELECT COD_MANTIDO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'') OR e.CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')'
    USING v_id,v_id,v_id;

  -- Colunas fisicas com a convencao CODBAI/CODEND.
  FOR r IN (
    SELECT DISTINCT c.table_name,c.column_name
      FROM all_tab_columns c
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.column_name IN ('CODBAI','CODEND')
       AND NVL(t.iot_type,'HEAP')='HEAP'
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc_tab)
     ORDER BY c.table_name,c.column_name
  ) LOOP
    SAVEPOINT RMD_IMS_2930_BRANCH;
    BEGIN
      add_refs(r.table_name,r.column_name,CASE WHEN r.column_name='CODBAI' THEN 'BAI' ELSE 'END' END);
      DBMS_OUTPUT.PUT_LINE('RAMO_OK|'||r.table_name||'|'||r.column_name);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_IMS_2930_BRANCH;
      log_exc(r.table_name,r.column_name,SQLERRM);
      DBMS_OUTPUT.PUT_LINE('RAMO_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  -- FKs que usam nomes proprios: a coluna pai define se e BAI ou END.
  FOR r IN (
    SELECT DISTINCT c.table_name,c.constraint_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc
        ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p
        ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
      JOIN all_cons_columns pc
        ON pc.owner=p.owner AND pc.constraint_name=p.constraint_name AND pc.position=cc.position
     WHERE c.owner=v_owner
       AND c.constraint_type='R'
       AND p.owner=v_owner
       AND p.table_name IN ('TSIBAI','TSIEND')
       AND pc.column_name IN ('CODBAI','CODEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc_tab)
     ORDER BY c.table_name,c.constraint_name,cc.column_name
  ) LOOP
    SAVEPOINT RMD_IMS_2930_FK_BRANCH;
    BEGIN
      add_refs(r.table_name,r.column_name,CASE WHEN r.referenced_table='TSIBAI' THEN 'BAI' ELSE 'END' END);
      DBMS_OUTPUT.PUT_LINE('FK_RAMO_OK|'||r.table_name||'|'||r.column_name);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_IMS_2930_FK_BRANCH;
      log_exc(r.table_name,r.column_name,SQLERRM);
      DBMS_OUTPUT.PUT_LINE('FK_RAMO_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc_tab||' WHERE ID_EXECUCAO=:1' INTO v_exc USING v_id;
  IF v_exc <> 0 THEN
    RAISE_APPLICATION_ERROR(-20401,'Excecoes de ramo impedem o commit do merge; consulte '||v_exc_tab);
  END IF;

  -- Pos-validacao abrangente antes da exclusao dos pais.
  FOR r IN (
    SELECT DISTINCT c.table_name,c.column_name
      FROM all_tab_columns c
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.column_name IN ('CODBAI','CODEND')
       AND NVL(t.iot_type,'HEAP')='HEAP'
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc_tab)
     ORDER BY c.table_name,c.column_name
  ) LOOP
    count_refs(r.table_name,r.column_name,CASE WHEN r.column_name='CODBAI' THEN 'BAI' ELSE 'END' END);
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.table_name,c.constraint_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
      JOIN all_cons_columns pc ON pc.owner=p.owner AND pc.constraint_name=p.constraint_name AND pc.position=cc.position
     WHERE c.owner=v_owner AND c.constraint_type='R'
       AND p.owner=v_owner AND p.table_name IN ('TSIBAI','TSIEND')
       AND pc.column_name IN ('CODBAI','CODEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc_tab)
  ) LOOP
    count_refs(r.table_name,r.column_name,CASE WHEN r.referenced_table='TSIBAI' THEN 'BAI' ELSE 'END' END);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_REMANESCENTES='||v_ref);
  IF v_ref <> 0 THEN
    RAISE_APPLICATION_ERROR(-20402,'Referencias obsoletas remanescentes; paises nao serao excluidos');
  END IF;

  EXECUTE IMMEDIATE 'DELETE FROM TSIBAI WHERE CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' USING v_id;
  v_del_bai := SQL%ROWCOUNT;
  EXECUTE IMMEDIATE 'DELETE FROM TSIEND WHERE CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' USING v_id;
  v_del_end := SQL%ROWCOUNT;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIBAI WHERE CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' INTO v_n USING v_id;
  IF v_n <> 0 THEN RAISE_APPLICATION_ERROR(-20403,'Pos-validacao BAI falhou'); END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIEND WHERE CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' INTO v_n USING v_id;
  IF v_n <> 0 THEN RAISE_APPLICATION_ERROR(-20404,'Pos-validacao END falhou'); END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('STATUS=CONCLUIDO; ID_EXECUCAO='||v_id||'; ALTERACOES_REFERENCIAS='||v_changed||'; EXCLUIDOS_BAI='||v_del_bai||'; EXCLUIDOS_END='||v_del_end||'; BACKUP='||v_bkp_bai||','||v_bkp_end||'; AUDITORIA='||v_dep);
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/

SELECT 'MAPA_BAI' TIPO, COUNT(*) QTD FROM BKP_RMD_MRG_IMS_20260914 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001' AND TIPO='BAI'
UNION ALL
SELECT 'MAPA_END', COUNT(*) FROM BKP_RMD_MRG_IMS_20260914 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001' AND TIPO='END'
UNION ALL
SELECT 'BACKUP_BAI', COUNT(*) FROM BKP_RMD_MRG_IMS_20260914_BAI WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001'
UNION ALL
SELECT 'BACKUP_END', COUNT(*) FROM BKP_RMD_MRG_IMS_20260914_END WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001'
UNION ALL
SELECT 'AUDITORIA_DEP', COUNT(*) FROM BKP_RMD_MRG_IMS_20260914_DEP WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001'
UNION ALL
SELECT 'EXCECOES', COUNT(*) FROM BKP_RMD_MRG_IMS_20260914_EXC WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001';

PROMPT === CARD 29/30 - MERGE DEFINITIVO CONCLUIDO ===
SPOOL OFF
