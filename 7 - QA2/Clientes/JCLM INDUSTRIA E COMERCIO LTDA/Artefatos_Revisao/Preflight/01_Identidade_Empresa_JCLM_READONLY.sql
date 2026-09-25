-- Consulta somente leitura criada para o preflight da base JCLM.
-- Nao autoriza DML/DDL; listar todas as empresas que coincidem com a razao
-- social informada ou com tokens diagnosticos relacionados.
SELECT CODEMP,
       TRIM(NOMEFANTASIA) AS NOMEFANTASIA,
       TRIM(RAZAOSOCIAL) AS RAZAOSOCIAL,
       CASE
         WHEN UPPER(TRIM(RAZAOSOCIAL)) = UPPER(TRIM('JCLM INDUSTRIA E COMERCIO LTDA'))
           THEN 'RAZAO_SOCIAL_EXATA'
         ELSE 'VARIACAO_PARA_VALIDAR'
       END AS CLASSIFICACAO
  FROM TSIEMP
 WHERE UPPER(TRIM(RAZAOSOCIAL)) = UPPER(TRIM('JCLM INDUSTRIA E COMERCIO LTDA'))
    OR UPPER(TRIM(NOMEFANTASIA)) LIKE '%JCLM%'
    OR UPPER(TRIM(RAZAOSOCIAL)) LIKE '%JCLM%'
 ORDER BY CODEMP;
