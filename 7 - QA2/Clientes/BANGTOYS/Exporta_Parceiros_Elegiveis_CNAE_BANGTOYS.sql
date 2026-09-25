-- Exportacao local, somente leitura, dos parceiros elegiveis para enriquecimento CNAE.
-- Nao consulta servico externo e nao altera o banco.

SET DEFINE OFF;
SET SQLFORMAT CSV;
SET FEEDBACK OFF;
SET HEADING ON;
SET ECHO OFF;
SET TERMOUT OFF;

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/BANGTOYS/Parceiros_Elegiveis_CNAE_BANGTOYS.csv"

SELECT P.CODPARC,
       REGEXP_REPLACE(P.CGC_CPF, '[^0-9]', '') AS CNPJ,
       P.NOMEPARC,
       P.RAZAOSOCIAL,
       COUNT(*) AS QTD_VENDAS,
       MIN(C.DTNEG) AS PRIMEIRA_VENDA,
       MAX(C.DTNEG) AS ULTIMA_VENDA
  FROM TGFPAR P
  JOIN TGFCAB C ON C.CODPARC = P.CODPARC
 WHERE C.TIPMOV = 'V'
   AND P.TIPPESSOA = 'J'
   AND LENGTH(REGEXP_REPLACE(P.CGC_CPF, '[^0-9]', '')) = 14
 GROUP BY P.CODPARC,
          REGEXP_REPLACE(P.CGC_CPF, '[^0-9]', ''),
          P.NOMEPARC,
          P.RAZAOSOCIAL
 ORDER BY CNPJ, P.CODPARC;

SPOOL OFF;

SET TERMOUT ON;
SET FEEDBACK ON;
PROMPT EXPORTACAO_CONCLUIDA=Parceiros_Elegiveis_CNAE_BANGTOYS.csv

