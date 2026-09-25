-- HIGIEPAM - fase 1 de 29/30: merge controlado de bairros e enderecos.
-- O mapa somente agrupa equivalencias com o mesmo contexto funcional:
-- TSIBAI por CODREG; TSIEND por TIPO, CODLOGRADOURO e nome normalizado.
-- A exclusao dos pais obsoletos e uma fase posterior, com backup proprio.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(50) := 'RMD_HIGIEPAM_2930_MERGE_20260922082832';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_ref NUMBER := 0;
  v_map VARCHAR2(128) := 'RMD_HIGIEPAM_2930_MAP';
  v_bkp_bai VARCHAR2(128) := 'RMD_HIGIEPAM_2930_BAI_BKP';
  v_bkp_end VARCHAR2(128) := 'RMD_HIGIEPAM_2930_END_BKP';
  v_dep VARCHAR2(128) := 'RMD_HIGIEPAM_2930_DEP';
  v_exc VARCHAR2(128) := 'RMD_HIGIEPAM_2930_EXC';

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
      '''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'''||','||
      '''AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'''||
      ')),'' {2,}'','' '')';
  END;

  PROCEDURE log_exc(p_tab VARCHAR2,p_col VARCHAR2,p_msg VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO '||v_exc||
      '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,MENSAGEM,DTLOG) VALUES (:1,:2,:3,:4,SYSTIMESTAMP)'
      USING v_id,p_tab,p_col,SUBSTR(p_msg,1,1000);
  END;
BEGIN
  ddl('CREATE TABLE '||v_map||' ('||
      'ID_EXECUCAO VARCHAR2(50),TIPO VARCHAR2(4),COD_OBSOLETO NUMBER,'||
      'COD_MANTIDO NUMBER,CHAVE_NORM VARCHAR2(4000),CHAVE_CONTEXTO VARCHAR2(4000),'||
      'CRITERIO VARCHAR2(100),DTLOG TIMESTAMP)');
  ddl('CREATE TABLE '||v_bkp_bai||' AS SELECT CAST(NULL AS VARCHAR2(50)) ID_EXECUCAO,'||
      'CAST(NULL AS TIMESTAMP) DT_BACKUP,b.* FROM TSIBAI b WHERE 1=0');
  ddl('CREATE TABLE '||v_bkp_end||' AS SELECT CAST(NULL AS VARCHAR2(50)) ID_EXECUCAO,'||
      'CAST(NULL AS TIMESTAMP) DT_BACKUP,e.* FROM TSIEND e WHERE 1=0');
  ddl('CREATE TABLE '||v_dep||' ('||
      'ID_EXECUCAO VARCHAR2(50),TABLE_NAME VARCHAR2(128),COLUMN_NAME VARCHAR2(128),'||
      'RID VARCHAR2(30),OLD_VALUE NUMBER,NEW_VALUE NUMBER,DTLOG TIMESTAMP)');
  ddl('CREATE TABLE '||v_exc||' ('||
      'ID_EXECUCAO VARCHAR2(50),TABLE_NAME VARCHAR2(128),COLUMN_NAME VARCHAR2(128),'||
      'MENSAGEM VARCHAR2(1000),DTLOG TIMESTAMP)');

  EXECUTE IMMEDIATE 'DELETE FROM '||v_map||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'DELETE FROM '||v_dep||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'DELETE FROM '||v_exc||' WHERE ID_EXECUCAO=:1' USING v_id;

  v_sql := 'INSERT INTO '||v_map||
    '(ID_EXECUCAO,TIPO,COD_OBSOLETO,COD_MANTIDO,CHAVE_NORM,CHAVE_CONTEXTO,CRITERIO,DTLOG) '||
    'SELECT :1,''BAI'',CODBAI,KEEP_ID,NORM,''CODREG=''||TO_CHAR(CODREG),'||
    '''MESMO_CODREG_E_MENOR_CODBAI'',SYSTIMESTAMP FROM ('||
    'SELECT CODBAI,CODREG,NORM,MIN(CODBAI) OVER(PARTITION BY CODREG,NORM) KEEP_ID,'||
    'COUNT(*) OVER(PARTITION BY CODREG,NORM) QTD FROM ('||
    'SELECT CODBAI,CODREG,'||norm('NOMEBAI')||' NORM FROM TSIBAI)) '||
    'WHERE QTD>1 AND CODBAI<>KEEP_ID';
  EXECUTE IMMEDIATE v_sql USING v_id;

  v_sql := 'INSERT INTO '||v_map||
    '(ID_EXECUCAO,TIPO,COD_OBSOLETO,COD_MANTIDO,CHAVE_NORM,CHAVE_CONTEXTO,CRITERIO,DTLOG) '||
    'SELECT :1,''END'',CODEND,KEEP_ID,NORM,'||
    '''TIPO=''||NVL(TIPO,''<NULL>'')||'';CODLOGRADOURO=''||NVL(CODLOGRADOURO,''<NULL>''),'||
    '''MESMO_TIPO_CODLOGRADOURO_E_MENOR_CODEND'',SYSTIMESTAMP FROM ('||
    'SELECT CODEND,TIPO,CODLOGRADOURO,NORM,'||
    'MIN(CODEND) OVER(PARTITION BY TIPO,NORM,NVL(CODLOGRADOURO,''<NULL>'')) KEEP_ID,'||
    'COUNT(*) OVER(PARTITION BY TIPO,NORM,NVL(CODLOGRADOURO,''<NULL>'')) QTD FROM ('||
    'SELECT CODEND,TIPO,CODLOGRADOURO,'||norm('NOMEEND')||' NORM FROM TSIEND)) '||
    'WHERE QTD>1 AND CODEND<>KEEP_ID';
  EXECUTE IMMEDIATE v_sql USING v_id;

  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_bai||
    ' SELECT :1,SYSTIMESTAMP,b.* FROM TSIBAI b WHERE b.CODBAI IN ('||
    'SELECT COD_MANTIDO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'' '||
    'UNION SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')'
    USING v_id,v_id,v_id;
  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_end||
    ' SELECT :1,SYSTIMESTAMP,e.* FROM TSIEND e WHERE e.CODEND IN ('||
    'SELECT COD_MANTIDO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'' '||
    'UNION SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')'
    USING v_id,v_id,v_id;

  FOR r IN (
    SELECT DISTINCT c.table_name,c.column_name
      FROM all_tab_columns c
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.column_name IN ('CODBAI','CODEND')
       AND c.data_type='NUMBER'
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc)
       AND c.table_name NOT LIKE 'BKP\_%' ESCAPE '\'
       AND c.table_name NOT LIKE 'RMD\_%' ESCAPE '\'
     ORDER BY c.table_name,c.column_name
  ) LOOP
    SAVEPOINT RMD_HIGIEPAM_2930_T;
    BEGIN
      IF r.column_name='CODBAI' THEN
        v_sql := 'INSERT INTO '||v_dep||
          '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) '||
          'SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.CODBAI,m.COD_MANTIDO,SYSTIMESTAMP '||
          'FROM '||r.table_name||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI';
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET CODBAI=('||
          'SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI) WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
          'AND m.COD_OBSOLETO=t.CODBAI)';
      ELSE
        v_sql := 'INSERT INTO '||v_dep||
          '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) '||
          'SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.CODEND,m.COD_MANTIDO,SYSTIMESTAMP '||
          'FROM '||r.table_name||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND';
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET CODEND=('||
          'SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND) WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
          'AND m.COD_OBSOLETO=t.CODEND)';
      END IF;
      EXECUTE IMMEDIATE v_sql USING v_id,v_id;
      DBMS_OUTPUT.PUT_LINE('RAMO_OK|'||r.table_name||'|'||r.column_name||'|'||SQL%ROWCOUNT);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_HIGIEPAM_2930_T;
      log_exc(r.table_name,r.column_name,SQLERRM);
      DBMS_OUTPUT.PUT_LINE('RAMO_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.table_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
     WHERE c.owner=v_owner
       AND c.constraint_type='R'
       AND p.owner=v_owner
       AND p.table_name IN ('TSIBAI','TSIEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc)
       AND c.table_name NOT LIKE 'BKP\_%' ESCAPE '\'
       AND c.table_name NOT LIKE 'RMD\_%' ESCAPE '\'
     ORDER BY c.table_name,cc.column_name
  ) LOOP
    SAVEPOINT RMD_HIGIEPAM_2930_F;
    BEGIN
      IF r.referenced_table='TSIBAI' THEN
        v_sql := 'INSERT INTO '||v_dep||
          '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) '||
          'SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.'||r.column_name||',m.COD_MANTIDO,SYSTIMESTAMP '||
          'FROM '||r.table_name||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name;
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET '||r.column_name||'=('||
          'SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||') WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
          'AND m.COD_OBSOLETO=t.'||r.column_name||')';
      ELSE
        v_sql := 'INSERT INTO '||v_dep||
          '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) '||
          'SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.'||r.column_name||',m.COD_MANTIDO,SYSTIMESTAMP '||
          'FROM '||r.table_name||' t JOIN '||v_map||' m ON m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name;
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET '||r.column_name||'=('||
          'SELECT m.COD_MANTIDO FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 '||
          'AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||') WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
          'AND m.COD_OBSOLETO=t.'||r.column_name||')';
      END IF;
      EXECUTE IMMEDIATE v_sql USING v_id,v_id;
      DBMS_OUTPUT.PUT_LINE('FK_RAMO_OK|'||r.table_name||'|'||r.column_name||'|'||SQL%ROWCOUNT);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_HIGIEPAM_2930_F;
      log_exc(r.table_name,r.column_name,SQLERRM);
      DBMS_OUTPUT.PUT_LINE('FK_RAMO_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.table_name,c.column_name
      FROM all_tab_columns c
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.column_name IN ('CODBAI','CODEND')
       AND c.data_type='NUMBER'
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc)
       AND c.table_name NOT LIKE 'BKP\_%' ESCAPE '\'
       AND c.table_name NOT LIKE 'RMD\_%' ESCAPE '\'
  ) LOOP
    BEGIN
      IF r.column_name='CODBAI' THEN
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
          'AND m.COD_OBSOLETO=t.CODBAI)';
      ELSE
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
          'AND m.COD_OBSOLETO=t.CODEND)';
      END IF;
      EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
      v_ref:=v_ref+v_n;
    EXCEPTION WHEN OTHERS THEN
      log_exc(r.table_name,r.column_name,SQLERRM);
    END;
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.table_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
     WHERE c.owner=v_owner
       AND c.constraint_type='R'
       AND p.owner=v_owner
       AND p.table_name IN ('TSIBAI','TSIEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc)
       AND c.table_name NOT LIKE 'BKP\_%' ESCAPE '\'
       AND c.table_name NOT LIKE 'RMD\_%' ESCAPE '\'
  ) LOOP
    BEGIN
      IF r.referenced_table='TSIBAI' THEN
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
          'AND m.COD_OBSOLETO=t.'||r.column_name||')';
      ELSE
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
          'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
          'AND m.COD_OBSOLETO=t.'||r.column_name||')';
      END IF;
      EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
      v_ref:=v_ref+v_n;
    EXCEPTION WHEN OTHERS THEN
      log_exc(r.table_name,r.column_name,SQLERRM);
    END;
  END LOOP;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  DBMS_OUTPUT.PUT_LINE('MAPA_LINHAS='||v_n);
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_dep||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  DBMS_OUTPUT.PUT_LINE('DEPENDENCIAS_REDIRECIONADAS='||v_n);
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  DBMS_OUTPUT.PUT_LINE('EXCECOES='||v_n);
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_REMANESCENTES='||v_ref);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('STATUS=MERGE_EXECUTADO_SEM_EXCLUSAO; ID_EXECUCAO='||v_id);
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/
