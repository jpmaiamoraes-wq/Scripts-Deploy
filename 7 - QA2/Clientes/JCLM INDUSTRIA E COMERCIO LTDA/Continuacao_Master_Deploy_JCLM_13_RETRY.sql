-- Retomada aprovada da atividade 13 apos a correcao reutilizavel do script.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
@@../../Revisao Master Deploy/13_Configurar_TOPs_Giro_GOL.sql
