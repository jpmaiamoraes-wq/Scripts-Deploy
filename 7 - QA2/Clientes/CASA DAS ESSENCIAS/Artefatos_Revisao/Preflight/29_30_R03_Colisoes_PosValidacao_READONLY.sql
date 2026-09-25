SELECT 'TSIBAI_GRUPOS_DUP_CODREG_NOME' OBJETO, COUNT(*) QTD
  FROM (
    SELECT CODREG,
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUU')),' {2,}',' ') NORM,
           COUNT(*) QTD
      FROM SANKHYA.TSIBAI
     GROUP BY CODREG,
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUU')),' {2,}',' ')
    HAVING COUNT(*)>1
  )
UNION ALL
SELECT 'TSIEND_GRUPOS_DUP_TIPO_CODLOGRADOURO_NOME', COUNT(*)
  FROM (
    SELECT TIPO, NVL(CODLOGRADOURO,'<NULL>'),
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUU')),' {2,}',' ') NORM,
           COUNT(*) QTD
      FROM SANKHYA.TSIEND
     GROUP BY TIPO, NVL(CODLOGRADOURO,'<NULL>'),
           REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUU')),' {2,}',' ')
    HAVING COUNT(*)>1
  )
