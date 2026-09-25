
		SELECT *
FROM (
    SELECT
        1 AS ORDEM,
        'GERAL' AS SECAO,
        'Total de notas/cabecalhos processados' AS INDICADOR,
        COUNT(*) AS QTD,
        'Registros existentes na TGFCAB' AS OBSERVACAO
    FROM TGFCAB

    UNION ALL

    SELECT
        2 AS ORDEM,
        'GERAL' AS SECAO,
        'Total de itens processados' AS INDICADOR,
        COUNT(*) AS QTD,
        'Registros existentes na TGFITE' AS OBSERVACAO
    FROM TGFITE

    UNION ALL

    SELECT
        3 AS ORDEM,
        'GERAL' AS SECAO,
        'Periodo de movimentacao' AS INDICADOR,
        COUNT(*) AS QTD,
        'De ' || TO_CHAR(MIN(DTNEG), 'DD/MM/YYYY') || ' ate ' || TO_CHAR(MAX(DTNEG), 'DD/MM/YYYY') AS OBSERVACAO
    FROM TGFCAB
    WHERE DTNEG IS NOT NULL

    UNION ALL

    SELECT
        4 AS ORDEM,
        'FINANCEIRO' AS SECAO,
        'Total de registros financeiros' AS INDICADOR,
        COUNT(*) AS QTD,
        'Registros existentes na TGFFIN' AS OBSERVACAO
    FROM TGFFIN

    UNION ALL

    SELECT
        5 AS ORDEM,
        'FINANCEIRO' AS SECAO,
        'Contas a receber' AS INDICADOR,
        COUNT(*) AS QTD,
        'TGFFIN.RECDESP = 1' AS OBSERVACAO
    FROM TGFFIN
    WHERE RECDESP = 1

    UNION ALL

    SELECT
        6 AS ORDEM,
        'FINANCEIRO' AS SECAO,
        'Contas a pagar' AS INDICADOR,
        COUNT(*) AS QTD,
        'TGFFIN.RECDESP = -1' AS OBSERVACAO
    FROM TGFFIN
    WHERE RECDESP = -1

    UNION ALL

    SELECT
        7 AS ORDEM,
        'CADASTROS' AS SECAO,
        'Total de produtos cadastrados' AS INDICADOR,
        COUNT(*) AS QTD,
        'Produtos cadastrados, desconsiderando CODPROD 0' AS OBSERVACAO
    FROM TGFPRO
    WHERE CODPROD <> 0

    UNION ALL

    SELECT
        8 AS ORDEM,
        'CADASTROS' AS SECAO,
        'Total de parceiros cadastrados' AS INDICADOR,
        COUNT(*) AS QTD,
        'Registros existentes na TGFPAR' AS OBSERVACAO
    FROM TGFPAR

    UNION ALL

    SELECT
        9 AS ORDEM,
        'PRODUTOS' AS SECAO,
        'Referencias duplicadas' AS INDICADOR,
        COUNT(*) AS QTD,
        'Referencias com mais de um produto vinculado' AS OBSERVACAO
    FROM (
        SELECT REFERENCIA
        FROM TGFPRO
        WHERE REFERENCIA IS NOT NULL
        GROUP BY REFERENCIA
        HAVING COUNT(*) > 1
    )

    UNION ALL

    SELECT
        10 AS ORDEM,
        'PRODUTOS' AS SECAO,
        'Produtos envolvidos em referencias duplicadas' AS INDICADOR,
        NVL(SUM(QTD), 0) AS QTD,
        'Produtos que compartilham a mesma referencia/codigo de barras' AS OBSERVACAO
    FROM (
        SELECT REFERENCIA, COUNT(*) AS QTD
        FROM TGFPRO
        WHERE REFERENCIA IS NOT NULL
        GROUP BY REFERENCIA
        HAVING COUNT(*) > 1
    )

    UNION ALL

    SELECT
        11 AS ORDEM,
        'PRODUTOS' AS SECAO,
        'Descricoes duplicadas' AS INDICADOR,
        COUNT(*) AS QTD,
        'Descricoes/NCM/origem com mais de um produto' AS OBSERVACAO
    FROM (
        SELECT NCM, DESCRPROD, ORIGPROD
        FROM TGFPRO
        GROUP BY NCM, DESCRPROD, ORIGPROD
        HAVING COUNT(*) > 1
    )

    UNION ALL

    SELECT
        12 AS ORDEM,
        'PRODUTOS' AS SECAO,
        'Produtos envolvidos em descricoes duplicadas' AS INDICADOR,
        NVL(SUM(QTD), 0) AS QTD,
        'Produtos que possuem mesma descricao, NCM e origem' AS OBSERVACAO
    FROM (
        SELECT NCM, DESCRPROD, ORIGPROD, COUNT(*) AS QTD
        FROM TGFPRO
        GROUP BY NCM, DESCRPROD, ORIGPROD
        HAVING COUNT(*) > 1
    )

    UNION ALL

    SELECT
        13 AS ORDEM,
        'PARCEIROS' AS SECAO,
        'CNPJ/CPF repetidos' AS INDICADOR,
        COUNT(*) AS QTD,
        'Grupos de CNPJ/CPF repetidos' AS OBSERVACAO
    FROM (
        SELECT CGC_CPF, IDENTINSCESTAD
        FROM TGFPAR
        WHERE CGC_CPF IS NOT NULL
        GROUP BY CGC_CPF, IDENTINSCESTAD
        HAVING COUNT(*) > 1
    )

    UNION ALL

    SELECT
        14 AS ORDEM,
        'PARCEIROS' AS SECAO,
        'Parceiros envolvidos em CNPJ/CPF repetido' AS INDICADOR,
        NVL(SUM(QTD), 0) AS QTD,
        'Cadastros envolvidos em duplicidade' AS OBSERVACAO
    FROM (
        SELECT CGC_CPF, IDENTINSCESTAD, COUNT(*) AS QTD
        FROM TGFPAR
        WHERE CGC_CPF IS NOT NULL
        GROUP BY CGC_CPF, IDENTINSCESTAD
        HAVING COUNT(*) > 1
    )

    UNION ALL

    SELECT
        15 AS ORDEM,
        'FISCAL' AS SECAO,
        'Classificacao fiscal divergente' AS INDICADOR,
        COUNT(*) AS QTD,
        'Parceiros cuja classificacao ICMS difere da classificacao esperada' AS OBSERVACAO
    FROM (
        SELECT
            P.CODPARC,
            P.CLASSIFICMS,
            CASE
                WHEN P.TIPPESSOA = 'J'
                 AND P.IDENTINSCESTAD IS NOT NULL
                 AND UPPER(P.IDENTINSCESTAD) <> 'ISENTO'
                    THEN 'R'
                WHEN P.TIPPESSOA = 'F'
                 AND P.IDENTINSCESTAD IS NOT NULL
                 AND UPPER(P.IDENTINSCESTAD) <> 'ISENTO'
                    THEN 'P'
                WHEN NVL(P.IDENTINSCESTAD, 'ISENTO') = 'ISENTO'
                    THEN 'C'
            END AS CLASSIFICMS_ESPERADO
        FROM TGFPAR P
    )
    WHERE CLASSIFICMS_ESPERADO IS NOT NULL
      AND CLASSIFICMS <> CLASSIFICMS_ESPERADO

    UNION ALL

    SELECT
        16 AS ORDEM,
        'FINANCEIRO' AS SECAO,
        'Financeiros sem nota' AS INDICADOR,
        COUNT(*) AS QTD,
        'Financeiros cujo NUNOTA nao existe na TGFCAB' AS OBSERVACAO
    FROM (
        SELECT DISTINCT F.NUFIN
        FROM TGFFIN F
        WHERE NOT EXISTS (
            SELECT 1
            FROM TGFCAB C
            WHERE C.NUNOTA = F.NUNOTA
        )
    )

    UNION ALL

    SELECT
        17 AS ORDEM,
        'FINANCEIRO' AS SECAO,
        'Notas sem financeiro' AS INDICADOR,
        COUNT(*) AS QTD,
        'Notas com TOP que atualiza financeiro, mas sem registro na TGFFIN' AS OBSERVACAO
    FROM (
        SELECT DISTINCT C.NUNOTA
        FROM TGFCAB C
        INNER JOIN TGFTOP T
            ON T.CODTIPOPER = C.CODTIPOPER
           AND T.DHALTER = C.DHTIPOPER
        WHERE T.ATUALFIN <> 0
          AND C.TIPMOV <> 'Z'
          AND NOT EXISTS (
              SELECT 1
              FROM TGFFIN F
              WHERE F.NUNOTA = C.NUNOTA
          )
    )

    UNION ALL

    SELECT
        18 AS ORDEM,
        'PRODUTOS' AS SECAO,
        'Produtos vendidos sem registro de entrada' AS INDICADOR,
        COUNT(*) AS QTD,
        'Produtos com venda identificada, mas sem entrada correspondente' AS OBSERVACAO
    FROM (
        SELECT DISTINCT I.CODPROD
        FROM TGFITE I
        INNER JOIN TGFCAB C
            ON C.NUNOTA = I.NUNOTA
        WHERE C.TIPMOV = 'V'
          AND NOT EXISTS (
              SELECT 1
              FROM TGFITE IC
              INNER JOIN TGFCAB CC
                  ON CC.NUNOTA = IC.NUNOTA
                 AND CC.TIPMOV = 'C'
              WHERE IC.CODPROD = I.CODPROD
          )
    )

    UNION ALL

    SELECT
        19 AS ORDEM,
        'CUSTOS' AS SECAO,
        'Produtos com custo zero' AS INDICADOR,
        COUNT(*) AS QTD,
        'Produtos de revenda/venda com custo medio sem ICMS igual a zero' AS OBSERVACAO
    FROM (
        SELECT DISTINCT P.CODPROD
        FROM TGFPRO P
        INNER JOIN TGFCUS C
            ON C.CODPROD = P.CODPROD
        WHERE C.CUSSEMICM = 0
          AND P.USOPROD IN ('V', 'R')
    )

    UNION ALL

    SELECT
        20 AS ORDEM,
        'CUSTOS' AS SECAO,
        'Produtos sem registro de custo' AS INDICADOR,
        COUNT(*) AS QTD,
        'Produtos de revenda/venda sem registro na TGFCUS' AS OBSERVACAO
    FROM (
        SELECT DISTINCT P.CODPROD
        FROM TGFPRO P
        LEFT JOIN TGFCUS C
            ON C.CODPROD = P.CODPROD
        WHERE C.CODPROD IS NULL
          AND P.USOPROD IN ('V', 'R')
          AND P.CODPROD <> 0
    )

    UNION ALL

    SELECT
        21 AS ORDEM,
        'INTEGRIDADE' AS SECAO,
        'Itens sem cabecalho' AS INDICADOR,
        COUNT(*) AS QTD,
        'Itens existentes na TGFITE sem correspondente na TGFCAB' AS OBSERVACAO
    FROM (
        SELECT DISTINCT I.NUNOTA
        FROM TGFITE I
        WHERE NOT EXISTS (
            SELECT 1
            FROM TGFCAB C
            WHERE C.NUNOTA = I.NUNOTA
        )
    )

    UNION ALL

    SELECT
        22 AS ORDEM,
        'INTEGRIDADE' AS SECAO,
        'Cabecalhos sem itens' AS INDICADOR,
        COUNT(*) AS QTD,
        'Notas existentes na TGFCAB sem itens na TGFITE' AS OBSERVACAO
    FROM (
        SELECT DISTINCT C.NUNOTA
        FROM TGFCAB C
        WHERE C.TIPMOV <> 'Z'
          AND NOT EXISTS (
              SELECT 1
              FROM TGFITE I
              WHERE I.NUNOTA = C.NUNOTA
          )
    )

    UNION ALL

    SELECT
        23 AS ORDEM,
        'CADASTROS' AS SECAO,
        'Codigos fiscais de cidades duplicados' AS INDICADOR,
        COUNT(*) AS QTD,
        'Codigos CODMUNFIS com mais de uma cidade vinculada' AS OBSERVACAO
    FROM (
        SELECT CODMUNFIS
        FROM TSICID
        WHERE CODMUNFIS IS NOT NULL
        GROUP BY CODMUNFIS
        HAVING COUNT(*) > 1
    )
)
WHERE ORDEM NOT IN (3, 10, 12, 14)
ORDER BY
    CASE SECAO
        WHEN 'GERAL' THEN 1
        WHEN 'FINANCEIRO' THEN 2
        WHEN 'CADASTROS' THEN 3
        WHEN 'PRODUTOS' THEN 4
        WHEN 'PARCEIROS' THEN 5
        WHEN 'FISCAL' THEN 6
        WHEN 'CUSTOS' THEN 7
        WHEN 'INTEGRIDADE' THEN 8
        ELSE 99
    END,
    ORDEM
	
