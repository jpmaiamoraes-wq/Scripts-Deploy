SELECT 17 AS CARD,
       'Itens sem Tabela de Preço' AS INDICADOR,
       COUNT(*) AS QTD
FROM (
    SELECT
        X.CODPROD,
        X.DESCRPROD,
        X.USOPROD,
        X.DESC_USOPROD,
        X.AD_IDEXTERNO,
        X.AD_ORIGDEPLOY
    FROM (
        SELECT DISTINCT
            P.CODPROD,
            P.DESCRPROD,
            P.USOPROD,
            OPC.OPCAO AS DESC_USOPROD,
            P.AD_IDEXTERNO,
            P.AD_ORIGDEPLOY,
            C.CODTIPOPER
        FROM TGFITE I
        JOIN TGFCAB C ON C.NUNOTA = I.NUNOTA
        JOIN TGFPRO P ON P.CODPROD = I.CODPROD
        LEFT JOIN TDDCAM CAM
          ON CAM.NOMETAB = 'TGFPRO'
         AND CAM.NOMECAMPO = 'USOPROD'
        LEFT JOIN TDDOPC OPC
          ON OPC.NUCAMPO = CAM.NUCAMPO
         AND OPC.VALOR = P.USOPROD
        WHERE C.TIPMOV = 'V'
          AND NOT EXISTS (
              SELECT 1
              FROM TGFEXC E
              WHERE E.CODPROD = P.CODPROD
          )
    ) X
    GROUP BY
        X.CODPROD,
        X.DESCRPROD,
        X.USOPROD,
        X.DESC_USOPROD,
        X.AD_IDEXTERNO,
        X.AD_ORIGDEPLOY
)

UNION ALL

SELECT 18 AS CARD,
       'Itens com Descrição Similar' AS INDICADOR,
       COUNT(*) AS QTD
FROM (
    WITH PROD_HASH AS (
        SELECT CODPROD,
               DESCRPROD,
               AD_IDEXTERNO,
               NCM,
               CODPARCFORN,
               AD_ORIGDEPLOY,
               ORA_HASH(UPPER(REGEXP_REPLACE(DESCRPROD, '[^A-Z0-9 ]', '')), 999999) AS HASH_DESCR,
               UPPER(REGEXP_REPLACE(DESCRPROD, '[^A-Z0-9 ]', '')) AS DESCRNORM,
               (SELECT COUNT(1)
                  FROM TGFITE I
                  INNER JOIN TGFCAB C ON I.NUNOTA = C.NUNOTA
                 WHERE I.CODPROD = TGFPRO.CODPROD
                   AND C.TIPMOV = 'C') AS QTDCOMPRA,
               (SELECT COUNT(1)
                  FROM TGFITE I
                  INNER JOIN TGFCAB C ON I.NUNOTA = C.NUNOTA
                 WHERE I.CODPROD = TGFPRO.CODPROD
                   AND C.TIPMOV = 'V') AS QTDVENDA
        FROM TGFPRO
    )
    SELECT A.CODPROD AS CODPROD_A,
           B.CODPROD AS CODPROD_B
    FROM PROD_HASH A
    JOIN PROD_HASH B
      ON A.HASH_DESCR = B.HASH_DESCR
     AND A.CODPROD < B.CODPROD
    WHERE UTL_MATCH.JARO_WINKLER_SIMILARITY(A.DESCRNORM, B.DESCRNORM) > 85
)

UNION ALL

SELECT 19 AS CARD,
       'CNPJ Matrizes' AS INDICADOR,
       COUNT(*) AS QTD
FROM TGFPAR P
WHERE SUBSTR(P.CGC_CPF, 9, 4) = '0001'
  AND LENGTH(P.CGC_CPF) = 14
  AND SUBSTR(P.CGC_CPF, 1, 8) <> '00000000'
  AND EXISTS (
      SELECT 1
      FROM TGFPAR F
      WHERE SUBSTR(F.CGC_CPF, 1, 8) = SUBSTR(P.CGC_CPF, 1, 8)
        AND SUBSTR(F.CGC_CPF, 9, 4) <> '0001'
        AND LENGTH(F.CGC_CPF) = 14
  )

UNION ALL

SELECT 20 AS CARD,
       'Produtos Comprados sem Registro de Saída' AS INDICADOR,
       COUNT(*) AS QTD
FROM (
    SELECT DISTINCT I.CODPROD
    FROM TGFITE I
    JOIN TGFCAB C ON C.NUNOTA = I.NUNOTA
    JOIN TGFPRO P ON P.CODPROD = I.CODPROD
    WHERE C.TIPMOV = 'C'
      AND NOT EXISTS (
          SELECT 1
          FROM TGFITE IC
          JOIN TGFCAB CC
            ON CC.NUNOTA = IC.NUNOTA
           AND CC.TIPMOV = 'V'
          WHERE IC.CODPROD = I.CODPROD
      )
)

UNION ALL

SELECT 21 AS CARD,
       'Regras Tributárias Inseridas' AS INDICADOR,
       COUNT(*) AS QTD
FROM TTKPITI
