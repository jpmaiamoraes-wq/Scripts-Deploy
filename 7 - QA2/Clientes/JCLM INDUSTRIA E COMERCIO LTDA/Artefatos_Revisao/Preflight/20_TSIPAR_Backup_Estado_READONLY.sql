-- Estado persistido do backup e da alteracao da etapa 02; somente leitura.
SELECT 'BKP_RMD_01_TSIPAR' AS OBJETO,
       COUNT(*) AS QTD_REGISTROS_BACKUP,
       MIN(ID_EXECUCAO) AS PRIMEIRO_ID_EXECUCAO,
       MAX(ID_EXECUCAO) AS ULTIMO_ID_EXECUCAO
  FROM BKP_RMD_01_TSIPAR;
