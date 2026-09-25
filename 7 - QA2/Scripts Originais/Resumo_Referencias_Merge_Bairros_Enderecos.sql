
SET SERVEROUTPUT ON SIZE UNLIMITED
SET PAGESIZE 200
SET LINESIZE 220
SET FEEDBACK ON

PROMPT === TOTAIS DE GRUPOS E REGISTROS OBSOLETOS ===
WITH b AS (
  SELECT CODBAI,
         REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
           'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
           'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
           ' {2,}', ' ') NORM
    FROM TSIBAI
), g AS (
  SELECT NORM, COUNT(*) QTD FROM b GROUP BY NORM HAVING COUNT(*) > 1
)
SELECT COUNT(*) GRUPOS_BAIRRO, SUM(QTD - 1) OBSOLETOS_BAIRRO FROM g;

WITH e AS (
  SELECT CODEND, TIPO,
         REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
           'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
           'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
           ' {2,}', ' ') NORM
    FROM TSIEND
), g AS (
  SELECT TIPO, NORM, COUNT(*) QTD FROM e GROUP BY TIPO, NORM HAVING COUNT(*) > 1
)
SELECT COUNT(*) GRUPOS_ENDERECO, SUM(QTD - 1) OBSOLETOS_ENDERECO FROM g;

PROMPT === TABELAS FISICAS COM REFERENCIAS NAO ZERO ===
DECLARE
  v_sql   VARCHAR2(32767);
  v_count NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('TIPO|TABELA|COLUNA|LINHAS_REFERENCIADAS');

  FOR r IN (
    SELECT DISTINCT c.table_name, c.column_name
      FROM all_tab_columns c
      JOIN all_tables t
        ON t.owner = c.owner
       AND t.table_name = c.table_name
     WHERE c.owner = 'SANKHYA'
       AND c.column_name IN ('CODBAI', 'CODEND')
       AND c.table_name NOT IN ('TSIBAI', 'TSIEND')
     ORDER BY c.column_name, c.table_name
  ) LOOP
    BEGIN
      IF r.column_name = 'CODBAI' THEN
        v_sql :=
          'SELECT COUNT(*) FROM SANKHYA.' || DBMS_ASSERT.SIMPLE_SQL_NAME(r.table_name) || ' x ' ||
          'WHERE x.CODBAI IN (' ||
          'SELECT CODBAI FROM (' ||
          'SELECT CODBAI, MIN(CODBAI) OVER (PARTITION BY REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),' ||
          '''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'',' ||
          '''AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'')),'' {2,}'','' '')) KEEP_ID,' ||
          'COUNT(*) OVER (PARTITION BY REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),' ||
          '''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'',' ||
          '''AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'')),'' {2,}'','' '')) CNT ' ||
          'FROM TSIBAI) WHERE CNT > 1 AND CODBAI <> KEEP_ID)';
      ELSE
        v_sql :=
          'SELECT COUNT(*) FROM SANKHYA.' || DBMS_ASSERT.SIMPLE_SQL_NAME(r.table_name) || ' x ' ||
          'WHERE x.CODEND IN (' ||
          'SELECT CODEND FROM (' ||
          'SELECT CODEND, MIN(CODEND) OVER (PARTITION BY TIPO, REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),' ||
          '''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'',' ||
          '''AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'')),'' {2,}'','' '')) KEEP_ID,' ||
          'COUNT(*) OVER (PARTITION BY TIPO, REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),' ||
          '''ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû'',' ||
          '''AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'')),'' {2,}'','' '')) CNT ' ||
          'FROM TSIEND) WHERE CNT > 1 AND CODEND <> KEEP_ID)';
      END IF;

      EXECUTE IMMEDIATE v_sql INTO v_count;
      IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE(
          CASE r.column_name WHEN 'CODBAI' THEN 'BAIRRO' ELSE 'ENDERECO' END || '|' ||
          r.table_name || '|' || r.column_name || '|' || v_count
        );
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('NAO_LIDA|' || r.table_name || '|' || r.column_name || '|' || SQLERRM);
    END;
  END LOOP;
END;
/

PROMPT === FIM DO RESUMO SOMENTE LEITURA ===
