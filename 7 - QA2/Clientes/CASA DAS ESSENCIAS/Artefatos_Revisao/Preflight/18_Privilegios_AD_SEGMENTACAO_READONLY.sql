-- Privilegios de objeto read-only para a tabela usada pela atividade 12.
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
 WHERE TABLE_NAME='AD_SEGMENTACAOEMPRESAS'
 ORDER BY OWNER, TABLE_NAME, GRANTEE, PRIVILEGE;
