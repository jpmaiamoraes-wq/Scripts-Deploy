-- Grants da TGFEMP e do backup para o usuario/role operacional observado; somente leitura.
SELECT *
  FROM ALL_TAB_PRIVS
 WHERE TABLE_NAME IN ('TGFEMP','BKP_RMD_02_TGFEMP')
   AND GRANTEE IN ('FRANCISCO_JUNIOR','RLCONSULTOR');
