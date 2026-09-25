-- Atividade: CMV sem ICMS acima do faturamento
-- Fase: investigacao read-only do chamador do custo medio
-- Base: INSTITUTO MOREIRA SALLES
-- Execucao: 2026-09-15

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Logs/49_Atividade_CMV_maior_faturamento_Rotina_Custo_Chamador_ReadOnly_20260915.log"

SELECT LISTAGG(ARGUMENT_NAME||'|'||POSITION||'|'||IN_OUT||'|'||DATA_TYPE||'|'||DEFAULTED,'; ') WITHIN GROUP(ORDER BY POSITION) AS ASSINATURA
  FROM ALL_ARGUMENTS
 WHERE OWNER='SANKHYA'
   AND OBJECT_NAME='STP_CALCULARCUSTOPRODUCAO';

SELECT LINE||'|'||TEXT
  FROM ALL_SOURCE
 WHERE OWNER='SANKHYA'
   AND NAME='STP_CALCULARCUSTOPRODUCAO'
 ORDER BY LINE;

SPOOL OFF
