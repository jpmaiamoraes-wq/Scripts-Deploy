#!/bin/bash
# Onda 3 (FOCUSFINTAXPRD), autorizada por "EXECUTAR FOCUSFINTAXPRD":
#  A) 29/30 fase 3 - padroniza os 413 bairros / 6877 enderecos remanescentes (backup em BKP_RMD_PAD_*; guarda interna R04)
#  B) Card 09 - estado read-only, mapa direto XML (sem INSERT em TGFFIN) e pos-validacao
cd "$(dirname "$0")/../../.." || exit 1
set -o pipefail
A="7 - QA2/Revisao Master Deploy/Automacao"; B="7 - QA2/Clientes/FOCUSFINTAXPRD"; PY=".venv/bin/python"
TS=$(date +%Y%m%d_%H%M%S)
CONN=(--host 10.100.106.5 --port 1521 --service FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR --username francisco_junior)
RES="$B/Logs/Onda3_${TS}.resumo.txt"
mark() { echo "$1;inicio=$2;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$(( $(date +%s)-$3 ));rc=$4" | tee -a "$RES"; }
echo "ONDA3 FOCUSFINTAXPRD TS=$TS" | tee "$RES"
# A) Normalizacao remanescente 29/30
ID="FOCUS_NORM2930_20260923_01"
$PY "$A/oracle_batch.py" preflight --script "$B/29_30_Merge_Antifragil_FOCUSFINTAXPRD_Normalizar_Remanentes.sql" > "$B/Logs/${ID}_preflight.json" || { echo "PREFLIGHT_NORM=BLOQUEADO" | tee -a "$RES"; exit 2; }
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_batch.py" apply "${CONN[@]}" --script "$B/29_30_Merge_Antifragil_FOCUSFINTAXPRD_Normalizar_Remanentes.sql" \
  --post-script "$B/Artefatos_Revisao/PostValidacao/29_30_Normalizacao_Remanescente_FOCUS_READONLY.sql" \
  --execution-id "$ID" --preauthorized --authorization "EXECUTAR FOCUSFINTAXPRD" --log "$B/Logs/${ID}.log" > "$B/Logs/${ID}_console.txt" 2>&1
rc=$?; mark APPLY_NORM2930 "$si" "$s" $rc
if [ $rc -eq 0 ]; then
  si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
  $PY "$A/oracle_29_30_preflight.py" "${CONN[@]}" --output "$B/Artefatos_Revisao/Preflight_29_30_R05_pos_normalizacao_${TS}.json" > "$B/Logs/P19_R05_${TS}.json" 2>&1
  rc=$?; mark P19_R05_POS_NORMALIZACAO "$si" "$s" $rc
else
  echo "NORM2930_FALHOU: Card 09 segue por ser independente" | tee -a "$RES"
fi
# B) Card 09 - mapa
ID="FOCUS_FDUP_20260923_01"
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$B/Preflight/32_Card09_Preflight_Estado_FOCUS_READONLY.sql" > "$B/Logs/32_Card09_Preflight_Estado_${TS}.json" 2>&1
rc=$?; mark CARD09_PREFLIGHT_ESTADO "$si" "$s" $rc; [ $rc -eq 0 ] || exit 3
$PY - "$B/Logs/32_Card09_Preflight_Estado_${TS}.json" <<'PY' || { echo "GUARDA_CARD09=ESTADO_DIVERGENTE; mapa NAO executado" | tee -a "$RES"; exit 4; }
import json,sys
d=json.load(open(sys.argv[1])); v={r["METRICA"]:r["VALOR"] for r in d["linhas"]}
assert d["service_name"].upper()=="FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR"
assert v["TABELAS_MAPA_EXISTENTES"]=="0" and v["TABELAS_FDUP_ANTERIORES"]=="0" and v["LINHAS_TGFNUM_TGFFIN"]=="1", v
print("CARD09_ESTADO=NAO_INICIADO; ESCOPO="+v["ESCOPO_DASHBOARD_NOTAS_SEM_FIN"])
PY
echo "PREFLIGHT_EXECUTADO=SIM; GUARDA_CARD09=NAO_INICIADO_OK" | tee -a "$RES"
$PY "$A/oracle_batch.py" preflight --script "$B/32A_Card09_Mapear_Direto_XML_FOCUSFINTAXPRD.sql" > "$B/Logs/${ID}_preflight.json" || { echo "PREFLIGHT_MAPA=BLOQUEADO" | tee -a "$RES"; exit 5; }
si=$(date +%Y-%m-%dT%H:%M:%S%z); s=$(date +%s)
$PY "$A/oracle_batch.py" apply "${CONN[@]}" --script "$B/32A_Card09_Mapear_Direto_XML_FOCUSFINTAXPRD.sql" \
  --post-script "$B/Artefatos_Revisao/PostValidacao/32_Card09_Mapa_PosValidacao_FOCUS_READONLY.sql" \
  --execution-id "$ID" --preauthorized --authorization "EXECUTAR FOCUSFINTAXPRD" --log "$B/Logs/${ID}_MAPA.log" > "$B/Logs/${ID}_MAPA_console.txt" 2>&1
rc=$?; mark APPLY_CARD09_MAPA "$si" "$s" $rc
echo "FIM $(date +%Y-%m-%dT%H:%M:%S%z)" | tee -a "$RES"
