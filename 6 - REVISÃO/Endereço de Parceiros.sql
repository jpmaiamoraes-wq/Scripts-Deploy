MERGE INTO TGFPAR P
USING (
    -- Esta é a sua consulta original, que atua como a "fonte de dados"
    SELECT
        Q.CODPARC,
        Q.CEP_XML,
        Q.CODCID_XML
    FROM (
        SELECT
            C.CODPARC,
            -- Lógica de Inversão CEP
            CASE WHEN COALESCE(XT.CNPJ_EMIT, XT.CPF_EMIT) IN ('21066139000108', '47964749000112', '21066139003042','17134434000187','21066139000450','21066139001422')
                 THEN XT.CEP_DEST ELSE XT.CEP_EMIT END AS CEP_XML,
            -- Lógica para obter a cidade, necessária para o UPDATE
            (SELECT CID.CODCID
             FROM TSICID CID
             INNER JOIN TSIUFS U ON U.CODUF = CID.UF
             WHERE CID.CODMUNFIS = (CASE WHEN COALESCE(XT.CNPJ_EMIT, XT.CPF_EMIT) IN ('21066139000108', '47964749000112', '21066139003042','17134434000187','21066139000450','21066139001422')
                                         THEN XT.MUN_DEST ELSE XT.MUN_EMIT END)
               AND U.UF = (CASE WHEN COALESCE(XT.CNPJ_EMIT, XT.CPF_EMIT) IN ('21066139000108', '47964749000112', '21066139003042','17134434000187','21066139000450','21066139001422')
                                THEN XT.UF_DEST ELSE XT.UF_EMIT END)
               AND ROWNUM = 1) AS CODCID_XML,
            ROW_NUMBER() OVER (PARTITION BY C.CODPARC ORDER BY C.DTNEG DESC) AS RN
        FROM TGFCAB C
        INNER JOIN TGFNFE X ON C.NUNOTA = X.NUNOTA
        CROSS JOIN XMLTABLE(
            XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe'),
            '//infNFe'
            PASSING XMLTYPE(X.XML)
            COLUMNS
                CNPJ_EMIT VARCHAR2(14) PATH 'emit/CNPJ',
                CPF_EMIT  VARCHAR2(11) PATH 'emit/CPF',
                CEP_EMIT  VARCHAR2(8)  PATH 'emit/enderEmit/CEP',
                MUN_EMIT  VARCHAR2(60) PATH 'emit/enderEmit/cMun',
                UF_EMIT   VARCHAR2(2)  PATH 'emit/enderEmit/UF',
                CNPJ_DEST VARCHAR2(14) PATH 'dest/CNPJ',
                CPF_DEST  VARCHAR2(11) PATH 'dest/CPF',
                CEP_DEST  VARCHAR2(8)  PATH 'dest/enderDest/CEP',
                MUN_DEST  VARCHAR2(60) PATH 'dest/enderDest/cMun',
                UF_DEST   VARCHAR2(2)  PATH 'dest/enderDest/UF'
        ) XT
    ) Q
    WHERE Q.RN = 1 AND Q.CEP_XML IS NOT NULL -- Garantimos que temos a última nota e que o CEP do XML não é nulo
) FONTE ON (P.CODPARC = FONTE.CODPARC) -- Condição de junção entre a tabela alvo e a fonte
WHEN MATCHED THEN
    UPDATE SET
        P.CEP = FONTE.CEP_XML,
        P.CODCID = FONTE.CODCID_XML -- Atualizando também a cidade
    WHERE
        P.CEP <> FONTE.CEP_XML ; -- Aplicando a sua condição original aqui

