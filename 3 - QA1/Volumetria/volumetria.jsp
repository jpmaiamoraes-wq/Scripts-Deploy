<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="UTF-8" isELIgnored ="false"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib prefix="snk" uri="/WEB-INF/tld/sankhyaUtil.tld" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html lang="pt-BR">
<head>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Volumetria - Deploy Agent</title>
    <link rel="stylesheet" type="text/css" href="${BASE_FOLDER}/styles.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <snk:load/> <!-- essa tag deve ficar nesta posição -->

    <!-- abrir nivel Financeiro -->
    <script type='text/javascript'>
        function abrirID_1(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a1mpu50', params);
           }
    </script>

    <!-- abrir nivel Entradas e Saidas -->
    <script type='text/javascript'>
        function abrirID_2(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a1mpvbi', params);
           }
    </script>

    <!-- abrir nivel Produtos por USOPROD -->
    <script type='text/javascript'>
        function abrirID_3(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a1rx0c0', params);
           }
    </script>

    <!-- abrir nivel Produtos por Grupo de Produto -->
    <script type='text/javascript'>
        function abrirID_4(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a2qo6ix', params);
           }
    </script>

    <!-- abrir nivel Referencias Duplicadas -->
    <script type='text/javascript'>
        function abrirID_5(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a2qo6my', params);
           }
    </script>

    <!-- abrir nivel Descricoes Duplicadas -->
    <script type='text/javascript'>
        function abrirID_6(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a2qo6dr', params);
           }
    </script>

    <!-- abrir nivel CNPJ/CPF Repetidos -->
    <script type='text/javascript'>
        function abrirID_7(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n31h', params);
           }
    </script>

    <!-- abrir nivel Financeiros sem Nota -->
    <script type='text/javascript'>
        function abrirID_8(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n33r', params);
           }
    </script>

    <!-- abrir nivel Notas sem Financeiro -->
    <script type='text/javascript'>
        function abrirID_9(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n34r', params);
           }
    </script>

    <!-- abrir nivel Produtos vendidos sem entrada -->
    <script type='text/javascript'>
        function abrirID_10(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n4cr', params);
           }
    </script>

    <!-- abrir nivel Produtos com custo zero -->
    <script type='text/javascript'>
        function abrirID_11(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n4ek', params);
           }
    </script>

    <!-- abrir nivel Produtos sem Custo -->
    <script type='text/javascript'>
        function abrirID_12(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a2qo6g1', params);
           }
    </script>

    <!-- abrir nivel Itens sem cabeçalho de nota -->
    <script type='text/javascript'>
        function abrirID_13(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n4ix', params);
           }
    </script>

    <!-- abrir nivel Cabecalhos sem Itens -->
    <script type='text/javascript'>
        function abrirID_14(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n4jm', params);
           }
    </script>

    <!-- abrir nivel Cidades Duplicadas -->
    <script type='text/javascript'>
        function abrirID_15(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n4kc', params);
           }
    </script>

    <!-- abrir nivel Parceiros com divergencias classif. ICMS -->
    <script type='text/javascript'>
        function abrirID_16(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_a20n4s4', params);
           }
    </script>

    <!-- abrir nivel Itens sem tabela de preço -->
    <script type='text/javascript'>
        function abrirID_17(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_zc6jly', params);
           }
    </script>    

    <!-- abrir nivel Itens c/ similaridade de descricoes -->
    <script type='text/javascript'>
        function abrirID_18(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_af9lkrx', params);
           }
    </script>    

    <!-- abrir nivel CNPJ Matrizes -->
    <script type='text/javascript'>
        function abrirID_19(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_5lj0cl', params);
           }
    </script>

    <!-- abrir nivel Produtos comprados sem saida -->
    <script type='text/javascript'>
        function abrirID_20(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_aselmol', params);
           }
    </script> 

    <!-- abrir nivel Regras tributárias -->
    <script type='text/javascript'>
        function abrirID_21(codUSU){
            var params = {'A_CODUSU' : codUSU};
            openLevel('lvl_03U', params);
           }
    </script> 

</head>
<body>
     
    <snk:query var="contadores">          
        WITH PROD_HASH AS (
          SELECT CODPROD,
                 DESCRPROD,
                 CODGRUPOPROD,
                 REFERENCIA,
                 ORIGPROD,
                 USOPROD,
                 AD_IDEXTERNO,
                 NCM,
                 CODPARCFORN,
                 ORA_HASH(UPPER(REGEXP_REPLACE(DESCRPROD, '[^A-Z0-9 ]', '')), 999999) AS HASH_DESCR,
                 UPPER(REGEXP_REPLACE(DESCRPROD, '[^A-Z0-9 ]', '')) AS DESCRNORM
          FROM TGFPRO
        )
        SELECT 1 AS ID, 'Financeiro' AS TIPO,
               'Registros de títulos financeiros' AS TIPO2,
               TO_CHAR((SELECT COUNT(*) FROM TGFFIN F), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 2 AS ID, 'Entradas e Saídas' AS TIPO,
               'Registros por tipo de movimento' AS TIPO2,
               TO_CHAR((SELECT COUNT(*) FROM TGFCAB C), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 3 AS ID, 'Produtos por USOPROD' AS TIPO,
               'Classificação por uso do produto' AS TIPO2,
               TO_CHAR((SELECT COUNT(*) FROM PROD_HASH PRO WHERE PRO.CODPROD <> 0), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 4 AS ID, 'Produtos por Grupo' AS TIPO,
               'Agrupamento de produtos' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT PRO.CODGRUPOPROD) FROM PROD_HASH PRO WHERE PRO.CODPROD <> 0), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 5 AS ID, 'Referências Duplicadas' AS TIPO,
               'Produtos com referências repetidas' AS TIPO2,
               TO_CHAR((SELECT COUNT(*) FROM (
                  SELECT P.REFERENCIA
                  FROM PROD_HASH P
                  WHERE P.REFERENCIA IS NOT NULL
                  GROUP BY P.REFERENCIA
                  HAVING COUNT(*) > 1
                )), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 6 AS ID, 'Descrições Duplicadas' AS TIPO,
               'Produtos com descrições repetidas (mesmo NCM e Origem)' AS TIPO2,
               TO_CHAR((SELECT NVL(SUM(CONTADOR),0) FROM (
                  SELECT NCM, DESCRPROD, ORIGPROD, COUNT(1) AS CONTADOR
                  FROM PROD_HASH
                  GROUP BY NCM, DESCRPROD, ORIGPROD
                  HAVING COUNT(*) > 1
                )), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 7 AS ID, 'CNPJ/CPF Repetidos' AS TIPO,
               'Parceiros com documentos duplicados' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT p1.CGC_CPF)
                FROM TGFPAR p1
                JOIN TGFPAR p2 ON p1.CGC_CPF = p2.CGC_CPF AND p1.CODPARC <> p2.CODPARC
                WHERE p1.CGC_CPF IS NOT NULL), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 8 AS ID, 'Financeiros Sem Nota' AS TIPO,
               'Registros financeiros vinculados a notas que não existem' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT f.NUNOTA)
                FROM TGFFIN f
                WHERE NOT EXISTS (SELECT 1 FROM TGFCAB c WHERE c.NUNOTA = f.NUNOTA)), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 9 AS ID, 'Notas Sem Financeiro' AS TIPO,
               'Notas sem registros financeiros vinculados' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT C.NUNOTA)
                FROM TGFCAB C
                INNER JOIN TGFTOP T ON (C.CODTIPOPER = T.CODTIPOPER AND C.DHTIPOPER = T.DHALTER)
                WHERE T.ATUALFIN <> 0
                  AND C.TIPMOV <> 'Z'
                  AND NOT EXISTS (SELECT 1 FROM TGFFIN F WHERE F.NUNOTA = C.NUNOTA)), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 10 AS ID, 'Produtos Vendidos' AS TIPO,
               'Vendidos sem registro de entrada' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT IV.CODPROD)
                FROM TGFITE IV
                JOIN TGFCAB CV ON CV.NUNOTA = IV.NUNOTA AND CV.TIPMOV = 'V'
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM TGFITE IC
                    JOIN TGFCAB CC ON CC.NUNOTA = IC.NUNOTA AND CC.TIPMOV = 'C'
                    WHERE IC.CODPROD = IV.CODPROD
                )), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 11 AS ID, 'Produtos Com Custo Zero' AS TIPO,
        'Produtos onde todos os registros de custo são zero' AS TIPO2,
        TO_CHAR((
           SELECT COUNT(*) FROM (
               SELECT C.CODPROD
               FROM TGFCUS C
               JOIN TGFPRO P ON P.CODPROD = C.CODPROD
               WHERE P.USOPROD IN ('V', 'R')
                 AND C.DTATUAL <> TO_DATE('01/01/1900', 'DD/MM/YYYY')
               GROUP BY C.CODPROD, C.CODEMP
               HAVING MAX(C.CUSSEMICM) = 0
           )
        ), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 12 AS ID, 'Produtos Sem Custo' AS TIPO,
               'Produtos sem registro na tabela de custos' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT P.CODPROD)
                FROM PROD_HASH P
                LEFT JOIN TGFCUS C ON C.CODPROD = P.CODPROD
                WHERE C.CODPROD IS NULL
                  AND P.USOPROD IN ('V', 'R')
                  AND P.CODPROD <> 0), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 13 AS ID, 'Itens Sem Cabeçalho' AS TIPO,
               'Itens sem cabeçalho de nota' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT i.NUNOTA)
                FROM TGFITE i
                WHERE NOT EXISTS (SELECT 1 FROM TGFCAB c WHERE c.NUNOTA = i.NUNOTA)), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 14 AS ID, 'Cabeçalho Sem Itens' AS TIPO,
               'Cabeçalhos de nota sem itens' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT c.NUNOTA)
                FROM TGFCAB c
                WHERE NOT EXISTS (SELECT 1 FROM TGFITE i WHERE i.NUNOTA = c.NUNOTA)
                  AND c.TIPMOV <> 'Z'), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 15 AS ID, 'Cidades Duplicadas' AS TIPO,
               'Código fiscal com múltiplos registros' AS TIPO2,
               TO_CHAR((SELECT NVL(SUM(CONTADOR),0)
                FROM (SELECT CODMUNFIS, COUNT(1) AS CONTADOR
                      FROM TSICID
                      WHERE CODMUNFIS IS NOT NULL
                      GROUP BY CODMUNFIS
                      HAVING COUNT(*) > 1)), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 16 AS ID, 'Classificação Fiscal' AS TIPO,
               'Parceiros com classificação divergente' AS TIPO2,
               TO_CHAR((SELECT COUNT(*)
                FROM TGFPAR P
                WHERE (CASE
                    WHEN (P.TIPPESSOA = 'J' AND P.IDENTINSCESTAD IS NOT NULL AND UPPER(P.IDENTINSCESTAD) <> 'ISENTO')
                         THEN 'R'
                    WHEN (P.TIPPESSOA = 'F' AND P.IDENTINSCESTAD IS NOT NULL AND UPPER(P.IDENTINSCESTAD) <> 'ISENTO')
                         THEN 'P'
                    WHEN (NVL(P.IDENTINSCESTAD, 'ISENTO') = 'ISENTO')
                         THEN 'C'
                END) <> P.CLASSIFICMS
                AND (CASE
                    WHEN (P.TIPPESSOA = 'J' AND P.IDENTINSCESTAD IS NOT NULL AND UPPER(P.IDENTINSCESTAD) <> 'ISENTO')
                         THEN 'R'
                    WHEN (P.TIPPESSOA = 'F' AND P.IDENTINSCESTAD IS NOT NULL AND UPPER(P.IDENTINSCESTAD) <> 'ISENTO')
                         THEN 'P'
                    WHEN (NVL(P.IDENTINSCESTAD, 'ISENTO') = 'ISENTO')
                         THEN 'C'
                END) IS NOT NULL), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 17 AS ID, 'Itens Sem Tabela de Preço' AS TIPO,
               'Produtos vendidos que não possuem tabela de preço' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT ITE.CODPROD)
                          FROM TGFITE ITE
                          INNER JOIN TGFCAB CAB ON ITE.NUNOTA = CAB.NUNOTA
                         WHERE CAB.TIPMOV = 'V'
                           AND NOT EXISTS (SELECT 1
                                             FROM TGFEXC
                                            WHERE CODPROD = ITE.CODPROD)), 'FM999G999G990') AS RESULTADO
        FROM DUAL
        UNION ALL
        SELECT 18 AS ID, 'Itens Com Descrições Similares' AS TIPO,
               'Produtos que possuem descrições similares' AS TIPO2,
                TO_CHAR((SELECT COUNT(1)
                           FROM PROD_HASH A
                           JOIN PROD_HASH B ON A.HASH_DESCR = B.HASH_DESCR AND A.CODPROD < B.CODPROD
                          WHERE UTL_MATCH.JARO_WINKLER_SIMILARITY(A.DESCRNORM, B.DESCRNORM) > 85), 'FM999G999G990') AS RESULTADO
          FROM DUAL
        UNION ALL
        SELECT 19 AS ID, 'CNPJ Matrizes' AS TIPO,
               'CNPJ de parceiros que possuem filiais cadastradas' AS TIPO2,
               TO_CHAR((SELECT COUNT(1)
                          FROM TGFPAR p
                         WHERE SUBSTR(p.CGC_CPF,9,4) = '0001' -- somente matrizes
                           AND LENGTH(p.CGC_CPF) = 14
                           AND SUBSTR(p.CGC_CPF,1,8) <> '00000000'
                           AND EXISTS (
                               SELECT 1
                                 FROM TGFPAR f
                                WHERE SUBSTR(f.CGC_CPF,1,8) = SUBSTR(p.CGC_CPF,1,8)
                                  AND SUBSTR(f.CGC_CPF,9,4) <> '0001'
                                  AND LENGTH(f.CGC_CPF) = 14))) AS RESULTADO
          FROM DUAL
        UNION ALL
                SELECT 20 AS ID, 'Produtos Comprados' AS TIPO,
               'Comprados sem registro de venda' AS TIPO2,
               TO_CHAR((SELECT COUNT(DISTINCT IV.CODPROD)
                FROM TGFITE IV
                JOIN TGFCAB CV ON CV.NUNOTA = IV.NUNOTA AND CV.TIPMOV = 'C'
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM TGFITE IC
                    JOIN TGFCAB CC ON CC.NUNOTA = IC.NUNOTA AND CC.TIPMOV = 'V'
                    WHERE IC.CODPROD = IV.CODPROD
                )), 'FM999G999G990') AS RESULTADO
          FROM DUAL
        UNION ALL 
        SELECT 21 AS ID, 'Regras tributárias inseridas' AS TIPO,
                          'Impostos mapeados' AS TIPO2,
        TO_CHAR(
         (SELECT COUNT(1) FROM TGFICM WHERE TIPRESTRICAO NOT IN ('S', 'X', 'N')) +
        
         (SELECT COUNT(DISTINCT ISS.CODPROD) 
            FROM TGFISS ISS
            INNER JOIN TGFITE ITE ON ITE.CODPROD = ISS.CODPROD
            INNER JOIN TGFCAB CAB ON ITE.NUNOTA = CAB.NUNOTA
            WHERE CAB.CODTIPOPER = 1106) +
        
            (SELECT COUNT(1) FROM (
                SELECT DISTINCT IMA.CODIGO, IMA.CODIMP 
                FROM TGFIMA IMA
                INNER JOIN TGFITE ITE ON ITE.CODPROD = IMA.CODIGO
                INNER JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA
                WHERE CAB.CODTIPOPER = 1106
            )), 
        'FM999G999G990') AS RESULTADO
        FROM DUAL
        ORDER BY ID
    </snk:query>

    <div class="container">
        <header class="dashboard-header">
            <h1><i class="fas fa-rocket"></i> Volumetria Deploy Agent</h1>
            <div class="header-controls">
                <a href="https://www.sankhya.com.br" target="_blank">
                    <img src="${BASE_FOLDER}img/logo_sankhya.svg" height="36" width="167"></img>
                </a>
            </div>
        </header>

        <main class="dashboard">
            <div class="card-grid">

                <c:forEach items="${contadores.rows}" var="row">
                    <div class="card" data-category="primary" onclick="javascript:abrirID_${row.ID}( ${CODUSU_LOG} )">
                        <div class="card-content">
                            <h3><c:out value="${row.TIPO}" /></h3>
                            <p><c:out value="${row.TIPO2}" /></p>
                        </div>
                        <div class="counter" data-count="1,247">
                            <span class="count-number"><c:out value="${row.RESULTADO}" /></span>
                            <span class="count-label">registros</span>
                        </div>
                    </div>
                </c:forEach>

            </div>
        </main>

    </div>

</body>
</html>