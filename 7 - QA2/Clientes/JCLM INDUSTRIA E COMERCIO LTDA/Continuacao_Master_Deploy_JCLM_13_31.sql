-- Retomada das atividades 13 a 31 da base JCLM.
-- Atividades 01 a 12 ja possuem log, backup/auditoria e pos-validacao proprios.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
VARIABLE RMD_ID_MASTER VARCHAR2(30)
BEGIN
  :RMD_ID_MASTER := 'RMD_RUN_20260919211829041';
  DBMS_OUTPUT.PUT_LINE('ID_MASTER_PRESERVADO='||:RMD_ID_MASTER);
END;
/
@@../../Revisao Master Deploy/13_Configurar_TOPs_Giro_GOL.sql
@@../../Revisao Master Deploy/14_Configurar_Analise_Giro_848.sql
@@../../Revisao Master Deploy/15_Desativar_Rastro_Sem_Controle.sql
@@../../Revisao Master Deploy/16_Aplicar_Higienizacao_TSICFG.sql
@@../../Revisao Master Deploy/17_Normalizar_Unidades.sql
@@../../Revisao Master Deploy/18_Preparar_Backups_18_30.sql
@@../../Revisao Master Deploy/18_Ajustar_Preferencias_GOL.sql
@@../../Revisao Master Deploy/19_Ajustar_Parceiro_Matriz.sql
@@../../Revisao Master Deploy/20_Atualizar_Cards_Deploy.sql
@@../../Revisao Master Deploy/21_Classificar_ICMS_Parceiros.sql
@@../../Revisao Master Deploy/22_Ajustar_Nomes_Parceiros.sql
@@../../Revisao Master Deploy/23_Validar_Reabilitar_Objetos.sql
@@../../Revisao Master Deploy/24_Padronizar_Parceiros.sql
@@../../Revisao Master Deploy/25_Padronizar_Produtos.sql
@@../../Revisao Master Deploy/26_Padronizar_Tipos_Titulo.sql
@@../../Revisao Master Deploy/27_Padronizar_Cidades.sql
@@../../Revisao Master Deploy/28_Padronizar_Tipos_Venda.sql
@@../../Revisao Master Deploy/29_Padronizar_Bairros.sql
@@../../Revisao Master Deploy/30_Padronizar_Enderecos.sql
@@../../Revisao Master Deploy/31_Recompilar_Objetos_Invalidos.sql
