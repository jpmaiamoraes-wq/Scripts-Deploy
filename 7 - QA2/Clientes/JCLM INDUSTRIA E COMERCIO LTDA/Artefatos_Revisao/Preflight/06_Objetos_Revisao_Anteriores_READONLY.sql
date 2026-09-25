-- Inventario somente leitura de objetos que podem indicar execucoes anteriores.
SELECT OWNER,
       OBJECT_TYPE,
       OBJECT_NAME,
       STATUS,
       LAST_DDL_TIME
  FROM ALL_OBJECTS
 WHERE OWNER = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
   AND (
        UPPER(OBJECT_NAME) LIKE 'RMD%'
        OR UPPER(OBJECT_NAME) LIKE 'BKP_RMD%'
        OR UPPER(OBJECT_NAME) LIKE 'MAPA_RMD%'
        OR UPPER(OBJECT_NAME) LIKE 'AUD_RMD%'
       )
 ORDER BY OBJECT_NAME, OBJECT_TYPE;
