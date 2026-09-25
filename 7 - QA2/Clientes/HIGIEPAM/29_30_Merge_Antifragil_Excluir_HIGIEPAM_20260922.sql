-- HIGIEPAM - fase 2 de 29/30: exclusao controlada dos pais obsoletos.
-- Somente executa depois do merge com zero excecoes e zero referencias.
-- O backup desta fase e independente do backup da fase de redirecionamento.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_merge_id VARCHAR2(50) := 'RMD_HIGIEPAM_2930_MERGE_20260922082832';
  v_id VARCHAR2(50) := 'RMD_HIGIEPAM_2930_EXCL_20260922084148';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_ref NUMBER := 0;
  v_map VARCHAR2(128) := 'RMD_HIGIEPAM_2930_MAP';
  v_exc VARCHAR2(128) := 'RMD_HIGIEPAM_2930_EXC';
  v_bkp_bai VARCHAR2(128) := 'RMD_HIGIEPAM_2930_X_BAI';
  v_bkp_end VARCHAR2(128) := 'RMD_HIGIEPAM_2930_X_END';

  PROCEDURE ddl(p_sql VARCHAR2) IS
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE p_sql;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE <> -955 THEN RAISE; END IF;
    END;
  END;

  PROCEDURE log_exc(p_tab VARCHAR2,p_col VARCHAR2,p_msg VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE 'INSERT INTO '||v_exc||
      '(ID_EXECUCAO,TABLE_NAME,COLUMN_NAME,MENSAGEM,DTLOG) VALUES (:1,:2,:3,:4,SYSTIMESTAMP)'
      USING v_id,p_tab,p_col,SUBSTR(p_msg,1,1000);
  END;

  PROCEDURE validate_refs IS
  BEGIN
    v_ref := 0;
    FOR r IN (
      SELECT DISTINCT c.table_name,c.column_name
        FROM all_tab_columns c
        JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
       WHERE c.owner=v_owner
         AND c.column_name IN ('CODBAI','CODEND')
         AND c.data_type='NUMBER'
         AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_exc,v_bkp_bai,v_bkp_end)
         AND c.table_name NOT LIKE 'BKP\_%' ESCAPE '\'
         AND c.table_name NOT LIKE 'RMD\_%' ESCAPE '\'
    ) LOOP
      BEGIN
        IF r.column_name='CODBAI' THEN
          v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
            'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
            'AND m.COD_OBSOLETO=t.CODBAI)';
        ELSE
          v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
            'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
            'AND m.COD_OBSOLETO=t.CODEND)';
        END IF;
        EXECUTE IMMEDIATE v_sql INTO v_n USING v_merge_id;
        v_ref := v_ref + v_n;
      EXCEPTION WHEN OTHERS THEN
        log_exc(r.table_name,r.column_name,SQLERRM);
        RAISE_APPLICATION_ERROR(-20344,'Falha ao validar referencia em '||r.table_name||'.'||r.column_name);
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
         AND c.table_name NOT IN ('TSIBAI','TSIEND',v_map,v_exc,v_bkp_bai,v_bkp_end)
         AND c.table_name NOT LIKE 'BKP\_%' ESCAPE '\'
         AND c.table_name NOT LIKE 'RMD\_%' ESCAPE '\'
    ) LOOP
      BEGIN
        IF r.referenced_table='TSIBAI' THEN
          v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
            'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' '||
            'AND m.COD_OBSOLETO=t.'||r.column_name||')';
        ELSE
          v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
            'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' '||
            'AND m.COD_OBSOLETO=t.'||r.column_name||')';
        END IF;
        EXECUTE IMMEDIATE v_sql INTO v_n USING v_merge_id;
        v_ref := v_ref + v_n;
      EXCEPTION WHEN OTHERS THEN
        log_exc(r.table_name,r.column_name,SQLERRM);
        RAISE_APPLICATION_ERROR(-20345,'Falha ao validar FK em '||r.table_name||'.'||r.column_name);
      END;
    END LOOP;
  END;
BEGIN
  ddl('CREATE TABLE '||v_bkp_bai||' AS SELECT CAST(NULL AS VARCHAR2(50)) ID_EXECUCAO,'||
      'CAST(NULL AS TIMESTAMP) DT_BACKUP,b.* FROM TSIBAI b WHERE 1=0');
  ddl('CREATE TABLE '||v_bkp_end||' AS SELECT CAST(NULL AS VARCHAR2(50)) ID_EXECUCAO,'||
      'CAST(NULL AS TIMESTAMP) DT_BACKUP,e.* FROM TSIEND e WHERE 1=0');

  EXECUTE IMMEDIATE 'DELETE FROM '||v_exc||' WHERE ID_EXECUCAO=:1' USING v_id;
  SELECT COUNT(*) INTO v_n FROM RMD_HIGIEPAM_2930_MAP WHERE ID_EXECUCAO=v_merge_id;
  IF v_n=0 THEN RAISE_APPLICATION_ERROR(-20340,'Mapa do merge HIGIEPAM inexistente.'); END IF;
  SELECT COUNT(*) INTO v_n FROM RMD_HIGIEPAM_2930_EXC WHERE ID_EXECUCAO=v_merge_id;
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20341,'Merge possui excecoes registradas; exclusao bloqueada.'); END IF;

  SELECT COUNT(*) INTO v_n FROM (
    SELECT CHAVE_NORM
      FROM RMD_HIGIEPAM_2930_MAP
     WHERE ID_EXECUCAO=v_merge_id AND TIPO='BAI'
     GROUP BY CHAVE_NORM
    HAVING COUNT(DISTINCT CHAVE_CONTEXTO)>1
  );
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20342,'Bairros com contexto CODREG divergente; exclusao bloqueada.'); END IF;

  SELECT COUNT(*) INTO v_n FROM (
    SELECT SUBSTR(CHAVE_CONTEXTO,1,INSTR(CHAVE_CONTEXTO,';')-1) TIPO_CTX,CHAVE_NORM
      FROM RMD_HIGIEPAM_2930_MAP
     WHERE ID_EXECUCAO=v_merge_id AND TIPO='END'
     GROUP BY SUBSTR(CHAVE_CONTEXTO,1,INSTR(CHAVE_CONTEXTO,';')-1),CHAVE_NORM
    HAVING COUNT(DISTINCT CHAVE_CONTEXTO)>1
  );
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20343,'Enderecos com CODLOGRADOURO divergente; exclusao bloqueada.'); END IF;

  validate_refs;
  IF v_ref<>0 THEN
    RAISE_APPLICATION_ERROR(-20346,'Ainda existem referencias a codigos obsoletos: '||v_ref);
  END IF;

  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_bai||
    ' SELECT :1,SYSTIMESTAMP,b.* FROM TSIBAI b WHERE b.CODBAI IN ('||
    'SELECT COD_MANTIDO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'' '||
    'UNION SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')'
    USING v_id,v_merge_id,v_merge_id;
  EXECUTE IMMEDIATE 'INSERT INTO '||v_bkp_end||
    ' SELECT :1,SYSTIMESTAMP,e.* FROM TSIEND e WHERE e.CODEND IN ('||
    'SELECT COD_MANTIDO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'' '||
    'UNION SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')'
    USING v_id,v_merge_id,v_merge_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  DBMS_OUTPUT.PUT_LINE('BACKUP_TSIBAI='||v_n);
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_n USING v_id;
  DBMS_OUTPUT.PUT_LINE('BACKUP_TSIEND='||v_n);
  COMMIT;

  DELETE FROM TSIBAI WHERE CODBAI IN (
    SELECT COD_OBSOLETO FROM RMD_HIGIEPAM_2930_MAP
     WHERE ID_EXECUCAO=v_merge_id AND TIPO='BAI'
  );
  DBMS_OUTPUT.PUT_LINE('TSIBAI_OBSOLETOS_EXCLUIDOS='||SQL%ROWCOUNT);
  DELETE FROM TSIEND WHERE CODEND IN (
    SELECT COD_OBSOLETO FROM RMD_HIGIEPAM_2930_MAP
     WHERE ID_EXECUCAO=v_merge_id AND TIPO='END'
  );
  DBMS_OUTPUT.PUT_LINE('TSIEND_OBSOLETOS_EXCLUIDOS='||SQL%ROWCOUNT);

  UPDATE TSIBAI b
     SET NOMEBAI=(SELECT MAX(m.CHAVE_NORM) FROM RMD_HIGIEPAM_2930_MAP m
                   WHERE m.ID_EXECUCAO=v_merge_id AND m.TIPO='BAI'
                     AND m.COD_MANTIDO=b.CODBAI)
   WHERE EXISTS (SELECT 1 FROM RMD_HIGIEPAM_2930_MAP m
                  WHERE m.ID_EXECUCAO=v_merge_id AND m.TIPO='BAI'
                    AND m.COD_MANTIDO=b.CODBAI);
  DBMS_OUTPUT.PUT_LINE('TSIBAI_MANTIDOS_NORMALIZADOS='||SQL%ROWCOUNT);
  UPDATE TSIEND e
     SET NOMEEND=(SELECT MAX(m.CHAVE_NORM) FROM RMD_HIGIEPAM_2930_MAP m
                   WHERE m.ID_EXECUCAO=v_merge_id AND m.TIPO='END'
                     AND m.COD_MANTIDO=e.CODEND)
   WHERE EXISTS (SELECT 1 FROM RMD_HIGIEPAM_2930_MAP m
                  WHERE m.ID_EXECUCAO=v_merge_id AND m.TIPO='END'
                    AND m.COD_MANTIDO=e.CODEND);
  DBMS_OUTPUT.PUT_LINE('TSIEND_MANTIDOS_NORMALIZADOS='||SQL%ROWCOUNT);

  SELECT COUNT(*) INTO v_n FROM (
    WITH N AS (
      SELECT REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
        'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
        'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),' {2,}',' ') NORM
        FROM TSIBAI
    )
    SELECT NORM FROM N GROUP BY NORM HAVING COUNT(*)>1
  );
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20347,'Colisoes normalizadas de bairros remanescentes: '||v_n); END IF;

  SELECT COUNT(*) INTO v_n FROM (
    WITH N AS (
      SELECT TIPO,
             REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
               'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
               'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),' {2,}',' ') NORM
        FROM TSIEND
    )
    SELECT TIPO,NORM FROM N GROUP BY TIPO,NORM HAVING COUNT(*)>1
  );
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20348,'Colisoes normalizadas de enderecos remanescentes: '||v_n); END IF;

  validate_refs;
  IF v_ref<>0 THEN RAISE_APPLICATION_ERROR(-20349,'Referencias remanescentes apos exclusao: '||v_ref); END IF;
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_REMANESCENTES='||v_ref);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('STATUS=EXCLUSAO_PAIS_OBSOLETOS_CONCLUIDA; ID_EXECUCAO='||v_id||'; MERGE_ORIGEM='||v_merge_id);
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/
