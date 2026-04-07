-- Criação de tabela auxiliar
CREATE TABLE TGFNFE_ITEM_XML_STG (
    NUNOTA   NUMBER        NOT NULL,
    CHNFE    VARCHAR2(44)  NOT NULL,
    NITEM    NUMBER        NOT NULL,
    CPROD    VARCHAR2(60),
    XPROD    VARCHAR2(255),
    CEAN     VARCHAR2(14),
    CONSTRAINT PK_TGFNFE_ITEM_XML_STG
        PRIMARY KEY (NUNOTA, NITEM)
);

-- Criação de indices
CREATE INDEX IDX_NFEITEM_CHNFE ON TGFNFE_ITEM_XML_STG (CHNFE);
CREATE INDEX IDX_NFEITEM_CPROD ON TGFNFE_ITEM_XML_STG (CPROD);
CREATE INDEX IDX_NFEITEM_CEAN  ON TGFNFE_ITEM_XML_STG (CEAN);
    
-- Compilação da Procedure
CREATE OR REPLACE PROCEDURE STP_CARGA_NFE_ITEM_STG(p_step IN NUMBER DEFAULT 10000) IS
  v_min NUMBER;
  v_max NUMBER;
  v_ini NUMBER;
  v_fim NUMBER;
  v_ins NUMBER;
BEGIN
  SELECT MIN(nunota), MAX(nunota)
    INTO v_min, v_max
    FROM tgfnfe;

  v_ini := v_min;

  WHILE v_ini <= v_max LOOP
    v_fim := LEAST(v_ini + p_step - 1, v_max);

    INSERT INTO TGFNFE_ITEM_XML_STG (NUNOTA, CHNFE, NITEM, CPROD, XPROD, CEAN)
    SELECT
      n.nunota,
      x.chnfe,
      d.nitem,
      d.cprod,
      SUBSTR(d.xprod, 1, 255) AS xprod,
      SUBSTR(d.cean, 1, 14)  AS cean
    FROM tgfnfe n
    CROSS JOIN XMLTABLE(
      XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe'),
      '/nfeProc'
      PASSING XMLTYPE(n.xml)
      COLUMNS
        chnfe VARCHAR2(44) PATH 'protNFe/infProt/chNFe',
        dets  XMLTYPE      PATH 'NFe/infNFe/det'
    ) x
    CROSS JOIN XMLTABLE(
      XMLNAMESPACES(DEFAULT 'http://www.portalfiscal.inf.br/nfe'),
      '/det'
      PASSING x.dets
      COLUMNS
        nitem NUMBER          PATH '@nItem',
        cprod VARCHAR2(60)    PATH 'prod/cProd',
        xprod VARCHAR2(4000)  PATH 'prod/xProd',
        cean  VARCHAR2(60)    PATH 'prod/cEAN'
    ) d
    WHERE n.nunota BETWEEN v_ini AND v_fim
      AND NOT EXISTS (
            SELECT 1
            FROM TGFNFE_ITEM_XML_STG s
            WHERE s.nunota = n.nunota
              AND s.nitem  = d.nitem
          );

    v_ins := SQL%ROWCOUNT;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Bloco NUNOTA '||v_ini||'..'||v_fim||' -> inseridas: '||v_ins);

    v_ini := v_fim + 1;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Concluído.');
END;
/

-- Execução da Procedure
SET SERVEROUTPUT ON;
BEGIN
  STP_CARGA_NFE_ITEM_STG(10000);
END;
/

-- Consulta Comparativa
SELECT DISTINCT
  C.TIPMOV,
  I.NUNOTA,
  I.SEQUENCIA,
  P1.REFERENCIA,
  I.CODPROD,
  P1.AD_IDEXTERNO,
  P1.DESCRPROD,
  X.NITEM,
  X.CEAN,
  X.CPROD,
  X.XPROD,
  X.CHNFE
FROM TGFITE I
JOIN TGFCAB C ON C.NUNOTA = I.NUNOTA
JOIN TGFPRO P1
  ON P1.CODPROD = I.CODPROD
LEFT JOIN TGFNFE_ITEM_XML_STG X
  ON X.NUNOTA = I.NUNOTA
 AND X.NITEM  = I.SEQUENCIA
-- JOIN TGFPRO P2
--  ON P2.CODPROD =
--     CASE
--       WHEN REGEXP_LIKE(TRIM(X.CPROD), '^[0-9]+$')
--         THEN TO_NUMBER(TRIM(X.CPROD))   -- remove zeros à esquerda automaticamente
--       ELSE NULL
--     END
WHERE I.CODPROD <> CASE
                       WHEN REGEXP_LIKE(TRIM(X.CPROD), '^[0-9]+$')
                         THEN TO_NUMBER(TRIM(X.CPROD))   -- remove zeros à esquerda automaticamente
                       ELSE NULL
                     END
AND SUBSTR(REGEXP_REPLACE(TRIM(UPPER(P1.DESCRPROD)),' {2,}',' '),1,2) <> SUBSTR(REGEXP_REPLACE(TRIM(UPPER(X.XPROD)),' {2,}',' '),1,2)
AND P1.REFERENCIA <> X.CEAN
--AND SUBSTR(P1.DESCRPROD,1,5) <> SUBSTR(X.XPROD,1,5)
--WHERE i.nunota = 3260
--AND I.CODPROD = 14517
ORDER BY I.NUNOTA, I.SEQUENCIA;

SELECT XML FROM TGFNFE WHERE NUNOTA = 838;
