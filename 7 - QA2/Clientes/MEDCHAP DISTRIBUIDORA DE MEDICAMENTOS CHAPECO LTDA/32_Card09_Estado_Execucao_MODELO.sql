-- Card 09 - inventario read-only do estado da execucao.
-- Execute antes do mapa, classificacao, insert ou pos-validacao.
-- Nao cria, altera ou remove objetos e evita consultas a tabelas inexistentes.

SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET TRIMSPOOL ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DEFINE ID_EXECUCAO = 'BASE_YYYYMMDD_FDUP_01'
DEFINE TBL_BASE = 'BKP_RMD_FDUP_BASE_YYYYMMDD'
DEFINE TBL_PPG = 'BKP_RMD_FDUP_BASE_YYYYMMDD_PPG'
DEFINE TBL_INS = 'BKP_RMD_FDUP_BASE_YYYYMMDD_INS'
DEFINE LOG_FILE = 'Logs/Card09_Estado_BASE_YYYYMMDD.log'

SPOOL "&LOG_FILE"
PROMPT === CARD 09 - ESTADO DA EXECUCAO READ-ONLY ===
PROMPT ID_EXECUCAO=&ID_EXECUCAO

DECLARE
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_base_exists BOOLEAN;
  v_ppg_exists BOOLEAN;
  v_ins_exists BOOLEAN;
  v_base_rows NUMBER := 0;
  v_ppg_rows NUMBER := 0;
  v_ins_rows NUMBER := 0;

  FUNCTION tabela_existe(p_nome VARCHAR2) RETURN BOOLEAN IS
    v_qtd NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_qtd
      FROM ALL_TABLES
     WHERE OWNER=v_owner
       AND TABLE_NAME=UPPER(TRIM(p_nome));
    RETURN v_qtd=1;
  END;

  FUNCTION qtd_id(p_nome VARCHAR2) RETURN NUMBER IS
    v_qtd NUMBER;
  BEGIN
    EXECUTE IMMEDIATE
      'SELECT COUNT(*) FROM '||DBMS_ASSERT.SIMPLE_SQL_NAME(UPPER(TRIM(p_nome)))||
      ' WHERE ID_EXECUCAO=:1'
      INTO v_qtd USING '&ID_EXECUCAO';
    RETURN v_qtd;
  END;
BEGIN
  v_base_exists := tabela_existe('&TBL_BASE');
  v_ppg_exists := tabela_existe('&TBL_PPG');
  v_ins_exists := tabela_existe('&TBL_INS');

  IF v_base_exists THEN v_base_rows := qtd_id('&TBL_BASE'); END IF;
  IF v_ppg_exists THEN v_ppg_rows := qtd_id('&TBL_PPG'); END IF;
  IF v_ins_exists THEN v_ins_rows := qtd_id('&TBL_INS'); END IF;

  DBMS_OUTPUT.PUT_LINE('TBL_BASE_EXISTE='||CASE WHEN v_base_exists THEN 'SIM' ELSE 'NAO' END);
  DBMS_OUTPUT.PUT_LINE('TBL_PPG_EXISTE='||CASE WHEN v_ppg_exists THEN 'SIM' ELSE 'NAO' END);
  DBMS_OUTPUT.PUT_LINE('TBL_INS_EXISTE='||CASE WHEN v_ins_exists THEN 'SIM' ELSE 'NAO' END);
  DBMS_OUTPUT.PUT_LINE('TBL_BASE_LINHAS_ID='||v_base_rows);
  DBMS_OUTPUT.PUT_LINE('TBL_PPG_LINHAS_ID='||v_ppg_rows);
  DBMS_OUTPUT.PUT_LINE('TBL_INS_LINHAS_ID='||v_ins_rows);

  IF NOT v_base_exists AND NOT v_ppg_exists AND NOT v_ins_exists THEN
    DBMS_OUTPUT.PUT_LINE('STATUS_ESTADO=NAO_INICIADO');
  ELSIF v_base_exists AND NOT v_ppg_exists THEN
    DBMS_OUTPUT.PUT_LINE('STATUS_ESTADO=BASE_CRIADA_CLASSIFICACAO_PENDENTE');
  ELSIF v_base_exists AND v_ppg_exists AND NOT v_ins_exists THEN
    DBMS_OUTPUT.PUT_LINE('STATUS_ESTADO=MAPA_COMPLETO_DML_PENDENTE');
  ELSIF v_ins_exists AND v_ins_rows=0 THEN
    DBMS_OUTPUT.PUT_LINE('STATUS_ESTADO=AUDITORIA_CRIADA_SEM_LINHAS');
  ELSIF v_ins_exists AND v_ins_rows>0 THEN
    DBMS_OUTPUT.PUT_LINE('STATUS_ESTADO=DML_AUDITADO_POS_VALIDACAO_PENDENTE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('STATUS_ESTADO=OBJETOS_EXISTEM_REVISAR_ESTADO');
  END IF;
END;
/

PROMPT Nenhuma alteracao foi realizada por este inventario.
SPOOL OFF
