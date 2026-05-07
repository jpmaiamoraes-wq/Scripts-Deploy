WITH ResumoMovimentacao AS (
    SELECT
        EMP.CODEMP,
        PITI.UFORIG,
        PITI.CBENEFUF,
        PITI.CSTCSOSN,
        PITI.CFOP,

        CASE
            WHEN PITI.CFOP >= 6000 THEN 'S'
            ELSE 'N'
        END AS INDOPINTEST,

        ROW_NUMBER() OVER (
            PARTITION BY 
                EMP.CODEMP,
                PITI.UFORIG,
                PITI.CBENEFUF,
                PITI.CSTCSOSN,
                PITI.CFOP
            ORDER BY COUNT(*) DESC
        ) AS RANKING

    FROM TTKPITI PITI
    JOIN TSIEMP EMP 
      ON EMP.CGC = PITI.CPFCNPJORIG

    WHERE PITI.CFOP >= 5000
      AND PITI.CBENEFUF IS NOT NULL
      AND PITI.CBENEFUF <> 'SEM CBENEF'
      AND PITI.CSTCSOSN <> '00'

    GROUP BY
        EMP.CODEMP,
        PITI.UFORIG,
        PITI.CBENEFUF,
        PITI.CSTCSOSN,
        PITI.CFOP
),

Base AS (
    SELECT
        CODEMP,
        UFORIG,
        CBENEFUF,
        CSTCSOSN,
        CFOP,
        INDOPINTEST
    FROM ResumoMovimentacao
    WHERE RANKING = 1
),

Analise AS (
    SELECT
        CODEMP,
        UFORIG,
        CBENEFUF,
        INDOPINTEST,
        COUNT(DISTINCT CFOP) AS QTD_CFOP,
        COUNT(DISTINCT CSTCSOSN) AS QTD_CST
    FROM Base
    GROUP BY
        CODEMP,
        UFORIG,
        CBENEFUF,
        INDOPINTEST
),

Regras AS (
    SELECT
        B.CODEMP,
        B.UFORIG,
        B.CBENEFUF,
        B.CSTCSOSN,
        B.INDOPINTEST,

        CASE
            WHEN A.QTD_CFOP > 1 
             AND A.QTD_CST = 1
                THEN NULL
            ELSE B.CFOP
        END AS CFOP_REGRA,

        CASE
            WHEN A.QTD_CFOP > 1 
             AND A.QTD_CST = 1
                THEN 'CST'
            ELSE 'CST_CFOP'
        END AS TIPO_REGRA

    FROM Base B
    JOIN Analise A 
      ON A.CODEMP = B.CODEMP
     AND A.UFORIG = B.UFORIG
     AND A.CBENEFUF = B.CBENEFUF
     AND A.INDOPINTEST = B.INDOPINTEST
),

RegrasFinal AS (
    SELECT DISTINCT
        CODEMP,
        UFORIG,
        CBENEFUF,
        CSTCSOSN,
        CFOP_REGRA,
        INDOPINTEST,
        TIPO_REGRA
    FROM Regras
),

Numerado AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY 
                UFORIG,
                CBENEFUF,
                CSTCSOSN,
                INDOPINTEST,
                CFOP_REGRA
        ) AS LINHA,

        CODEMP,
        UFORIG,
        CBENEFUF,
        CSTCSOSN,
        CFOP_REGRA,
        INDOPINTEST,
        TIPO_REGRA

    FROM RegrasFinal
)

SELECT
    LINHA,
    CODEMP,
    UFORIG,
    CBENEFUF,
    CSTCSOSN,
    CFOP_REGRA,
    INDOPINTEST,
    TIPO_REGRA,

    'INSERT INTO TGFBEN '
    || '(NUMBEN, CODEMP, CODBENEFNAUF, DESCRBEN, CODTRIB, INDOPINTEST) VALUES ('
    || LINHA || ', '
    || CODEMP || ', '''
    || CBENEFUF || ''', '''
    || CASE
           WHEN TIPO_REGRA = 'CST'
               THEN 'CST ' || CSTCSOSN
                    || ' - cBenef ' || CBENEFUF
                    || CASE
                           WHEN INDOPINTEST = 'S'
                               THEN ' - Interestadual'
                           ELSE ' - Interna'
                       END

           ELSE 'CFOP ' || CFOP_REGRA
                || ' - CST ' || CSTCSOSN
       END
    || ''', '''
    || CSTCSOSN || ''', '''
    || INDOPINTEST || ''');'

    AS COMANDO_INSERT

FROM Numerado

ORDER BY
    UFORIG,
    CBENEFUF,
    CSTCSOSN,
    INDOPINTEST,
    CFOP_REGRA;
