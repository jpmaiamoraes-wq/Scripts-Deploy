-- Politicas de seguranca aplicadas a TGFEMP; somente leitura.
SELECT *
  FROM ALL_POLICIES
 WHERE OBJECT_NAME IN ('TGFEMP','AD_SEGMENTACAOEMPRESAS')
;
