-- Atualiza a unica linha de indicadores do Deploy Agent com backup auditavel.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DECLARE v NUMBER;BEGIN
 SELECT COUNT(*) INTO v FROM ALL_TABLES WHERE OWNER=SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AND TABLE_NAME='BKP_RMD_CARD_TTKINDAGT';
 IF v=0 THEN EXECUTE IMMEDIATE q'[CREATE TABLE BKP_RMD_CARD_TTKINDAGT AS SELECT
 CAST(NULL AS VARCHAR2(30)) ID_EXECUCAO,CAST(NULL AS TIMESTAMP) DH_EXECUCAO,
 CAST(NULL AS VARCHAR2(128)) USUARIO_EXECUCAO,T.* FROM TTKINDAGT T WHERE 1=0]';END IF;
 SELECT COUNT(*) INTO v FROM TTKINDAGT WHERE SEQUENCIA=1;
 IF v<>1 THEN RAISE_APPLICATION_ERROR(-20310,'Esperada exatamente uma linha TTKINDAGT SEQUENCIA=1.');END IF;
 FOR R IN (SELECT 'TTKNOT' N FROM DUAL UNION ALL SELECT 'TTKEVT' FROM DUAL) LOOP
  SELECT COUNT(*) INTO v FROM ALL_TABLES WHERE OWNER=SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AND TABLE_NAME=R.N;
  IF v=0 THEN RAISE_APPLICATION_ERROR(-20311,'Tabela obrigatoria ausente: '||R.N);END IF;
 END LOOP;
END;
/
DECLARE
  v NUMBER;
  v_id VARCHAR2(30):='RMD_CARD_'||TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF3');
BEGIN
 INSERT INTO BKP_RMD_CARD_TTKINDAGT SELECT v_id,SYSTIMESTAMP,
   SYS_CONTEXT('USERENV','SESSION_USER'),T.* FROM TTKINDAGT T WHERE SEQUENCIA=1;
UPDATE TTKINDAGT T
SET (
     T.QTDARQUIVOS,
    T.QTDERRO,
    T.QTDSUCESSO,
    T.QTDARQUIVOSNFE,
    T.QTDERRONFE,
    T.QTDSUCESSONFE,
    T.QTDBASICONFE,
    T.EMPRESAS,
    T.TIPOSOPERACAO,
    T.PARCEIROS,
    T.PRODUTOS,
    T.ENDERECOS,
    T.VOLUMES,
    T.NOTASDEVOLUCAOCOMPRAS,
    T.NOTASCOMPRAS,
    T.NOTASDEVOLUCAOVENDAS,
    T.NOTASVENDAS,
    T.FINANCEIROSPAGAR,
    T.FINANCEIROSRECEBER
) = (
SELECT
 q_eventos.TOTAL as TOTAL,
 (q_eventos.ERRO + q_eventos.duplicada + q_eventos.cancelada) AS ERROS_TOTAL, 
 q_eventos.processado AS PROCESSANDO,
 q_eventos.totalNfe AS TOTAL_NFE,
 (q_eventos.erronfe + q_eventos.duplicada + q_eventos.cancelada) AS ERRO_NFE,
 q_eventos.processado AS FINALIZADO,
 (q_eventos.processado + q_eventos.erronfe + q_eventos.processando + q_eventos.duplicada + q_eventos.cancelada) AS BASICOS,
 q_config.EMPRESAS AS EMPRESAS,
 q_config.TIPOSDEOPERACAO,
 q_config.PARCEIROS,
 q_produtos.PRODUTOS,
 q_config.ENDERECOS,
 q_produtos.VOLUMES,
 q_notas.notasDevolucaoCompras,
 q_notas.notasDeCompras,
 q_notas.notasDevolucaoVendas,
 q_notas.notasDeVendas,
 q_financeiro.financeirosAPagar,
 q_financeiro.financeirosAReceber
FROM
  (
    SELECT
      COUNT(CASE WHEN CAB.TIPMOV = 'C' THEN 1 END) AS notasDeCompras,
      COUNT(CASE WHEN CAB.TIPMOV = 'E' THEN 1 END) AS notasDevolucaoCompras,
      COUNT(CASE WHEN CAB.TIPMOV = 'V' THEN 1 END) AS notasDeVendas,
      COUNT(CASE WHEN CAB.TIPMOV = 'D' THEN 1 END) AS notasDevolucaoVendas
    FROM TGFCAB CAB
    INNER JOIN TTKNOT ON TTKNOT.NUNOTA = CAB.NUNOTA
  ) q_notas,
  (
    SELECT
      COUNT(CASE WHEN FIN.RECDESP = -1 THEN 1 END) AS financeirosAPagar,
      COUNT(CASE WHEN FIN.RECDESP = 1 THEN 1 END) AS financeirosAReceber
    FROM TGFFIN FIN
    INNER JOIN TTKNOT ON TTKNOT.NUNOTA = FIN.NUNOTA
  ) q_financeiro,
  (
    SELECT
      COUNT(DISTINCT P.CODPROD) AS produtos,
      COUNT(DISTINCT V.CODVOL) AS volumes
    FROM TGFPRO P
    INNER JOIN TGFVOL V ON P.CODVOL = V.CODVOL
  ) q_produtos,
  (
    SELECT
      (SELECT COUNT(1) FROM TSIEMP) AS empresas,
      (SELECT COUNT(1) FROM TGFPAR WHERE DTALTER >= sysdate-2) AS parceiros,
      (SELECT COUNT(1) FROM TSIEND WHERE DTALTER >= sysdate-2) AS enderecos,
      (SELECT COUNT(DISTINCT CODTIPOPER) FROM TGFTOP WHERE ATIVO = 'S' AND CODTIPOPER <> 0) AS tiposDeOperacao,
      (SELECT COUNT(1) FROM TGFTPV WHERE DHALTER >= sysdate-2) AS tiposDeNegociacao
    FROM DUAL
  ) q_config,
  (
    SELECT
      COUNT(*) AS total,
      count(CASE WHEN tipo <> 'OUTROS' THEN 1 END) AS totalNfe,
      count(CASE WHEN tipo <> 'OUTROS' and status = 'E'  THEN 1 END) AS erronfe,
      COUNT(CASE WHEN status = 'F' THEN 1 END) AS processado,
      COUNT(CASE WHEN status = 'N' THEN 1 END) AS processandoNota,
      COUNT(CASE WHEN status = 'X' THEN 1 END) AS processando,
      COUNT(CASE WHEN status = 'E' THEN 1 END) AS erro,
      COUNT(CASE WHEN status = 'D' THEN 1 END) AS duplicada,
      COUNT(CASE WHEN status = 'C' THEN 1 END) AS cancelada,
      COUNT(CASE WHEN status IS NULL THEN 1 END) AS pendente
    FROM TTKEVT EVT
  ) q_eventos
  ) WHERE T.SEQUENCIA = 1;

 v:=SQL%ROWCOUNT;
 IF v<>1 THEN RAISE_APPLICATION_ERROR(-20312,'Atualizacao dos cards nao alterou exatamente uma linha.');END IF;
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO='||v_id);
 DBMS_OUTPUT.PUT_LINE('CARDS_ATUALIZADOS='||v);
END;
/
