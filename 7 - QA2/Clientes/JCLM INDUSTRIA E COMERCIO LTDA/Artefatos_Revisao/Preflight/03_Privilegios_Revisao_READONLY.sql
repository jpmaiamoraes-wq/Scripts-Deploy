-- Inventario somente leitura de todos os privilegios da sessao.
-- A filtragem dos privilegios relevantes sera feita no registro local, para
-- evitar que o validador read-only interprete nomes de privilegio como DDL.
SELECT PRIVILEGE
  FROM SESSION_PRIVS
 ORDER BY PRIVILEGE;
