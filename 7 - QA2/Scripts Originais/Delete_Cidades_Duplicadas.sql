/* Testado em base depois de ter rodado script de padronização dos nomes */
   UPDATE TGFPAR P
      SET P.CODCID = (NVL((SELECT MIN(CODCID) 
                             FROM TSICID 
                            WHERE NOMECID = (SELECT NOMECID FROM TSICID WHERE CODCID = P.CODCID)
                              AND DDD = SUBSTR(P.TELEFONE, 1, 2)), 
                        (SELECT 
                            MIN(CODCID) 
                           FROM TSICID 
                          WHERE NOMECID = (SELECT NOMECID FROM TSICID WHERE CODCID = P.CODCID))))
    WHERE EXISTS (SELECT 1 
                    FROM TSICID 
                   WHERE CODCID = P.CODCID 
                     AND CODMUNSIAFI IS NULL 
                     AND DDD IS NULL 
                     AND DESCRICAOCORREIO IS NULL);
                     
    DELETE TSICID C
     WHERE C.CODMUNSIAFI IS NULL
       AND C.DDD IS NULL 
       AND C.DESCRICAOCORREIO IS NULL
       AND NOT EXISTS (SELECT 1 FROM TGFPAR WHERE CODCID = C.CODCID); COMMIT;
  

  
  
  
  WHERE CODCID IN (SELECT CODCI 
                      FROM TSICID 
                     WHERE CODMUNSIAFI IS NULL
                       AND UPPER(NOMECID) <> 'EXTERIOR'
                       AND DDD IS NULL
                       AND DESCRICAOCORREIO IS NULL); COMMIT;