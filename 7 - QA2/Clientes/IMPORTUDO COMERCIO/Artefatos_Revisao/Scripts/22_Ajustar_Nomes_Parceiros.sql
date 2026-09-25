-- ============================================================
-- Ajuste_nomes_parceros_numeros.sql
-- Remove do INICIO ou do FIM de NOMEPARC/RAZAOSOCIAL um trecho
-- numerico que faca parte do CPF/CNPJ do proprio parceiro.
--
-- Seguranca:
--   * exige ao menos 6 digitos coincidentes;
--   * preserva numeros no meio do nome;
--   * nao permite que o nome fique sem letras;
--   * altera somente registros efetivamente divergentes;
--   * cria backup persistente, auditavel por ID_EXECUCAO;
--   * pode ser executado novamente sem repetir alteracoes.
-- ============================================================

SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- A estrutura precisa existir antes da compilacao do bloco que faz o INSERT.
DECLARE
  v_tabela_existe NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO v_tabela_existe
    FROM ALL_TABLES
   WHERE OWNER = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
     AND TABLE_NAME = 'BKP_AJNP_TGFPAR';

  IF v_tabela_existe = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE BKP_AJNP_TGFPAR AS
      SELECT CAST(NULL AS VARCHAR2(30))  AS ID_EXECUCAO,
             CAST(NULL AS DATE)          AS DH_EXECUCAO,
             CAST(NULL AS VARCHAR2(128)) AS USUARIO_EXECUCAO,
             P.CODPARC,
             P.NOMEPARC    AS NOMEPARC_ANTES,
             P.RAZAOSOCIAL AS RAZAOSOCIAL_ANTES,
             P.NOMEPARC    AS NOMEPARC_DEPOIS,
             P.RAZAOSOCIAL AS RAZAOSOCIAL_DEPOIS
        FROM TGFPAR P
       WHERE 1 = 0
    ]';
    DBMS_OUTPUT.PUT_LINE('BACKUP_CRIADO=BKP_AJNP_TGFPAR');
  ELSE
    DBMS_OUTPUT.PUT_LINE('BACKUP_EXISTENTE=BKP_AJNP_TGFPAR');
  END IF;
END;
/

DECLARE
  c_id_execucao CONSTANT VARCHAR2(30) :=
    'AJNP_' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF3');

  v_alterados     PLS_INTEGER := 0;
  v_backups       PLS_INTEGER := 0;

  FUNCTION somente_digitos(p_texto VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE(p_texto, '[^0-9]', '');
  END;

  FUNCTION textos_diferentes(p_atual VARCHAR2, p_novo VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_atual <> p_novo)
        OR (p_atual IS NULL AND p_novo IS NOT NULL)
        OR (p_atual IS NOT NULL AND p_novo IS NULL);
  END;

  FUNCTION nome_ajustado(
    p_nome    VARCHAR2,
    p_cgc_cpf VARCHAR2
  ) RETURN VARCHAR2 IS
    v_nome          VARCHAR2(4000);
    v_documento     VARCHAR2(32);
    v_bloco_inicial VARCHAR2(4000);
    v_bloco_final   VARCHAR2(4000);
    v_digitos       VARCHAR2(64);
    v_resultado     VARCHAR2(4000);
    v_removeu       BOOLEAN := FALSE;

    FUNCTION corresponde_documento(p_digitos VARCHAR2) RETURN BOOLEAN IS
    BEGIN
      RETURN LENGTH(p_digitos) >= 6
         AND INSTR(v_documento, p_digitos) > 0;
    END;
  BEGIN
    IF p_nome IS NULL OR p_cgc_cpf IS NULL THEN
      RETURN p_nome;
    END IF;

    v_nome := REPLACE(REPLACE(REPLACE(p_nome, CHR(160), ' '), CHR(9), ' '), CHR(13), ' ');
    v_nome := REPLACE(v_nome, CHR(10), ' ');
    v_documento := somente_digitos(p_cgc_cpf);

    v_resultado := v_nome;

    -- Captura o bloco anterior a primeira letra.
    v_bloco_inicial := REGEXP_SUBSTR(v_nome, '^[0-9 .,/()-]*');
    v_digitos := somente_digitos(v_bloco_inicial);

    IF corresponde_documento(v_digitos) THEN
      v_resultado := SUBSTR(v_resultado, LENGTH(v_bloco_inicial) + 1);
      v_removeu := TRUE;
    END IF;

    -- Captura o bloco posterior a ultima letra, depois do ajuste inicial.
    v_bloco_final := REGEXP_SUBSTR(v_resultado, '[0-9 .,/()-]*$');
    v_digitos := somente_digitos(v_bloco_final);

    IF corresponde_documento(v_digitos) THEN
      v_resultado := SUBSTR(v_resultado, 1, LENGTH(v_resultado) - LENGTH(v_bloco_final));
      v_removeu := TRUE;
    END IF;

    IF NOT v_removeu THEN
      RETURN p_nome;
    END IF;

    v_resultado := REGEXP_REPLACE(TRIM(v_resultado), ' +', ' ');

    IF v_resultado IS NULL OR NOT REGEXP_LIKE(v_resultado, '[A-Za-z]') THEN
      RETURN p_nome;
    END IF;

    RETURN v_resultado;
  END;
BEGIN
  SAVEPOINT AJUSTE_NOMES_INICIO;

  FOR r IN (
    SELECT CODPARC, NOMEPARC, RAZAOSOCIAL, CGC_CPF
      FROM TGFPAR
     WHERE CGC_CPF IS NOT NULL
       AND (NOMEPARC IS NOT NULL OR RAZAOSOCIAL IS NOT NULL)
     ORDER BY CODPARC
  ) LOOP
    DECLARE
      v_nome_novo  TGFPAR.NOMEPARC%TYPE;
      v_razao_nova TGFPAR.RAZAOSOCIAL%TYPE;
    BEGIN
      v_nome_novo  := nome_ajustado(r.NOMEPARC, r.CGC_CPF);
      v_razao_nova := nome_ajustado(r.RAZAOSOCIAL, r.CGC_CPF);

      IF textos_diferentes(r.NOMEPARC, v_nome_novo)
         OR textos_diferentes(r.RAZAOSOCIAL, v_razao_nova)
      THEN
        INSERT INTO BKP_AJNP_TGFPAR (
          ID_EXECUCAO, DH_EXECUCAO, USUARIO_EXECUCAO, CODPARC,
          NOMEPARC_ANTES, RAZAOSOCIAL_ANTES,
          NOMEPARC_DEPOIS, RAZAOSOCIAL_DEPOIS
        ) VALUES (
          c_id_execucao, SYSDATE, SYS_CONTEXT('USERENV', 'SESSION_USER'), r.CODPARC,
          r.NOMEPARC, r.RAZAOSOCIAL, v_nome_novo, v_razao_nova
        );
        v_backups := v_backups + 1;

        UPDATE TGFPAR
           SET NOMEPARC    = v_nome_novo,
               RAZAOSOCIAL = v_razao_nova
         WHERE CODPARC = r.CODPARC;
        v_alterados := v_alterados + SQL%ROWCOUNT;
      END IF;
    END;
  END LOOP;

  IF v_alterados <> v_backups THEN
    RAISE_APPLICATION_ERROR(
      -20031,
      'Quantidade alterada (' || v_alterados ||
      ') difere dos backups (' || v_backups || ').'
    );
  END IF;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO=' || c_id_execucao);
  DBMS_OUTPUT.PUT_LINE('BACKUPS=' || v_backups);
  DBMS_OUTPUT.PUT_LINE('REGISTROS_ALTERADOS=' || v_alterados);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO AJUSTE_NOMES_INICIO;
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    RAISE;
END;
/
