-- Mantem o modelo aprovado da Analise de Giro 848, com backup pontual.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DECLARE v NUMBER;BEGIN
 SELECT COUNT(*) INTO v FROM ALL_TABLES WHERE OWNER=SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AND TABLE_NAME='BKP_RMD_13_TSIIMP';
 IF v=0 THEN EXECUTE IMMEDIATE q'[CREATE TABLE BKP_RMD_13_TSIIMP AS SELECT CAST(NULL AS VARCHAR2(30)) ID_EXECUCAO,
 CAST(NULL AS TIMESTAMP) DH_EXECUCAO,CAST(NULL AS VARCHAR2(128)) USUARIO_EXECUCAO,
 I.CODREL,I.LISTA1 LISTA1_ANTES FROM TSIIMP I WHERE 1=0]';END IF;
 SELECT COUNT(*) INTO v FROM TSIIMP WHERE CODREL=848;
 IF v<>1 THEN RAISE_APPLICATION_ERROR(-20340,'Esperada exatamente uma configuracao TSIIMP CODREL=848.');END IF;
END;
/
DECLARE v_id VARCHAR2(30):='RMD_G848_'||TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF3');v_b NUMBER;v_u NUMBER;BEGIN
 INSERT INTO BKP_RMD_13_TSIIMP SELECT v_id,SYSTIMESTAMP,SYS_CONTEXT('USERENV','SESSION_USER'),CODREL,LISTA1 FROM TSIIMP WHERE CODREL=848;
 v_b:=SQL%ROWCOUNT;
 UPDATE TSIIMP SET LISTA1='{"periodos":[["Jan 1, 2026 12:00:00 AM","Jan 8, 2026 12:00:00 AM"],["Dec 1, 2025 12:00:00 AM","Dec 31, 2025 12:00:00 AM"],["Nov 1, 2025 12:00:00 AM","Nov 30, 2025 12:00:00 AM"],["Oct 1, 2025 12:00:00 AM","Oct 31, 2025 12:00:00 AM"],["Sep 1, 2025 12:00:00 AM","Sep 30, 2025 12:00:00 AM"],["Aug 1, 2025 12:00:00 AM","Aug 31, 2025 12:00:00 AM"],["Jul 1, 2025 12:00:00 AM","Jul 31, 2025 12:00:00 AM"],["Jun 1, 2025 12:00:00 AM","Jun 30, 2025 12:00:00 AM"],["May 1, 2025 12:00:00 AM","May 31, 2025 12:00:00 AM"],["Apr 1, 2025 12:00:00 AM","Apr 30, 2025 12:00:00 AM"],["Mar 1, 2025 12:00:00 AM","Mar 31, 2025 12:00:00 AM"],["Feb 1, 2025 12:00:00 AM","Feb 28, 2025 12:00:00 AM"]],"codRel":848,"resourceID":"br.com.sankhya.com.rotinas.analisegiro","descricao":"An�lise Mensal com giro","qtdPeriodosDinamicos":12,"intervaloPeriodoDinamico":"MES","tipoPeriodo":"D","utilizarPeriodosFechados":"S","agrupaProdAltern":"N","incluirSemEstoque":"N","incluirSemGiro":"N","unidadeCompra":"N","apresentaEmpresa":"S","apresentaMatriz":"N","apresentaLocal":"N","apresentaControle":"N","desprezarPeriodoGiro":0,"detalhe":"P","custo":"CUSSEMICM","percAcrescimoSugestao":0,"diasEstocagem":30,"estMinIncluiVendaZero":"S","naoAtuSugestaoZero":"S","desconsiderarPeriodoRupturaGiroMedDiario":"N","filterParams":{},"desconsiderarPedidosCompraVenda":"N","temListaFiltros":"S","nomeUsu":"SUP","dtCriacao":"24/11/2022","listarPCVPend":"N"}'
 WHERE CODREL=848;
 v_u:=SQL%ROWCOUNT;
 IF v_b<>1 OR v_u<>1 THEN RAISE_APPLICATION_ERROR(-20341,'Backup ou atualizacao da Analise 848 divergente.');END IF;
 COMMIT;DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO='||v_id);DBMS_OUTPUT.PUT_LINE('ANALISE_GIRO_848_ATUALIZADA=1');
EXCEPTION WHEN OTHERS THEN ROLLBACK;RAISE;END;
/

