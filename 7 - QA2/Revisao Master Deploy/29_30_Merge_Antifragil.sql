-- Merge generico e evolutivo das colisoes de TSIBAI/TSIEND.
-- Cada execucao deve trocar somente o ID_EXECUCAO e os nomes dos artefatos.
-- O motor descobre colunas CODBAI/CODEND em tabelas fisicas, atualiza cada ramo
-- com savepoint, registra excecoes e so exclui pais quando nao houver referencias.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := CASE
                         WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE'
                           THEN 'JCLM_MRG_20260919_01'
                         WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE'
                           THEN 'MOVE_MRG_20260922_01'
                         WHEN SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD'
                           THEN 'RMD_RIO_2930_20260923_01'
                         ELSE 'DCOMMERCE_20260911_MERGE_01'
                       END;
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_ref NUMBER := 0;
  v_map_bai VARCHAR2(128) := CASE
                               WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE'
                                 THEN 'RMD_JCLM_MRG_20260919'
                               WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE'
                                 THEN 'RMD_MVE_MRG_20260922'
                               WHEN SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD'
                                 THEN 'RMD_RIO_2930_MAP'
                               ELSE 'BKP_RMD_MRG_DCOM_20260911'
                             END;
  v_bkp_bai VARCHAR2(128) := CASE
                               WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE'
                                 THEN 'RMD_JCLM_MRG_20260919_BAI'
                               WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE'
                                 THEN 'BKP_RMD_MVE_20260922_BAI'
                               WHEN SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD'
                                 THEN 'RMD_RIO_2930_BAI'
                               ELSE 'BKP_RMD_MRG_DCOM_20260911_BAI'
                             END;
  v_bkp_end VARCHAR2(128) := CASE
                               WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE'
                                 THEN 'RMD_JCLM_MRG_20260919_END'
                               WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE'
                                 THEN 'BKP_RMD_MVE_20260922_END'
                               WHEN SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD'
                                 THEN 'RMD_RIO_2930_END'
                               ELSE 'BKP_RMD_MRG_DCOM_20260911_END'
                             END;
  v_dep VARCHAR2(128) := CASE
                           WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE'
                             THEN 'RMD_JCLM_MRG_20260919_DEP'
                           WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE'
                             THEN 'RMD_MVE_MRG_20260922_DEP'
                           WHEN SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD'
                             THEN 'RMD_RIO_2930_DEP'
                           ELSE 'BKP_RMD_MRG_DCOM_20260911_DEP'
                         END;
  v_exc VARCHAR2(128) := CASE
                           WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE'
                             THEN 'RMD_JCLM_MRG_20260919_EXC'
                           WHEN SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE'
                             THEN 'RMD_MVE_MRG_20260922_EXC'
                           WHEN SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD'
                             THEN 'RMD_RIO_2930_EXC'
                           ELSE 'BKP_RMD_MRG_DCOM_20260911_EXC'
                         END;
  v_map_count NUMBER;
  v_bkp_bai_count NUMBER;
  v_bkp_end_count NUMBER;
  v_dep_count NUMBER;
  v_exc_count NUMBER;
  v_composite_fk NUMBER;
  v_external_fk NUMBER;
  v_non_numeric NUMBER;
  PROCEDURE ddl(p_sql VARCHAR2) IS
  BEGIN
    BEGIN EXECUTE IMMEDIATE p_sql;
    EXCEPTION WHEN OTHERS THEN IF SQLCODE <> -955 THEN RAISE; END IF;
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
  SELECT COUNT(*) INTO v_composite_fk
    FROM (
      SELECT c.OWNER,c.CONSTRAINT_NAME
        FROM ALL_CONSTRAINTS c
        JOIN ALL_CONS_COLUMNS cc ON cc.OWNER=c.OWNER AND cc.CONSTRAINT_NAME=c.CONSTRAINT_NAME
        JOIN ALL_CONSTRAINTS p ON p.OWNER=c.R_OWNER AND p.CONSTRAINT_NAME=c.R_CONSTRAINT_NAME
       WHERE c.OWNER=v_owner AND c.CONSTRAINT_TYPE='R'
         AND p.OWNER=v_owner AND p.TABLE_NAME IN ('TSIBAI','TSIEND')
       GROUP BY c.OWNER,c.CONSTRAINT_NAME
      HAVING COUNT(*)>1
    );
  IF v_composite_fk<>0 THEN
    RAISE_APPLICATION_ERROR(-20380,'FK composta detectada; merge bloqueado.');
  END IF;
  SELECT COUNT(*) INTO v_external_fk
    FROM ALL_CONSTRAINTS c
    JOIN ALL_CONSTRAINTS p ON p.OWNER=c.R_OWNER AND p.CONSTRAINT_NAME=c.R_CONSTRAINT_NAME
   WHERE c.CONSTRAINT_TYPE='R'
     AND p.OWNER=v_owner AND p.TABLE_NAME IN ('TSIBAI','TSIEND')
     AND c.OWNER<>v_owner;
  IF v_external_fk<>0 THEN
    RAISE_APPLICATION_ERROR(-20381,'FK de outro schema detectada; merge bloqueado.');
  END IF;
  SELECT COUNT(*) INTO v_non_numeric
    FROM (
      SELECT c.TABLE_NAME,c.COLUMN_NAME
        FROM ALL_TAB_COLUMNS c
        JOIN ALL_TABLES t ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME
       WHERE c.OWNER=v_owner AND t.TEMPORARY='N'
         AND SUBSTR(c.TABLE_NAME,1,4) NOT IN ('BKP_','RMD_')
         AND c.COLUMN_NAME IN ('CODBAI','CODEND')
         AND c.TABLE_NAME NOT IN ('TSIBAI','TSIEND')
         AND c.DATA_TYPE NOT IN ('NUMBER','FLOAT','BINARY_FLOAT','BINARY_DOUBLE')
      UNION
      SELECT cc.TABLE_NAME,cc.COLUMN_NAME
        FROM ALL_CONSTRAINTS c
        JOIN ALL_CONS_COLUMNS cc ON cc.OWNER=c.OWNER AND cc.CONSTRAINT_NAME=c.CONSTRAINT_NAME
        JOIN ALL_CONSTRAINTS p ON p.OWNER=c.R_OWNER AND p.CONSTRAINT_NAME=c.R_CONSTRAINT_NAME
        JOIN ALL_TABLES t ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME
        JOIN ALL_TAB_COLUMNS x ON x.OWNER=cc.OWNER AND x.TABLE_NAME=cc.TABLE_NAME AND x.COLUMN_NAME=cc.COLUMN_NAME
       WHERE c.OWNER=v_owner AND c.CONSTRAINT_TYPE='R'
         AND p.OWNER=v_owner AND p.TABLE_NAME IN ('TSIBAI','TSIEND')
         AND t.TEMPORARY='N'
         AND SUBSTR(c.TABLE_NAME,1,4) NOT IN ('BKP_','RMD_')
         AND cc.COLUMN_NAME NOT IN ('CODBAI','CODEND')
         AND x.DATA_TYPE NOT IN ('NUMBER','FLOAT','BINARY_FLOAT','BINARY_DOUBLE')
    );
  IF v_non_numeric<>0 THEN
    RAISE_APPLICATION_ERROR(-20382,'Dependencia de bairro/endereco nao numerica detectada.');
  END IF;

  ddl('CREATE TABLE '||v_map_bai||' (ID_EXECUCAO VARCHAR2(40),TIPO VARCHAR2(4),COD_OBSOLETO NUMBER,COD_MANTIDO NUMBER,CHAVE_NORM VARCHAR2(4000),DTLOG TIMESTAMP)');
  ddl('CREATE TABLE '||v_bkp_bai||' AS SELECT CAST(NULL AS VARCHAR2(40)) ID_EXECUCAO,b.* FROM TSIBAI b WHERE 1=0');
  ddl('CREATE TABLE '||v_bkp_end||' AS SELECT CAST(NULL AS VARCHAR2(40)) ID_EXECUCAO,e.* FROM TSIEND e WHERE 1=0');
  ddl('CREATE TABLE '||v_dep||' (ID_EXECUCAO VARCHAR2(40),TABLE_NAME VARCHAR2(128),COLUMN_NAME VARCHAR2(128),RID VARCHAR2(30),OLD_VALUE NUMBER,NEW_VALUE NUMBER,DTLOG TIMESTAMP)');
  ddl('CREATE TABLE '||v_exc||' (ID_EXECUCAO VARCHAR2(40),TABLE_NAME VARCHAR2(128),COLUMN_NAME VARCHAR2(128),MENSAGEM VARCHAR2(1000),DTLOG TIMESTAMP)');

  EXECUTE IMMEDIATE 'DELETE FROM '||v_map_bai||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'DELETE FROM '||v_dep||' WHERE ID_EXECUCAO=:1' USING v_id;
  EXECUTE IMMEDIATE 'DELETE FROM '||v_exc||' WHERE ID_EXECUCAO=:1' USING v_id;

  v_sql := 'INSERT INTO '||v_map_bai||'(ID_EXECUCAO,TIPO,COD_OBSOLETO,COD_MANTIDO,CHAVE_NORM,DTLOG) '||
    'SELECT :1,''BAI'',CODBAI,KEEP_ID,NORM,SYSTIMESTAMP FROM ('||
    'SELECT CODBAI,MIN(CODBAI) OVER(PARTITION BY NORM) KEEP_ID,NORM,COUNT(*) OVER(PARTITION BY NORM) QTD FROM ('||
    'SELECT CODBAI,'||norm('NOMEBAI')||' NORM FROM TSIBAI)) WHERE QTD>1 AND CODBAI<>KEEP_ID';
  EXECUTE IMMEDIATE v_sql USING v_id;
  v_sql := 'INSERT INTO '||v_map_bai||'(ID_EXECUCAO,TIPO,COD_OBSOLETO,COD_MANTIDO,CHAVE_NORM,DTLOG) '||
    'SELECT :1,''END'',CODEND,KEEP_ID,TIPO||''|''||NORM,SYSTIMESTAMP FROM ('||
    'SELECT CODEND,TIPO,MIN(CODEND) OVER(PARTITION BY TIPO,NORM) KEEP_ID,NORM,COUNT(*) OVER(PARTITION BY TIPO,NORM) QTD FROM ('||
    'SELECT CODEND,TIPO,'||norm('NOMEEND')||' NORM FROM TSIEND)) WHERE QTD>1 AND CODEND<>KEEP_ID';
  EXECUTE IMMEDIATE v_sql USING v_id;

  -- Somente pais obsoletos serao removidos; os codigos mantidos nao mudam.
  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_bai||' SELECT :1,b.* FROM TSIBAI b WHERE b.CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map_bai||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' USING v_id,v_id;
  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_end||' SELECT :1,e.* FROM TSIEND e WHERE e.CODEND IN (SELECT COD_OBSOLETO FROM '||v_map_bai||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' USING v_id,v_id;

  FOR r IN (SELECT DISTINCT c.table_name,c.column_name FROM all_tab_columns c JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name WHERE c.owner=v_owner AND t.temporary='N' AND SUBSTR(c.table_name,1,4) NOT IN ('BKP_','RMD_') AND c.column_name IN ('CODBAI','CODEND') AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map_bai,v_bkp_bai,v_bkp_end,v_dep,v_exc) ORDER BY c.table_name,c.column_name) LOOP
    SAVEPOINT RMD_MERGE_TABLE;
    BEGIN
      IF r.column_name='CODBAI' THEN
        v_sql := 'INSERT INTO '||v_dep||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.CODBAI,m.COD_MANTIDO,SYSTIMESTAMP FROM '||r.table_name||' t JOIN '||v_map_bai||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI';
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET t.CODBAI=(SELECT m.COD_MANTIDO FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI) WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI)';
      ELSE
        v_sql := 'INSERT INTO '||v_dep||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.CODEND,m.COD_MANTIDO,SYSTIMESTAMP FROM '||r.table_name||' t JOIN '||v_map_bai||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND';
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET t.CODEND=(SELECT m.COD_MANTIDO FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND) WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND)';
      END IF;
      EXECUTE IMMEDIATE v_sql USING v_id,v_id;
      DBMS_OUTPUT.PUT_LINE('RAMO_OK|'||r.table_name||'|'||r.column_name||'|'||SQL%ROWCOUNT);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_MERGE_TABLE;
      log_exc(r.table_name,r.column_name,SQLERRM);
      DBMS_OUTPUT.PUT_LINE('RAMO_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  -- Descoberta complementar por FK: cobre colunas filhas com nomes proprios
  -- da base, sem depender da convencao CODBAI/CODEND.
  FOR r IN (
    SELECT DISTINCT c.table_name,c.constraint_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc
        ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p
        ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
      JOIN all_tables t
        ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.constraint_type='R'
       AND p.owner=v_owner
       AND p.table_name IN ('TSIBAI','TSIEND')
       AND t.temporary='N'
       AND SUBSTR(c.table_name,1,4) NOT IN ('BKP_','RMD_')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map_bai,v_bkp_bai,v_bkp_end,v_dep,v_exc)
     ORDER BY c.table_name,c.constraint_name,cc.column_name
  ) LOOP
    SAVEPOINT RMD_MERGE_FK;
    BEGIN
      IF r.referenced_table='TSIBAI' THEN
        v_sql := 'INSERT INTO '||v_dep||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.'||r.column_name||',m.COD_MANTIDO,SYSTIMESTAMP FROM '||r.table_name||' t JOIN '||v_map_bai||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name;
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET t.'||r.column_name||'=(SELECT m.COD_MANTIDO FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||') WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
      ELSE
        v_sql := 'INSERT INTO '||v_dep||'(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,RID,OLD_VALUE,NEW_VALUE,DTLOG) SELECT :1,:2,:3,ROWIDTOCHAR(t.ROWID),t.'||r.column_name||',m.COD_MANTIDO,SYSTIMESTAMP FROM '||r.table_name||' t JOIN '||v_map_bai||' m ON m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name;
        EXECUTE IMMEDIATE v_sql USING v_id,r.table_name,r.column_name,v_id;
        v_sql := 'UPDATE '||r.table_name||' t SET t.'||r.column_name||'=(SELECT m.COD_MANTIDO FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||') WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
      END IF;
      EXECUTE IMMEDIATE v_sql USING v_id,v_id;
      DBMS_OUTPUT.PUT_LINE('FK_RAMO_OK|'||r.table_name||'|'||r.column_name||'|'||SQL%ROWCOUNT);
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK TO RMD_MERGE_FK;
      log_exc(r.table_name,r.column_name,SQLERRM);
      DBMS_OUTPUT.PUT_LINE('FK_RAMO_EXCECAO|'||r.table_name||'|'||r.column_name||'|'||SQLERRM);
    END;
  END LOOP;

  -- So apaga pais quando nenhum valor obsoleto ainda e referenciado.
  -- A validacao final considera somente tabelas fisicas. Views podem expor
  -- CODBAI/CODEND sem serem dependencias gravaveis e nao podem bloquear a
  -- exclusao dos pais.
  FOR r IN (SELECT DISTINCT c.table_name,c.column_name
              FROM all_tab_columns c
             JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
             WHERE c.owner=v_owner
               AND t.temporary='N'
               AND SUBSTR(c.table_name,1,4) NOT IN ('BKP_','RMD_')
               AND c.column_name IN ('CODBAI','CODEND')
               AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map_bai,v_bkp_bai,v_bkp_end,v_dep,v_exc)) LOOP
    BEGIN
      IF r.column_name='CODBAI' THEN
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI)';
      ELSE
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND)';
      END IF;
      EXECUTE IMMEDIATE v_sql INTO v_n USING v_id; v_ref:=v_ref+v_n;
    EXCEPTION WHEN OTHERS THEN log_exc(r.table_name,r.column_name,SQLERRM); END;
  END LOOP;
  FOR r IN (
    SELECT DISTINCT c.table_name,c.constraint_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner AND c.constraint_type='R'
       AND p.owner=v_owner AND p.table_name IN ('TSIBAI','TSIEND')
       AND t.temporary='N'
       AND SUBSTR(c.table_name,1,4) NOT IN ('BKP_','RMD_')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map_bai,v_bkp_bai,v_bkp_end,v_dep,v_exc)
  ) LOOP
    BEGIN
      IF r.referenced_table='TSIBAI' THEN
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
      ELSE
        v_sql:='SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS (SELECT 1 FROM '||v_map_bai||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.column_name||')';
      END IF;
      EXECUTE IMMEDIATE v_sql INTO v_n USING v_id; v_ref:=v_ref+v_n;
    EXCEPTION WHEN OTHERS THEN log_exc(r.table_name,r.column_name,SQLERRM); END;
  END LOOP;
  IF v_ref=0 THEN
    DBMS_OUTPUT.PUT_LINE('PAIS_OBSOLETOS_EXCLUIDOS=PENDENTE_SQL_NIVEL_SUPERIOR; REFERENCIAS_REMANESCENTES=0');
  ELSE
    DBMS_OUTPUT.PUT_LINE('PAIS_OBSOLETOS_EXCLUIDOS=NAO; REFERENCIAS_REMANESCENTES='||v_ref);
  END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map_bai||' WHERE ID_EXECUCAO=:1' INTO v_map_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_bkp_bai_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_bkp_end_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_dep||' WHERE ID_EXECUCAO=:1' INTO v_dep_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_exc_count USING v_id;
  DBMS_OUTPUT.PUT_LINE('MAPA_LINHAS='||v_map_count||'; BACKUP_BAI_OBSOLETOS='||v_bkp_bai_count||'; BACKUP_END_OBSOLETOS='||v_bkp_end_count);
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_AUDITADAS='||v_dep_count||'; EXCECOES='||v_exc_count||'; REFERENCIAS_REMANESCENTES='||v_ref);
  COMMIT;
  IF v_ref=0 AND v_exc_count=0 THEN
    DBMS_OUTPUT.PUT_LINE('STATUS=MERGE_REDIRECIONADO_REFERENCIAS_ZERO; ID_EXECUCAO='||v_id);
  ELSE
    DBMS_OUTPUT.PUT_LINE('STATUS=MERGE_PARCIAL_EXIGE_ANALISE; ID_EXECUCAO='||v_id);
  END IF;
EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/

DECLARE
  v_sql VARCHAR2(1000);
  v_qtd NUMBER;
BEGIN
  IF SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='JCLM_MERGE' THEN
    v_sql := 'SELECT COUNT(*) FROM RMD_JCLM_MRG_20260919 WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'JCLM_MRG_20260919_01';
    DBMS_OUTPUT.PUT_LINE('MAPA_LINHAS='||v_qtd);
    v_sql := 'SELECT COUNT(*) FROM RMD_JCLM_MRG_20260919_EXC WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'JCLM_MRG_20260919_01';
    DBMS_OUTPUT.PUT_LINE('EXCECOES='||v_qtd);
  ELSIF SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER')='MOVE_MERGE' THEN
    v_sql := 'SELECT COUNT(*) FROM RMD_MVE_MRG_20260922 WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'MOVE_MRG_20260922_01';
    DBMS_OUTPUT.PUT_LINE('MAPA_LINHAS='||v_qtd);
    v_sql := 'SELECT COUNT(*) FROM RMD_MVE_MRG_20260922_EXC WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'MOVE_MRG_20260922_01';
    DBMS_OUTPUT.PUT_LINE('EXCECOES='||v_qtd);
  ELSIF SYS_CONTEXT('USERENV','DB_NAME')='RIOSLTDAPRD' THEN
    v_sql := 'SELECT COUNT(*) FROM RMD_RIO_2930_MAP WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'RMD_RIO_2930_20260923_01';
    DBMS_OUTPUT.PUT_LINE('MAPA_LINHAS='||v_qtd);
    v_sql := 'SELECT COUNT(*) FROM RMD_RIO_2930_EXC WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'RMD_RIO_2930_20260923_01';
    DBMS_OUTPUT.PUT_LINE('EXCECOES='||v_qtd);
  ELSE
    v_sql := 'SELECT COUNT(*) FROM BKP_RMD_MRG_DCOM_20260911 WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'DCOMMERCE_20260911_MERGE_01';
    DBMS_OUTPUT.PUT_LINE('MAPA_LINHAS='||v_qtd);
    v_sql := 'SELECT COUNT(*) FROM BKP_RMD_MRG_DCOM_20260911_EXC WHERE ID_EXECUCAO=:1';
    EXECUTE IMMEDIATE v_sql INTO v_qtd USING 'DCOMMERCE_20260911_MERGE_01';
    DBMS_OUTPUT.PUT_LINE('EXCECOES='||v_qtd);
  END IF;
END;
/
