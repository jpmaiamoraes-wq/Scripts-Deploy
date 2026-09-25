-- Retomada isolada da atividade 15 da base JCLM.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
@@../../Revisao Master Deploy/15_Desativar_Rastro_Sem_Controle.sql
