-- Inventario somente leitura de tabelas temporarias do schema corrente.
SELECT OWNER,
       TABLE_NAME,
       TEMPORARY,
       DURATION
  FROM ALL_TABLES
 WHERE OWNER = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
   AND TEMPORARY = 'Y'
 ORDER BY TABLE_NAME;
