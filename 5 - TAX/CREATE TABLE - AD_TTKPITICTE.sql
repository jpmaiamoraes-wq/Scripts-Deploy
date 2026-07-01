CREATE TABLE AD_TTKPITICTE
AS
SELECT 
    C.NUNOTA,
    C.NUMNOTA,
    C.DTNEG,
    C.CHAVECTE,
    XT.CFOP,
    O.DESCRCFO AS DESCRICAO,
    E.RAZAOSOCIAL AS RAZAO_SOCIAL,
    E.CGC,
    P.NOMEPARC AS NOME_PARCEIRO,
    P.CGC_CPF,
    XT.UF_INI,
    XT.UF_FIM,
    XT.CST,
    XT.PERC_ICMS,
    XT.PERC_RED,
    XT.PERC_ICMS_RET,
    XT.PERC_OUTRA_UF,
    XT.OBSERVACAO,
    CASE XT.TPSERV
        WHEN '0' THEN 1109
        WHEN '1' THEN 1110
        WHEN '2' THEN 1111
        WHEN '3' THEN 1112
        WHEN '4' THEN 1109
        ELSE C.CODTIPOPER
    END AS TOP_SUGERIDA
FROM TGFCAB C
INNER JOIN TGFPAR P ON P.CODPARC = C.CODPARC
INNER JOIN TGFNCTE N ON N.NUNOTA = C.NUNOTA
CROSS JOIN XMLTABLE(
    XMLNAMESPACES('http://www.portalfiscal.inf.br/cte' AS "ns"),
    '/ns:cteProc/ns:CTe/ns:infCte'
    PASSING XMLTYPE(N.XML)
    COLUMNS
        PRESTADOR_RAW  VARCHAR2(20)   PATH 'ns:emit/ns:CNPJ',
        OBSERVACAO     VARCHAR2(4000) PATH 'ns:compl/ns:xObs',
        UF_INI         VARCHAR2(2)    PATH 'ns:ide/ns:UFIni',
        UF_FIM         VARCHAR2(2)    PATH 'ns:ide/ns:UFFim',
        CFOP           VARCHAR2(4)    PATH 'ns:ide/ns:CFOP',
        TPSERV         VARCHAR2(2)    PATH 'ns:ide/ns:tpServ',
        -- Buscamos o primeiro filho de ICMS e então a tag desejada dentro dele
        CST            VARCHAR2(14)   PATH 'ns:imp/ns:ICMS/*[1]/ns:CST',
        PERC_ICMS      VARCHAR2(14)   PATH 'ns:imp/ns:ICMS/*[1]/ns:pICMS',
        PERC_RED       VARCHAR2(14)   PATH 'ns:imp/ns:ICMS/*[1]/ns:pRedBC',
        PERC_ICMS_RET  VARCHAR2(14)   PATH 'ns:imp/ns:ICMS/*[1]/ns:pICMSSTRet',
        PERC_OUTRA_UF  VARCHAR2(14)   PATH 'ns:imp/ns:ICMS/*[1]/ns:pICMSOutraUF'
) XT
JOIN TGFCFO O ON O.CODCFO = XT.CFOP
JOIN TSIEMP E ON REGEXP_REPLACE(XT.PRESTADOR_RAW, '[^0-9]', '') = REGEXP_REPLACE(E.CGC, '[^0-9]', '');