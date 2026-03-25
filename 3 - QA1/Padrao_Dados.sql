UPDATE TGFPAR
SET RAZAOSOCIAL = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(RAZAOSOCIAL),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ),
    NOMEPARC = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(NOMEPARC),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ),
       EMAIL = LOWER(EMAIL); COMMIT;
      
UPDATE TGFPRO
SET DESCRPROD = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(DESCRPROD),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ),
    COMPLDESC = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(COMPLDESC),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ); COMMIT;
    
UPDATE TGFTIT
SET DESCRTIPTIT = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(DESCRTIPTIT),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ); COMMIT;

UPDATE TSICID
SET NOMECID = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(NOMECID),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ),
    DESCRICAOCORREIO = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(DESCRICAOCORREIO),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ); COMMIT; 
     
UPDATE TSIBAI
SET NOMEBAI = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(NOMEBAI),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ); COMMIT;
    
UPDATE TSIEND
   SET NOMEEND = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(NOMEEND),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ); COMMIT;

UPDATE TGFTPV
   SET DESCRTIPVENDA = REGEXP_REPLACE(
                        TRIM(
                          TRANSLATE(
                            UPPER(DESCRTIPVENDA),
                            'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
                            'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU'
                          )
                        ),
                        ' {2,}', ' '
                      ); COMMIT;