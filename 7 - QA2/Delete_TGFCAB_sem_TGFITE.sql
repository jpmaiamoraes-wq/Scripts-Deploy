ALTER TRIGGER TRG_DLT_TGFFIN DISABLE;

DELETE TGFFIN
 WHERE NUNOTA IN (
                    SELECT CAB.NUNOTA
                      FROM TGFCAB CAB
                     WHERE CAB.TIPMOV <> 'Z' 
                       AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
                    ); COMMIT;
                    
ALTER TRIGGER TRG_DLT_TGFFIN ENABLE;

DELETE TGFCAB
 WHERE NUNOTA IN (
                    SELECT CAB.NUNOTA
                      FROM TGFCAB CAB
                     WHERE CAB.TIPMOV <> 'Z' 
                       AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
                    ); COMMIT;                  
                    
DELETE TGFNFE
 WHERE NUNOTA IN (
                    SELECT CAB.NUNOTA
                      FROM TGFCAB CAB
                     WHERE CAB.TIPMOV <> 'Z' 
                       AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
                    ); COMMIT;
                    
--DELETE TTKEVT
-- WHERE SEQUENCIA IN (
--                    SELECT NOTE.SEQUENCIA
--                      FROM TGFCAB CAB
--                      JOIN TTKNOT NOTE ON NOTE.NUNOTA = CAB.NUNOTA
--                     WHERE CAB.TIPMOV <> 'Z' 
--                       AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
--                    ); COMMIT;
                    
                    
UPDATE TTKEVT
   SET STATUS = 'E' -- Erro
 WHERE STATUS = 'F' -- Processado
   AND SEQUENCIA IN (
                    SELECT NOTE.SEQUENCIA
                      FROM TGFCAB CAB
                      JOIN TTKNOT NOTE ON NOTE.NUNOTA = CAB.NUNOTA
                     WHERE CAB.TIPMOV <> 'Z' 
                       AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
                       ); COMMIT;
                  
DELETE TTKNOT
 WHERE NUNOTA IN (
                    SELECT CAB.NUNOTA
                      FROM TGFCAB CAB
                     WHERE CAB.TIPMOV <> 'Z' 
                       AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
                    ); COMMIT;