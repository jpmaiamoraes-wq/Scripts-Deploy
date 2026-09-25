-- Estado read-only dos artefatos apos a interrupcao do merge R01.
SELECT TABLE_NAME,
       NUM_ROWS,
       LAST_ANALYZED
  FROM ALL_TABLES
 WHERE OWNER='SANKHYA'
   AND TABLE_NAME LIKE 'RMD_CASA_2930_R01%'
 ORDER BY TABLE_NAME;
