-- Triggers da TGFEMP que podem participar da falha; somente leitura.
SELECT OWNER,
       TRIGGER_NAME,
       TABLE_NAME,
       STATUS,
       TRIGGER_TYPE,
       TRIGGERING_EVENT
  FROM ALL_TRIGGERS
 WHERE TABLE_NAME = 'TGFEMP'
 ORDER BY OWNER, TRIGGER_NAME;
