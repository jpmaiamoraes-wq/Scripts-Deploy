-- MEDCHAP (MEDCHAPPRD) fase 2 (lote MEDCHAP_DEL_20260925_01): copia da versao homologada FOCUSFINTAXPRD 23/09 (origem MOVE), trocando somente identidade e nomes dos artefatos de MEDCHAP_MRG_20260925_01.
-- Reversao: Artefatos_Revisao/Rollback/29_30_Rollback_MEDCHAP_MRG_20260925_01.sql (restaura pais e referencias).
-- Fase separada: somente exclui codigos obsoletos apos merge e pos-validacao.
-- Backup, mapa, auditoria e ausencia de referencias sao gates obrigatorios.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_id VARCHAR2(40) := 'MEDCHAP_MRG_20260925_01';
  v_map VARCHAR2(128) := 'RMD_MDCH_MRG_20260925';
  v_bkp_bai VARCHAR2(128) := 'BKP_RMD_MDCH_20260925_BAI';
  v_bkp_end VARCHAR2(128) := 'BKP_RMD_MDCH_20260925_END';
  v_dep VARCHAR2(128) := 'RMD_MDCH_MRG_20260925_DEP';
  v_exc VARCHAR2(128) := 'RMD_MDCH_MRG_20260925_EXC';
  v_sql VARCHAR2(32767);
  v_n NUMBER;
  v_ref NUMBER := 0;
  v_map_bai NUMBER;
  v_map_end NUMBER;
  v_bkp_bai_count NUMBER;
  v_bkp_end_count NUMBER;
  v_dep_count NUMBER;
  v_exc_count NUMBER;
  v_live_bai NUMBER;
  v_live_end NUMBER;
  v_del_bai NUMBER;
  v_del_end NUMBER;
  v_composite_fk NUMBER;
  v_external_fk NUMBER;
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR'
     OR v_owner <> 'SANKHYA'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MEDCHAPPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20390,'Identidade MEDCHAPPRD divergente; exclusao bloqueada.');
  END IF;

  SELECT COUNT(*) INTO v_n
    FROM ALL_TABLES
   WHERE OWNER=v_owner
     AND TABLE_NAME IN (v_map,v_bkp_bai,v_bkp_end,v_dep,v_exc);
  IF v_n <> 5 THEN
    RAISE_APPLICATION_ERROR(-20391,'Mapa, backups, auditoria ou excecoes ausentes.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI''' INTO v_map_bai USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END''' INTO v_map_end USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_bai||' WHERE ID_EXECUCAO=:1' INTO v_bkp_bai_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_bkp_end||' WHERE ID_EXECUCAO=:1' INTO v_bkp_end_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_dep||' WHERE ID_EXECUCAO=:1' INTO v_dep_count USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_exc||' WHERE ID_EXECUCAO=:1' INTO v_exc_count USING v_id;

  IF v_map_bai=0 OR v_map_end=0 OR v_map_bai<>v_bkp_bai_count OR v_map_end<>v_bkp_end_count THEN
    RAISE_APPLICATION_ERROR(-20392,'Contagem de mapa diverge dos backups de pais obsoletos.');
  END IF;
  IF v_dep_count=0 OR v_exc_count<>0 THEN
    RAISE_APPLICATION_ERROR(-20393,'Auditoria ausente ou excecoes impedem a exclusao.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'' AND COD_OBSOLETO=0' INTO v_n USING v_id;
  IF v_n<>0 THEN
    RAISE_APPLICATION_ERROR(-20394,'Codigo 0 esta marcado como obsoleto; exclusao bloqueada.');
  END IF;

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
    RAISE_APPLICATION_ERROR(-20395,'FK composta detectada depois do preflight.');
  END IF;

  SELECT COUNT(*) INTO v_external_fk
    FROM ALL_CONSTRAINTS c
    JOIN ALL_CONSTRAINTS p ON p.OWNER=c.R_OWNER AND p.CONSTRAINT_NAME=c.R_CONSTRAINT_NAME
   WHERE c.CONSTRAINT_TYPE='R'
     AND p.OWNER=v_owner AND p.TABLE_NAME IN ('TSIBAI','TSIEND')
     AND c.OWNER<>v_owner;
  IF v_external_fk<>0 THEN
    RAISE_APPLICATION_ERROR(-20396,'FK de outro schema detectada depois do preflight.');
  END IF;

  FOR r IN (
    SELECT DISTINCT c.TABLE_NAME,c.COLUMN_NAME
      FROM ALL_TAB_COLUMNS c
      JOIN ALL_TABLES t ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME
     WHERE c.OWNER=v_owner AND t.TEMPORARY='N'
       AND SUBSTR(c.TABLE_NAME,1,4) NOT IN ('BKP_','RMD_')
       AND c.COLUMN_NAME IN ('CODBAI','CODEND')
       AND c.TABLE_NAME NOT IN ('TSIBAI','TSIEND')
     ORDER BY c.TABLE_NAME,c.COLUMN_NAME
  ) LOOP
    IF r.COLUMN_NAME='CODBAI' THEN
      v_sql := 'SELECT COUNT(*) FROM '||r.TABLE_NAME||' t WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.CODBAI)';
    ELSE
      v_sql := 'SELECT COUNT(*) FROM '||r.TABLE_NAME||' t WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.CODEND)';
    END IF;
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref:=v_ref+v_n;
  END LOOP;

  FOR r IN (
    SELECT DISTINCT c.TABLE_NAME,cc.COLUMN_NAME,p.TABLE_NAME REFERENCED_TABLE
      FROM ALL_CONSTRAINTS c
      JOIN ALL_CONS_COLUMNS cc ON cc.OWNER=c.OWNER AND cc.CONSTRAINT_NAME=c.CONSTRAINT_NAME
      JOIN ALL_CONSTRAINTS p ON p.OWNER=c.R_OWNER AND p.CONSTRAINT_NAME=c.R_CONSTRAINT_NAME
      JOIN ALL_TABLES t ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME
     WHERE c.OWNER=v_owner AND c.CONSTRAINT_TYPE='R'
       AND p.OWNER=v_owner AND p.TABLE_NAME IN ('TSIBAI','TSIEND')
       AND t.TEMPORARY='N'
       AND SUBSTR(c.TABLE_NAME,1,4) NOT IN ('BKP_','RMD_')
       AND cc.COLUMN_NAME NOT IN ('CODBAI','CODEND')
     ORDER BY c.TABLE_NAME,cc.COLUMN_NAME
  ) LOOP
    IF r.REFERENCED_TABLE='TSIBAI' THEN
      v_sql := 'SELECT COUNT(*) FROM '||r.TABLE_NAME||' t WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''BAI'' AND m.COD_OBSOLETO=t.'||r.COLUMN_NAME||')';
    ELSE
      v_sql := 'SELECT COUNT(*) FROM '||r.TABLE_NAME||' t WHERE EXISTS (SELECT 1 FROM '||v_map||' m WHERE m.ID_EXECUCAO=:1 AND m.TIPO=''END'' AND m.COD_OBSOLETO=t.'||r.COLUMN_NAME||')';
    END IF;
    EXECUTE IMMEDIATE v_sql INTO v_n USING v_id;
    v_ref:=v_ref+v_n;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('MAPA_BAI='||v_map_bai||'; MAPA_END='||v_map_end);
  DBMS_OUTPUT.PUT_LINE('BACKUP_BAI='||v_bkp_bai_count||'; BACKUP_END='||v_bkp_end_count||'; AUDITORIA_REFERENCIAS='||v_dep_count||'; EXCECOES='||v_exc_count);
  DBMS_OUTPUT.PUT_LINE('REFERENCIAS_FISICAS_REMANESCENTES='||v_ref);
  IF v_ref<>0 THEN
    RAISE_APPLICATION_ERROR(-20397,'Ainda existem referencias fisicas a codigos obsoletos.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIBAI WHERE CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' INTO v_live_bai USING v_id;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIEND WHERE CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' INTO v_live_end USING v_id;
  IF v_live_bai<>v_bkp_bai_count OR v_live_end<>v_bkp_end_count THEN
    RAISE_APPLICATION_ERROR(-20398,'Quantidade de pais vivos diverge do backup; exclusao bloqueada.');
  END IF;

  EXECUTE IMMEDIATE 'DELETE FROM TSIBAI WHERE CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' USING v_id;
  v_del_bai:=SQL%ROWCOUNT;
  EXECUTE IMMEDIATE 'DELETE FROM TSIEND WHERE CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' USING v_id;
  v_del_end:=SQL%ROWCOUNT;
  IF v_del_bai<>v_bkp_bai_count OR v_del_end<>v_bkp_end_count THEN
    RAISE_APPLICATION_ERROR(-20399,'Quantidade excluida diverge do backup; lote sera revertido.');
  END IF;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIBAI WHERE CODBAI IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''BAI'')' INTO v_n USING v_id;
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20400,'Pos-validacao BAI falhou.'); END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM TSIEND WHERE CODEND IN (SELECT COD_OBSOLETO FROM '||v_map||' WHERE ID_EXECUCAO=:1 AND TIPO=''END'')' INTO v_n USING v_id;
  IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20401,'Pos-validacao END falhou.'); END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('PAIS_OBSOLETOS_EXCLUIDOS=SIM; BAI='||v_del_bai||'; END='||v_del_end);
  DBMS_OUTPUT.PUT_LINE('STATUS=PAIS_OBSOLETOS_EXCLUIDOS_COM_BACKUP; ID_EXECUCAO='||v_id);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
