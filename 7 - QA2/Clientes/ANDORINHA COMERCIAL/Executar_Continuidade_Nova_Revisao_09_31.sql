-- Retomada da nova revisao a partir da etapa 09.
-- Etapas 01-08 ja executadas e validadas; nao repetir.
-- Execute conectado a ANDORINHA COMERCIAL como SCRIPT (F5).
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/ANDORINHA COMERCIAL/Logs/Continuidade_Nova_Revisao_09_31.log"

PROMPT === RETOMADA NOVA REVISAO: ETAPAS 09 A 31 ===
SELECT SYS_CONTEXT('USERENV','SESSION_USER') USUARIO, SYS_CONTEXT('USERENV','CURRENT_SCHEMA') SCHEMA_ATUAL, SYS_CONTEXT('USERENV','SERVICE_NAME') SERVICO FROM DUAL;

VARIABLE RMD_ID_MASTER VARCHAR2(30)
BEGIN :RMD_ID_MASTER := 'RMD_RUN_20260908102607051'; END;
/

PROMPT [09/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/09_Liberar_Itens_Documentos_Legados.sql"
PROMPT [09/31] FIM
PROMPT [10/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/10_Habilitar_ICMS_Gerencial.sql"
PROMPT [10/31] FIM
PROMPT [11/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/11_Habilitar_Ruptura_Produtos.sql"
PROMPT [11/31] FIM
PROMPT [12/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/12_Habilitar_Ruptura_Empresas.sql"
PROMPT [12/31] FIM
PROMPT [13/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/13_Configurar_TOPs_Giro_GOL.sql"
PROMPT [13/31] FIM
PROMPT [14/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/14_Configurar_Analise_Giro_848.sql"
PROMPT [14/31] FIM
PROMPT [15/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/15_Desativar_Rastro_Sem_Controle.sql"
PROMPT [15/31] FIM
PROMPT [16/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/16_Aplicar_Higienizacao_TSICFG.sql"
PROMPT [16/31] FIM
PROMPT [17/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/17_Normalizar_Unidades.sql"
PROMPT [17/31] FIM
PROMPT [18/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/18_Ajustar_Preferencias_GOL.sql"
PROMPT [18/31] FIM
PROMPT [19/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/19_Ajustar_Parceiro_Matriz.sql"
PROMPT [19/31] FIM
PROMPT [20/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/20_Atualizar_Cards_Deploy.sql"
PROMPT [20/31] FIM
PROMPT [21/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/21_Classificar_ICMS_Parceiros.sql"
PROMPT [21/31] FIM
PROMPT [22/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/22_Ajustar_Nomes_Parceiros.sql"
PROMPT [22/31] FIM
PROMPT [23/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/23_Validar_Reabilitar_Objetos.sql"
PROMPT [23/31] FIM
PROMPT [24/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/24_Padronizar_Parceiros.sql"
PROMPT [24/31] FIM
PROMPT [25/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/25_Padronizar_Produtos.sql"
PROMPT [25/31] FIM
PROMPT [26/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/26_Padronizar_Tipos_Titulo.sql"
PROMPT [26/31] FIM
PROMPT [27/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/27_Padronizar_Cidades.sql"
PROMPT [27/31] FIM
PROMPT [28/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/28_Padronizar_Tipos_Venda.sql"
PROMPT [28/31] FIM
PROMPT [29/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/29_Padronizar_Bairros.sql"
PROMPT [29/31] FIM
PROMPT [30/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/30_Padronizar_Enderecos.sql"
PROMPT [30/31] FIM
PROMPT [31/31] INICIO
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/31_Recompilar_Objetos_Invalidos.sql"
PROMPT [31/31] FIM
PROMPT === RETOMADA NOVA REVISAO 09 A 31 CONCLUIDA ===
SPOOL OFF
