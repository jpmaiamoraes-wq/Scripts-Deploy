WITH N AS (
       SELECT CODBAI,
              NOMEBAI,
              REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                ' {2,}',' ') AS NORM
         FROM TSIBAI
     ), G AS (
       SELECT NORM,
              COUNT(*) AS QTD_REGISTROS,
              MIN(CODBAI) AS MENOR_CODBAI,
              MAX(CODBAI) AS MAIOR_CODBAI
         FROM N
        GROUP BY NORM
       HAVING COUNT(*) > 1
     )
SELECT G.NORM,
       G.QTD_REGISTROS,
       G.MENOR_CODBAI,
       G.MAIOR_CODBAI,
       N.CODBAI,
       N.NOMEBAI,
       ROW_NUMBER() OVER (PARTITION BY N.NORM ORDER BY N.CODBAI) AS ORDEM_NO_GRUPO
  FROM G
  JOIN N ON N.NORM = G.NORM
 ORDER BY G.NORM, N.CODBAI
