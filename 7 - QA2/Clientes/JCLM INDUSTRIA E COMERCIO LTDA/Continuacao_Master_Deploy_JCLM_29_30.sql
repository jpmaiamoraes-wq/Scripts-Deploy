-- Retomada isolada das atividades 29 e 30 da base JCLM.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
@@../../Revisao Master Deploy/29_Padronizar_Bairros.sql
@@../../Revisao Master Deploy/30_Padronizar_Enderecos.sql
