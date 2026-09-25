-- Diagnostico read-only dos privilegios visiveis para o ramo TGFEMP.
-- Nao executa DML/DDL e nao substitui a validacao do lote.
SELECT OWNER,
       TABLE_NAME,
       GRANTEE,
       PRIVILEGE,
       GRANTOR,
       GRANTABLE,
       HIERARCHY,
       COMMON,
       TYPE
  FROM ALL_TAB_PRIVS_RECD
 WHERE TABLE_NAME IN ('TGFEMP','BKP_RMD_02_TGFEMP')
 ORDER BY OWNER, TABLE_NAME, GRANTEE, PRIVILEGE;
