#!/bin/bash
# Onda 2 / fase 1 das atividades 29/30 (FOCUSFINTAXPRD), autorizada por "EXECUTAR FOCUSFINTAXPRD".
# 1) diagnosticos read-only; 2) guarda: artefatos FOCUS_MRG inexistentes; 3) preflight + apply do merge
# (mapa, backup dos pais obsoletos, redirecionamento; sem exclusao de pais); 4) preflight 29/30 pos-merge.
cd "$(dirname "$0")/../../.." || exit 1
set -o pipefail
A="7 - QA2/Revisao Master Deploy/Automacao"; B="7 - QA2/Clientes/FOCUSFINTAXPRD"; PY=".venv/bin/python"
TS=$(date +%Y%m%d_%H%M%S); ID="FOCUS_MRG_20260923_01"
CONN=(--host 10.100.106.5 --port 1521 --service FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR --username francisco_junior)
RES="$B/Logs/Onda2_Fase1_${TS}.resumo.txt"
step() { local n="$1"; shift; local si=$(date +%Y-%m-%dT%H:%M:%S%z) s=$(date +%s); "$@" > "$B/Logs/${n}_${TS}.json" 2>&1; local rc=$?; echo "$n;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"; return $rc; }
echo "ONDA2_FASE1 FOCUSFINTAXPRD TS=$TS ID=$ID" | tee "$RES"
step D01_CabSemItens_TIPMOV $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Preflight/D01_CabSemItens_TIPMOV.sql"
step D02_Artefatos_Merge_Fila $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Preflight/D02_Artefatos_Merge_Fila.sql" || exit 2
step V02_Volumetria_Pos_Master $PY "$A/oracle_direct.py" query-jrxml "${CONN[@]}" --jrxml-file "7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml" --include-excluded
step P19_R02_Preflight_29_30_Pos_Master $PY "$A/oracle_29_30_preflight.py" "${CONN[@]}" --output "$B/Artefatos_Revisao/Preflight_29_30_R02_pos_master_${TS}.json" || exit 3
$PY - "$B/Logs/D02_Artefatos_Merge_Fila_${TS}.json" <<'PY' || { echo "GUARDA=ARTEFATOS_FOCUS_MRG_JA_EXISTEM_OU_CONSULTA_INVALIDA; merge NAO executado" | tee -a "$RES"; exit 4; }
import json,sys
d=json.load(open(sys.argv[1]))
assert d["status"]=="CONSULTA_READ_ONLY_CONCLUIDA" and d["service_name"].upper()=="FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR"
assert not [r for r in d["linhas"] if "FOCUS_MRG" in r["TABLE_NAME"] or "RMD_FOCUS_20260923" in r["TABLE_NAME"] or "BKP_RMD_FOCUS_20260923" in r["TABLE_NAME"]]
PY
echo "GUARDA=ARTEFATOS_AUSENTES_OK" | tee -a "$RES"
$PY "$A/oracle_batch.py" preflight --script "$B/29_30_Merge_Antifragil_FOCUSFINTAXPRD.sql" > "$B/Logs/${ID}_preflight.json" || { echo "PREFLIGHT_MERGE=BLOQUEADO" | tee -a "$RES"; exit 5; }
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_batch.py" apply "${CONN[@]}" --script "$B/29_30_Merge_Antifragil_FOCUSFINTAXPRD.sql" \
  --post-script "$B/Artefatos_Revisao/PostValidacao/02_Merge_PosRedirecionamento_FOCUS_READONLY.sql" \
  --execution-id "$ID" --preauthorized --authorization "EXECUTAR FOCUSFINTAXPRD" \
  --log "$B/Logs/${ID}.log" > "$B/Logs/${ID}_console.txt" 2>&1
rc=$?; echo "APPLY_MERGE;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"
[ $rc -eq 0 ] || exit 6
step P19_R03_Preflight_29_30_Pos_Merge $PY "$A/oracle_29_30_preflight.py" "${CONN[@]}" --output "$B/Artefatos_Revisao/Preflight_29_30_R03_pos_merge_${TS}.json"
echo "FIM $(date +%Y-%m-%dT%H:%M:%S%z)" | tee -a "$RES"
