SET SERVEROUTPUT ON;
SET DEFINE OFF;

DECLARE
  -- controle / feedback
  v_backup_created_par  NUMBER := 0;
  v_backup_created_cab  NUMBER := 0;

  v_rows_tgfpar         NUMBER := 0;
  v_rows_tgfcab         NUMBER := 0;
  v_rows_tgffin         NUMBER := 0;
  v_rows_tgfpro         NUMBER := 0;
  v_rows_tgfgir         NUMBER := 0;
  v_rows_del_tgfpar     NUMBER := 0;

  v_loop                NUMBER := 0;

  PROCEDURE safe_exec(p_sql IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('AVISO: falha ao executar: '||p_sql||' -> '||SQLERRM);
  END;

  PROCEDURE create_table_if_not_exists(p_table IN VARCHAR2, p_sql_create IN VARCHAR2, p_flag OUT NUMBER) IS
    v_exists NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_exists
      FROM USER_TABLES
     WHERE TABLE_NAME = UPPER(p_table);

    IF v_exists = 0 THEN
      EXECUTE IMMEDIATE p_sql_create;
      p_flag := 1;
      DBMS_OUTPUT.PUT_LINE('OK: tabela '||UPPER(p_table)||' criada.');
    ELSE
      p_flag := 0;
      DBMS_OUTPUT.PUT_LINE('OK: tabela '||UPPER(p_table)||' já existe (não recriada).');
    END IF;
  END;

BEGIN
  DBMS_OUTPUT.PUT_LINE('=== INICIO - Consolidação de parceiros (por CGC_CPF + UF) ===');

  ---------------------------------------------------------------------------
  -- 1) DESABILITA TRIGGERS (não falha se não existirem)
  ---------------------------------------------------------------------------
  safe_exec('ALTER TRIGGER TRG_UPT_TGFFIN_NUBCO DISABLE');
  safe_exec('ALTER TRIGGER TRG_DLT_TGFCAB_ESTTERC DISABLE');
  DBMS_OUTPUT.PUT_LINE('OK: triggers desabilitadas (se existiam).');

  ---------------------------------------------------------------------------
  -- 2) BACKUP (somente se não existir)
  ---------------------------------------------------------------------------
  create_table_if_not_exists(
    p_table      => 'TGFPAR_BKP',
    p_sql_create => 'CREATE TABLE TGFPAR_BKP AS SELECT * FROM TGFPAR',
    p_flag       => v_backup_created_par
  );

  create_table_if_not_exists(
    p_table      => 'TGFCAB_BKP',
    p_sql_create => 'CREATE TABLE TGFCAB_BKP AS SELECT * FROM TGFCAB',
    p_flag       => v_backup_created_cab
  );

  ---------------------------------------------------------------------------
  -- 3) PROCESSA CONSOLIDAÇÃO
  ---------------------------------------------------------------------------
  FOR i IN (
    SELECT
      P.CODPARC,
      P.CGC_CPF,
      (
        SELECT MIN(P2.CODPARC)
          FROM TGFPAR P2
          JOIN TSICID C2 ON P2.CODCID = C2.CODCID
          JOIN TSIUFS U2 ON C2.UF     = U2.CODUF
         WHERE P2.CGC_CPF = P.CGC_CPF
           AND U2.CODUF   = U.CODUF
      ) AS MENOR
    FROM TGFPAR P
    JOIN TSICID C ON P.CODCID = C.CODCID
    JOIN TSIUFS U ON C.UF     = U.CODUF
    WHERE EXISTS (
      SELECT 1
        FROM TGFPAR P3
        JOIN TSICID C3 ON P3.CODCID = C3.CODCID
        JOIN TSIUFS U3 ON C3.UF     = U3.CODUF
       WHERE P3.CGC_CPF = P.CGC_CPF
         AND U3.CODUF   = U.CODUF
       GROUP BY P3.CGC_CPF, U3.CODUF
      HAVING COUNT(*) > 1
    )
    AND P.CODPARC > (
      SELECT MIN(P4.CODPARC)
        FROM TGFPAR P4
        JOIN TSICID C4 ON P4.CODCID = C4.CODCID
        JOIN TSIUFS U4 ON C4.UF     = U4.CODUF
       WHERE P4.CGC_CPF = P.CGC_CPF
         AND U4.CODUF   = U.CODUF
    )
    AND P.CODPARC IN (1942, 4, 361, 1944, 303, 855)
  )
  LOOP
    v_loop := v_loop + 1;

    -- garante flags no "menor"
    UPDATE TGFPAR
       SET FORNECEDOR = 'S',
           CLIENTE    = 'S'
     WHERE CODPARC = i.MENOR;
    v_rows_tgfpar := v_rows_tgfpar + SQL%ROWCOUNT;

    -- move referencias
    UPDATE TGFCAB
       SET CODPARC       = i.MENOR,
           CODPARCTRANSP = i.MENOR
     WHERE CODPARC = i.CODPARC;
    v_rows_tgfcab := v_rows_tgfcab + SQL%ROWCOUNT;

    UPDATE TGFFIN
       SET CODPARC = i.MENOR
     WHERE CODPARC = i.CODPARC;
    v_rows_tgffin := v_rows_tgffin + SQL%ROWCOUNT;

    UPDATE TGFPRO
       SET CODPARCFORN = i.MENOR
     WHERE CODPARCFORN = i.CODPARC;
    v_rows_tgfpro := v_rows_tgfpro + SQL%ROWCOUNT;

    UPDATE TGFGIR
       SET CODPARCFORN = i.MENOR
     WHERE CODPARCFORN = i.CODPARC;
    v_rows_tgfgir := v_rows_tgfgir + SQL%ROWCOUNT;

    -- remove o duplicado (com sua regra)
    DELETE FROM TGFPAR
     WHERE CODPARC = i.CODPARC
       AND NOMEPARC NOT LIKE '%CONSUMIDOR%';
    v_rows_del_tgfpar := v_rows_del_tgfpar + SQL%ROWCOUNT;

  END LOOP;

  COMMIT;

  ---------------------------------------------------------------------------
  -- 4) FEEDBACK
  ---------------------------------------------------------------------------
  DBMS_OUTPUT.PUT_LINE('--- RESUMO ---');
  DBMS_OUTPUT.PUT_LINE('Parceiros processados no loop: '||v_loop);
  DBMS_OUTPUT.PUT_LINE('TGFPAR atualizados (flags): '||v_rows_tgfpar);
  DBMS_OUTPUT.PUT_LINE('TGFCAB movidos: '||v_rows_tgfcab);
  DBMS_OUTPUT.PUT_LINE('TGFFIN movidos: '||v_rows_tgffin);
  DBMS_OUTPUT.PUT_LINE('TGFPRO movidos: '||v_rows_tgfpro);
  DBMS_OUTPUT.PUT_LINE('TGFGIR movidos: '||v_rows_tgfgir);
  DBMS_OUTPUT.PUT_LINE('TGFPAR deletados: '||v_rows_del_tgfpar);
  DBMS_OUTPUT.PUT_LINE('=== FIM (COMMIT OK) ===');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: '||SQLERRM);
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK executado.');

    -- reabilita triggers mesmo com erro
    safe_exec('ALTER TRIGGER TRG_UPT_TGFFIN_NUBCO ENABLE');
    safe_exec('ALTER TRIGGER TRG_DLT_TGFCAB_ESTTERC ENABLE');
    DBMS_OUTPUT.PUT_LINE('Triggers reabilitadas (após erro).');

    RAISE;
END;
/
-- Garante reabilitar triggers no caminho "sucesso" também:
BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFFIN_NUBCO ENABLE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_TGFCAB_ESTTERC ENABLE';
EXCEPTION WHEN OTHERS THEN NULL; END;
/