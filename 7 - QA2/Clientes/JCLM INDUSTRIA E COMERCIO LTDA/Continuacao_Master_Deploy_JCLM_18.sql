-- Retomada isolada das atividades 18 da base JCLM.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
@@../../Revisao Master Deploy/18_Preparar_Backups_18_30.sql
@@../../Revisao Master Deploy/18_Ajustar_Preferencias_GOL.sql
