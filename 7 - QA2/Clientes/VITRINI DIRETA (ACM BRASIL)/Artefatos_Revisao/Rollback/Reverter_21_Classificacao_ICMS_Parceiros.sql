-- Reverte apenas os parceiros alterados por uma execucao identificada.
SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

ACCEPT P_ID_EXECUCAO CHAR PROMPT 'ID da execucao CLASSICMS_: '

DECLARE
  v_backup      PLS_INTEGER;
  v_atualizados PLS_INTEGER;
BEGIN
  SELECT COUNT(*)
    INTO v_backup
    FROM BKP_CLASSICMS_TGFPAR
   WHERE ID_EXECUCAO = '&&P_ID_EXECUCAO';

  IF v_backup = 0 THEN
    RAISE_APPLICATION_ERROR(-20032,
      'Backup de classificacao ICMS nao encontrado para o ID informado.');
  END IF;

  UPDATE TGFPAR P
     SET P.CLASSIFICMS = (
           SELECT B.CLASSIFICMS_ANTES
             FROM BKP_CLASSICMS_TGFPAR B
            WHERE B.ID_EXECUCAO = '&&P_ID_EXECUCAO'
              AND B.CODPARC = P.CODPARC
         )
   WHERE EXISTS (
           SELECT 1
             FROM BKP_CLASSICMS_TGFPAR B
            WHERE B.ID_EXECUCAO = '&&P_ID_EXECUCAO'
              AND B.CODPARC = P.CODPARC
         );
  v_atualizados := SQL%ROWCOUNT;

  IF v_atualizados <> v_backup THEN
    RAISE_APPLICATION_ERROR(-20033,
      'Rollback ICMS divergente: backup=' || v_backup ||
      ', atualizados=' || v_atualizados);
  END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('CLASSIFICACAO_ICMS_REVERTIDA=' || v_atualizados);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
UNDEFINE P_ID_EXECUCAO
PROMPT === FIM REVERSAO CLASSIFICACAO ICMS ===
