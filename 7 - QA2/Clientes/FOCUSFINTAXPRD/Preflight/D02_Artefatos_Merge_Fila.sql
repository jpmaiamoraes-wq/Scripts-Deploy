-- Diagnostico read-only: artefatos da fase 29/30 desta base e tabela de fila de eventos observada em outra base.
SELECT OWNER, TABLE_NAME, NUM_ROWS
  FROM ALL_TABLES
 WHERE OWNER = SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
   AND (TABLE_NAME LIKE '%FOCUS%' OR TABLE_NAME = 'TEMP_TGLATS_V2')
 ORDER BY TABLE_NAME
