SELECT RECORD_TYPE,
       OWNER,
       TABLE_NAME,
       COLUMN_NAME,
       DATA_TYPE
  FROM (
        SELECT 'TABLE' AS RECORD_TYPE,
               OWNER,
               TABLE_NAME,
               CAST(NULL AS VARCHAR2(128)) AS COLUMN_NAME,
               CAST(NULL AS VARCHAR2(128)) AS DATA_TYPE
          FROM ALL_TABLES
         WHERE OWNER = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
           AND (
                UPPER(TABLE_NAME) LIKE 'BKP_RMD%'
                OR UPPER(TABLE_NAME) LIKE '%FDUP%'
                OR UPPER(TABLE_NAME) LIKE '%CARD09%'
               )
        UNION ALL
        SELECT 'COLUMN' AS RECORD_TYPE,
               OWNER,
               TABLE_NAME,
               COLUMN_NAME,
               DATA_TYPE
          FROM ALL_TAB_COLUMNS
         WHERE OWNER = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
           AND (
                UPPER(TABLE_NAME) LIKE '%FDUP%'
                OR UPPER(TABLE_NAME) LIKE '%CARD09%'
               )
           AND UPPER(COLUMN_NAME) IN (
                'ID_EXECUCAO',
                'STATUS_MAPA',
                'VDUP_XML',
                'DVENC_XML',
                'NDUP_XML',
                'NUNOTA'
               )
       )
 ORDER BY TABLE_NAME, RECORD_TYPE, COLUMN_NAME
