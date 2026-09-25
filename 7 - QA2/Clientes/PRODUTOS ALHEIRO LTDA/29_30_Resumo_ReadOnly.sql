-- Revisão Master Deploy - Cards 29 e 30
-- Resumo somente leitura após a descoberta qualificada de constraints/FKs.
SET DEFINE OFF
SET HEADING ON
SET FEEDBACK ON
SET LINESIZE 240
SET PAGESIZE 100
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT === RESUMO CARD 29/30 - SOMENTE LEITURA ===
SELECT SYS_CONTEXT('USERENV','CURRENT_SCHEMA') schema_operacional,
       (SELECT COUNT(*)
          FROM ALL_CONSTRAINTS
         WHERE owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
           AND table_name IN ('TSIBAI','TSIEND')) constraints_nas_tabelas,
       (SELECT COUNT(*)
          FROM ALL_CONSTRAINTS c
          JOIN ALL_CONSTRAINTS p
            ON p.owner = c.r_owner
           AND p.constraint_name = c.r_constraint_name
         WHERE c.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
           AND c.constraint_type = 'R'
           AND p.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
           AND p.table_name IN ('TSIBAI','TSIEND')) fks_referenciando_tabelas,
       (SELECT COUNT(*)
          FROM ALL_CONS_COLUMNS cc
          JOIN ALL_CONSTRAINTS c
            ON c.owner = cc.owner
           AND c.constraint_name = cc.constraint_name
         WHERE c.owner = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
           AND (c.table_name IN ('TSIBAI','TSIEND') OR c.constraint_type = 'R')) colunas_mapeadas;

SELECT 'CARD29_GRUPOS_COLISAO_BAIRROS' indicador, COUNT(*) quantidade
  FROM (SELECT REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                   'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ','AAAAAEEEEIIIIOOOOOUUUUC')),
                   '[[:space:]]+',' ') chave
          FROM TSIBAI
         GROUP BY REGEXP_REPLACE(TRIM(TRANSLATE(UPPER(NOMEBAI),
                   'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ','AAAAAEEEEIIIIOOOOOUUUUC')),
                   '[[:space:]]+',' ')
        HAVING COUNT(*) > 1)
UNION ALL
SELECT 'CARD30_GRUPOS_COLISAO_ENDERECOS', COUNT(*)
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

SELECT TABLESPACE_NAME, MAX_BYTES, BYTES, BLOCKS
  FROM USER_TS_QUOTAS
 ORDER BY TABLESPACE_NAME;

PROMPT === FIM RESUMO CARD 29/30 - SOMENTE LEITURA ===
