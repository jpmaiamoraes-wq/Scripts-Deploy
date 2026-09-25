#!/bin/bash
# Preflight somente leitura da base FOCUSFINTAXPRD.
# Usa exclusivamente oracle_direct.py (identity/query/query-jrxml), revisao_deploy.py prepare
# e oracle_29_30_preflight.py. Nao executa DML/DDL. Nao recebe, grava ou exibe senha.
cd "$(dirname "$0")/../../../.." || exit 1
A="7 - QA2/Revisao Master Deploy/Automacao"
B="7 - QA2/Clientes/FOCUSFINTAXPRD"
PY=".venv/bin/python"
TS=$(date +%Y%m%d_%H%M%S)
CONN=(--host 10.100.106.5 --port 1521 --service FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR --username francisco_junior)
mkdir -p "$B/Logs"
RES="$B/Logs/Preflight_ReadOnly_${TS}.resumo.txt"
run() { # nome, comando...
  local n="$1"; shift
  local s=$(date +%s) si=$(date +%Y-%m-%dT%H:%M:%S%z)
  "$@" > "$B/Logs/${n}_${TS}.json" 2>&1; local rc=$?
  local e=$(date +%s)
  echo "$n;inicio=$si;fim=$(date +%Y-%m-%dT%H:%M:%S%z);dur_s=$((e-s));rc=$rc" | tee -a "$RES"
}
echo "PREFLIGHT_READ_ONLY FOCUSFINTAXPRD TS=$TS" | tee "$RES"
$PY "$A/revisao_deploy.py" prepare --client FOCUSFINTAXPRD --hostname 10.100.106.5 --port 1521 \
  --service FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR --username francisco_junior \
  --gp "marcelo.borel@sankhya.com.br" \
  --analista-nome "ANA RODRIGUES" --analista-email "ana.rodrigues@sankhya.com.br" 2>&1 | tee "$B/Logs/00_prepare_${TS}.log"
echo "prepare;rc=${PIPESTATUS[0]}" | tee -a "$RES"
run P00_credential_status $PY "$A/oracle_direct.py" credential status "${CONN[@]}"
for f in "$B"/Preflight/P*.sql; do
  run "$(basename "$f" .sql)" $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$f"
done
run V01_Volumetria_Inicial_JRXML $PY "$A/oracle_direct.py" query-jrxml "${CONN[@]}" \
  --jrxml-file "7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml" --include-excluded
run P19_Preflight_29_30 $PY "$A/oracle_29_30_preflight.py" "${CONN[@]}" \
  --output "$B/Artefatos_Revisao/Preflight_29_30_${TS}.json"
echo "FIM $(date +%Y-%m-%dT%H:%M:%S%z)" | tee -a "$RES"
