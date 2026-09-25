-- Estado read-only da trigger tocada pela atividade 09.
SELECT OWNER,
       TRIGGER_NAME,
       TABLE_NAME,
       STATUS,
       TRIGGER_TYPE,
       TRIGGERING_EVENT
  FROM ALL_TRIGGERS
 WHERE OWNER='SANKHYA'
   AND TRIGGER_NAME='TRG_UPT_TGFITE';
