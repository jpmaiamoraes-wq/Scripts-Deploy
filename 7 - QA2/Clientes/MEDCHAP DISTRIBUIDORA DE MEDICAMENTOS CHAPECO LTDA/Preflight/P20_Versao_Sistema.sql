-- Preflight read-only MEDCHAP DISTRIBUIDORA DE MEDICAMENTOS CHAPECO LTDA. Somente SELECT/WITH via oracle_direct.py query. Sem DML/DDL.
-- Versao do sistema Sankhya (campo 'Versao do Sistema' de eventual chamado Cloud).
SELECT TEXTO AS VERSAO_SISTEMA
  FROM TSIPAR
 WHERE CHAVE = 'VERSAOSKWBIN'
