SPOOL OFF
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/IMPORTUDO COMERCIO/Logs/Continuidade_12_31_T02.log"
PROMPT CONTINUIDADE IMPORTUDO COMERCIO - ETAPAS 10 A 31
SELECT SYS_CONTEXT('USERENV','SESSION_USER') USUARIO, SYS_CONTEXT('USERENV','CURRENT_SCHEMA') SCHEMA_ATUAL, SYS_CONTEXT('USERENV','SERVICE_NAME') SERVICO FROM DUAL;
ALTER SESSION SET CURRENT_SCHEMA=SANKHYA;
BEGIN
 IF UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'IMPORTUDOPRD.SANKHYACLOUD.COM.BR' OR SYS_CONTEXT('USERENV','SESSION_USER') <> 'FRANCISCO_JUNIOR' THEN
 RAISE_APPLICATION_ERROR(-20501,'Conexao divergente'); END IF;
END;
/
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
PROMPT [18-30] PREPARAR BACKUPS
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/18_Preparar_Backups_18_30.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/18_Ajustar_Preferencias_GOL.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/19_Ajustar_Parceiro_Matriz.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/20_Atualizar_Cards_Deploy.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/21_Classificar_ICMS_Parceiros.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/22_Ajustar_Nomes_Parceiros.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/23_Validar_Reabilitar_Objetos.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/24_Padronizar_Parceiros.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/25_Padronizar_Produtos.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/26_Padronizar_Tipos_Titulo.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/27_Padronizar_Cidades.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/28_Padronizar_Tipos_Venda.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/29_Padronizar_Bairros.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/30_Padronizar_Enderecos.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/31_Recompilar_Objetos_Invalidos.sql"
PROMPT CONTINUIDADE_10_31_CONCLUIDA
SPOOL OFF
