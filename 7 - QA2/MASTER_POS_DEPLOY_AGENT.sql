-- ============================================================
-- MASTER_POS_DEPLOY_AGENT.sql
-- Unifica execução dos scripts pós-Deploy Agent
-- Requisitos: todos os .sql na mesma pasta deste master
-- Observação: este master NÃO para em erro (CONTINUE) e segue.
-- ============================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;
WHENEVER SQLERROR CONTINUE;

PROMPT
PROMPT ============================================================
PROMPT  MASTER POS-DEPLOY AGENT - INICIO
PROMPT  Data/Hora: &&_DATE &&_TIME
PROMPT ============================================================
PROMPT

PROMPT -------------------------
PROMPT INDICE / BLOCOS
PROMPT [01] Scripts Variados
PROMPT [02] TSICFG (RAINHA)
PROMPT [03] Padronizacao de Dados
PROMPT [04] Limpeza / Normalizacao de Unidades
PROMPT [05] Ajuste TGFCGM / Preferencias
PROMPT [06] Ajuste CODPARCMATRIZ
PROMPT [07] Ajuste Cards Deploy_Agent
PROMPT -------------------------
PROMPT

-- ============================================================
PROMPT [01] INICIO - Scripts Variados
PROMPT ============================================================
@@Scripts_Variados.sql
PROMPT [01] FIM - Scripts Variados
PROMPT

-- ============================================================
PROMPT [02] INICIO - TSICFG RAINHA
PROMPT ============================================================
@@TSICFG_RAINHA.sql
PROMPT [02] FIM - TSICFG RAINHA
PROMPT

-- ============================================================
PROMPT [03] INICIO - Padronizacao de Dados
PROMPT ============================================================
@@Padrao_Dados.sql
PROMPT [03] FIM - Padronizacao de Dados
PROMPT

-- ============================================================
PROMPT [04] INICIO - Limpeza / Normalizacao de Unidades
PROMPT ============================================================
@@Limpeza_Unidades.sql
PROMPT [04] FIM - Limpeza / Normalizacao de Unidades
PROMPT

-- ============================================================
PROMPT [05] INICIO - Ajuste TGFCGM / Preferencias
PROMPT ============================================================
@@AJUSTE_TGFCGM.sql
PROMPT [05] FIM - Ajuste TGFCGM / Preferencias
PROMPT

-- ============================================================
PROMPT [06] INICIO - Ajuste CODPARCMATRIZ
PROMPT ============================================================
@@Ajusta_CODPARCMATRIZ.sql
PROMPT [06] FIM - Ajuste CODPARCMATRIZ
PROMPT

-- ============================================================
PROMPT [07] INICIO - Ajuste Cards Deploy_Agent
PROMPT ============================================================
@@Ajusta_Cards_Deploy.sql
PROMPT [07] FIM - Ajuste Cards Deploy_Agent
PROMPT

PROMPT
PROMPT ============================================================
PROMPT  MASTER POS-DEPLOY AGENT - FIM
PROMPT  Data/Hora: &&_DATE &&_TIME
PROMPT ============================================================
PROMPT

WHENEVER SQLERROR EXIT;