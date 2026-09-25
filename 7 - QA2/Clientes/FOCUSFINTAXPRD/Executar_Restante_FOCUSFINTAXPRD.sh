#!/bin/bash
# Execucao consolidada das atividades restantes da FOCUSFINTAXPRD, sob "EXECUTAR FOCUSFINTAXPRD".
# 1) Onda 3: normalizacao remanescente 29/30 + estado/mapa/pos-validacao do Card 09 (sem INSERT em TGFFIN)
# 2) Verificacoes finais somente leitura: volumetria final com os 4 indicadores, objetos invalidos (etapa 31),
#    estado do controle do Master e diagnostico final 29/30 (gerado na onda 3).
# Nenhuma fase financeira, reversao, limpeza ou arquivo fora da lista acima e executado.
cd "$(dirname "$0")/../../.." || exit 1
A="7 - QA2/Revisao Master Deploy/Automacao"; B="7 - QA2/Clientes/FOCUSFINTAXPRD"; PY=".venv/bin/python"
TS=$(date +%Y%m%d_%H%M%S)
CONN=(--host 10.100.106.5 --port 1521 --service FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR --username francisco_junior)
RES="$B/Logs/Restante_${TS}.resumo.txt"
echo "RESTANTE FOCUSFINTAXPRD TS=$TS inicio=$(date +%Y-%m-%dT%H:%M:%S%z)" | tee "$RES"
bash "$B/Executar_Onda3_Normalizacao2930_Card09Mapa_FOCUSFINTAXPRD.sh"; echo "ONDA3;rc=$?" | tee -a "$RES"
q() { local n="$1"; shift; local si=$(date +%Y-%m-%dT%H:%M:%S%z) s=$(date +%s); "$@" > "$B/Logs/${n}_${TS}.json" 2>&1; local rc=$?; echo "$n;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"; }
q V03_Volumetria_Final $PY "$A/oracle_direct.py" query-jrxml "${CONN[@]}" --jrxml-file "7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml" --include-excluded
q F13_Objetos_Invalidos_Final $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Preflight/P13_Etapa31_Lista_Objetos_Invalidos.sql"
q F12_Invalidos_Privilegio_Final $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Preflight/P12_Etapa31_Invalidos_Privilegio.sql"
q F00_Master_Estado_Final $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Artefatos_Revisao/PostValidacao/00_Master_PosExecucao_FOCUSFINTAXPRD_READONLY.sql"
echo "FIM $(date +%Y-%m-%dT%H:%M:%S%z)" | tee -a "$RES"
