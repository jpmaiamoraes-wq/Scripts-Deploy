--CREATE TABLE TGFPAR_BKP AS SELECT * FROM TGFPAR;
--SELECT * FROM TGFPAR_BKP;

DECLARE
  v_cgc_digits   VARCHAR2(32);
  v_nom          VARCHAR2(4000);
  v_raz          VARCHAR2(4000);
  v_lead_block   VARCHAR2(4000);
  v_tail_block   VARCHAR2(4000);
  v_lead_digits  VARCHAR2(64);
  v_tail_digits  VARCHAR2(64);

  FUNCTION only_digits(p_txt VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE(p_txt, '\D', '');
  END;
BEGIN
  FOR r IN (
    SELECT CODPARC, NOMEPARC, RAZAOSOCIAL, CGC_CPF
    FROM TGFPAR
    WHERE NOMEPARC IS NOT NULL OR RAZAOSOCIAL IS NOT NULL
  ) LOOP
    v_cgc_digits := only_digits(NVL(r.CGC_CPF,''));

    ----------------------------------------------------------------
    -- NOMEPARC
    ----------------------------------------------------------------
    IF r.NOMEPARC IS NOT NULL THEN
      -- normaliza NBSP e similares
      v_nom := REPLACE(r.NOMEPARC, CHR(160), ' ');

      -- BLOCO INICIAL: tudo até a primeira letra (inclui dígitos, espaços, pontuação)
      v_lead_block  := REGEXP_SUBSTR(v_nom, '^[^[:alpha:]]*');       -- pode ser NULL
      v_lead_digits := only_digits(NVL(v_lead_block, ''));

      IF v_cgc_digits IS NOT NULL
         AND LENGTH(v_lead_digits) >= 3
         AND INSTR(v_cgc_digits, v_lead_digits) > 0
      THEN
        -- remove o bloco inicial não-alfabético
        v_nom := SUBSTR(v_nom, LENGTH(NVL(v_lead_block,'')) + 1);
      END IF;

      -- BLOCO FINAL: tudo após a última letra
      v_tail_block  := REGEXP_SUBSTR(v_nom, '[^[:alpha:]]*$');
      v_tail_digits := only_digits(NVL(v_tail_block, ''));

      IF v_cgc_digits IS NOT NULL
         AND LENGTH(v_tail_digits) >= 3
         AND INSTR(v_cgc_digits, v_tail_digits) > 0
      THEN
        -- remove o bloco final não-alfabético
        v_nom := SUBSTR(v_nom, 1, LENGTH(v_nom) - LENGTH(NVL(v_tail_block,'')));
      END IF;

      -- acabamento: trim + colapsa espaços múltiplos
      v_nom := REGEXP_REPLACE(TRIM(v_nom), ' {2,}', ' ');

      UPDATE TGFPAR
         SET NOMEPARC = v_nom
       WHERE CODPARC  = r.CODPARC;
    END IF;

    ----------------------------------------------------------------
    -- RAZAOSOCIAL
    ----------------------------------------------------------------
    IF r.RAZAOSOCIAL IS NOT NULL THEN
      v_raz := REPLACE(r.RAZAOSOCIAL, CHR(160), ' ');

      v_lead_block  := REGEXP_SUBSTR(v_raz, '^[^[:alpha:]]*');
      v_lead_digits := only_digits(NVL(v_lead_block, ''));

      IF v_cgc_digits IS NOT NULL
         AND LENGTH(v_lead_digits) >= 3
         AND INSTR(v_cgc_digits, v_lead_digits) > 0
      THEN
        v_raz := SUBSTR(v_raz, LENGTH(NVL(v_lead_block,'')) + 1);
      END IF;

      v_tail_block  := REGEXP_SUBSTR(v_raz, '[^[:alpha:]]*$');
      v_tail_digits := only_digits(NVL(v_tail_block, ''));

      IF v_cgc_digits IS NOT NULL
         AND LENGTH(v_tail_digits) >= 3
         AND INSTR(v_cgc_digits, v_tail_digits) > 0
      THEN
        v_raz := SUBSTR(v_raz, 1, LENGTH(v_raz) - LENGTH(NVL(v_tail_block,'')));
      END IF;

      v_raz := REGEXP_REPLACE(TRIM(v_raz), ' {2,}', ' ');

      UPDATE TGFPAR
         SET RAZAOSOCIAL = v_raz
       WHERE CODPARC     = r.CODPARC;
    END IF;

  END LOOP;

  COMMIT;
END;