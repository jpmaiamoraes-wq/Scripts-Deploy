-- Retomada das atividades 14 e 15 da base JCLM.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
@@../../Revisao Master Deploy/14_Configurar_Analise_Giro_848.sql
@@../../Revisao Master Deploy/15_Desativar_Rastro_Sem_Controle.sql
