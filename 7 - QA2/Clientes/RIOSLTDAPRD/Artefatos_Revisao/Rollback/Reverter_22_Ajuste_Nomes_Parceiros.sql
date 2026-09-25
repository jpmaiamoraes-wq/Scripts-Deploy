-- ============================================================
-- Reverte_Ajuste_Nomes_Parceiros_Numeros.sql
-- Reverte uma execucao registrada em BKP_AJNP_TGFPAR.
-- O backup e mantido apos a reversao para auditoria.
-- ============================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
ACCEPT ID_EXECUCAO_A_REVERTER CHAR PROMPT 'Informe o ID_EXECUCAO a reverter: '

DECLARE
  c_id_execucao CONSTANT VARCHAR2(30) := '&ID_EXECUCAO_A_REVERTER';
  v_backups     PLS_INTEGER;
  v_restaurados PLS_INTEGER;
BEGIN
  SELECT COUNT(*)
    INTO v_backups
    FROM BKP_AJNP_TGFPAR
   WHERE ID_EXECUCAO = c_id_execucao;

  IF v_backups = 0 THEN
    RAISE_APPLICATION_ERROR(-20032, 'ID_EXECUCAO nao encontrado: ' || c_id_execucao);
  END IF;

  SAVEPOINT REVERTE_NOMES_INICIO;

  MERGE INTO TGFPAR p
  USING (
    SELECT CODPARC, NOMEPARC_ANTES, RAZAOSOCIAL_ANTES
      FROM BKP_AJNP_TGFPAR
     WHERE ID_EXECUCAO = c_id_execucao
  ) b
     ON (b.CODPARC = p.CODPARC)
   WHEN MATCHED THEN UPDATE
        SET p.NOMEPARC    = b.NOMEPARC_ANTES,
            p.RAZAOSOCIAL = b.RAZAOSOCIAL_ANTES;

  v_restaurados := SQL%ROWCOUNT;

  IF v_restaurados <> v_backups THEN
    RAISE_APPLICATION_ERROR(
      -20033,
      'Quantidade restaurada (' || v_restaurados ||
      ') difere dos backups (' || v_backups || ').'
    );
  END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO_REVERTIDA=' || c_id_execucao);
  DBMS_OUTPUT.PUT_LINE('REGISTROS_RESTAURADOS=' || v_restaurados);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO REVERTE_NOMES_INICIO;
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    RAISE;
END;
/

