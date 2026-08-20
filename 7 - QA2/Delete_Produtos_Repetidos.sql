CREATE TABLE TGFPRO_BKP AS SELECT * FROM TGFPRO;
CREATE TABLE TGFITE_BKP AS SELECT * FROM TGFITE;


DECLARE
  -- você pode usar isso depois se quiser logar algo
  v_erro VARCHAR2(4000);
BEGIN
  -- Desabilita triggers
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_UPD_TGFCUS DISABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INC_UPD_TGFITE_ATIVO DISABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE DISABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_TGFVOA DISABLE';

  BEGIN
    FOR i IN (
      SELECT CODPROD,
             DESCRPROD,
             AD_IDEXTERNO,
             CODVOL,
             (
               SELECT MIN(P4.CODPROD)
                 FROM TGFPRO P4
                WHERE P4.DESCRPROD = P.DESCRPROD
                  --AND P4.AD_IDEXTERNO = P.AD_IDEXTERNO
                  --AND P4.CODVOL      = P.CODVOL
                  --AND P4.USOPROD = 'S'
             ) AS MENOR
        FROM TGFPRO P
       WHERE EXISTS (
               SELECT 1
                 FROM TGFPRO P2
                WHERE P2.DESCRPROD = P.DESCRPROD
                  --AND P2.AD_IDEXTERNO = P.AD_IDEXTERNO
                  --AND P2.CODVOL      = P.CODVOL
                  --AND P2.USOPROD = 'S'
                GROUP BY P2.DESCRPROD
               HAVING COUNT(*) > 1
                  --AND COUNT(DISTINCT P2.AD_IDEXTERNO) = 1
                  --AND COUNT(DISTINCT P2.CODVOL)      = 1
             )
         AND CODPROD > (
               SELECT MIN(P3.CODPROD)
                 FROM TGFPRO P3
                WHERE P3.DESCRPROD = P.DESCRPROD
                  --AND P3.AD_IDEXTERNO = P.AD_IDEXTERNO
                  --AND P3.CODVOL      = P.CODVOL
                  --AND P3.USOPROD = 'S'
             )
          AND USOPROD = 'S'
    )
    LOOP
      -- Redireciona movimentos para o menor CODPROD
      UPDATE TGFITE
         SET CODPROD = i.MENOR
       WHERE CODPROD = i.CODPROD;

      -- Limpa cadastros relacionados ao CODPROD que será excluído
      DELETE FROM TGFCUS  WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFGIR1 WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFEXC  WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFEST  WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFPAP  WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFVOA  WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFBAR  WHERE CODPROD = i.CODPROD;
      DELETE FROM TGFPRO  WHERE CODPROD = i.CODPROD;
      -- sem COMMIT aqui: deixa tudo numa transação só
    END LOOP;

    COMMIT; -- só um commit no final, se tudo der certo
--  EXCEPTION
--    WHEN OTHERS THEN
--      v_erro := SQLERRM;
--      ROLLBACK; -- desfaz todos updates/deletes da transação

      -- Tenta reativar as triggers mesmo em caso de erro
      BEGIN
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_UPD_TGFCUS ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INC_UPD_TGFITE_ATIVO ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_TGFVOA ENABLE';
      EXCEPTION
        WHEN OTHERS THEN
          NULL; -- aqui não tem muito o que fazer, só evitar estourar outro erro
      END;

      -- Se quiser só logar o erro, pode usar DBMS_OUTPUT:
      DBMS_OUTPUT.PUT_LINE('Erro no processamento: ' || v_erro);

      -- Se quiser propagar o erro pra cima:
      -- RAISE;
  END;

  -- Se chegou aqui sem cair no EXCEPTION interno, reativa as triggers normalmente
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_UPD_TGFCUS ENABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INC_UPD_TGFITE_ATIVO ENABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE ENABLE';
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_DLT_TGFVOA ENABLE';
END;