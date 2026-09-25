WITH N AS (
       SELECT CODEND,
              TIPO,
              NOMEEND,
              REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
                'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                ' {2,}',' ') AS NORM
         FROM TSIEND
     ), G AS (
       SELECT TIPO,
              NORM,
              COUNT(*) AS QTD_REGISTROS,
              MIN(CODEND) AS MENOR_CODEND,
              MAX(CODEND) AS MAIOR_CODEND
         FROM N
        GROUP BY TIPO, NORM
       HAVING COUNT(*) > 1
     )
SELECT G.TIPO,
       G.NORM,
       G.QTD_REGISTROS,
       G.MENOR_CODEND,
       G.MAIOR_CODEND,
       N.CODEND,
       N.NOMEEND,
       ROW_NUMBER() OVER (PARTITION BY N.TIPO, N.NORM ORDER BY N.CODEND) AS ORDEM_NO_GRUPO
  FROM G
  JOIN N ON N.TIPO = G.TIPO AND N.NORM = G.NORM
 ORDER BY G.TIPO, G.NORM, N.CODEND
