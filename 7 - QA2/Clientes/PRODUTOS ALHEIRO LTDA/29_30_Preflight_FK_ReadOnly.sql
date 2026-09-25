-- Revisão Master Deploy - Cards 29 e 30
-- Somente leitura: descoberta qualificada de constraints/FKs e colisões.
-- Não criar mapas, não executar DML e não alterar objetos.
SET DEFINE OFF
SET HEADING ON
SET FEEDBACK ON
SET LINESIZE 240
SET PAGESIZE 200
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT === CARD 29/30 - DICIONARIO DE CONSTRAINTS E FKs ===
SELECT c.owner,
       c.table_name,
       c.constraint_name,
       c.constraint_type,
       c.status,
       p.owner referenced_owner,
       p.table_name referenced_table,
       p.constraint_name referenced_constraint
  FROM ALL_CONSTRAINTS c
  LEFT JOIN ALL_CONSTRAINTS p
    ON p.owner = c.r_owner
   AND p.constraint_name = c.r_constraint_name
 WHERE c.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
   AND (c.table_name IN ('TSIBAI','TSIEND')
        OR (c.constraint_type = 'R'
            AND p.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
            AND p.table_name IN ('TSIBAI','TSIEND')))
 ORDER BY c.table_name, c.constraint_name;

PROMPT === CARD 29/30 - COLUNAS DAS CONSTRAINTS ===
SELECT c.owner,
       c.table_name,
       c.constraint_name,
       c.constraint_type,
       cc.position,
       cc.column_name,
       c.r_owner referenced_owner,
       c.r_constraint_name referenced_constraint
  FROM ALL_CONSTRAINTS c
  JOIN ALL_CONS_COLUMNS cc
    ON cc.owner = c.owner
   AND cc.constraint_name = c.constraint_name
 WHERE c.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
   AND (c.table_name IN ('TSIBAI','TSIEND') OR c.constraint_type = 'R')
 ORDER BY c.table_name, c.constraint_name, cc.position;

PROMPT === CARD 29 - GRUPOS DE COLISAO ===
SELECT COUNT(*) grupos_colisao_bairros
  FROM (SELECT REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                   'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ','AAAAAEEEEIIIIOOOOOUUUUC')),
                   '[[:space:]]+',' ') chave
          FROM TSIBAI
         GROUP BY REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                   'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ','AAAAAEEEEIIIIOOOOOUUUUC')),
                   '[[:space:]]+',' ')
        HAVING COUNT(*) > 1);

PROMPT === CARD 30 - GRUPOS DE COLISAO ===
SELECT COUNT(*) grupos_colisao_enderecos
  FROM (SELECT TIPO,
               REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
                   'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ','AAAAAEEEEIIIIOOOOOUUUUC')),
                   '[[:space:]]+',' ') chave
          FROM TSIEND
         GROUP BY TIPO,
                  REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEEND),
                   'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ','AAAAAEEEEIIIIOOOOOUUUUC')),
                   '[[:space:]]+',' ')
        HAVING COUNT(*) > 1);

PROMPT === CARD 29/30 - QUOTA DA SESSAO ===
SELECT TABLESPACE_NAME, MAX_BYTES, BYTES, BLOCKS
  FROM USER_TS_QUOTAS
 ORDER BY TABLESPACE_NAME;

PROMPT === FIM CARD 29/30 - SOMENTE LEITURA ===
