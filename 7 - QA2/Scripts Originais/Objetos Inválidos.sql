--⭐ Consulta “coringa” (uso diário)
SELECT OBJECT_TYPE,
       OBJECT_NAME,
       STATUS
FROM   USER_OBJECTS
WHERE  STATUS <> 'VALID'
   OR  (OBJECT_TYPE = 'TRIGGER' AND OBJECT_NAME IN (
        SELECT TRIGGER_NAME
        FROM USER_TRIGGERS
        WHERE STATUS = 'DISABLED'
   ))
ORDER  BY OBJECT_TYPE, OBJECT_NAME;

--Apenas triggers DISABLED
SELECT TRIGGER_NAME,
       TABLE_NAME,
       STATUS
FROM   USER_TRIGGERS
WHERE  STATUS = 'DISABLED';

--Objetos inválidos (procedures, functions, packages, views, triggers, etc.)
SELECT OBJECT_TYPE,
       OBJECT_NAME,
       STATUS
FROM   USER_OBJECTS
WHERE  STATUS <> 'VALID'
ORDER  BY OBJECT_TYPE, OBJECT_NAME;

--Ver o erro na compilação.
SELECT LINE,
       POSITION,
       TEXT
FROM   USER_ERRORS
WHERE  NAME = 'NOME_DO_OBJETO'
ORDER  BY SEQUENCE;

-- Compilar todos objetos inválidos.
BEGIN
  DBMS_UTILITY.COMPILE_SCHEMA(
    schema => USER,
    compile_all => TRUE
  );
END;
/