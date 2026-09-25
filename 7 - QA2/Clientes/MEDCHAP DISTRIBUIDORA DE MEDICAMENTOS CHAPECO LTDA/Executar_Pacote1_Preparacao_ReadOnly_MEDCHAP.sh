#!/bin/bash
# Pacote 1 (somente leitura) — MEDCHAP DISTRIBUIDORA DE MEDICAMENTOS CHAPECO LTDA
# Ordem: credential status -> prepare -> identity (gate) -> preflight read-only -> volumetria -> 29/30 -> fila somente leitura.
# Usa somente executores homologados. Nao executa DML/DDL. Nao recebe, grava ou exibe senha:
# se nao houver item no Keychain, a janela protegida do macOS aparece UMA vez no passo identity.
cd "$(dirname "$0")/../../.." || exit 1          # raiz Scripts-Deploy
A="7 - QA2/Revisao Master Deploy/Automacao"
BASE="MEDCHAP DISTRIBUIDORA DE MEDICAMENTOS CHAPECO LTDA"
B="7 - QA2/Clientes/$BASE"
PY=".venv/bin/python"
TS=$(date +%Y%m%d_%H%M%S)
CONN=(--host 10.100.76.5 --port 1521 --service MEDCHAPPRD.SANKHYACLOUD.COM.BR --username francisco_junior)
mkdir -p "$B/Logs"
RES="$B/Logs/Pacote1_ReadOnly_${TS}.resumo.txt"
stamp() { date +%Y-%m-%dT%H:%M:%S%z; }
run() { # nome, comando...
  local n="$1"; shift
  local s=$(date +%s) si=$(stamp)
  "$@" > "$B/Logs/${n}_${TS}.json" 2>&1; local rc=$?
  echo "$n;inicio=$si;fim=$(stamp);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"
  return $rc
}
para() { echo "PARADO: $1" | tee -a "$RES"; echo "FIM $(stamp)" | tee -a "$RES"; exit 1; }

echo "PACOTE1_READ_ONLY base=$BASE TS=$TS inicio=$(stamp)" | tee "$RES"
[ -x "$PY" ] || para "ambiente .venv ausente em $(pwd)"
echo ">> Confirme que a VPN FortiClient esta conectada (Enter para continuar, Ctrl+C para cancelar)"; read -r _

# 1) credencial: somente status, antes de qualquer janela de senha
run P00_credential_status $PY "$A/oracle_direct.py" credential status "${CONN[@]}"
grep -o '"status": *"[A-Z_]*"' "$B/Logs/P00_credential_status_${TS}.json" | tee -a "$RES"

# 2) prepare (GP obrigatorio; analista opcional, informar nome e e-mail juntos ou deixar ambos vazios)
if [ ! -f "$B/Dados_Revisao.json" ]; then
  read -r -p "GP (nome, e-mail ou 'Nome <e-mail>'): " GP
  [ -n "$GP" ] || para "GP nao informado"
  read -r -p "Analista de projetos - nome completo (Enter para informar depois): " AN
  AE=""; [ -n "$AN" ] && read -r -p "Analista de projetos - e-mail: " AE
  EXTRA=(); [ -n "$AN" ] && EXTRA=(--analista-nome "$AN" --analista-email "$AE")
  s=$(date +%s); si=$(stamp)
  $PY "$A/revisao_deploy.py" prepare --client "$BASE" --hostname 10.100.76.5 --port 1521 \
    --service MEDCHAPPRD.SANKHYACLOUD.COM.BR --username francisco_junior --gp "$GP" "${EXTRA[@]}" \
    > "$B/Logs/00_prepare_${TS}.log" 2>&1
  rc=$?; echo "prepare;inicio=$si;fim=$(stamp);dur_s=$(( $(date +%s)-s ));rc=$rc" | tee -a "$RES"
  cat "$B/Logs/00_prepare_${TS}.log"
  [ $rc -eq 0 ] || para "prepare falhou (ver Logs/00_prepare_${TS}.log)"
  grep -q "PORTA_ORACLE_ACESSIVEL=SIM" "$B/Logs/00_prepare_${TS}.log" || \
    para "porta Oracle inacessivel; IP 10.100.76.5 nao esta no catalogo de rotas /32 - decisao necessaria (nao aplicar rota manual)"
else
  echo "prepare;ignorado=Dados_Revisao.json ja existe" | tee -a "$RES"
fi

# 3) identidade (gate): sem repeticao de prompt em caso de falha
run P00_identity $PY "$A/oracle_direct.py" identity "${CONN[@]}" || para "identity falhou (ver Logs/P00_identity_${TS}.json); nao repetir senha"
grep -q '"status": *"IDENTIDADE_VALIDADA_READ_ONLY"' "$B/Logs/P00_identity_${TS}.json" || para "identidade nao validada"
grep -q '"service_compativel": *true' "$B/Logs/P00_identity_${TS}.json" || para "SERVICE_NAME divergente"

# 4) preflight read-only
for f in "$B"/Preflight/P*.sql; do
  run "$(basename "$f" .sql)" $PY "$A/oracle_direct.py" query "${CONN[@]}" --sql-file "$f"
done
run V01_Volumetria_Inicial_JRXML $PY "$A/oracle_direct.py" query-jrxml "${CONN[@]}" \
  --jrxml-file "7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml" --include-excluded
run P21_Preflight_29_30 $PY "$A/oracle_29_30_preflight.py" "${CONN[@]}" \
  --output "$B/Artefatos_Revisao/Preflight_29_30_${TS}.json"
echo "FIM_PREFLIGHT $(stamp)" | tee -a "$RES"

# 5) fila local somente leitura (deixe esta janela aberta; Ctrl+C encerra)
echo ">> Iniciando fila SOMENTE LEITURA. Deixe o Terminal aberto."
exec $PY "$A/fila_execucao.py" --base "$B"
