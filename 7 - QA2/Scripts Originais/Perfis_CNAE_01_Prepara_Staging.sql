-- ATENCAO: este arquivo contem DDL. Nao executar durante o piloto somente leitura.
-- Cria estruturas genericas para carga, auditoria e reversao.

SET SERVEROUTPUT ON SIZE UNLIMITED;
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK;

DECLARE
  FUNCTION tabela_existe(p_tabela VARCHAR2) RETURN BOOLEAN IS
    v_qtd NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_qtd
      FROM ALL_TABLES
     WHERE OWNER = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
       AND TABLE_NAME = UPPER(p_tabela);
    RETURN v_qtd > 0;
  END;
BEGIN
  IF NOT tabela_existe('STG_PPC_PERFIL') THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE STG_PPC_PERFIL (
        ID_CARGA          VARCHAR2(30)  NOT NULL,
        CODTIPPARC        NUMBER        NOT NULL,
        DESCRTIPPARC      VARCHAR2(60)  NOT NULL,
        CODTIPPARCPAI     NUMBER        NOT NULL,
        GRAU              NUMBER,
        ANALITICO         VARCHAR2(1)   NOT NULL,
        ATIVO             VARCHAR2(1)   NOT NULL,
        SEGATUA           CHAR(1)       NOT NULL,
        STATUS_VALIDACAO  VARCHAR2(20)  NOT NULL,
        OBSERVACAO        VARCHAR2(1000),
        DH_CARGA          DATE DEFAULT SYSDATE NOT NULL
      )]';
  END IF;

  IF NOT tabela_existe('STG_PPC_PARCEIRO') THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE STG_PPC_PARCEIRO (
        ID_CARGA             VARCHAR2(30)   NOT NULL,
        CODPARC              NUMBER         NOT NULL,
        CNPJ                 VARCHAR2(14)   NOT NULL,
        CNAE_PRINCIPAL       VARCHAR2(7)    NOT NULL,
        DESCR_CNAE_PRINCIPAL VARCHAR2(300),
        CNAES_SECUNDARIOS    VARCHAR2(4000),
        CODTIPPARC_SUGERIDO  NUMBER         NOT NULL,
        CONFIANCA            VARCHAR2(10)   NOT NULL,
        STATUS_VALIDACAO     VARCHAR2(20)   NOT NULL,
        SITUACAO_CADASTRAL   VARCHAR2(30),
        FONTE                VARCHAR2(100)  NOT NULL,
        DH_CONSULTA          DATE           NOT NULL,
        OBSERVACAO           VARCHAR2(1000),
        DH_CARGA             DATE DEFAULT SYSDATE NOT NULL
      )]';
  END IF;

  IF NOT tabela_existe('BKP_PPC_TGFPAR') THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE BKP_PPC_TGFPAR AS
      SELECT CAST(NULL AS VARCHAR2(30)) AS ID_EXECUCAO,
             CAST(NULL AS VARCHAR2(30)) AS ID_CARGA,
             CAST(NULL AS DATE) AS DH_EXECUCAO,
             CAST(NULL AS VARCHAR2(128)) AS USUARIO_EXECUCAO,
             P.CODPARC,
             P.CODTIPPARC AS CODTIPPARC_ANTES,
             CAST(NULL AS NUMBER) AS CODTIPPARC_DEPOIS
        FROM TGFPAR P
       WHERE 1 = 0]';
  END IF;

  IF NOT tabela_existe('BKP_PPC_TGFTPP') THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE BKP_PPC_TGFTPP (
        ID_EXECUCAO     VARCHAR2(30)  NOT NULL,
        ID_CARGA        VARCHAR2(30)  NOT NULL,
        DH_EXECUCAO     DATE          NOT NULL,
        USUARIO_EXECUCAO VARCHAR2(128) NOT NULL,
        CODTIPPARC      NUMBER        NOT NULL,
        DESCRTIPPARC    VARCHAR2(60)  NOT NULL,
        CODTIPPARCPAI   NUMBER        NOT NULL,
        GRAU            NUMBER,
        ANALITICO       VARCHAR2(1)   NOT NULL,
        ATIVO           VARCHAR2(1)   NOT NULL,
        SEGATUA         CHAR(1)       NOT NULL
      )]';
  END IF;

  DBMS_OUTPUT.PUT_LINE('Estruturas verificadas/criadas com sucesso.');
END;
/

