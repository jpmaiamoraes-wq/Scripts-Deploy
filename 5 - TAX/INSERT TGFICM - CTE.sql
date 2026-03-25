SELECT 
    COMANDO_INSERT 
FROM (
    SELECT
        UF_INI,
        UF_FIM,
        CFOP,
        CST,
        PERC_ICMS,
        PERC_RED,
        PERC_OUTRA_UF,
        ROW_NUMBER() OVER (
            PARTITION BY UF_INI, UF_FIM, CFOP 
            ORDER BY DTNEG DESC, NUMNOTA DESC
        ) AS RANKING,
        -- Montagem do Comando corrigida
        'INSERT INTO TGFICM (UFORIG, UFDEST, TIPRESTRICAO, CODRESTRICAO, TIPRESTRICAO2, CODRESTRICAO2, CODTRIB, ALIQUOTA, REDBASE, BASICMMOD) VALUES ('
        || NVL((SELECT TO_CHAR(CODUF) FROM TSIUFS WHERE UF = UF_INI AND UF <> 'EX'), '0') || ', '
        || NVL((SELECT TO_CHAR(CODUF) FROM TSIUFS WHERE UF = UF_FIM AND UF <> 'EX'), '0') || ', '
        || '''U'', '                                       
        || '''' || CFOP || ''', '  
        || '''' || 'S' || ''', '
        || '''' || '-1' || ''', '
        || TO_NUMBER(CST) || ', ' -- Convertendo CST para número para evitar erro de tipo
        || REPLACE(NVL(PERC_ICMS, NVL(PERC_OUTRA_UF, 0)), ',', '.') || ', '
        || REPLACE(NVL(PERC_RED, 0), ',', '.') || ', '
        || '3);' AS COMANDO_INSERT
    FROM AD_TTKPITICTE
) 
WHERE RANKING = 1 
  AND UF_FIM <> 'EX'
  AND CFOP > 5000;
