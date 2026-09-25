-- Inventario somente leitura de quota do usuario executor.
SELECT TABLESPACE_NAME,
       BYTES,
       MAX_BYTES,
       BLOCKS,
       MAX_BLOCKS
  FROM USER_TS_QUOTAS
 ORDER BY TABLESPACE_NAME;
