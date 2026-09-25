-- Pos-validacao independente dos Cards 29/30 para o Instituto Moreira Salles.
-- Somente leitura: confirma mapa, backups, auditoria, exclusoes e referencias.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 300
SET PAGESIZE 500
WHENEVER SQLERROR EXIT SQL.SQLCODE

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Logs/33_Posvalidacao_29_30_20260914.log"

PROMPT === POS-VALIDACAO INDEPENDENTE CARD 29/30 - INSTITUTO MOREIRA SALLES ===

SELECT SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS SCHEMA_ATUAL,
       SYS_CONTEXT('USERENV','DB_NAME') AS DB_NAME,
       SYS_CONTEXT('USERENV','SERVICE_NAME') AS SERVICE_NAME
FROM DUAL;

SELECT 'MAPA_BAI' TIPO, COUNT(*) QTD
  FROM BKP_RMD_MRG_IMS_20260914
 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001' AND TIPO='BAI'
UNION ALL
SELECT 'MAPA_END', COUNT(*)
  FROM BKP_RMD_MRG_IMS_20260914
 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001' AND TIPO='END'
UNION ALL
SELECT 'BACKUP_BAI', COUNT(*)
  FROM BKP_RMD_MRG_IMS_20260914_BAI
 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001'
UNION ALL
SELECT 'BACKUP_END', COUNT(*)
  FROM BKP_RMD_MRG_IMS_20260914_END
 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001'
UNION ALL
SELECT 'AUDITORIA_DEP', COUNT(*)
  FROM BKP_RMD_MRG_IMS_20260914_DEP
 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001'
UNION ALL
SELECT 'EXCECOES', COUNT(*)
  FROM BKP_RMD_MRG_IMS_20260914_EXC
 WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001';

SELECT 'OBSOLETOS_BAI_PRESENTES' TIPO, COUNT(*) QTD
  FROM TSIBAI
 WHERE CODBAI IN (
   SELECT COD_OBSOLETO FROM BKP_RMD_MRG_IMS_20260914
    WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001' AND TIPO='BAI')
UNION ALL
SELECT 'OBSOLETOS_END_PRESENTES', COUNT(*)
  FROM TSIEND
 WHERE CODEND IN (
   SELECT COD_OBSOLETO FROM BKP_RMD_MRG_IMS_20260914
    WHERE ID_EXECUCAO='RMD_2930_IMS_20260914154001' AND TIPO='END');

SELECT 'DUPLICIDADE_BAI_POS_MERGE' TIPO, COUNT(*) QTD
  FROM (
    SELECT REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
      'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
      'AAAAAEEEEIIIIOOOOOUUUUUCAAAAAEEEEIIIIOOOOOUUUUUCAAAOOAAEIIOOUU')),
      ' {2,}',' ') NORM
      FROM TSIBAI
     WHERE NOMEBAI IS NOT NULL
    GROUP BY REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
      'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
      'AAAAAEEEEIIIIOOOOOUUUUUCAAAAAEEEEIIIIOOOOOUUUUUCAAAOOAAEIIOOUU')),
      ' {2,}',' ')
    HAVING COUNT(*) > 1
  );

SELECT 'DUPLICIDADE_END_POS_MERGE' TIPO, COUNT(*) QTD
  FROM (
    SELECT TIPO,
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
             'AAAAAEEEEIIIIOOOOOUUUUUCAAAAAEEEEIIIIOOOOOUUUUUCAAAOOAAEIIOOUU')),
             ' {2,}',' ') NORM
      FROM TSIEND
     WHERE NOMEEND IS NOT NULL
    GROUP BY TIPO,
             REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
               'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
               'AAAAAEEEEIIIIOOOOOUUUUUCAAAAAEEEEIIIIOOOOOUUUUUCAAAOOAAEIIOOUU')),
               ' {2,}',' ')
    HAVING COUNT(*) > 1
  );

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := 'RMD_2930_IMS_20260914154001';
  v_map VARCHAR2(128) := 'BKP_RMD_MRG_IMS_20260914';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_ref NUMBER := 0;
BEGIN
  FOR r IN (
    SELECT DISTINCT c.table_name,c.column_name
      FROM all_tab_columns c
      JOIN all_tables t ON t.owner=c.owner AND t.table_name=c.table_name
     WHERE c.owner=v_owner
       AND c.column_name IN ('CODBAI','CODEND')
       AND NVL(t.iot_type,'HEAP')='HEAP'
       AND c.table_name NOT IN ('TSIBAI','TSIEND','BKP_RMD_MRG_IMS_20260914',
                                'BKP_RMD_MRG_IMS_20260914_BAI','BKP_RMD_MRG_IMS_20260914_END',
                                'BKP_RMD_MRG_IMS_20260914_DEP','BKP_RMD_MRG_IMS_20260914_EXC')
  ) LOOP
    v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
      'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO='''||
      CASE WHEN r.column_name='CODBAI' THEN 'BAI' ELSE 'END' END||
      ''' AND m.COD_OBSOLETO=t.'||r.column_name||')';
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref := v_ref + v_n;
    IF v_n > 0 THEN DBMS_OUTPUT.PUT_LINE('REMANESCENTE_FISICA|'||r.table_name||'|'||r.column_name||'|'||v_n); END IF;
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.table_name,cc.column_name,p.table_name referenced_table
      FROM all_constraints c
      JOIN all_cons_columns cc ON cc.owner=c.owner AND cc.constraint_name=c.constraint_name
      JOIN all_constraints p ON p.owner=c.r_owner AND p.constraint_name=c.r_constraint_name
      JOIN all_cons_columns pc ON pc.owner=p.owner AND pc.constraint_name=p.constraint_name AND pc.position=cc.position
     WHERE c.owner=v_owner AND c.constraint_type='R'
       AND p.owner=v_owner AND p.table_name IN ('TSIBAI','TSIEND')
       AND pc.column_name IN ('CODBAI','CODEND')
       AND cc.column_name NOT IN ('CODBAI','CODEND')
       AND c.table_name NOT IN ('TSIBAI','TSIEND','BKP_RMD_MRG_IMS_20260914',
                                'BKP_RMD_MRG_IMS_20260914_BAI','BKP_RMD_MRG_IMS_20260914_END',
                                'BKP_RMD_MRG_IMS_20260914_DEP','BKP_RMD_MRG_IMS_20260914_EXC')
  ) LOOP
    v_sql := 'SELECT COUNT(*) FROM '||r.table_name||' t WHERE EXISTS ('||
      'SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO='''||
      CASE WHEN r.referenced_table='TSIBAI' THEN 'BAI' ELSE 'END' END||
      ''' AND m.COD_OBSOLETO=t.'||r.column_name||')';
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref := v_ref + v_n;
    IF v_n > 0 THEN DBMS_OUTPUT.PUT_LINE('REMANESCENTE_FK|'||r.table_name||'|'||r.column_name||'|'||v_n); END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('VALIDACAO_REFERENCIAS_REMANESCENTES='||v_ref);
END;
/

SELECT 'OBJETOS_INVALIDOS' TIPO, COUNT(*) QTD
  FROM all_objects
 WHERE owner=SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AND status='INVALID';

SELECT OBJECT_TYPE||'|'||OBJECT_NAME OBJETO_INVALIDO
  FROM all_objects
 WHERE owner=SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AND status='INVALID'
 ORDER BY OBJECT_TYPE,OBJECT_NAME;

PROMPT === POS-VALIDACAO CARD 29/30 CONCLUIDA ===
SPOOL OFF
