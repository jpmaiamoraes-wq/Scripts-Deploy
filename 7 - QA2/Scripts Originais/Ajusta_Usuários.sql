MERGE INTO TSIUSU U
USING (
    WITH BASE AS (
        SELECT
            CODUSU,
            NOMEUSU,
            REGEXP_REPLACE(
              REGEXP_REPLACE(
                TRIM(
                  TRANSLATE(
                    UPPER(NOMEUSU),
                    'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                    'AAAAAEEEEIIIIOOOOOUUUUC'
                  )
                ),
                '(^| )(DE|DA|DO|DAS|DOS|E)( |$)',
                ' '
              ),
              ' {2,}',
              ' '
            ) AS NOME_LIMPO
        FROM TSIUSU
        WHERE NOMEUSU LIKE '% %'
    ),
    PARTES AS (
        SELECT
            CODUSU,
            NOMEUSU,
            NOME_LIMPO,
            REGEXP_SUBSTR(NOME_LIMPO, '[^ ]+', 1, 1) AS PRIMEIRO,
            REGEXP_SUBSTR(NOME_LIMPO, '[^ ]+', 1, REGEXP_COUNT(NOME_LIMPO, ' ') + 1) AS ULTIMO,
            REGEXP_SUBSTR(NOME_LIMPO, '[^ ]+', 1, REGEXP_COUNT(NOME_LIMPO, ' ')) AS PENULTIMO
        FROM BASE
    ),
    CANDIDATOS AS (
        SELECT
            CODUSU,
            NOMEUSU,
            PRIMEIRO || '.' || ULTIMO AS LOGIN_ULTIMO,
            PRIMEIRO || '.' || PENULTIMO AS LOGIN_PENULTIMO
        FROM PARTES
        WHERE PRIMEIRO IS NOT NULL
          AND ULTIMO IS NOT NULL
          AND PENULTIMO IS NOT NULL
    ),
    DECISAO_1 AS (
        SELECT
            C.*,
            COUNT(*) OVER (PARTITION BY LOGIN_ULTIMO) AS QTD_LOGIN_ULTIMO
        FROM CANDIDATOS C
    ),
    DECISAO_2 AS (
        SELECT
            D.*,
            CASE
                WHEN QTD_LOGIN_ULTIMO = 1 THEN LOGIN_ULTIMO
                ELSE LOGIN_PENULTIMO
            END AS NOVO_NOMEUSU
        FROM DECISAO_1 D
    ),
    VALIDACAO AS (
        SELECT
            D.*,
            COUNT(*) OVER (PARTITION BY NOVO_NOMEUSU) AS QTD_NOVO_NOMEUSU
        FROM DECISAO_2 D
    )
    SELECT CODUSU, NOVO_NOMEUSU
    FROM VALIDACAO
    WHERE QTD_NOVO_NOMEUSU = 1
) X
ON (U.CODUSU = X.CODUSU)
WHEN MATCHED THEN
  UPDATE SET U.NOMEUSU = X.NOVO_NOMEUSU
  WHERE U.NOMEUSU <> X.NOVO_NOMEUSU;

COMMIT;

-- Previa
/*WITH BASE AS (
    SELECT
        CODUSU,
        NOMEUSU,
        REGEXP_REPLACE(
          REGEXP_REPLACE(
            TRIM(
              TRANSLATE(
                UPPER(NOMEUSU),
                'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ',
                'AAAAAEEEEIIIIOOOOOUUUUC'
              )
            ),
            '(^| )(DE|DA|DO|DAS|DOS|E)( |$)',
            ' '
          ),
          ' {2,}',
          ' '
        ) AS NOME_LIMPO
    FROM TSIUSU
    WHERE NOMEUSU LIKE '% %'
),
PARTES AS (
    SELECT
        CODUSU,
        NOMEUSU,
        NOME_LIMPO,
        REGEXP_SUBSTR(NOME_LIMPO, '[^ ]+', 1, 1) AS PRIMEIRO,
        REGEXP_SUBSTR(NOME_LIMPO, '[^ ]+', 1, REGEXP_COUNT(NOME_LIMPO, ' ') + 1) AS ULTIMO,
        REGEXP_SUBSTR(NOME_LIMPO, '[^ ]+', 1, REGEXP_COUNT(NOME_LIMPO, ' ')) AS PENULTIMO
    FROM BASE
),
CANDIDATOS AS (
    SELECT
        CODUSU,
        NOMEUSU,
        PRIMEIRO || '.' || ULTIMO AS LOGIN_ULTIMO,
        PRIMEIRO || '.' || PENULTIMO AS LOGIN_PENULTIMO
    FROM PARTES
    WHERE PRIMEIRO IS NOT NULL
      AND ULTIMO IS NOT NULL
      AND PENULTIMO IS NOT NULL
),
DECISAO_1 AS (
    SELECT
        C.*,
        COUNT(*) OVER (PARTITION BY LOGIN_ULTIMO) AS QTD_LOGIN_ULTIMO
    FROM CANDIDATOS C
),
DECISAO_2 AS (
    SELECT
        D.*,
        CASE
            WHEN QTD_LOGIN_ULTIMO = 1 THEN LOGIN_ULTIMO
            ELSE LOGIN_PENULTIMO
        END AS NOVO_NOMEUSU
    FROM DECISAO_1 D
),
VALIDACAO AS (
    SELECT
        D.*,
        COUNT(*) OVER (PARTITION BY NOVO_NOMEUSU) AS QTD_NOVO_NOMEUSU
    FROM DECISAO_2 D
)
SELECT
    CODUSU,
    NOMEUSU,
    LOGIN_ULTIMO,
    LOGIN_PENULTIMO,
    NOVO_NOMEUSU,
    QTD_LOGIN_ULTIMO,
    QTD_NOVO_NOMEUSU,
    CASE
        WHEN QTD_NOVO_NOMEUSU = 1 THEN 'OK PARA ATUALIZAR'
        ELSE 'CONFLITO - ANALISAR MANUALMENTE'
    END AS STATUS
FROM VALIDACAO
ORDER BY STATUS, NOVO_NOMEUSU, CODUSU;*/