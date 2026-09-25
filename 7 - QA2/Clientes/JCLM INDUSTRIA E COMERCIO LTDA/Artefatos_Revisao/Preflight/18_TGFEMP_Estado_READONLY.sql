-- Estado somente leitura da tabela operacional afetada.
SELECT COUNT(*) AS QTD_TGFEMP,
       COUNT(CASE WHEN CODEMP <> 1 THEN 1 END) AS QTD_FORA_CODEMP_1
  FROM TGFEMP;
