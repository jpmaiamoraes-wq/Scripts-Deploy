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
 q_produtos.VOLUMES,
 q_config.ENDERECOS,
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
