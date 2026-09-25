-- Continuação da revisão Master Deploy HIGIEPAM após a etapa 02 interrompida.
-- A etapa 01 já foi concluída e não é repetida neste lote.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
SET SQLBLANKLINES ON
SET ECHO ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

PROMPT ============================================================
PROMPT CONTINUACAO MASTER DEPLOY HIGIEPAM - ETAPAS 02 A 31
PROMPT ============================================================

-- Reutiliza o ID_MASTER persistido pela etapa 01 da retomada anterior.
-- A etapa 01 não é repetida e este valor foi confirmado em consulta read-only.
VARIABLE RMD_ID_MASTER VARCHAR2(30)
BEGIN
  :RMD_ID_MASTER := 'RMD_RUN_20260921155603190';
  DBMS_OUTPUT.PUT_LINE('ID_MASTER_REUTILIZADO='||:RMD_ID_MASTER);
END;
/

PROMPT [02/31] INICIO - 02_Liberar_Filtros_Portais.sql
@@../../Revisao Master Deploy/02_Liberar_Filtros_Portais.sql
PROMPT [02/31] FIM - 02_Liberar_Filtros_Portais.sql

PROMPT [03/31] INICIO - 03_Padronizar_DANFE_Empresas.sql
@@../../Revisao Master Deploy/03_Padronizar_DANFE_Empresas.sql
PROMPT [03/31] FIM - 03_Padronizar_DANFE_Empresas.sql

PROMPT [04/31] INICIO - 04_Desativar_Custo_TOP_Devolucao.sql
@@../../Revisao Master Deploy/04_Desativar_Custo_TOP_Devolucao.sql
PROMPT [04/31] FIM - 04_Desativar_Custo_TOP_Devolucao.sql

PROMPT [05/31] INICIO - 05_Habilitar_Calculo_Giro_Produtos.sql
@@../../Revisao Master Deploy/05_Habilitar_Calculo_Giro_Produtos.sql
PROMPT [05/31] FIM - 05_Habilitar_Calculo_Giro_Produtos.sql

PROMPT [06/31] INICIO - 06_Zerar_Parcelas_Tipos_Negociacao.sql
@@../../Revisao Master Deploy/06_Zerar_Parcelas_Tipos_Negociacao.sql
PROMPT [06/31] FIM - 06_Zerar_Parcelas_Tipos_Negociacao.sql

PROMPT [07/31] INICIO - 07_Preencher_Data_Movimento.sql
@@../../Revisao Master Deploy/07_Preencher_Data_Movimento.sql
PROMPT [07/31] FIM - 07_Preencher_Data_Movimento.sql

PROMPT [08/31] INICIO - 08_Preencher_Protocolos_Documentos_Legados.sql
@@../../Revisao Master Deploy/08_Preencher_Protocolos_Documentos_Legados.sql
PROMPT [08/31] FIM - 08_Preencher_Protocolos_Documentos_Legados.sql

PROMPT [09/31] INICIO - 09_Liberar_Itens_Documentos_Legados.sql
@@../../Revisao Master Deploy/09_Liberar_Itens_Documentos_Legados.sql
PROMPT [09/31] FIM - 09_Liberar_Itens_Documentos_Legados.sql

PROMPT [10/31] INICIO - 10_Habilitar_ICMS_Gerencial.sql
@@../../Revisao Master Deploy/10_Habilitar_ICMS_Gerencial.sql
PROMPT [10/31] FIM - 10_Habilitar_ICMS_Gerencial.sql

PROMPT [11/31] INICIO - 11_Habilitar_Ruptura_Produtos.sql
@@../../Revisao Master Deploy/11_Habilitar_Ruptura_Produtos.sql
PROMPT [11/31] FIM - 11_Habilitar_Ruptura_Produtos.sql

PROMPT [12/31] INICIO - 12_Habilitar_Ruptura_Empresas.sql
@@../../Revisao Master Deploy/12_Habilitar_Ruptura_Empresas.sql
PROMPT [12/31] FIM - 12_Habilitar_Ruptura_Empresas.sql

PROMPT [13/31] INICIO - 13_Configurar_TOPs_Giro_GOL.sql
@@../../Revisao Master Deploy/13_Configurar_TOPs_Giro_GOL.sql
PROMPT [13/31] FIM - 13_Configurar_TOPs_Giro_GOL.sql

PROMPT [14/31] INICIO - 14_Configurar_Analise_Giro_848.sql
@@../../Revisao Master Deploy/14_Configurar_Analise_Giro_848.sql
PROMPT [14/31] FIM - 14_Configurar_Analise_Giro_848.sql

PROMPT [15/31] INICIO - 15_Desativar_Rastro_Sem_Controle.sql
@@../../Revisao Master Deploy/15_Desativar_Rastro_Sem_Controle.sql
PROMPT [15/31] FIM - 15_Desativar_Rastro_Sem_Controle.sql

PROMPT [16/31] INICIO - 16_Aplicar_Higienizacao_TSICFG.sql
@@../../Revisao Master Deploy/16_Aplicar_Higienizacao_TSICFG.sql
PROMPT [16/31] FIM - 16_Aplicar_Higienizacao_TSICFG.sql

PROMPT [17/31] INICIO - 17_Normalizar_Unidades.sql
@@../../Revisao Master Deploy/17_Normalizar_Unidades.sql
PROMPT [17/31] FIM - 17_Normalizar_Unidades.sql

PROMPT [PREP 18-30] INICIO - 18_Preparar_Backups_18_30.sql
@@../../Revisao Master Deploy/18_Preparar_Backups_18_30.sql
PROMPT [PREP 18-30] FIM - 18_Preparar_Backups_18_30.sql

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
PROMPT CONTINUACAO MASTER DEPLOY HIGIEPAM - FIM ETAPAS 02 A 31
PROMPT ============================================================
