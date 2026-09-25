-- Continuidade da revisao Andorinha: etapas 18 a 28.
-- Etapas 01 a 17 ja concluidas. Etapas 29 a 31 permanecem fora deste lote.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
SET PAGESIZE 200
SET LINESIZE 240
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/ANDORINHA COMERCIAL/Logs/Etapas_18_28_Estrito.log"

PROMPT === IDENTIDADE DA CONEXAO ===
SELECT SYS_CONTEXT('USERENV','SESSION_USER') USUARIO,
       SYS_CONTEXT('USERENV','CURRENT_SCHEMA') SCHEMA_ATUAL,
       SYS_CONTEXT('USERENV','SERVICE_NAME') SERVICO
FROM DUAL;

PROMPT === PREPARAR BACKUPS 18 A 28 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/18_Preparar_Backups_18_30.sql"

PROMPT === ETAPA 18 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/18_Ajustar_Preferencias_GOL.sql"

PROMPT === ETAPA 19 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/19_Ajustar_Parceiro_Matriz.sql"

PROMPT === ETAPA 20 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/20_Atualizar_Cards_Deploy.sql"

PROMPT === ETAPA 21 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/21_Classificar_ICMS_Parceiros.sql"

PROMPT === ETAPA 22 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/22_Ajustar_Nomes_Parceiros.sql"

PROMPT === ETAPA 23 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/23_Validar_Reabilitar_Objetos.sql"

PROMPT === ETAPA 24 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/24_Padronizar_Parceiros.sql"

PROMPT === ETAPA 25 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/25_Padronizar_Produtos.sql"

PROMPT === ETAPA 26 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/26_Padronizar_Tipos_Titulo.sql"

PROMPT === ETAPA 27 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/27_Padronizar_Cidades.sql"

PROMPT === ETAPA 28 ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/28_Padronizar_Tipos_Venda.sql"

PROMPT === VALIDACAO POS-LOTE 18 A 28 ===
SELECT '18_TGFCGM_DESTINOS_DIVERGENTES' ITEM,COUNT(*) QTD
FROM TGFCGM D
WHERE D.CODEMP<>1
  AND EXISTS (SELECT 1 FROM TGFCGM O WHERE O.CODEMP=1 AND O.ANO=1900 AND O.MES=1)
  AND (NVL(D.PERCCFFAB,-1)<>NVL((SELECT O.PERCCFFAB FROM TGFCGM O WHERE O.CODEMP=1 AND O.ANO=1900 AND O.MES=1),-1)
    OR NVL(D.PERCCOFINS,-1)<>NVL((SELECT O.PERCCOFINS FROM TGFCGM O WHERE O.CODEMP=1 AND O.ANO=1900 AND O.MES=1),-1))
UNION ALL
SELECT '19_CODPARCMATRIZ_DIVERGENTES',COUNT(*)
FROM TGFPAR P
WHERE (P.TIPPESSOA='F' OR (P.TIPPESSOA='J' AND P.CGC_CPF IS NOT NULL))
  AND DECODE(P.CODPARCMATRIZ,
    CASE WHEN P.TIPPESSOA='F' THEN P.CODPARC ELSE (
      SELECT MIN(M.CODPARC) KEEP
               (DENSE_RANK FIRST ORDER BY SUBSTR(LPAD(M.CGC_CPF,14,'0'),9,4),M.CODPARC)
      FROM TGFPAR M
      WHERE M.TIPPESSOA='J' AND M.CGC_CPF IS NOT NULL
        AND SUBSTR(LPAD(M.CGC_CPF,14,'0'),1,8)=SUBSTR(LPAD(P.CGC_CPF,14,'0'),1,8)
    ) END,1,0)=0
UNION ALL
SELECT '21_ICMS_DIVERGENTES',COUNT(*) FROM TGFPAR
 WHERE (TIPPESSOA='J' AND IDENTINSCESTAD IS NOT NULL AND UPPER(TRIM(IDENTINSCESTAD))<>'ISENTO' AND NVL(CLASSIFICMS,'Z')<>'R')
    OR (TIPPESSOA='F' AND IDENTINSCESTAD IS NOT NULL AND UPPER(TRIM(IDENTINSCESTAD))<>'ISENTO' AND NVL(CLASSIFICMS,'Z')<>'P')
    OR (NVL(UPPER(TRIM(IDENTINSCESTAD)),'ISENTO')='ISENTO' AND NVL(CLASSIFICMS,'Z')<>'C')
UNION ALL
SELECT '23_OBJETOS_PENDENTES',COUNT(*) FROM RMD_CONTROLE_OBJETOS
 WHERE STATUS_ANTES='ENABLED' AND NVL(STATUS_DEPOIS,'PENDENTE')<>'ENABLED';

PROMPT === LOTE 18 A 28 FINALIZADO ===
SPOOL OFF
