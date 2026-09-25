SET PAGESIZE 200
SET LINESIZE 240
SET FEEDBACK ON

PROMPT === OBJETOS COM NOMES DE BACKUP DE UNIDADES ===
SELECT owner, object_name, object_type, status, created, last_ddl_time
  FROM all_objects
 WHERE object_name IN ('TGFVOL_BKP', 'TGFVOA_BKP')
 ORDER BY object_name, owner, object_type;

PROMPT === TABELAS DE BACKUP E QUANTIDADES ===
DECLARE
  v_count NUMBER;
BEGIN
  FOR r IN (
    SELECT owner, table_name
      FROM all_tables
     WHERE table_name IN ('TGFVOL_BKP', 'TGFVOA_BKP')
     ORDER BY table_name, owner
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE
        'SELECT COUNT(*) FROM ' ||
        DBMS_ASSERT.SCHEMA_NAME(r.owner) || '.' ||
        DBMS_ASSERT.SIMPLE_SQL_NAME(r.table_name)
        INTO v_count;
      DBMS_OUTPUT.PUT_LINE(r.owner || '|' || r.table_name || '|LINHAS=' || v_count);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(r.owner || '|' || r.table_name || '|NAO_LIDA=' || SQLERRM);
    END;
  END LOOP;
END;
/

PROMPT === SINONIMOS COM NOMES DE BACKUP ===
SELECT owner, synonym_name, table_owner, table_name, db_link
  FROM all_synonyms
 WHERE synonym_name IN ('TGFVOL_BKP', 'TGFVOA_BKP')
 ORDER BY synonym_name, owner;

PROMPT === FIM DO DIAGNOSTICO DE BACKUPS ===
