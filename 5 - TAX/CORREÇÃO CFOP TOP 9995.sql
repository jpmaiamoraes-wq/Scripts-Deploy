UPDATE TGFITE I
   SET I.CODCFO = (
       SELECT XT.CFOP_TAG
       FROM TGFNFE X
       INNER JOIN TGFCAB C ON C.CHAVENFE = X.CHAVENFE
       CROSS JOIN XMLTABLE(
           XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe'),
           '(/nfeProc/NFe/infNFe/det | /NFe/infNFe/det)'
           PASSING XMLTYPE(X.XML)
           COLUMNS 
               NITEM     VARCHAR2(10) PATH '@nItem',
               CFOP_TAG  VARCHAR2(10) PATH 'prod/CFOP'
       ) XT
       WHERE C.NUNOTA = I.NUNOTA
         AND TO_NUMBER(I.SEQUENCIA) = TO_NUMBER(XT.NITEM)   -- vínculo direto com o item
         AND XT.CFOP_TAG IS NOT NULL
         AND NVL(I.CODCFO, -1) <> NVL(XT.CFOP_TAG, -1)
         AND C.CODTIPOPER IN (9995)
         
   )
 WHERE EXISTS (
       SELECT 1
       FROM TGFNFE X
	   INNER JOIN TGFCAB C ON C.CHAVENFE = X.CHAVENFE
       CROSS JOIN XMLTABLE(
           XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe'),
           '(/nfeProc/NFe/infNFe/det | /NFe/infNFe/det)'
           PASSING XMLTYPE(X.XML)
           COLUMNS 
               NITEM     VARCHAR2(10) PATH '@nItem',
               CFOP_TAG  VARCHAR2(10) PATH 'prod/CFOP'
       ) XT
       WHERE C.NUNOTA = I.NUNOTA
         AND TO_NUMBER(I.SEQUENCIA) = TO_NUMBER(XT.NITEM)
         AND XT.CFOP_TAG IS NOT NULL
         AND NVL(I.CODCFO, -1) <> NVL(XT.CFOP_TAG, -1)
         AND C.CODTIPOPER IN (9995)
   );