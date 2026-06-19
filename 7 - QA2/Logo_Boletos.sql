CREATE OR REPLACE FUNCTION FNC_BLOB_TO_CLOB(p_blob BLOB)
RETURN CLOB
IS
  v_clob        CLOB;
  v_dest_offset INTEGER := 1;
  v_src_offset  INTEGER := 1;
  v_lang_ctx    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
  v_warning     INTEGER;
BEGIN
  DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

  DBMS_LOB.CONVERTTOCLOB(
    dest_lob     => v_clob,
    src_blob     => p_blob,
    amount       => DBMS_LOB.LOBMAXSIZE,
    dest_offset  => v_dest_offset,
    src_offset   => v_src_offset,
    blob_csid    => NLS_CHARSET_ID('AL32UTF8'),
    lang_context => v_lang_ctx,
    warning      => v_warning
  );

  RETURN v_clob;
END;
/

SELECT DISTINCT
       X.NURFE,
       TO_CHAR(X.ARQUIVO_IMAGEM_CLOB) AS ARQUIVO_IMAGEM
FROM (
    SELECT R.NURFE,
           REGEXP_SUBSTR(
             FNC_BLOB_TO_CLOB(R.ARQUIVOBIN),
             '\$P\{PDIR_MODELO\}\s*\+\s*"([^"]+\.(png|jpg|jpeg|gif|bmp))"',
             1,
             LEVEL,
             'i',
             1
           ) AS ARQUIVO_IMAGEM_CLOB
    FROM TSIRFA R
    JOIN TSIRFE E ON E.NURFE = R.NURFE
    WHERE UPPER(R.NOME) LIKE '%BOL%'
    CONNECT BY LEVEL <= REGEXP_COUNT(
                          FNC_BLOB_TO_CLOB(R.ARQUIVOBIN),
                          '\$P\{PDIR_MODELO\}\s*\+\s*"[^"]+\.(png|jpg|jpeg|gif|bmp)"',
                          1,
                          'i'
                        )
           AND PRIOR R.NURFE = R.NURFE
           AND PRIOR SYS_GUID() IS NOT NULL
) X
WHERE X.ARQUIVO_IMAGEM_CLOB IS NOT NULL
ORDER BY 1
;



SELECT * from tsirfa where nurfe = 170;







