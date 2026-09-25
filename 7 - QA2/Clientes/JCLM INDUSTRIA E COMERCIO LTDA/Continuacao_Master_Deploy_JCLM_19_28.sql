-- Retomada isolada das atividades 19 a 28 da base JCLM.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
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
