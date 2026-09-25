#!/usr/bin/env python3
"""Fila local de execucao da Revisao Master Deploy (roda no Terminal do Mac).

O agente grava pedidos JSON em <BASE>/Fila_Execucao/pendentes/. Esta fila executa
somente os tipos previstos, usando os executores homologados (oracle_direct.py,
oracle_batch.py, oracle_29_30_preflight.py), com a conexao lida do
Dados_Revisao.json da base. Nao aceita SQL inline, conexao diferente, caminhos
fora de '7 - QA2', scripts de reversao/limpeza nem alteracoes sem a autorizacao
digitada pelo usuario ao iniciar a fila (--autorizar "EXECUTAR <BASE>").
Nenhuma senha passa por aqui: a credencial continua no Keychain.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
SUITE_ROOT = HERE.parents[1]            # .../7 - QA2
REPO_ROOT = SUITE_ROOT.parent            # .../Scripts-Deploy
PY = sys.executable
ORACLE_DIRECT = HERE / "oracle_direct.py"
ORACLE_BATCH = HERE / "oracle_batch.py"
PREFLIGHT_2930 = HERE / "oracle_29_30_preflight.py"

READ_ONLY_TYPES = {"credential_status", "identity", "query", "query_jrxml", "preflight_29_30", "batch_preflight"}
MUTATING_TYPES = {"batch_apply"}
FORBIDDEN_NAME = re.compile(r"(rollback|reverter|limpar_objetos)", re.I)
SAFE_ID = re.compile(r"^[A-Za-z0-9_.-]{3,80}$")
TIMEOUT_S = {"batch_apply": 3 * 3600, "preflight_29_30": 1800}
DEFAULT_TIMEOUT_S = 900


def now() -> str:
    return dt.datetime.now().astimezone().isoformat(timespec="seconds")


class JobError(ValueError):
    pass


def inside_suite(value: str, must_exist: bool = True) -> Path:
    if not isinstance(value, str) or not value.strip():
        raise JobError("caminho ausente")
    raw = Path(value)
    path = (raw if raw.is_absolute() else (REPO_ROOT / raw)).resolve()
    try:
        path.relative_to(SUITE_ROOT)
    except ValueError as exc:
        raise JobError(f"caminho fora de '7 - QA2': {value}") from exc
    if must_exist and not path.is_file():
        raise JobError(f"arquivo inexistente: {value}")
    return path


def inside_base(base: Path, value: str) -> Path:
    path = inside_suite(value, must_exist=False)
    try:
        path.relative_to(base)
    except ValueError as exc:
        raise JobError(f"saida fora da pasta da base: {value}") from exc
    return path


def connection_args(base: Path) -> list[str]:
    meta = json.loads((base / "Dados_Revisao.json").read_text(encoding="utf-8"))
    return ["--host", str(meta["hostname"]), "--port", str(meta["port"]),
            "--service", str(meta["servicename"]), "--username", str(meta["username"])]


def build_command(job: dict, base: Path, authorization: str | None) -> tuple[list[str], Path, Path | None]:
    """Valida o pedido e devolve (comando, arquivo_saida, log_do_lote)."""
    allowed = {"id", "tipo", "sql_file", "jrxml_file", "include_excluded", "script",
               "post_script", "execution_id", "saida", "descricao"}
    extra = set(job) - allowed
    if extra:
        raise JobError(f"campos nao permitidos: {sorted(extra)}")
    job_id = str(job.get("id", ""))
    if not SAFE_ID.match(job_id):
        raise JobError("id invalido")
    kind = job.get("tipo")
    if kind not in READ_ONLY_TYPES | MUTATING_TYPES:
        raise JobError(f"tipo nao permitido: {kind}")
    out = inside_base(base, job.get("saida") or f"{base.relative_to(REPO_ROOT)}/Logs/FILA_{job_id}.json")
    if out.exists():
        raise JobError(f"saida ja existe (nao sobrescrever): {out.name}")
    conn = connection_args(base)
    batch_log = None
    if kind == "credential_status":
        cmd = [PY, str(ORACLE_DIRECT), "credential", "status", *conn]
    elif kind == "identity":
        cmd = [PY, str(ORACLE_DIRECT), "identity", *conn]
    elif kind == "query":
        cmd = [PY, str(ORACLE_DIRECT), "query", *conn, "--sql-file", str(inside_suite(job.get("sql_file")))]
    elif kind == "query_jrxml":
        cmd = [PY, str(ORACLE_DIRECT), "query-jrxml", *conn, "--jrxml-file", str(inside_suite(job.get("jrxml_file")))]
        if job.get("include_excluded"):
            cmd.append("--include-excluded")
    elif kind == "preflight_29_30":
        cmd = [PY, str(PREFLIGHT_2930), *conn, "--output", str(out.with_suffix(".preflight_29_30.json"))]
    else:
        script = inside_suite(job.get("script"))
        if FORBIDDEN_NAME.search(script.name):
            raise JobError("scripts de reversao/limpeza nao entram na fila")
        if kind == "batch_preflight":
            cmd = [PY, str(ORACLE_BATCH), "preflight", "--script", str(script)]
        else:
            if not authorization:
                raise JobError("alteracao recusada: fila iniciada sem --autorizar")
            exec_id = str(job.get("execution_id", ""))
            if not SAFE_ID.match(exec_id):
                raise JobError("execution_id invalido")
            batch_log = inside_base(base, f"{base.relative_to(REPO_ROOT)}/Logs/{exec_id}.log")
            if batch_log.exists():
                raise JobError("execution_id ja utilizado (log existente); gere novo ID")
            cmd = [PY, str(ORACLE_BATCH), "apply", *conn, "--script", str(script),
                   "--execution-id", exec_id, "--preauthorized", "--authorization", authorization,
                   "--log", str(batch_log)]
            if job.get("post_script"):
                post = inside_suite(job["post_script"])
                cmd += ["--post-script", str(post)]
    return cmd, out, batch_log


def run_job(job_path: Path, base: Path, authorization: str | None, fila: Path) -> dict:
    started = now(); t0 = time.time()
    result: dict = {"pedido": job_path.name, "inicio_local": started}
    try:
        job = json.loads(job_path.read_text(encoding="utf-8"))
        result["id"] = job.get("id"); result["tipo"] = job.get("tipo")
        cmd, out, batch_log = build_command(job, base, authorization)
        timeout = TIMEOUT_S.get(job.get("tipo"), DEFAULT_TIMEOUT_S)
        if job.get("tipo") == "batch_apply":
            # plan/preflight obrigatorio imediatamente antes do apply
            pre = subprocess.run([PY, str(ORACLE_BATCH), "preflight", "--script", cmd[cmd.index("--script") + 1]],
                                 cwd=REPO_ROOT, capture_output=True, text=True, timeout=600)
            (out.with_suffix(".preflight.json")).write_text(pre.stdout + pre.stderr, encoding="utf-8")
            if pre.returncode != 0:
                raise JobError("preflight do lote bloqueado; apply nao executado")
        with open(out, "w", encoding="utf-8") as fh:
            proc = subprocess.run(cmd, cwd=REPO_ROOT, stdout=fh, stderr=subprocess.STDOUT, text=True, timeout=timeout)
        result.update({"status": "CONCLUIDO" if proc.returncode == 0 else "ERRO_EXECUTOR", "rc": proc.returncode,
                       "saida": str(out.relative_to(REPO_ROOT)),
                       "log_lote": str(batch_log.relative_to(REPO_ROOT)) if batch_log else None})
    except subprocess.TimeoutExpired:
        result.update({"status": "TIMEOUT"})
    except (JobError, json.JSONDecodeError, KeyError, OSError) as exc:
        result.update({"status": "RECUSADO" if isinstance(exc, JobError) else "ERRO_PEDIDO", "motivo": str(exc)})
    result.update({"fim_local": now(), "duracao_s": round(time.time() - t0, 1)})
    return result


def main() -> int:
    ap = argparse.ArgumentParser(description="Fila local de execucao da Revisao Master Deploy")
    ap.add_argument("--base", required=True, help="pasta da base, ex.: '7 - QA2/Clientes/FOCUSFINTAXPRD'")
    ap.add_argument("--autorizar", help="frase EXECUTAR <BASE> digitada pelo usuario; sem ela so leitura")
    ap.add_argument("--intervalo", type=float, default=5.0)
    ap.add_argument("--uma-vez", action="store_true", help="processa os pendentes e encerra")
    args = ap.parse_args()
    base = inside_suite(args.base, must_exist=False)
    if not (base / "Dados_Revisao.json").is_file():
        print("Dados_Revisao.json ausente na base; rode o prepare antes."); return 2
    meta = json.loads((base / "Dados_Revisao.json").read_text(encoding="utf-8"))
    authorization = None
    if args.autorizar:
        expected = f"EXECUTAR {meta.get('cliente_informado', '')}".strip().upper()
        if args.autorizar.strip().upper() != expected:
            print(f"Autorizacao nao confere com a base (esperado: {expected})."); return 3
        authorization = args.autorizar.strip()
    fila = base / "Fila_Execucao"
    for sub in ("pendentes", "em_execucao", "concluidos"):
        (fila / sub).mkdir(parents=True, exist_ok=True)
    print(f"FILA_ATIVA base={base.name} modo={'LEITURA_E_ALTERACAO' if authorization else 'SOMENTE_LEITURA'} (Ctrl+C para encerrar)")
    while True:
        (fila / "heartbeat.json").write_text(json.dumps({"ativo_em": now(), "pid": os.getpid(),
            "modo": "LEITURA_E_ALTERACAO" if authorization else "SOMENTE_LEITURA"}), encoding="utf-8")
        for job in sorted((fila / "pendentes").glob("*.json")):
            running = fila / "em_execucao" / job.name
            shutil.move(str(job), running)
            print(f"{now()} EXECUTANDO {job.name}", flush=True)
            res = run_job(running, base, authorization, fila)
            (fila / "concluidos" / f"{running.stem}.resultado.json").write_text(json.dumps(res, ensure_ascii=False, indent=2), encoding="utf-8")
            shutil.move(str(running), fila / "concluidos" / running.name)
            with open(fila / "fila.log", "a", encoding="utf-8") as fh:
                fh.write(json.dumps(res, ensure_ascii=False) + "\n")
            print(f"{now()} {res.get('status')} {job.name}", flush=True)
        if args.uma_vez:
            return 0
        time.sleep(args.intervalo)


if __name__ == "__main__":
    raise SystemExit(main())
