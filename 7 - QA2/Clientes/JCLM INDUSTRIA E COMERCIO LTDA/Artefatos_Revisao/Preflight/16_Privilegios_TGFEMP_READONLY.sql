-- Privilegios de objeto recebidos e estado da tabela TGFEMP; somente leitura.
SELECT *
  FROM ALL_TAB_PRIVS_RECD
 WHERE TABLE_NAME IN ('TGFEMP','BKP_RMD_02_TGFEMP');
