SET PAGESIZE 500
SET LINESIZE 240
SET LONG 100000
SET TRIMSPOOL ON
SET SERVEROUTPUT ON

PROMPT === 01. COLUNAS DAS RESTRICOES QUE APRESENTARAM ERRO ===
SELECT owner, constraint_name, table_name, constraint_type, status
  FROM all_constraints
 WHERE owner = 'SANKHYA'
   AND constraint_name IN ('AK_NOMEBAI_TSIBAI', 'AK_NOMEEND_TSIEND')
 ORDER BY constraint_name;

SELECT owner, constraint_name, table_name, column_name, position
  FROM all_cons_columns
 WHERE owner = 'SANKHYA'
   AND constraint_name IN ('AK_NOMEBAI_TSIBAI', 'AK_NOMEEND_TSIEND')
 ORDER BY constraint_name, position;

PROMPT === 02. BAIRROS QUE COLIDEM APOS NORMALIZACAO ===
WITH b AS (
  SELECT codbai,
         nomebai,
         REGEXP_REPLACE(
           TRIM(TRANSLATE(UPPER(nomebai),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
           ' {2,}', ' '
         ) nome_normalizado
    FROM tsibai
)
SELECT nome_normalizado,
       COUNT(*) qtd,
       MIN(codbai) codigo_sugerido,
       LISTAGG(codbai || '=' || nomebai, ' | ') WITHIN GROUP (ORDER BY codbai) registros
  FROM b
 GROUP BY nome_normalizado
HAVING COUNT(*) > 1
 ORDER BY nome_normalizado;

PROMPT === 03. ENDERECOS QUE COLIDEM APOS NORMALIZACAO ===
WITH e AS (
  SELECT codend,
         tipo,
         nomeend,
         REGEXP_REPLACE(
           TRIM(TRANSLATE(UPPER(nomeend),
             'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüçÃãÕõÂâÊêÎîÔôÛû',
             'AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU')),
           ' {2,}', ' '
         ) nome_normalizado
    FROM tsiend
)
SELECT tipo,
       nome_normalizado,
       COUNT(*) qtd,
       MIN(codend) codigo_sugerido,
       LISTAGG(codend || '=' || nomeend, ' | ') WITHIN GROUP (ORDER BY codend) registros
  FROM e
 GROUP BY tipo, nome_normalizado
HAVING COUNT(*) > 1
 ORDER BY tipo, nome_normalizado;

PROMPT === 04. FOREIGN KEYS DECLARADAS PARA TSIBAI E TSIEND ===
SELECT c.owner child_owner,
       c.table_name child_table,
       cc.column_name child_column,
       p.table_name parent_table,
       pc.column_name parent_column,
       c.constraint_name fk_name,
       c.status
  FROM all_constraints c
  JOIN all_cons_columns cc
    ON cc.owner = c.owner
   AND cc.constraint_name = c.constraint_name
  JOIN all_constraints p
    ON p.owner = c.r_owner
   AND p.constraint_name = c.r_constraint_name
  JOIN all_cons_columns pc
    ON pc.owner = p.owner
   AND pc.constraint_name = p.constraint_name
   AND pc.position = cc.position
 WHERE c.constraint_type = 'R'
   AND p.owner = 'SANKHYA'
   AND p.table_name IN ('TSIBAI', 'TSIEND')
 ORDER BY p.table_name, c.owner, c.table_name, cc.position;

PROMPT === 05. TODAS AS COLUNAS CANDIDATAS, INCLUSIVE SEM FOREIGN KEY ===
SELECT owner, table_name, column_name
  FROM all_tab_columns
 WHERE owner = 'SANKHYA'
   AND column_name IN ('CODBAI', 'CODEND')
 ORDER BY column_name, table_name;

PROMPT === FIM DO DIAGNOSTICO SOMENTE LEITURA ===
