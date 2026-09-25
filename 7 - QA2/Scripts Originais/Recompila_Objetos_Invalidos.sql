-- Tenta recompilar objetos invalidos do schema atual e lista o que permanecer invalido.
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET SQLBLANKLINES ON;
DECLARE
  v_schema VARCHAR2(128) := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
  v_antes  NUMBER;
  v_depois NUMBER;
  v_alter_any_procedure NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_antes
    FROM ALL_OBJECTS
   WHERE OWNER = v_schema
     AND STATUS = 'INVALID';
  DBMS_OUTPUT.PUT_LINE('Schema verificado: ' || v_schema);
  DBMS_OUTPUT.PUT_LINE('Objetos invalidos antes da recompilacao: ' || v_antes);
  SELECT COUNT(*) INTO v_alter_any_procedure
    FROM SESSION_PRIVS
   WHERE PRIVILEGE = 'ALTER ANY PROCEDURE';
  IF v_schema <> SYS_CONTEXT('USERENV', 'SESSION_USER') AND v_alter_any_procedure = 0 THEN
    DBMS_OUTPUT.PUT_LINE('AVISO: usuario ' || SYS_CONTEXT('USERENV', 'SESSION_USER') ||
      ' nao possui ALTER ANY PROCEDURE para recompilar funcoes/procedures do schema ' || v_schema || '.');
  END IF;
  IF v_antes > 0 THEN
    BEGIN
      DBMS_UTILITY.COMPILE_SCHEMA(SCHEMA => v_schema, COMPILE_ALL => FALSE);
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('AVISO: tentativa global de recompilacao retornou: ' || SQLERRM);
    END;
  END IF;
  SELECT COUNT(*) INTO v_depois
    FROM ALL_OBJECTS
   WHERE OWNER = v_schema
     AND STATUS = 'INVALID';
  DBMS_OUTPUT.PUT_LINE('Objetos invalidos depois da recompilacao: ' || v_depois);
END;
/
COLUMN OBJECT_TYPE FORMAT A24
COLUMN OBJECT_NAME FORMAT A50
SELECT OBJECT_TYPE, OBJECT_NAME
  FROM ALL_OBJECTS
 WHERE OWNER = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
   AND STATUS = 'INVALID'
 ORDER BY OBJECT_TYPE, OBJECT_NAME;
COLUMN NAME FORMAT A50
COLUMN TYPE FORMAT A20
COLUMN TEXT FORMAT A120
SELECT NAME, TYPE, LINE, POSITION, TEXT
  FROM ALL_ERRORS
 WHERE OWNER = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
 ORDER BY NAME, TYPE, SEQUENCE;
PROMPT === FIM RECOMPILACAO OBJETOS INVALIDOS ===
