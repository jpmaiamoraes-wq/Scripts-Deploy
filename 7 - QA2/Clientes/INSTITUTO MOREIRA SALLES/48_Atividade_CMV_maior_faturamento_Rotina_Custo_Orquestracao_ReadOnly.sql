-- Atividade: CMV sem ICMS acima do faturamento
-- Fase: investigacao read-only da rotina de custo em lote
-- Base: INSTITUTO MOREIRA SALLES
-- Execucao: 2026-09-15

SPOOL "/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/INSTITUTO MOREIRA SALLES/Logs/48_Atividade_CMV_maior_faturamento_Rotina_Custo_Orquestracao_ReadOnly_20260915.log"

SELECT LISTAGG(ARGUMENT_NAME||'|'||POSITION||'|'||IN_OUT||'|'||DATA_TYPE||'|'||DEFAULTED,'; ') WITHIN GROUP(ORDER BY POSITION) AS ASSINATURA
  FROM ALL_ARGUMENTS
 WHERE OWNER='SANKHYA'
   AND OBJECT_NAME='STP_CALCULARCUSTOPRODUCAOMEDIO';

SELECT LINE||'|'||TEXT
  FROM ALL_SOURCE
 WHERE OWNER='SANKHYA'
   AND NAME='STP_CALCULARCUSTOPRODUCAOMEDIO'
 ORDER BY LINE;

SPOOL OFF
