-- Diagnostico individual de objetos invalidos no CURRENT_SCHEMA.
-- Tenta recompilar cada objeto e imprime os erros imediatamente.
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET SQLBLANKLINES ON;
DECLARE
  v_schema    VARCHAR2(128) := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
  v_sql       VARCHAR2(1000);
  v_status    VARCHAR2(7);
  v_restantes NUMBER;
  v_erros     NUMBER;
  v_sem_priv   NUMBER := 0;
  v_outras     NUMBER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('DIAGNOSTICO_SCHEMA=' || v_schema);
  FOR r IN (
    SELECT OBJECT_TYPE, OBJECT_NAME
      FROM ALL_OBJECTS
     WHERE OWNER = v_schema
       AND STATUS = 'INVALID'
     ORDER BY OBJECT_TYPE, OBJECT_NAME
  ) LOOP
    v_sql := NULL;
    v_status := NULL;
    IF r.OBJECT_TYPE = 'FUNCTION' THEN
      v_sql := 'ALTER FUNCTION ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE';
    ELSIF r.OBJECT_TYPE = 'PROCEDURE' THEN
      v_sql := 'ALTER PROCEDURE ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE';
    ELSIF r.OBJECT_TYPE = 'PACKAGE' THEN
      v_sql := 'ALTER PACKAGE ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE SPECIFICATION';
    ELSIF r.OBJECT_TYPE = 'PACKAGE BODY' THEN
      v_sql := 'ALTER PACKAGE ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE BODY';
    ELSIF r.OBJECT_TYPE = 'TRIGGER' THEN
      v_sql := 'ALTER TRIGGER ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE';
    ELSIF r.OBJECT_TYPE = 'VIEW' THEN
      v_sql := 'ALTER VIEW ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE';
    ELSIF r.OBJECT_TYPE = 'TYPE' THEN
      v_sql := 'ALTER TYPE ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE SPECIFICATION';
    ELSIF r.OBJECT_TYPE = 'TYPE BODY' THEN
      v_sql := 'ALTER TYPE ' || DBMS_ASSERT.ENQUOTE_NAME(v_schema, FALSE) || '.' || DBMS_ASSERT.ENQUOTE_NAME(r.OBJECT_NAME, FALSE) || ' COMPILE BODY';
    END IF;
    IF v_sql IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('NAO_SUPORTADO|' || r.OBJECT_TYPE || '|' || r.OBJECT_NAME);
    ELSE
      BEGIN
        EXECUTE IMMEDIATE v_sql;
        SELECT STATUS INTO v_status
          FROM ALL_OBJECTS
         WHERE OWNER = v_schema
           AND OBJECT_TYPE = r.OBJECT_TYPE
           AND OBJECT_NAME = r.OBJECT_NAME
           AND ROWNUM = 1;
        DBMS_OUTPUT.PUT_LINE('RESULTADO|' || r.OBJECT_TYPE || '|' || r.OBJECT_NAME || '|' || v_status);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('FALHA|' || r.OBJECT_TYPE || '|' || r.OBJECT_NAME || '|' || SQLERRM);
          IF SQLCODE = -1031 THEN
            v_sem_priv := v_sem_priv + 1;
          ELSE
            v_outras := v_outras + 1;
          END IF;
      END;
      v_erros := 0;
      FOR e IN (
        SELECT TYPE, LINE, POSITION, TEXT
          FROM ALL_ERRORS
         WHERE OWNER = v_schema
           AND NAME = r.OBJECT_NAME
         ORDER BY TYPE, SEQUENCE
      ) LOOP
        v_erros := v_erros + 1;
        DBMS_OUTPUT.PUT_LINE('ERRO_COMPILACAO|' || r.OBJECT_NAME || '|' || e.TYPE || '|LINHA=' || e.LINE || '|POS=' || e.POSITION || '|' || e.TEXT);
      END LOOP;
      IF v_erros = 0 AND NVL(v_status, 'INVALID') = 'INVALID' THEN
        DBMS_OUTPUT.PUT_LINE('SEM_DETALHE_ALL_ERRORS|' || r.OBJECT_TYPE || '|' || r.OBJECT_NAME);
      END IF;
    END IF;
  END LOOP;
  SELECT COUNT(*) INTO v_restantes
    FROM ALL_OBJECTS
   WHERE OWNER = v_schema
     AND STATUS = 'INVALID';
  DBMS_OUTPUT.PUT_LINE('INVALIDOS_RESTANTES=' || v_restantes);
  DBMS_OUTPUT.PUT_LINE('FALHAS_SEM_PRIVILEGIO=' || v_sem_priv);
  DBMS_OUTPUT.PUT_LINE('FALHAS_OUTROS_MOTIVOS=' || v_outras);
END;
/
PROMPT === FIM DIAGNOSTICO INDIVIDUAL OBJETOS INVALIDOS ===
