-- Estado dos objetos iniciais da atividade 17 apos falha de privilegio; somente leitura.
SELECT OBJECT_NAME,
       OBJECT_TYPE,
       STATUS,
       CREATED,
       LAST_DDL_TIME
  FROM ALL_OBJECTS
 WHERE OWNER='SANKHYA'
   AND OBJECT_NAME IN ('RMD_MAP_UNIDADES','BKP_RMD_UNID_MAP',
                       'BKP_RMD_UNID_TGFPRO','BKP_RMD_UNID_TGFITE',
                       'BKP_RMD_UNID_TGFPAP','BKP_RMD_UNID_TGFCOI2',
                       'BKP_RMD_UNID_TGFGIR1','BKP_RMD_UNID_TGFVOA',
                       'BKP_RMD_UNID_TGFVOL')
 ORDER BY OBJECT_NAME;
