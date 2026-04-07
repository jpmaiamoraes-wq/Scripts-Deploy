 INSERT INTO TGFNUM (ARQUIVO, CODEMP, SERIE, NOMEARQ, AUTOMATICO, ULTCOD, TIPOIMPRESSORA, IMPNOTA, TOTITENSNOTA,
                     TOTSERVNOTA, ULTNOTATALAO, MODNOTAFIS, QTDAVISO, CODMAQ, CODMODDOC, DIASAVISO, DTVAL) 
  SELECT DISTINCT 
         'SEMNUM'       AS ARQUIVO,
         C.CODEMP,
         C.SERIENOTA    AS SERIE, 
         NULL           AS NOMEARQ,
         'N'            AS AUTOMATICO,
         0              AS ULTCOD,
         1              AS TIPOIMPRESSORA,
         NULL           AS IMPNOTA,
         NULL           AS TOTITENSNOTA,
         NULL           AS TOTSERVNOTA,
         999999999      AS ULTNOTATALAO,
         NULL           AS MODNOTAFIS,
         0              AS QTDAVISO,
         NULL           AS CODMAQ,
         0              AS CODMODDOC,
         NULL           AS DIASAVISO,
         NULL           AS DTVAL
    FROM TGFCAB C
   WHERE C.TIPMOV = 'C'
     AND NOT EXISTS (SELECT 1 FROM TGFNUM WHERE ARQUIVO = 'SEMNUM' 
                                            AND  CODEMP = C.CODEMP 
                                            AND SERIE = C.SERIENOTA 
                                            AND CODMODDOC = 0);