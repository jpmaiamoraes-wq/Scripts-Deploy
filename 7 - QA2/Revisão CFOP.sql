SELECT 'CFOP errada nas Vendas' as TIPO, COUNT(1) AS QTD
FROM TGFITE ITE
JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA AND 
                   CAB.TIPMOV = 'V'
WHERE ITE.CODCFO < 5000

UNION ALL 

SELECT 'CFOP errada nas Compras' as TIPO, COUNT(1) AS QTD
FROM TGFITE ITE
JOIN TGFCAB CAB ON CAB.NUNOTA = ITE.NUNOTA AND 
                   CAB.TIPMOV = 'C'
WHERE ITE.CODCFO > 5000;


UPDATE TGFITE ITE
   SET ITE.CODCFO = CASE ITE.CODCFO
                       WHEN 5101 THEN 1102
                       WHEN 5102 THEN 1102
                       WHEN 5405 THEN 1403
                       WHEN 5656 THEN 1653
                       WHEN 6101 THEN 2102
                       WHEN 6102 THEN 2102
                       WHEN 6129 THEN 2102
                       WHEN 6403 THEN 2403
                       WHEN 6910 THEN 2910
                       WHEN 6911 THEN 2911
                       WHEN 6949 THEN 2949
                       ELSE ITE.CODCFO
                    END
 WHERE EXISTS (SELECT 1
                 FROM TGFCAB CAB
                WHERE CAB.NUNOTA = ITE.NUNOTA
                  AND CAB.TIPMOV = 'C')
   AND ITE.CODCFO IN (5101,5102,5405,5656,6101,6102,6129,6403,6910,6911,6949);