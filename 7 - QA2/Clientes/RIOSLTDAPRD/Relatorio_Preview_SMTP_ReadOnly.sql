WITH PARAMETRO_RESUMO AS (
    SELECT CASE
               WHEN LOWER(SUBSTR(REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 1), 1,
                                  INSTR(REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 1) || ':', ':') - 1)) = 'email-smtp.us-east-1.amazonaws.com'
                 OR LOWER(REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 4)) = 'noreply@sankhya.com.br'
               THEN 1 ELSE 0
           END CONTA_TESTE,
           CASE
               WHEN REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 1) IS NULL
                 OR REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 2) IS NULL
                 OR REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 4) IS NULL
                 OR REGEXP_SUBSTR(TEXTO, '[^'||CHR(59)||']+', 1, 6) IS NULL
               THEN 1 ELSE 0
           END CAMPOS_NAO_SECRETOS_INCOMPLETOS
      FROM TSIPAR
     WHERE CHAVE = 'MSDSMTPPROP'
), SMTP_RESUMO AS (
    SELECT CASE
               WHEN LOWER(NVL(SERVIDOR, '-')) = 'email-smtp.us-east-1.amazonaws.com'
                 OR LOWER(NVL(REMETENTE, '-')) = 'noreply@sankhya.com.br'
               THEN 1 ELSE 0
           END CONTA_TESTE,
           CASE
               WHEN SERVIDOR IS NULL OR PORTA IS NULL OR TIPO IS NULL OR REMETENTE IS NULL
               THEN 1 ELSE 0
           END CAMPOS_NAO_SECRETOS_INCOMPLETOS
      FROM TSISMTP
)
SELECT FONTE, QTD_REGISTROS, QTD_CONTAS_TESTE,
       QTD_CONTAS_CLIENTE, QTD_CLIENTE_INCOMPLETAS
  FROM (
        SELECT 'TSIPAR.MSDSMTPPROP' FONTE,
               COUNT(*) QTD_REGISTROS,
               NVL(SUM(CONTA_TESTE), 0) QTD_CONTAS_TESTE,
               COUNT(*) - NVL(SUM(CONTA_TESTE), 0) QTD_CONTAS_CLIENTE,
               NVL(SUM(CASE WHEN CONTA_TESTE = 0 THEN CAMPOS_NAO_SECRETOS_INCOMPLETOS ELSE 0 END), 0) QTD_CLIENTE_INCOMPLETAS
          FROM PARAMETRO_RESUMO
        UNION ALL
        SELECT 'TSISMTP' FONTE,
               COUNT(*) QTD_REGISTROS,
               NVL(SUM(CONTA_TESTE), 0) QTD_CONTAS_TESTE,
               COUNT(*) - NVL(SUM(CONTA_TESTE), 0) QTD_CONTAS_CLIENTE,
               NVL(SUM(CASE WHEN CONTA_TESTE = 0 THEN CAMPOS_NAO_SECRETOS_INCOMPLETOS ELSE 0 END), 0) QTD_CLIENTE_INCOMPLETAS
          FROM SMTP_RESUMO
       )
 ORDER BY FONTE
