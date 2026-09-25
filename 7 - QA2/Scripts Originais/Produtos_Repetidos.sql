UPDATE TGFITE I 
--SELECT TGFITE I
   SET I.CODPROD = (SELECT MIN(CODPROD) 
                      FROM TGFPRO 
                     WHERE DESCRPROD = (SELECT DESCRPROD FROM TGFPRO WHERE CODPROD = I.CODPROD) 
                       AND AD_IDEXTERNO = (SELECT AD_IDEXTERNO FROM TGFPRO WHERE CODPROD = I.CODPROD))
WHERE I.CODPROD IN (SELECT P.CODPROD
                      FROM TGFPRO P
                     WHERE P.DESCRPROD IN (SELECT DESCRPROD
                                            FROM TGFPRO
                                        GROUP BY DESCRPROD
                                    HAVING COUNT(1) > 1))
  AND I.CODPROD NOT IN (SELECT MIN(CODPROD) 
                          FROM TGFPRO 
                         WHERE DESCRPROD = (SELECT DESCRPROD FROM TGFPRO WHERE CODPROD = I.CODPROD) 
                           AND AD_IDEXTERNO = (SELECT AD_IDEXTERNO FROM TGFPRO WHERE CODPROD = I.CODPROD));
 -- AND I.CODPROD IN (102,103,107);

DELETE TGFPRO P                        
--DELETE TGFEXC P
--SELECT DESCRPROD, USOPROD FROM TGFPRO P
--SELECT * FROM TGFEXC P
 WHERE P.CODPROD IN (SELECT CODPROD
                       FROM TGFPRO
                      WHERE DESCRPROD IN (SELECT DESCRPROD
                                            FROM TGFPRO
                                        GROUP BY DESCRPROD
                                          HAVING COUNT(1) > 1))
   AND P.CODPROD NOT IN (SELECT PRO.CODPROD
                           FROM TGFPRO PRO
                          WHERE PRO.DESCRPROD IN (SELECT DESCRPROD
                                                    FROM TGFPRO
                                                GROUP BY DESCRPROD
                                                  HAVING COUNT(1) > 1)                    
                            AND PRO.CODPROD = (SELECT MIN(CODPROD) 
                                              FROM TGFPRO 
                                             WHERE DESCRPROD = PRO.DESCRPROD 
                                               AND AD_IDEXTERNO = PRO.AD_IDEXTERNO))
   AND P.AD_IDEXTERNO IS NOT NULL
   AND P.USOPROD NOT IN ('S', '3')
;