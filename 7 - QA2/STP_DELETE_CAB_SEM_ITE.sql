CREATE OR REPLACE PROCEDURE STP_DELETE_CAB_SEM_ITE AS
    v_step VARCHAR2(100);
    v_count_tgffin  NUMBER := 0;
    v_count_tgfcab  NUMBER := 0;
    v_count_tgfnfe  NUMBER := 0;
    v_count_ttkevt  NUMBER := 0;
    v_count_ttknot  NUMBER := 0;
BEGIN

    BEGIN
        v_step := 'Desabilitar trigger';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_TGFFIN DISABLE';

        v_step := 'Delete TGFFIN';
        DELETE TGFFIN
         WHERE NUNOTA IN (
            SELECT CAB.NUNOTA
              FROM TGFCAB CAB
             WHERE CAB.TIPMOV <> 'Z' 
               AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
        );
        v_count_tgffin := SQL%ROWCOUNT;

        v_step := 'Reabilitar trigger';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_TGFFIN ENABLE';

        v_step := 'Delete TGFNFE';
        DELETE TGFNFE
         WHERE NUNOTA IN (
            SELECT CAB.NUNOTA
              FROM TGFCAB CAB
             WHERE CAB.TIPMOV <> 'Z' 
               AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
        );
        v_count_tgfnfe := SQL%ROWCOUNT;

    
        v_step := 'Delete TTKEVT';
        DELETE TTKEVT
         WHERE SEQUENCIA IN (
                SELECT NOTE.SEQUENCIA
                  FROM TGFCAB CAB
                  JOIN TTKNOT NOTE ON NOTE.NUNOTA = CAB.NUNOTA
                 WHERE CAB.TIPMOV <> 'Z' 
                   AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
        );
        v_count_ttkevt := SQL%ROWCOUNT;
      

        v_step := 'Delete TTKNOT';
        DELETE TTKNOT
         WHERE NUNOTA IN (
            SELECT CAB.NUNOTA
              FROM TGFCAB CAB
             WHERE CAB.TIPMOV <> 'Z' 
               AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
        );
        v_count_ttknot := SQL%ROWCOUNT;
        
        v_step := 'Delete TGFCAB';
        DELETE TGFCAB
         WHERE NUNOTA IN (
            SELECT CAB.NUNOTA
              FROM TGFCAB CAB
             WHERE CAB.TIPMOV <> 'Z' 
               AND NOT EXISTS (SELECT 1 FROM TGFITE WHERE NUNOTA = CAB.NUNOTA)
        );
        v_count_tgfcab := SQL%ROWCOUNT;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Processo concluído com sucesso!');
        DBMS_OUTPUT.PUT_LINE('TGFFIN deletados: ' || v_count_tgffin);
        DBMS_OUTPUT.PUT_LINE('TGFCAB deletados: ' || v_count_tgfcab);
        DBMS_OUTPUT.PUT_LINE('TGFNFE deletados: ' || v_count_tgfnfe);    
        DBMS_OUTPUT.PUT_LINE('TTKEVT deletados: ' || v_count_ttkevt);
        DBMS_OUTPUT.PUT_LINE('TGFNOT deletados: ' || v_count_ttknot);

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Erro na etapa: ' || v_step || ' - ' || SQLERRM);
            RAISE;
    END;
END;