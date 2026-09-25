-- Atividade: CMV sem ICMS acima do faturamento
-- Fase: investigacao read-only da orquestracao do GOL
-- Base: INSTITUTO MOREIRA SALLES
-- Execucao: 2026-09-15

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Logs/44_Atividade_CMV_maior_faturamento_Rotina_GOL_Orquestracao_ReadOnly_20260915.log"

SELECT LISTAGG(ARGUMENT_NAME||'|'||POSITION||'|'||IN_OUT||'|'||DATA_TYPE||'|'||DEFAULTED,'; ') WITHIN GROUP(ORDER BY POSITION) AS ASSINATURA
  FROM ALL_ARGUMENTS
 WHERE OWNER='SANKHYA'
   AND OBJECT_NAME='PFCM_CONSOLIDACAO';

SELECT LINE||'|'||TEXT
  FROM ALL_SOURCE
 WHERE OWNER='SANKHYA'
   AND NAME='PFCM_CONSOLIDACAO'
 ORDER BY LINE;

SPOOL OFF
