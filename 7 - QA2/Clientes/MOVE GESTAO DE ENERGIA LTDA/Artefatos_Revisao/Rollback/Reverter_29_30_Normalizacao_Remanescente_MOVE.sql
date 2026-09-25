-- Reversao autocontida da normalizacao residual MOVE; fora da allowlist normal.
-- Restaura somente NOMEBAI/NOMEEND dos ROWIDs respaldados por esta execucao.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  c_id CONSTANT VARCHAR2(30) := 'MOVE_NORM2930_20260923_01';
  c_bai CONSTANT PLS_INTEGER := 413;
  c_end CONSTANT PLS_INTEGER := 6877;
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_backup_bai PLS_INTEGER;
  v_backup_end PLS_INTEGER;
  v_ready_bai PLS_INTEGER;
  v_ready_end PLS_INTEGER;
  v_restored_bai PLS_INTEGER;
  v_restored_end PLS_INTEGER;

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
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MOVEENERGIAPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20440,'Identidade MOVE divergente; reversao bloqueada.');
  END IF;

  SELECT COUNT(*) INTO v_backup_bai FROM BKP_RMD_PAD_TSIBAI WHERE ID_EXECUCAO=c_id;
  SELECT COUNT(*) INTO v_backup_end FROM BKP_RMD_PAD_TSIEND WHERE ID_EXECUCAO=c_id;
  IF v_backup_bai<>c_bai OR v_backup_end<>c_end THEN
    RAISE_APPLICATION_ERROR(-20441,'Backups da normalizacao ausentes ou divergentes.');
  END IF;

  EXECUTE IMMEDIATE
    'SELECT COUNT(*) FROM TSIBAI t JOIN BKP_RMD_PAD_TSIBAI b '
    ||'ON b.ID_EXECUCAO=:id AND ROWIDTOCHAR(t.ROWID)=b.ROWID_ORIGINAL '
    ||'WHERE DECODE(t.NOMEBAI,'||norm('b.NOMEBAI')||',1,0)=1'
    INTO v_ready_bai USING c_id;
  EXECUTE IMMEDIATE
    'SELECT COUNT(*) FROM TSIEND t JOIN BKP_RMD_PAD_TSIEND b '
    ||'ON b.ID_EXECUCAO=:id AND ROWIDTOCHAR(t.ROWID)=b.ROWID_ORIGINAL '
    ||'WHERE DECODE(t.NOMEEND,'||norm('b.NOMEEND')||',1,0)=1'
    INTO v_ready_end USING c_id;
  IF v_ready_bai<>c_bai OR v_ready_end<>c_end THEN
    RAISE_APPLICATION_ERROR(-20442,'Linhas mudaram depois da normalizacao; reversao requer analise.');
  END IF;

  MERGE INTO TSIBAI t
  USING (SELECT ROWID_ORIGINAL,NOMEBAI,
                REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                  'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                  'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                  ' {2,}',' ') NORM
           FROM BKP_RMD_PAD_TSIBAI WHERE ID_EXECUCAO=c_id) b
     ON (ROWIDTOCHAR(t.ROWID)=b.ROWID_ORIGINAL)
   WHEN MATCHED THEN UPDATE SET t.NOMEBAI=b.NOMEBAI
    WHERE DECODE(t.NOMEBAI,b.NORM,1,0)=1;
  v_restored_bai:=SQL%ROWCOUNT;
  IF v_restored_bai<>c_bai THEN
    RAISE_APPLICATION_ERROR(-20443,'Restauracao BAI diverge do backup.');
  END IF;

  MERGE INTO TSIEND t
  USING (SELECT ROWID_ORIGINAL,NOMEEND,
                REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
                  'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                  'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                  ' {2,}',' ') NORM
           FROM BKP_RMD_PAD_TSIEND WHERE ID_EXECUCAO=c_id) b
     ON (ROWIDTOCHAR(t.ROWID)=b.ROWID_ORIGINAL)
   WHEN MATCHED THEN UPDATE SET t.NOMEEND=b.NOMEEND
    WHERE DECODE(t.NOMEEND,b.NORM,1,0)=1;
  v_restored_end:=SQL%ROWCOUNT;
  IF v_restored_end<>c_end THEN
    RAISE_APPLICATION_ERROR(-20444,'Restauracao END diverge do backup.');
  END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO_REVERTIDA='||c_id);
  DBMS_OUTPUT.PUT_LINE('BAIRROS_RESTAURADOS='||v_restored_bai);
  DBMS_OUTPUT.PUT_LINE('ENDERECOS_RESTAURADOS='||v_restored_end);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
