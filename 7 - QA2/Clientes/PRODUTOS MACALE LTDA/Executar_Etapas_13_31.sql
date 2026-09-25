-- Continuidade autorizada da revisao: etapas 13 a 31; etapa 12 permanece pendente.
SET DEFINE ON
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/PRODUTOS MACALE LTDA/Logs/Continuacao_13_31_20260909.log"

ACCEPT P_CONFIRMA CHAR PROMPT 'Digite EXECUTAR PRODUTOS MACALE LTDA para continuar as etapas 13 a 31: '
BEGIN
  IF UPPER(TRIM('&&P_CONFIRMA')) <> 'EXECUTAR PRODUTOS MACALE LTDA' THEN
    RAISE_APPLICATION_ERROR(-20500,'Execucao cancelada: confirmacao da base divergente.');
  END IF;
  IF UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> 'MACALEPRD.SANKHYACLOUD.COM.BR' THEN
    RAISE_APPLICATION_ERROR(-20501,'Execucao cancelada: SERVICE_NAME diferente do esperado.');
  END IF;
END;
/
UNDEFINE P_CONFIRMA

PROMPT === CONTINUACAO: ETAPAS 13 A 31; ETAPA 12 PENDENTE ===
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/13_Configurar_TOPs_Giro_GOL.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/14_Configurar_Analise_Giro_848.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/15_Desativar_Rastro_Sem_Controle.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/16_Aplicar_Higienizacao_TSICFG.sql"
@@"/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Revisao Master Deploy/17_Normalizar_Unidades.sql"
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
SPOOL OFF
