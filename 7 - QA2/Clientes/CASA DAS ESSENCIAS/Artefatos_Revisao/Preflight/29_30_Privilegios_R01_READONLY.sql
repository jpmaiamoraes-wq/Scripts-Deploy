-- Privilegios recebidos no novo conjunto de artefatos e nos backups 29/30 existentes.
SELECT OWNER,
       TABLE_NAME,
       GRANTEE,
       PRIVILEGE,
       GRANTOR,
       GRANTABLE,
       TYPE
  FROM ALL_TAB_PRIVS_RECD
 WHERE TABLE_NAME IN (
     'RMD_CASA_2930_R01_MAP',
     'RMD_CASA_2930_R01_BAI_BKP',
     'RMD_CASA_2930_R01_END_BKP',
     'RMD_CASA_2930_R01_DEP',
     'RMD_CASA_2930_R01_EXC',
     'BKP_RMD_PAD_TSIBAI',
     'BKP_RMD_PAD_TSIEND'
   )
 ORDER BY TABLE_NAME, GRANTEE, PRIVILEGE;
