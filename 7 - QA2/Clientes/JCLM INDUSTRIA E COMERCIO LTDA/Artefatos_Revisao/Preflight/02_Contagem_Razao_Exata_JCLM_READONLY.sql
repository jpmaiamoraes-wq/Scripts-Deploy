-- Consulta somente leitura da quantidade de razoes sociais exatas.
SELECT COUNT(*) AS QTD_RAZAO_EXATA
  FROM TSIEMP
 WHERE UPPER(TRIM(RAZAOSOCIAL)) = UPPER(TRIM('JCLM INDUSTRIA E COMERCIO LTDA'));
