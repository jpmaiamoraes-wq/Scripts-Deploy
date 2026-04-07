MERGE INTO TGFCAB C
USING (
  /* 1) Distinct do relacionamento para evitar duplicatas na origem */
  WITH TV AS (
    SELECT DISTINCT CODTIPVENDA, DESCRTIPVENDA
    FROM TGFTPV
  ),
  /* 2) Descrições repetidas e seu menor CODTIPVENDA */
  DUP AS (
    SELECT DESCRTIPVENDA, MIN(CODTIPVENDA) AS CODTIP_MIN
    FROM TGFTPV
    GROUP BY DESCRTIPVENDA
    HAVING COUNT(*) > 1
  ),
  /* 3) Para o CODTIP_MIN escolhido, pegar um DHALTER consistente (o mais recente) */
  MAP AS (
    SELECT D.DESCRTIPVENDA,
           D.CODTIP_MIN,
           (SELECT MAX(P.DHALTER)
              FROM TGFTPV P
             WHERE P.CODTIPVENDA = D.CODTIP_MIN) AS DH_MIN
    FROM DUP D
  ),
  /* 4) Origem do MERGE: 1 linha por NUNOTA (ROWID), deduplicada */
  SRC AS (
    SELECT
      C.ROWID             AS RID,
      M.CODTIP_MIN        AS NEW_CODTIP,
      M.DH_MIN            AS NEW_DH,
      ROW_NUMBER() OVER (
        PARTITION BY C.ROWID
        ORDER BY M.CODTIP_MIN
      ) AS RN
    FROM TGFCAB C
    JOIN TV      T  ON T.CODTIPVENDA = C.CODTIPVENDA     -- evita multi-linhas por versões
    JOIN MAP     M  ON M.DESCRTIPVENDA = T.DESCRTIPVENDA  -- 1 linha por descrição
    WHERE C.CODTIPVENDA <> M.CODTIP_MIN
  )
  SELECT RID, NEW_CODTIP, NEW_DH
  FROM SRC
  WHERE RN = 1     -- garante conjunto estável (1 origem por destino)
) S
ON (C.ROWID = S.RID)
WHEN MATCHED THEN
  UPDATE SET C.CODTIPVENDA = S.NEW_CODTIP,
             C.DHTIPVENDA  = S.NEW_DH;MERGE INTO TGFCAB C
USING (
  /* 1) Distinct do relacionamento para evitar duplicatas na origem */
  WITH TV AS (
    SELECT DISTINCT CODTIPVENDA, DESCRTIPVENDA
    FROM TGFTPV
  ),
  /* 2) Descrições repetidas e seu menor CODTIPVENDA */
  DUP AS (
    SELECT DESCRTIPVENDA, MIN(CODTIPVENDA) AS CODTIP_MIN
    FROM TGFTPV
    GROUP BY DESCRTIPVENDA
    HAVING COUNT(*) > 1
  ),
  /* 3) Para o CODTIP_MIN escolhido, pegar um DHALTER consistente (o mais recente) */
  MAP AS (
    SELECT D.DESCRTIPVENDA,
           D.CODTIP_MIN,
           (SELECT MAX(P.DHALTER)
              FROM TGFTPV P
             WHERE P.CODTIPVENDA = D.CODTIP_MIN) AS DH_MIN
    FROM DUP D
  ),
  /* 4) Origem do MERGE: 1 linha por NUNOTA (ROWID), deduplicada */
  SRC AS (
    SELECT
      C.ROWID             AS RID,
      M.CODTIP_MIN        AS NEW_CODTIP,
      M.DH_MIN            AS NEW_DH,
      ROW_NUMBER() OVER (
        PARTITION BY C.ROWID
        ORDER BY M.CODTIP_MIN
      ) AS RN
    FROM TGFCAB C
    JOIN TV      T  ON T.CODTIPVENDA = C.CODTIPVENDA     -- evita multi-linhas por versões
    JOIN MAP     M  ON M.DESCRTIPVENDA = T.DESCRTIPVENDA  -- 1 linha por descrição
    WHERE C.CODTIPVENDA <> M.CODTIP_MIN
  )
  SELECT RID, NEW_CODTIP, NEW_DH
  FROM SRC
  WHERE RN = 1     -- garante conjunto estável (1 origem por destino)
) S
ON (C.ROWID = S.RID)
WHEN MATCHED THEN
  UPDATE SET C.CODTIPVENDA = S.NEW_CODTIP,
             C.DHTIPVENDA  = S.NEW_DH;