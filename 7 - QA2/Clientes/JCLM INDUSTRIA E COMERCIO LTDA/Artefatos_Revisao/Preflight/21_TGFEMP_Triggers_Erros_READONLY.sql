-- Erros persistidos e dependencias dos triggers da TGFEMP; somente leitura.
SELECT OWNER,
       NAME,
       TYPE,
       LINE,
       POSITION,
       ATTRIBUTE,
       TEXT
  FROM ALL_ERRORS
 WHERE NAME IN ('TRG_DLT_TGFEMP','TRG_FX_TGFEMP','TRG_INC_UPT_TGFEMP',
                'TRG_INC_UPT_TGFEMP_AFTER','TRG_INC_UPT_TGFEMP_WMS',
                'TRG_UPD_TGFEMP_ENOTAS','TRG_UPT_TGFEMP_ESTTERC')
 ORDER BY OWNER, NAME, SEQUENCE;
