-- Continuação da revisão Master Deploy HIGIEPAM a partir da etapa 18.
-- As etapas 01 a 17 e a preparação de backups 18-30 já foram concluídas.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT ============================================================
PROMPT CONTINUACAO MASTER DEPLOY HIGIEPAM - ETAPAS 18 A 31
PROMPT ============================================================

-- Reutiliza o ID_MASTER persistido pela etapa 01 da retomada anterior.
VARIABLE RMD_ID_MASTER VARCHAR2(30)
BEGIN
  :RMD_ID_MASTER := 'RMD_RUN_20260921155603190';
  DBMS_OUTPUT.PUT_LINE('ID_MASTER_REUTILIZADO='||:RMD_ID_MASTER);
END;
/

PROMPT [18/31] INICIO - 18_Ajustar_Preferencias_GOL.sql
@@../../Revisao Master Deploy/18_Ajustar_Preferencias_GOL.sql
PROMPT [18/31] FIM - 18_Ajustar_Preferencias_GOL.sql

PROMPT [19/31] INICIO - 19_Ajustar_Parceiro_Matriz.sql
@@../../Revisao Master Deploy/19_Ajustar_Parceiro_Matriz.sql
PROMPT [19/31] FIM - 19_Ajustar_Parceiro_Matriz.sql

PROMPT [20/31] INICIO - 20_Atualizar_Cards_Deploy.sql
@@../../Revisao Master Deploy/20_Atualizar_Cards_Deploy.sql
PROMPT [20/31] FIM - 20_Atualizar_Cards_Deploy.sql

PROMPT [21/31] INICIO - 21_Classificar_ICMS_Parceiros.sql
@@../../Revisao Master Deploy/21_Classificar_ICMS_Parceiros.sql
PROMPT [21/31] FIM - 21_Classificar_ICMS_Parceiros.sql

PROMPT [22/31] INICIO - 22_Ajustar_Nomes_Parceiros.sql
@@../../Revisao Master Deploy/22_Ajustar_Nomes_Parceiros.sql
PROMPT [22/31] FIM - 22_Ajustar_Nomes_Parceiros.sql

PROMPT [23/31] INICIO - 23_Validar_Reabilitar_Objetos.sql
@@../../Revisao Master Deploy/23_Validar_Reabilitar_Objetos.sql
PROMPT [23/31] FIM - 23_Validar_Reabilitar_Objetos.sql

PROMPT [24/31] INICIO - 24_Padronizar_Parceiros.sql
@@../../Revisao Master Deploy/24_Padronizar_Parceiros.sql
PROMPT [24/31] FIM - 24_Padronizar_Parceiros.sql

PROMPT [25/31] INICIO - 25_Padronizar_Produtos.sql
@@../../Revisao Master Deploy/25_Padronizar_Produtos.sql
PROMPT [25/31] FIM - 25_Padronizar_Produtos.sql

PROMPT [26/31] INICIO - 26_Padronizar_Tipos_Titulo.sql
@@../../Revisao Master Deploy/26_Padronizar_Tipos_Titulo.sql
PROMPT [26/31] FIM - 26_Padronizar_Tipos_Titulo.sql

PROMPT [27/31] INICIO - 27_Padronizar_Cidades.sql
@@../../Revisao Master Deploy/27_Padronizar_Cidades.sql
PROMPT [27/31] FIM - 27_Padronizar_Cidades.sql

PROMPT [28/31] INICIO - 28_Padronizar_Tipos_Venda.sql
@@../../Revisao Master Deploy/28_Padronizar_Tipos_Venda.sql
PROMPT [28/31] FIM - 28_Padronizar_Tipos_Venda.sql

PROMPT [29/31] INICIO - 29_Padronizar_Bairros.sql
@@../../Revisao Master Deploy/29_Padronizar_Bairros.sql
PROMPT [29/31] FIM - 29_Padronizar_Bairros.sql

PROMPT [30/31] INICIO - 30_Padronizar_Enderecos.sql
@@../../Revisao Master Deploy/30_Padronizar_Enderecos.sql
PROMPT [30/31] FIM - 30_Padronizar_Enderecos.sql

PROMPT [31/31] INICIO - 31_Recompilar_Objetos_Invalidos.sql
@@../../Revisao Master Deploy/31_Recompilar_Objetos_Invalidos.sql
PROMPT [31/31] FIM - 31_Recompilar_Objetos_Invalidos.sql

PROMPT ============================================================
PROMPT CONTINUACAO MASTER DEPLOY HIGIEPAM - FIM ETAPAS 18 A 31
PROMPT ============================================================
