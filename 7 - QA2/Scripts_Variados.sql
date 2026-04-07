SET SERVEROUTPUT ON;

DECLARE
  v_rows PLS_INTEGER;
BEGIN
  -- 1) Alterando parâmetros para liberar filtro nos portais sem limite de datas.
  UPDATE TSIPAR 
     SET INTEIRO  = NULL
   WHERE (CHAVE   = 'MAXDIASPORTAIS'
      OR CHAVE    = 'MAXDIASPORTVEND'
      OR CHAVE    = 'MAXDIASPORTCOMP'
      OR CHAVE    = 'MAXDIASMOVFIN')
     AND INTEIRO  IS NOT NULL;
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('1) TSIPAR - linhas atualizadas: '||v_rows);
  COMMIT;
  
  -- 2) Ajustando dados fiscais das empresas para correta emissão de danfe.    
  UPDATE TGFEMP 
     SET CODMODDANFESIMPLIFNFE    = (SELECT CODMODDANFESIMPLIFNFE FROM TGFEMP WHERE CODEMP = 1),
         CONTINGENCIANFE          = (SELECT CONTINGENCIANFE       FROM TGFEMP WHERE CODEMP = 1),
         ENVIOSINCRONONFE         = (SELECT ENVIOSINCRONONFE      FROM TGFEMP WHERE CODEMP = 1),
         --LOGODANFE                = (SELECT LOGODANFE             FROM TGFEMP WHERE CODEMP = 1),
         NURFE                    = (SELECT NURFE                 FROM TGFEMP WHERE CODEMP = 1),
         NURFECARTACORR           = (SELECT NURFECARTACORR        FROM TGFEMP WHERE CODEMP = 1),
         TIPODANFE                = (SELECT TIPODANFE             FROM TGFEMP WHERE CODEMP = 1),
         NFE                      = (SELECT NFE                   FROM TGFEMP WHERE CODEMP = 1),
         VERSAONFE                = (SELECT VERSAONFE             FROM TGFEMP WHERE CODEMP = 1),
         VERSAONT                 = (SELECT VERSAONT              FROM TGFEMP WHERE CODEMP = 1),
         UTILIZAMDE               = (SELECT UTILIZAMDE            FROM TGFEMP WHERE CODEMP = 1)
   WHERE TGFEMP.CODEMP <> 1;
   
  -- 2.1) Copinado endereço da logo caso as demais empresas estejam nulas   
  UPDATE TGFEMP 
     SET LOGODANFE                = (SELECT LOGODANFE             FROM TGFEMP WHERE CODEMP = 1)         
   WHERE TGFEMP.CODEMP <> 1
     AND LOGODANFE IS NULL ;
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('2) TGFEMP (danfe) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 3) Tirando as tops de devolução de venda para calcular custos.
  UPDATE TGFTOP
     SET PRECIFICA    = 'N'
   WHERE PRECIFICA    <> 'N'
     AND TIPMOV       = 'D';
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('3) TGFTOP Dev. Vendas c/ custo - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 4) Marcando produtos para calcular o giro.
  UPDATE TGFPRO
     SET CALCULOGIRO  = 'G'
   WHERE CALCULOGIRO  <> 'G'
     AND USOPROD IN ('V', 'R');
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('4) TGFPRO (CALCULOGIRO) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 5) Marcando tipos de negociação com nro de parcelas 0.
  UPDATE TGFTPV
     SET NROPARCELAS = 0
   WHERE NROPARCELAS <> 0;
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('5) TGFTPV - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 6) Igualando Data de Movimento = Data de Negociação.
  UPDATE TGFCAB
     SET DTMOV    = DTNEG
   WHERE DTMOV    IS NULL
     AND TIPMOV   <> 'Z';
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('6) TGFCAB (DTMOV=DTNEG) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 7.1) Preenchendo NUMPROTOC para imprimir Danfes do legado.
    UPDATE TGFCAB c
       SET c.NUMPROTOC = 0
     WHERE c.NUMPROTOC IS NULL
       AND EXISTS (SELECT 1 FROM TTKNOT n WHERE n.NUNOTA = c.NUNOTA)
       AND EXISTS (
             SELECT 1
               FROM TGFTOP t
              WHERE t.CODTIPOPER = c.CODTIPOPER
                AND t.DHALTER    = c.DHTIPOPER
                AND t.CODMODDOC  = 55
           );

  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('7.1) TGFCAB (NUMPROTOC=0) - linhas atualizadas: '||v_rows);
  COMMIT;


  -- 7.2) Preenchendo NUMPROTOCCTE para imprimir CTes do legado.    
    UPDATE TGFCAB c
       SET c.NUMPROTOCCTE = 0
     WHERE c.NUMPROTOCCTE IS NULL
       AND EXISTS (SELECT 1 FROM TTKNOT n WHERE n.NUNOTA = c.NUNOTA)
       AND EXISTS (
             SELECT 1
               FROM TGFTOP t
              WHERE t.CODTIPOPER = c.CODTIPOPER
                AND t.DHALTER    = c.DHTIPOPER
                AND t.CODMODDOC  = 57
           );
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('7.2) TGFCAB (NUMPROTOCCTE=0) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 8) Corrigir giro dos produtos TGFUVC (via TGFITE).
 -- DBMS_OUTPUT.PUT_LINE('8) Desabilitando trigger TRG_UPT_TGFITE...');
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE DISABLE';

  UPDATE TGFITE I
     SET I.STATUSNOTA     = 'L'
   WHERE I.STATUSNOTA     <> 'L'
     AND EXISTS (SELECT 1 FROM TTKNOT WHERE NUNOTA = I.NUNOTA);
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('8) TGFITE (STATUSNOTA=L) - linhas atualizadas: '||v_rows);

  --DBMS_OUTPUT.PUT_LINE('8) Reabilitando trigger TRG_UPT_TGFITE...');
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE ENABLE';
  COMMIT;

  -- 9) Corrigir cadastro de produtos para calcular GV.
  UPDATE TGFPRO
     SET ICMSGERENCIA = 'S'
   WHERE ICMSGERENCIA = 'N'
     AND USOPROD      IN ('V', 'R');
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('9) TGFPRO (ICMSGERENCIA=S) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 10) Habilitar cálculo de ruptura de estoque nos produtos.
  UPDATE TGFPRO
     SET CALRUPTURAESTOQUE            = 'S'
   WHERE NVL(CALRUPTURAESTOQUE, 'N')  <> 'S'
     AND USOPROD                      IN ('V', 'R');
  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('10) TGFPRO (CALRUPTURAESTOQUE=S) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 11) Habilitar ruptura de estoque nas empresas.
  UPDATE TGFEMP
     SET RUPTURAEST           = 'S'
   WHERE NVL(RUPTURAEST,'N')  <> 'S'
     AND EXISTS (SELECT 1 
                   FROM AD_SEGMENTACAOEMPRESAS S
                   JOIN TSIEMP E ON E.CGC = S.CGC
                  WHERE S.SEGMENTACAO <> 'S');
                  
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('11) TGFEMP (RUPTURAEST=S) - linhas atualizadas: '||v_rows);
  COMMIT;
                  
  -- 12) REVISÃO DAS TOPS PARA GIRO E GOL (* REGRA ATUAL NAO ESTA COMPLETA, AINDA NAO MAPEADO TOPS DE VENDA ENTREGA FUTURA, ENTRE OUTRAS *)
    UPDATE TGFTOP TOP
       SET TOP.GOLSINAL         = (CASE WHEN TOP.ATUALEST = 'B' AND TOP.TIPMOV = 'V' AND TOP.ATUALFIN =  1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN -1
                                        WHEN TOP.ATUALEST = 'E' AND TOP.TIPMOV = 'D' AND TOP.ATUALFIN = -1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN -1
                                        WHEN TOP.ATUALEST = 'E' AND TOP.TIPMOV = 'C' AND TOP.ATUALFIN = -1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN  1 
                                        WHEN TOP.ATUALEST = 'B' AND TOP.TIPMOV = 'E' AND TOP.ATUALFIN =  1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN  1 
                                        ELSE 0 END),
           TOP.GOLMPSINAL       = (CASE WHEN TOP.ATUALEST = 'B' AND TOP.TIPMOV = 'V' AND TOP.ATUALFIN =  1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN -1
                                        WHEN TOP.ATUALEST = 'E' AND TOP.TIPMOV = 'D' AND TOP.ATUALFIN = -1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN -1
                                        WHEN TOP.ATUALEST = 'E' AND TOP.TIPMOV = 'C' AND TOP.ATUALFIN = -1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN  1 
                                        WHEN TOP.ATUALEST = 'B' AND TOP.TIPMOV = 'E' AND TOP.ATUALFIN =  1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN  1 
                                        ELSE 0 END),
           TOP.GOLDEV           = (CASE WHEN TOP.TIPMOV IN ('D', 'E') AND TOP.ATUALEST IN ('E', 'B') AND TOP.CODMODDOC IN (55, 59, 65) AND (TOP.ATUALFIN <> 0 OR TOP.TIPATUALFIN <> 'P') THEN -1 
                                        ELSE 1 END),
           TOP.ANALISEGIRO      = (CASE WHEN TOP.TIPMOV = 'V' AND TOP.ATUALEST = 'B' AND TOP.ATUALFIN =  1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN -1 
                                        WHEN TOP.TIPMOV = 'D' AND TOP.ATUALEST = 'E' AND TOP.ATUALFIN = -1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN  1 
                                        ELSE 0 END),
           TOP.ATUALULTIMAVEND  = (CASE WHEN TOP.TIPMOV = 'V' AND TOP.ATUALEST = 'B' AND TOP.ATUALFIN =  1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN 'G' 
                                        ELSE 'N' END),
           TOP.ATUALULTIMACOMP  = (CASE WHEN TOP.TIPMOV = 'C' AND TOP.ATUALEST = 'E' AND TOP.ATUALFIN = -1 AND TOP.TIPATUALFIN = 'I' AND TOP.CODMODDOC IN (55, 59, 65) THEN 'E' 
                                        ELSE 'N' END);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('12) TGFTOP (TOPS P/ GIRO E GOL) - linhas atualizadas: '||v_rows);
  COMMIT;

  -- 13) AJUSTE DA ANALISE DE GIRO 848 *)
    UPDATE TSIIMP 
       SET LISTA1 = '{"periodos":[["Jan 1, 2026 12:00:00 AM","Jan 8, 2026 12:00:00 AM"],["Dec 1, 2025 12:00:00 AM","Dec 31, 2025 12:00:00 AM"],["Nov 1, 2025 12:00:00 AM","Nov 30, 2025 12:00:00 AM"],["Oct 1, 2025 12:00:00 AM","Oct 31, 2025 12:00:00 AM"],["Sep 1, 2025 12:00:00 AM","Sep 30, 2025 12:00:00 AM"],["Aug 1, 2025 12:00:00 AM","Aug 31, 2025 12:00:00 AM"],["Jul 1, 2025 12:00:00 AM","Jul 31, 2025 12:00:00 AM"],["Jun 1, 2025 12:00:00 AM","Jun 30, 2025 12:00:00 AM"],["May 1, 2025 12:00:00 AM","May 31, 2025 12:00:00 AM"],["Apr 1, 2025 12:00:00 AM","Apr 30, 2025 12:00:00 AM"],["Mar 1, 2025 12:00:00 AM","Mar 31, 2025 12:00:00 AM"],["Feb 1, 2025 12:00:00 AM","Feb 28, 2025 12:00:00 AM"]],"codRel":848,"resourceID":"br.com.sankhya.com.rotinas.analisegiro","descricao":"An�lise Mensal com giro","qtdPeriodosDinamicos":12,"intervaloPeriodoDinamico":"MES","tipoPeriodo":"D","utilizarPeriodosFechados":"S","agrupaProdAltern":"N","incluirSemEstoque":"N","incluirSemGiro":"N","unidadeCompra":"N","apresentaEmpresa":"S","apresentaMatriz":"N","apresentaLocal":"N","apresentaControle":"N","desprezarPeriodoGiro":0,"detalhe":"P","custo":"CUSSEMICM","percAcrescimoSugestao":0,"diasEstocagem":30,"estMinIncluiVendaZero":"S","naoAtuSugestaoZero":"S","desconsiderarPeriodoRupturaGiroMedDiario":"N","filterParams":{},"desconsiderarPedidosCompraVenda":"N","temListaFiltros":"S","nomeUsu":"SUP","dtCriacao":"24/11/2022","listarPCVPend":"N"}'
     WHERE TSIIMP.CODREL = 848; 
 
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('13) TSIIMP (AJUSTE DA ANALISE DE GIRO 848) - linhas atualizadas: '||v_rows);
  COMMIT;
   
  
  -- 14) TIRANDO RASTREAMENTO DE ESTOQUE PARA ITENS SEM CONTROLE ADICIONAL *)
    UPDATE TGFPRO
       SET TEMRASTROLOTE    = 'N'
     WHERE TEMRASTROLOTE    = 'S'
       AND TIPCONTEST       = 'N'; 
 
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('14) TGFPRO (ITENS C/ RASTREAMENTO DE ESTOQUE DESATIVADO) - linhas atualizadas: '||v_rows);
  COMMIT;  
END;
/