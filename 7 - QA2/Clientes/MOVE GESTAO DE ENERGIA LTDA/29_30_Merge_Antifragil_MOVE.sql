-- Fase de mapa, backup dos pais obsoletos e redirecionamento das referencias.
-- O executor valida base, usuario e schema antes da confirmacao nativa.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED

BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR'
     OR SYS_CONTEXT('USERENV','CURRENT_SCHEMA') <> 'SANKHYA'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MOVEENERGIAPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20390,'Identidade MOVE divergente; lote bloqueado.');
  END IF;
  DBMS_SESSION.SET_IDENTIFIER('MOVE_MERGE');
  DBMS_OUTPUT.PUT_LINE('CLIENT_IDENTIFIER=MOVE_MERGE');
END;
/

@../../Revisao Master Deploy/29_30_Merge_Antifragil.sql
