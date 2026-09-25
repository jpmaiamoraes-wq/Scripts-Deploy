-- FOCUSFINTAXPRD fase 3 (lote FOCUS_NORM2930_20260923_01): adaptado do script homologado da MOVE; constantes 413/6877 conferidas no preflight R04 desta base.
-- Reversao: Artefatos_Revisao/Rollback/Reverter_29_30_Normalizacao_Remanescente_FOCUSFINTAXPRD.sql
-- Continua a padronizacao das linhas que eram colisao antes do merge.
-- Preflight R04 (Artefatos_Revisao/Preflight_29_30_R04_pos_exclusao_20260923_154648.json): 413 bairros e 6877 enderecos, agora unicos pela regra 29/30.
-- Usa backups persistentes existentes; sem DDL, sem exclusao e sem mudanca de codigo.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  c_id CONSTANT VARCHAR2(30) := 'FOCUS_NORM2930_20260923_01';
  c_bai CONSTANT PLS_INTEGER := 413;
  c_end CONSTANT PLS_INTEGER := 6877;
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_objects PLS_INTEGER;
  v_columns PLS_INTEGER;
  v_existing PLS_INTEGER;
  v_candidates_bai PLS_INTEGER;
  v_candidates_end PLS_INTEGER;
  v_collisions_bai PLS_INTEGER;
  v_collisions_end PLS_INTEGER;
  v_backup_bai PLS_INTEGER;
  v_backup_end PLS_INTEGER;
  v_updated_bai PLS_INTEGER;
  v_updated_end PLS_INTEGER;
  v_remaining_bai PLS_INTEGER;
  v_remaining_end PLS_INTEGER;

  FUNCTION norm(p_column VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'REGEXP_REPLACE(TRIM(TRANSLATE(UPPER('||p_column||'),'
      ||'''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'''
      ||','||'''AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'''
      ||')),'' {2,}'','' '')';
  END;
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR'
     OR v_owner <> 'SANKHYA'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20420,'Identidade FOCUSFINTAXPRD divergente; normalizacao bloqueada.');
  END IF;

  SELECT COUNT(*) INTO v_objects
    FROM ALL_TABLES
   WHERE OWNER=v_owner AND TEMPORARY='N'
     AND TABLE_NAME IN ('BKP_RMD_PAD_TSIBAI','BKP_RMD_PAD_TSIEND');
  IF v_objects<>2 THEN
    RAISE_APPLICATION_ERROR(-20421,'Backups persistentes de bairros/enderecos ausentes.');
  END IF;

  SELECT COUNT(*) INTO v_columns
    FROM ALL_TAB_COLUMNS
   WHERE OWNER=v_owner
     AND ((TABLE_NAME='BKP_RMD_PAD_TSIBAI' AND COLUMN_NAME IN ('ID_EXECUCAO','ROWID_ORIGINAL','NOMEBAI'))
       OR (TABLE_NAME='BKP_RMD_PAD_TSIEND' AND COLUMN_NAME IN ('ID_EXECUCAO','ROWID_ORIGINAL','NOMEEND')));
  IF v_columns<>6 THEN
    RAISE_APPLICATION_ERROR(-20422,'Estrutura dos backups persistentes diverge do esperado.');
  END IF;

  SELECT COUNT(*) INTO v_existing FROM BKP_RMD_PAD_TSIBAI WHERE ID_EXECUCAO=c_id;
  IF v_existing<>0 THEN
    RAISE_APPLICATION_ERROR(-20423,'ID de execucao ja existe no backup TSIBAI.');
  END IF;
  SELECT COUNT(*) INTO v_existing FROM BKP_RMD_PAD_TSIEND WHERE ID_EXECUCAO=c_id;
  IF v_existing<>0 THEN
    RAISE_APPLICATION_ERROR(-20424,'ID de execucao ja existe no backup TSIEND.');
  END IF;

  EXECUTE IMMEDIATE
    'SELECT COUNT(CASE WHEN QTD=1 AND DECODE(NOME,NORM,0,1)=1 THEN 1 END), '
    ||'COUNT(DISTINCT CASE WHEN QTD>1 THEN NORM END) FROM ('
    ||'SELECT NOME,NORM,COUNT(*) OVER(PARTITION BY NORM) QTD FROM ('
    ||'SELECT NOMEBAI NOME,'||norm('NOMEBAI')||' NORM FROM TSIBAI))'
    INTO v_candidates_bai,v_collisions_bai;

  EXECUTE IMMEDIATE
    'SELECT COUNT(CASE WHEN QTD=1 AND DECODE(NOME,NORM,0,1)=1 THEN 1 END), '
    ||'COUNT(DISTINCT CASE WHEN QTD>1 THEN '
    ||'NVL(TO_CHAR(LENGTH(TIPO)),''-1'')||'':''||NVL(TIPO,'''')||'':''||'
    ||'NVL(TO_CHAR(LENGTH(NORM)),''-1'')||'':''||NVL(NORM,'''') END) FROM ('
    ||'SELECT TIPO,NOME,NORM,COUNT(*) OVER(PARTITION BY TIPO,NORM) QTD FROM ('
    ||'SELECT TIPO,NOMEEND NOME,'||norm('NOMEEND')||' NORM FROM TSIEND))'
    INTO v_candidates_end,v_collisions_end;

  IF v_candidates_bai<>c_bai OR v_candidates_end<>c_end
     OR v_collisions_bai<>0 OR v_collisions_end<>0 THEN
    RAISE_APPLICATION_ERROR(-20425,
      'Estado mudou desde R04; candidatos BAI='||v_candidates_bai||
      ', END='||v_candidates_end||'; grupos BAI='||v_collisions_bai||
      ', END='||v_collisions_end||'. Gere novo plano/preflight.');
  END IF;

  INSERT INTO BKP_RMD_PAD_TSIBAI
  SELECT c_id,SYSTIMESTAMP,SYS_CONTEXT('USERENV','SESSION_USER'),ROWIDTOCHAR(b.ROWID),b.*
    FROM TSIBAI b
    JOIN (
      SELECT RID FROM (
        SELECT ROWIDTOCHAR(x.ROWID) RID,x.NOMEBAI NOME,
               REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(x.NOMEBAI),
                 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                 'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                 ' {2,}',' ') NORM,
               COUNT(*) OVER(PARTITION BY REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(x.NOMEBAI),
                 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                 'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                 ' {2,}',' ')) QTD
          FROM TSIBAI x
      ) WHERE QTD=1 AND DECODE(NOME,NORM,0,1)=1
    ) candidatos ON candidatos.RID=ROWIDTOCHAR(b.ROWID);
  v_backup_bai:=SQL%ROWCOUNT;
  IF v_backup_bai<>c_bai THEN
    RAISE_APPLICATION_ERROR(-20426,'Backup BAI diverge do preflight R04.');
  END IF;

  INSERT INTO BKP_RMD_PAD_TSIEND
  SELECT c_id,SYSTIMESTAMP,SYS_CONTEXT('USERENV','SESSION_USER'),ROWIDTOCHAR(e.ROWID),e.*
    FROM TSIEND e
    JOIN (
      SELECT RID FROM (
        SELECT ROWIDTOCHAR(x.ROWID) RID,x.TIPO,x.NOMEEND NOME,
               REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(x.NOMEEND),
                 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                 'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                 ' {2,}',' ') NORM,
               COUNT(*) OVER(PARTITION BY x.TIPO,REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(x.NOMEEND),
                 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                 'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                 ' {2,}',' ')) QTD
          FROM TSIEND x
      ) WHERE QTD=1 AND DECODE(NOME,NORM,0,1)=1
    ) candidatos ON candidatos.RID=ROWIDTOCHAR(e.ROWID);
  v_backup_end:=SQL%ROWCOUNT;
  IF v_backup_end<>c_end THEN
    RAISE_APPLICATION_ERROR(-20427,'Backup END diverge do preflight R04.');
  END IF;

  MERGE INTO TSIBAI b
  USING (
    SELECT ROWID_ORIGINAL,NOMEBAI,
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
             ' {2,}',' ') NORM
      FROM BKP_RMD_PAD_TSIBAI WHERE ID_EXECUCAO=c_id
  ) x
  ON (ROWIDTOCHAR(b.ROWID)=x.ROWID_ORIGINAL)
  WHEN MATCHED THEN UPDATE SET b.NOMEBAI=x.NORM
    WHERE DECODE(b.NOMEBAI,x.NOMEBAI,1,0)=1;
  v_updated_bai:=SQL%ROWCOUNT;
  IF v_updated_bai<>v_backup_bai THEN
    RAISE_APPLICATION_ERROR(-20428,'Atualizacao BAI diverge do backup; lote sera revertido.');
  END IF;

  MERGE INTO TSIEND e
  USING (
    SELECT ROWID_ORIGINAL,NOMEEND,
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
             ' {2,}',' ') NORM
      FROM BKP_RMD_PAD_TSIEND WHERE ID_EXECUCAO=c_id
  ) x
  ON (ROWIDTOCHAR(e.ROWID)=x.ROWID_ORIGINAL)
  WHEN MATCHED THEN UPDATE SET e.NOMEEND=x.NORM
    WHERE DECODE(e.NOMEEND,x.NOMEEND,1,0)=1;
  v_updated_end:=SQL%ROWCOUNT;
  IF v_updated_end<>v_backup_end THEN
    RAISE_APPLICATION_ERROR(-20429,'Atualizacao END diverge do backup; lote sera revertido.');
  END IF;

  EXECUTE IMMEDIATE
    'SELECT COUNT(CASE WHEN QTD=1 AND DECODE(NOME,NORM,0,1)=1 THEN 1 END), '
    ||'COUNT(DISTINCT CASE WHEN QTD>1 THEN NORM END) FROM ('
    ||'SELECT NOME,NORM,COUNT(*) OVER(PARTITION BY NORM) QTD FROM ('
    ||'SELECT NOMEBAI NOME,'||norm('NOMEBAI')||' NORM FROM TSIBAI))'
    INTO v_remaining_bai,v_collisions_bai;

  EXECUTE IMMEDIATE
    'SELECT COUNT(CASE WHEN QTD=1 AND DECODE(NOME,NORM,0,1)=1 THEN 1 END), '
    ||'COUNT(DISTINCT CASE WHEN QTD>1 THEN '
    ||'NVL(TO_CHAR(LENGTH(TIPO)),''-1'')||'':''||NVL(TIPO,'''')||'':''||'
    ||'NVL(TO_CHAR(LENGTH(NORM)),''-1'')||'':''||NVL(NORM,'''') END) FROM ('
    ||'SELECT TIPO,NOME,NORM,COUNT(*) OVER(PARTITION BY TIPO,NORM) QTD FROM ('
    ||'SELECT TIPO,NOMEEND NOME,'||norm('NOMEEND')||' NORM FROM TSIEND))'
    INTO v_remaining_end,v_collisions_end;

  IF v_remaining_bai<>0 OR v_remaining_end<>0
     OR v_collisions_bai<>0 OR v_collisions_end<>0 THEN
    RAISE_APPLICATION_ERROR(-20430,'Pos-validacao 29/30 falhou; lote sera revertido.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO='||c_id);
  DBMS_OUTPUT.PUT_LINE('BACKUP_BAIRROS='||v_backup_bai||'; ATUALIZADOS='||v_updated_bai);
  DBMS_OUTPUT.PUT_LINE('BACKUP_ENDERECOS='||v_backup_end||'; ATUALIZADOS='||v_updated_end);
  DBMS_OUTPUT.PUT_LINE('COLISOES_BAIRROS_REMANESCENTES='||v_collisions_bai);
  DBMS_OUTPUT.PUT_LINE('COLISOES_ENDERECOS_REMANESCENTES='||v_collisions_end);
  DBMS_OUTPUT.PUT_LINE('CANDIDATOS_NAO_NORMALIZADOS_BAIRROS='||v_remaining_bai);
  DBMS_OUTPUT.PUT_LINE('CANDIDATOS_NAO_NORMALIZADOS_ENDERECOS='||v_remaining_end);
  DBMS_OUTPUT.PUT_LINE('STATUS=NORMALIZACAO_REMANESCENTE_CONCLUIDA');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
