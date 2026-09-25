SELECT CODMUNFIS,
       COUNT(*) AS QTD,
       RTRIM(
         XMLAGG(
           XMLELEMENT(e, CODCID || ' - ' || NOMECID || ' - ' || UF || ', ')
           ORDER BY CODCID
         ).getClobVal(),
         ', '
       ) AS CIDADES
  FROM TSICID
 WHERE CODMUNFIS IS NOT NULL
 GROUP BY CODMUNFIS
HAVING COUNT(*) > 1
 ORDER BY CODMUNFIS;
