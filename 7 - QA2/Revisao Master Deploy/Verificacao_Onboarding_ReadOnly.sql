-- VERIFICACAO GENERICA DE ONBOARDING - SOMENTE LEITURA
--
-- Objetivo:
--   Fornecer o snapshot tecnico da base para confronto com os arquivos mais
--   recentes da pasta do cliente em "8. Onboarding Deploy".
--
-- Uso:
--   1. Executar conectado ao schema da base revisada.
--   2. Preservar a saida integral em log por cliente e data.
--   3. Confrontar os resultados com os arquivos do onboarding.
--   4. Registrar divergencias comprovadas, sem transformar linhas de modelo
--      ou registros adicionais da base em erro automatico.
--
-- Seguranca:
--   - Este roteiro nao contem DML, DDL, COMMIT ou senha.
--   - Credenciais SMTP nunca sao exibidas; somente metadados e presenca.
--   - Nao preencher tabelas temporarias nem alterar a base para comparar.

SET DEFINE OFF
SET ECHO ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 240
SET LONG 2000
SET PAGESIZE 1000
SET TAB OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT ======================================================================
PROMPT IDENTIDADE DA CONEXAO
PROMPT ======================================================================
SELECT USER AS USUARIO,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS SCHEMA_ATUAL,
       SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS SERVICO
  FROM DUAL;

PROMPT ======================================================================
PROMPT 01 - EMPRESAS: TSIEMP + CIDADE/UF
PROMPT ======================================================================
SELECT E.CODEMP,
       E.RAZAOSOCIAL,
       E.CGC,
       E.INSCESTAD,
       E.CODCID,
       C.NOMECID,
       C.UF
  FROM TSIEMP E
  LEFT JOIN TSICID C ON C.CODCID = E.CODCID
 ORDER BY E.CODEMP;

PROMPT ======================================================================
PROMPT 07 - SMTP GLOBAL: TSIPAR - METADADOS SEM CREDENCIAIS
PROMPT ======================================================================
SELECT CHAVE,
       REGEXP_SUBSTR(TEXTO, '[^;]+', 1, 1) AS SERVIDOR_PORTA,
       REGEXP_SUBSTR(TEXTO, '[^;]+', 1, 2) AS CRIPTOGRAFIA,
       REGEXP_SUBSTR(TEXTO, '[^;]+', 1, 3) AS REMETENTE,
       CASE
         WHEN TEXTO IS NULL THEN 'AUSENTE'
         WHEN REGEXP_COUNT(TEXTO, ';') >= 3 THEN 'CREDENCIAL_PRESENTE_NAO_EXIBIDA'
         ELSE 'FORMATO_INCOMPLETO'
       END AS CREDENCIAL
  FROM TSIPAR
 WHERE CHAVE = 'MSDSMTPPROP';

PROMPT ======================================================================
PROMPT SMTP POR EMPRESA: TSIEMP - METADADOS SEM CREDENCIAIS
PROMPT ======================================================================
SELECT CODEMP,
       SERVIDORSMTP,
       TIPOSMTP,
       PORTASMTP,
       SEGURANCASMTP,
       CASE WHEN USUARIOSMTP IS NULL THEN 'AUSENTE' ELSE 'PRESENTE' END AS USUARIO_SMTP,
       CASE WHEN SENHASMTP IS NULL THEN 'AUSENTE' ELSE 'PRESENTE_NAO_EXIBIDA' END AS SENHA_SMTP
  FROM TSIEMP
 ORDER BY CODEMP;

PROMPT ======================================================================
PROMPT 08 - CONTAS BANCARIAS: TSICTA
PROMPT ======================================================================
SELECT A.CODCTABCOINT,
       A.CODEMP,
       A.CODBCO,
       A.CODAGE,
       A.CODCTABCO,
       A.EMITEBOLETA,
       A.ATIVA
  FROM TSICTA A
 ORDER BY A.CODEMP, A.CODCTABCOINT;

PROMPT ======================================================================
PROMPT 08 - USUARIOS: TSIUSU - METADADOS SEM CREDENCIAIS SMTP
PROMPT ======================================================================
SELECT U.CODUSU,
       U.NOMEUSU,
       U.EMAIL,
       U.CODGRUPO,
       U.CODEMP,
       U.CODVEND
  FROM TSIUSU U
 ORDER BY LOWER(U.EMAIL), U.CODUSU;

PROMPT ======================================================================
PROMPT 08 - VENDEDORES/COMPRADORES: TGFVEN
PROMPT ======================================================================
SELECT V.CODVEND,
       V.APELIDO,
       V.EMAIL,
       V.CODEMP,
       V.ATIVO,
       V.ATUACOMPRADOR
  FROM TGFVEN V
 ORDER BY V.CODVEND;

PROMPT ======================================================================
PROMPT 08 - GRUPOS DE PRODUTO: TGFGRU
PROMPT ======================================================================
SELECT G.CODGRUPOPROD,
       G.DESCRGRUPOPROD,
       G.CODGRUPAI,
       G.ATIVO
  FROM TGFGRU G
 ORDER BY G.CODGRUPOPROD;

PROMPT ======================================================================
PROMPT 08 - CENTROS DE RESULTADO: TSICUS
PROMPT ======================================================================
SELECT C.CODCENCUS,
       C.DESCRCENCUS,
       C.CODCENCUSPAI,
       C.ATIVO,
       C.ANALITICO
  FROM TSICUS C
 ORDER BY C.CODCENCUS;

PROMPT ======================================================================
PROMPT 08 - NATUREZAS: TGFNAT
PROMPT ======================================================================
SELECT N.CODNAT,
       N.DESCRNAT,
       N.CODNATPAI,
       N.ATIVA,
       N.ANALITICA
  FROM TGFNAT N
 ORDER BY N.CODNAT;

PROMPT ======================================================================
PROMPT 08 - LOCAIS DE ESTOQUE: TGFLOC
PROMPT ======================================================================
SELECT L.CODLOCAL,
       L.DESCRLOCAL,
       L.CODLOCALPAI,
       L.ATIVO,
       L.ANALITICO
  FROM TGFLOC L
 ORDER BY L.CODLOCAL;

PROMPT ======================================================================
PROMPT FIM - SNAPSHOT READ-ONLY DE ONBOARDING
PROMPT ======================================================================
