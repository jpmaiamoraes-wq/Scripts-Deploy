-- Atividade 35 - Contas de e-mail (SMTP) - MEDCHAP (MEDCHAPPRD). Condicional.
-- Regra (orientacao do responsavel pela revisao, 25/09/2026):
--   * conta principal: parametro TSIPAR MSDSMTPPROP (prioridade empresa 1); demais contas do cliente: TSISMTP;
--   * conta interna de testes do Deploy Agent (servidor email-smtp.us-east-1.amazonaws.com / remetente noreply@sankhya.com.br)
--     deve ser removida onde estiver.
-- Diagnostico desta base (somente leitura, sem expor segredos):
--   * MSDSMTPPROP ja contem a conta do cliente informada no onboarding (smtp.office365.com:587, envio@medchap.com.br): nada a alterar;
--   * TSISMTP contem somente CODSMTP=1, a conta de testes do Deploy Agent, sem referencias nas 6 tabelas com FK: remover;
--   * o onboarding informa uma unica conta (a principal): nenhuma conta adicional a cadastrar na TSISMTP.
-- Esta atividade nunca le, digita ou grava senhas: inclusao de contas do cliente com senha fica para o consultor na tela do Sankhya.
-- ID_EXECUCAO=MEDCHAP_SMTP_20260925_01; backup=BKP_RMD_MDCH_SMTP01 (linha removida, integral, dentro da propria base).
-- Reversao: Artefatos_Revisao/Rollback/Reverter_35_SMTP_Contas_MEDCHAP.sql
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_n NUMBER; v_ref NUMBER := 0;
  TYPE t_list IS TABLE OF VARCHAR2(30);
  v_fk t_list := t_list('TGFEMP','TPQPLA','TMDMSG','TSIARF','TSIMEM','TMDFMG');
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR'
     OR SYS_CONTEXT('USERENV','CURRENT_SCHEMA') <> 'SANKHYA'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MEDCHAPPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20490,'Identidade MEDCHAPPRD divergente; atividade 35 bloqueada.');
  END IF;
  SELECT COUNT(*) INTO v_n FROM ALL_TABLES WHERE OWNER=SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AND TABLE_NAME='BKP_RMD_MDCH_SMTP01';
  IF v_n > 0 THEN RAISE_APPLICATION_ERROR(-20491,'Backup da atividade 35 ja existe; gere novo ID.'); END IF;
  SELECT COUNT(*) INTO v_n FROM TSISMTP
   WHERE CODSMTP=1 AND LOWER(TRIM(SERVIDOR))='email-smtp.us-east-1.amazonaws.com' AND LOWER(TRIM(REMETENTE))='noreply@sankhya.com.br';
  IF v_n <> 1 THEN RAISE_APPLICATION_ERROR(-20492,'Conta de testes CODSMTP=1 nao encontrada no estado diagnosticado.'); END IF;
  FOR i IN 1..v_fk.COUNT LOOP
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_fk(i))||' WHERE CODSMTP=1' INTO v_n;
    IF v_n > 0 THEN DBMS_OUTPUT.PUT_LINE('REFERENCIA|'||v_fk(i)||'|'||v_n); END IF;
    v_ref := v_ref + v_n;
  END LOOP;
  IF v_ref <> 0 THEN RAISE_APPLICATION_ERROR(-20493,'Conta de testes possui '||v_ref||' referencias; remocao bloqueada para analise.'); END IF;
  SELECT COUNT(*) INTO v_n FROM TSIPAR
   WHERE CHAVE='MSDSMTPPROP' AND (INSTR(LOWER(TEXTO),'email-smtp.us-east-1.amazonaws.com')>0 OR INSTR(LOWER(TEXTO),'noreply@sankhya.com.br')>0);
  IF v_n <> 0 THEN RAISE_APPLICATION_ERROR(-20494,'MSDSMTPPROP contem a conta de testes: estado diverge do diagnostico; revisar antes.'); END IF;
  DBMS_OUTPUT.PUT_LINE('IDENTIDADE_VALIDADA=FRANCISCO_JUNIOR/SANKHYA/MEDCHAPPRD; CONTA_TESTE_TSISMTP=1; REFERENCIAS=0; MSDSMTPPROP=CONTA_CLIENTE');
END;
/

CREATE TABLE BKP_RMD_MDCH_SMTP01 AS
SELECT 'MEDCHAP_SMTP_20260925_01' ID_EXECUCAO_RMD, SYSDATE DT_BACKUP_RMD, S.*
  FROM TSISMTP S
 WHERE S.CODSMTP=1 AND LOWER(TRIM(S.SERVIDOR))='email-smtp.us-east-1.amazonaws.com' AND LOWER(TRIM(S.REMETENTE))='noreply@sankhya.com.br'
/

DECLARE
  v_bkp NUMBER; v_del NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM BKP_RMD_MDCH_SMTP01 WHERE ID_EXECUCAO_RMD=:1 AND CODSMTP=1' INTO v_bkp USING 'MEDCHAP_SMTP_20260925_01';
  IF v_bkp <> 1 THEN RAISE_APPLICATION_ERROR(-20495,'Backup da conta de testes divergente ('||v_bkp||'); nada removido.'); END IF;
  DELETE FROM TSISMTP
   WHERE CODSMTP=1 AND LOWER(TRIM(SERVIDOR))='email-smtp.us-east-1.amazonaws.com' AND LOWER(TRIM(REMETENTE))='noreply@sankhya.com.br';
  v_del := SQL%ROWCOUNT;
  IF v_del <> 1 THEN RAISE_APPLICATION_ERROR(-20496,'Remocao afetaria '||v_del||' registros (esperado 1); lote revertido.'); END IF;
  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO=MEDCHAP_SMTP_20260925_01; CONTA_TESTE_REMOVIDA=1; BACKUP=1');
  DBMS_OUTPUT.PUT_LINE('STATUS=SMTP_CONTA_TESTE_REMOVIDA');
END;
/
