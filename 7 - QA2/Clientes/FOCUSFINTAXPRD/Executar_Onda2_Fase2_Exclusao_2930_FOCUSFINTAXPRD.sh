#!/bin/bash
# Onda 2 / fase 2 das atividades 29/30 (FOCUSFINTAXPRD), autorizada por "EXECUTAR FOCUSFINTAXPRD".
# Exclui somente os pais obsoletos do mapa FOCUS_MRG_20260923_01, com backup ja validado (428 BAI / 7283 END),
# auditoria 61210, excecoes 0 e referencias fisicas zero verificadas dentro do proprio bloco antes do DELETE.
cd "$(dirname "$0")/../../.." || exit 1
set -o pipefail
A="7 - QA2/Revisao Master Deploy/Automacao"; B="7 - QA2/Clientes/FOCUSFINTAXPRD"; PY=".venv/bin/python"
TS=$(date +%Y%m%d_%H%M%S); ID="FOCUS_DEL_20260923_01"
CONN=(--host 10.100.106.5 --port 1521 --service FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR --username francisco_junior)
RES="$B/Logs/Onda2_Fase2_${TS}.resumo.txt"
echo "ONDA2_FASE2 FOCUSFINTAXPRD TS=$TS ID=$ID" | tee "$RES"
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Artefatos_Revisao/PostValidacao/02_Merge_PosRedirecionamento_FOCUS_READONLY.sql" > "$B/Logs/PRE_${ID}_estado_merge_${TS}.json" 2>&1
rc=$?; echo "PRE_ESTADO_MERGE;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"; [ $rc -eq 0 ] || exit 2
$PY - "$B/Logs/PRE_${ID}_estado_merge_${TS}.json" <<'PY' || { echo "GUARDA=ESTADO_MERGE_DIVERGENTE; exclusao NAO executada" | tee -a "$RES"; exit 3; }
import json,sys
d=json.load(open(sys.argv[1])); v={r["METRICA"]:r["VALOR"] for r in d["linhas"]}
assert d["service_name"].upper()=="FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR"
assert v["MAPA_BAI"]==v["BACKUP_BAI_OBSOLETO"]=="428" and v["MAPA_END"]==v["BACKUP_END_OBSOLETO"]=="7283", v
assert v["EXCECOES"]=="0" and int(v["REFERENCIAS_AUDITADAS"])>0, v
for k in ("TSICEP_BAI_REMANESCENTE","TSICEP_END_REMANESCENTE","TGFPAR_BAI_REMANESCENTE","TSIEMP_BAI_REMANESCENTE","TSIAGE_END_REMANESCENTE"): assert v[k]=="0",(k,v[k])
PY
echo "GUARDA=ESTADO_MERGE_OK" | tee -a "$RES"
$PY "$A/oracle_batch.py" preflight --script "$B/29_30_Merge_Antifragil_FOCUSFINTAXPRD_Excluir_Pais_Obsoletos.sql" > "$B/Logs/${ID}_preflight.json" || { echo "PREFLIGHT_EXCLUSAO=BLOQUEADO" | tee -a "$RES"; exit 4; }
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_batch.py" apply "${CONN[@]}" --script "$B/29_30_Merge_Antifragil_FOCUSFINTAXPRD_Excluir_Pais_Obsoletos.sql" \
  --post-script "$B/Artefatos_Revisao/PostValidacao/04_Merge_PosExclusao_FOCUS_READONLY.sql" \
  --execution-id "$ID" --preauthorized --authorization "EXECUTAR FOCUSFINTAXPRD" \
  --log "$B/Logs/${ID}.log" > "$B/Logs/${ID}_console.txt" 2>&1
rc=$?; echo "APPLY_EXCLUSAO;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"; [ $rc -eq 0 ] || exit 5
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_29_30_preflight.py" "${CONN[@]}" --output "$B/Artefatos_Revisao/Preflight_29_30_R04_pos_exclusao_${TS}.json" > "$B/Logs/P19_R04_Preflight_29_30_Pos_Exclusao_${TS}.json" 2>&1
rc=$?; echo "P19_R04_POS_EXCLUSAO;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"
echo "FIM $(date +%Y-%m-%dT%H:%M:%S%z)" | tee -a "$RES"
