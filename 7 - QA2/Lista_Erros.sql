-- Lista de erros.
SELECT Q.*
FROM (

WITH BASE AS (
  SELECT MENSAGEM
  FROM TTKEVT
  WHERE STATUS = 'E'
),
AGG AS (
  SELECT
    SUM(CASE WHEN INSTR(MENSAGEM, 'n?o possui o registro: 0000') > 0 THEN 1 ELSE 0 END) AS N1,
    SUM(CASE WHEN INSTR(MENSAGEM, 'Codigo Barra REPETIDO') > 0 THEN 1 ELSE 0 END)          AS N2,
    SUM(CASE WHEN INSTR(MENSAGEM, 'não há valores suficientes') > 0 THEN 1 ELSE 0 END)     AS N3,
    SUM(CASE WHEN INSTR(MENSAGEM, 'Volume:') > 0
              AND INSTR(MENSAGEM, 'n?o cadastrado para o produto') > 0 THEN 1 ELSE 0 END)  AS N4,
    SUM(CASE WHEN INSTR(MENSAGEM, 'A base e o valor do IPI devem ser zero (0)') > 0 THEN 1 ELSE 0 END) AS N5,
    SUM(CASE WHEN INSTR(MENSAGEM, 'não é possível estender segmento lob SANKHYA.SYS_') > 0 THEN 1 ELSE 0 END) AS N6,
    SUM(CASE WHEN INSTR(MENSAGEM, 'Referencia REPETIDO para o produto') > 0 THEN 1 ELSE 0 END) AS N7,
    SUM(CASE WHEN INSTR(MENSAGEM, 'nfedfe') > 0 THEN 1 ELSE 0 END) AS N8,
    SUM(CASE WHEN INSTR(MENSAGEM, 'N?o existem arquivos v?lidos para as empresas cadastradas') > 0 THEN 1 ELSE 0 END) AS N9, 
    SUM(CASE WHEN INSTR(MENSAGEM, 'N?o foi poss?vel localizar uma TOP para o CFOP: 6101') > 0 THEN 1 ELSE 0 END) AS N10 
  FROM BASE
)
SELECT
  MENSAGEM,
  QTD,
  ROUND(QTD * 100 / SUM(QTD) OVER (), 2) AS PERCENTUAL
FROM AGG
UNPIVOT (
  QTD FOR MENSAGEM IN (
    N1 AS 'n?o possui o registro: 0000',
    N2 AS 'Codigo Barra REPETIDO',
    N3 AS 'não há valores suficientes',
    N4 AS 'Volume: XX n?o cadastrado para o produto',
    N5 AS 'A base e o valor do IPI devem ser zero (0)',
    N6 AS 'não é possível estender segmento lob SANKHYA.SYS_',
    N7 AS 'Referencia REPETIDO para o produto',
    N8 AS 'nfedfe',
    N9 AS 'N?o existem arquivos v?lidos para as empresas cadastradas',
    N10 AS 'N?o foi poss?vel localizar uma TOP para o CFOP: 6101'
  )
)
) Q
WHERE Q.QTD > 0
ORDER BY Q.QTD DESC;




-- Para consultar as linhas que não constam  no select acima.
--SELECT *
--FROM TTKEVT
--WHERE MENSAGEM NOT LIKE '%n?o possui o registro: 0000%'
--AND MENSAGEM NOT LIKE  '%Codigo Barra REPETIDO%'
--AND MENSAGEM NOT LIKE '%não há valores suficientes%'
--AND MENSAGEM NOT LIKE '%Volume:%n?o cadastrado para o produto%'
--AND MENSAGEM NOT LIKE '%A base e o valor do IPI devem ser zero (0)%'
--AND MENSAGEM NOT LIKE '%não é possível estender segmento lob SANKHYA.SYS_%'
--AND MENSAGEM NOT LIKE '%Referencia REPETIDO para o produto%'
--AND MENSAGEM NOT LIKE '%nfedfe%'
--AND MENSAGEM NOT LIKE '%N?o existem arquivos v?lidos para as empresas cadastradas%'
--AND MENSAGEM NOT LIKE '%N?o foi poss?vel localizar uma TOP para o CFOP: 6101%'
--AND STATUS = 'E';
