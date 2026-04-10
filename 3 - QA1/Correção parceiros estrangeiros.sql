/*========================================
DELETE DOS ESTADOS ESTRANGEIROS DUPLICADOS
==========================================*/

BEGIN
  FOR i IN (
    SELECT 
      U.CODUF,
      U.CODPAIS,
      -- Busca o menor CODUF para cada país (o que será mantido)
      MIN(U.CODUF) OVER (PARTITION BY U.CODPAIS) AS MENOR
    FROM TSIUFS U
    WHERE U.CODPAIS <> 55
  )
  LOOP
    -- Só entra na lógica se o registro atual NÃO for o menor (ou seja, é um duplicado)
    IF i.CODUF <> i.MENOR THEN
      
      -- Etapa 1: Atualiza referências na TGFICM
      UPDATE TGFICM 
         SET UFDEST = i.MENOR 
       WHERE UFDEST = i.CODUF;
      
      -- Etapa 3: Deleta o estado duplicado
      DELETE FROM TSIUFS 
       WHERE CODUF = i.CODUF;
       
    END IF;
  END LOOP; 
END;

/*========================================
    INSERÇÃO DAS CIDADES PARA CADA PAIS
==========================================*/

INSERT INTO TSICID (CODCID, UF, NOMECID, DTALTER, CODMUNFIS)
SELECT 
    -- 1. Gerar um novo CODCID (Ex: Sequencia ou valor baseado no CODUF + offset)
    (U.CODUF + 16000) AS CODCID, 
    -- 2. UF (Sigla do Estado)
    U.CODUF, 
    -- 3. Nome da Cidade (EX - Nome do País)
    'EXTERIOR - ' || (SELECT P.DESCRICAO FROM TSIPAI P WHERE P.CODPAIS = U.CODPAIS) AS NOMECID, 
    -- 4. Data de Alteração
    TO_DATE('10/04/2026', 'DD/MM/YYYY') AS DTALTER, 
    -- 5. Código de Município Fiscal (9999999 para exterior)
    9999999 AS CODMUNFIS
FROM TSIUFS U
WHERE U.CODPAIS <> 55
AND U.CODUF <> 30;

/*============================================
SELECT PARA DESCOBRIR O CODCID CERTO DA TGFPAR
==============================================*/

SELECT * FROM (
    SELECT DISTINCT 
        P.CODPARC,
        P.RAZAOSOCIAL,
        XT.PAIS_XML,
        PAI.DESCRICAO AS PAIS_SISTEMA,
        CID.CODCID AS CODCID_SUGERIDO,
        CID.NOMECID,
        -- Cria um ranking para evitar que um parceiro apareça 50 vezes se o país tiver 50 estados
        ROW_NUMBER() OVER (PARTITION BY P.CODPARC ORDER BY CID.CODCID) AS RANK_SUGESTAO
    FROM TGFCAB C
    JOIN TGFNFE X ON X.CHAVENFE = C.CHAVENFE
    JOIN TGFPAR P ON P.CODPARC = C.CODPARC
    CROSS JOIN XMLTABLE(
        XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe'),
        '(/nfeProc/NFe/infNFe/dest | /NFe/infNFe/dest)'
        PASSING XMLTYPE(X.XML)
        COLUMNS
            PAIS_XML VARCHAR2(100) PATH 'enderDest/xPais'
    ) XT
    JOIN TSIPAI PAI ON (UTL_MATCH.JARO_WINKLER_SIMILARITY(UPPER(PAI.DESCRICAO), UPPER(XT.PAIS_XML)) > 80)
    JOIN TSIUFS UFS ON UFS.CODPAIS = PAI.CODPAIS
    JOIN TSICID CID ON CID.UF = UFS.CODUF 
    WHERE PAI.CODPAIS <> 55
      -- Removi o filtro de CODCID fixo para você encontrar os parceiros que precisam de correção
      AND (P.CODCID = 15788 OR 1=1) 
) 
WHERE RANK_SUGESTAO = 1 -- Pega apenas a primeira cidade encontrada para aquele país
ORDER BY RAZAOSOCIAL;