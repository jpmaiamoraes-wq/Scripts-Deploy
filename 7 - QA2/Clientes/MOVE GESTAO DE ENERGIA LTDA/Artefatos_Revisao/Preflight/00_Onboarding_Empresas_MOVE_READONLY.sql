WITH onboarding (cnpj, razao_social) AS (
    SELECT '81764680000111', 'MOVE GESTAO DE ENERGIA LTDA' FROM dual UNION ALL
    SELECT '85235430000145', 'MOVE COMERCIALIZADORA DE ENERGIA LTDA' FROM dual UNION ALL
    SELECT '38185835000136', 'COOPERATIVA DE ENERGIA MOVE' FROM dual UNION ALL
    SELECT '36922552000102', 'COOPERATIVA DE ENERGIA COTESA AUTEN' FROM dual UNION ALL
    SELECT '59196093000114', 'MOVE ENERGIA HOLDING S.A.' FROM dual
), base AS (
    SELECT e.codemp,
           TRIM(e.razaosocial) AS razao_social,
           LPAD(REGEXP_REPLACE(TRIM(e.cgc), '[^0-9]', ''), 14, '0') AS cnpj
      FROM tsiemp e
)
SELECT COALESCE(o.cnpj, b.cnpj) AS cnpj,
       o.razao_social AS razao_social_onboarding,
       b.codemp,
       b.razao_social AS razao_social_oracle,
       CASE
         WHEN o.cnpj IS NULL THEN 'ADICIONAL_NO_ORACLE'
         WHEN b.cnpj IS NULL THEN 'AUSENTE_NO_ORACLE'
         WHEN UPPER(TRIM(o.razao_social)) <> UPPER(TRIM(b.razao_social))
           THEN 'CNPJ_CORRESPONDE_RAZAO_SOCIAL_DIVERGENTE'
         ELSE 'CORRESPONDENTE'
       END AS classificacao
  FROM onboarding o
  FULL OUTER JOIN base b ON b.cnpj = o.cnpj
 ORDER BY COALESCE(o.cnpj, b.cnpj), b.codemp
