WITH N AS (
       SELECT CODBAI,
              CODREG,
              NOMEBAI,
              REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
                ' {2,}',' ') AS NORM
         FROM TSIBAI
     ), G AS (
       SELECT NORM,
              COUNT(*) AS QTD_REGISTROS,
              COUNT(DISTINCT CODREG) AS QTD_CODREG,
              MIN(CODREG) AS MENOR_CODREG,
              MAX(CODREG) AS MAIOR_CODREG,
              MIN(CODBAI) AS MENOR_CODBAI
         FROM N
        GROUP BY NORM
       HAVING COUNT(*) > 1
     )
SELECT G.NORM,
       G.QTD_REGISTROS,
       G.QTD_CODREG,
       G.MENOR_CODREG,
       G.MAIOR_CODREG,
       G.MENOR_CODBAI,
       N.CODBAI,
       N.CODREG,
       N.NOMEBAI,
       ROW_NUMBER() OVER (PARTITION BY N.NORM ORDER BY N.CODBAI) AS ORDEM_NO_GRUPO
  FROM G
  JOIN N ON N.NORM = G.NORM
 ORDER BY G.NORM, N.CODBAI
