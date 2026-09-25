#!/usr/bin/env python3
"""Servidor MCP (stdio) — wrapper fino e seguro sobre oracle_direct.py e
oracle_batch.py para a Revisão Master Deploy (Sankhya).

Este servidor NÃO reimplementa nenhuma trava de segurança. Cada ferramenta
apenas monta a linha de comando equivalente e chama o script Python
correspondente via subprocess, devolvendo a saída JSON tal como o script já
produz. Todas as garantias continuam vivas exatamente como estão em
oracle_direct.py / oracle_batch.py:

  - oracle_direct.py bloqueia DML/DDL/COMMIT/ROLLBACK por regex em qualquer
    consulta ad-hoc (ferramenta `consultar`).
  - oracle_batch.py só executa entrada aprovada e versionada, faz preflight
    estático antes de qualquer login, confirma a base (SERVICE_NAME) após
    conectar, exige a confirmação nativa única do macOS antes do primeiro
    comando, executa tudo em uma transação atômica com rollback automático
    em qualquer erro, e grava um log auditável por execução.

REGRA DELIBERADA: este servidor NUNCA passa --preauthorized/--authorization
para o oracle_batch.py. Quem decide dispensar a confirmação nativa é sempre
uma pessoa digitando esses flags manualmente na linha de comando — não uma
ferramenta que um agente de IA pode acionar sozinho. Não adicione esses
flags aqui sem decisão explícita e documentada do responsável pelo processo.

Instalação (rodar no Terminal do seu Mac, não pela ponte remota) — dois
ambientes Python separados, de propósito diferente:

  1) o venv que roda ESTE servidor (só precisa do pacote `mcp`):
       cd "7 - QA2/Revisao Master Deploy/Automacao"
       python3 -m venv .mcp-venv
       .mcp-venv/bin/pip install "mcp[cli]"

  2) o venv que sabe falar com o Oracle (oracledb) — normalmente já é o
     ".venv" descrito em README_ORACLE_DIRETO.md; se ainda não existir:
       python3 -m venv .venv
       .venv/bin/pip install -r requirements-oracle-direct.txt

Este servidor detecta automaticamente o ".venv" acima (ou a variável de
ambiente ORACLE_PYTHON, se você preferir outro caminho) para chamar
oracle_direct.py/oracle_batch.py — não precisa ser o mesmo interpretador
que executa o mcp_server.py em si.

Registro no Claude Desktop: veja o README_MCP_SERVER.md nesta mesma pasta.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any, Optional

from mcp.server.mcpserver import MCPServer, Context

HERE = Path(__file__).resolve().parent
PROJECT_ROOT = HERE.parents[1]  # .../7 - QA2
DIRECT = HERE / "oracle_direct.py"
BATCH = HERE / "oracle_batch.py"
LOGS_DIR = HERE / "Logs" / "mcp_server"


def _oracle_python() -> str:
    """Interpretador usado para chamar oracle_direct.py/oracle_batch.py.

    Não é necessariamente o mesmo que roda este servidor MCP: aquele só
    precisa do pacote `mcp`, este precisa do `oracledb`. Prioridade:
    ORACLE_PYTHON (env) > "<Automacao>/.venv" > "<raiz do repo>/.venv"
    (onde o .venv já usado por oracle_direct.py normalmente vive) >
    sys.executable.
    """
    override = os.environ.get("ORACLE_PYTHON")
    if override and Path(override).exists():
        return override
    for candidate_root in (HERE, PROJECT_ROOT.parent):
        venv_python = candidate_root / ".venv" / "bin" / "python3"
        if venv_python.exists():
            return str(venv_python)
    return sys.executable


mcp = MCPServer("sankhya-revisao-master-deploy")


def _run(cmd: list[str], *, timeout: Optional[float] = None) -> dict[str, Any]:
    """Executa um comando e tenta interpretar a saída como JSON.

    Nunca lança por código de saída não-zero: os próprios scripts já
    devolvem JSON estruturado ("status": "...") tanto no sucesso quanto no
    bloqueio, e é isso que a ferramenta MCP deve repassar ao chamador.
    """
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as exc:
        return {
            "status": "MCP_TIMEOUT",
            "mensagem": f"Comando excedeu {timeout}s: {' '.join(cmd)}",
            "saida_parcial": (exc.stdout or "") + (exc.stderr or ""),
        }

    combined = (result.stdout or "") + (result.stderr or "")
    try:
        parsed = json.loads(result.stdout) if result.stdout.strip() else json.loads(combined)
        if isinstance(parsed, dict):
            parsed.setdefault("returncode", result.returncode)
        return parsed
    except json.JSONDecodeError:
        return {
            "status": "SAIDA_NAO_JSON",
            "returncode": result.returncode,
            "saida": combined,
        }


def _resolve_script(script_path: str) -> Path:
    """Aceita caminho absoluto ou relativo a '7 - QA2/'."""
    p = Path(script_path).expanduser()
    if p.is_absolute():
        return p
    return (PROJECT_ROOT / p).resolve()


def _vault_flags(
    credential_source: str,
    vault_namespace: Optional[str],
    vault_mount: Optional[str],
    vault_path: Optional[str],
) -> list[str]:
    flags = ["--credential-source", credential_source]
    if vault_namespace:
        flags += ["--vault-namespace", vault_namespace]
    if vault_mount:
        flags += ["--vault-mount", vault_mount]
    if vault_path:
        flags += ["--vault-path", vault_path]
    return flags


@mcp.tool()
def status(
    host: str,
    port: int,
    service: str,
    username: str,
    credential_source: str = "auto",
    vault_namespace: Optional[str] = None,
    vault_mount: Optional[str] = None,
    vault_path: Optional[str] = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Verifica o ambiente (driver Oracle, Python) e a identidade da conexão,
    sem executar nenhum DML/DDL. Roda self-check (não conecta), identity
    (conecta, valida SERVICE_NAME e usuário) e vault-check (se um mount/path
    de Vault foi informado, confirma que o segredo existe sem exibi-lo).
    """
    oracle_python = _oracle_python()
    self_check = _run([oracle_python, str(DIRECT), "self-check"])

    identity_cmd = [
        oracle_python, str(DIRECT), "identity",
        "--host", host, "--port", str(port), "--service", service, "--username", username,
        "--prompt", "macos",
    ] + _vault_flags(credential_source, vault_namespace, vault_mount, vault_path)
    identity = _run(identity_cmd)

    vault_check: dict[str, Any] = {"status": "NAO_SOLICITADO"}
    if vault_mount and vault_path:
        vault_check_cmd = [
            oracle_python, str(DIRECT), "vault-check",
            "--vault-namespace", vault_namespace or "",
            "--vault-mount", vault_mount,
            "--vault-path", vault_path,
        ]
        vault_check = _run(vault_check_cmd)

    return {"self_check": self_check, "identity": identity, "vault_check": vault_check}


@mcp.tool()
def consultar(
    sql: str,
    host: str,
    port: int,
    service: str,
    username: str,
    credential_source: str = "auto",
    vault_namespace: Optional[str] = None,
    vault_mount: Optional[str] = None,
    vault_path: Optional[str] = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Executa uma consulta read-only (SELECT/WITH). Qualquer DML/DDL/COMMIT/
    ROLLBACK no texto é bloqueado pelo próprio oracle_direct.py antes de
    tentar login — esta ferramenta não afrouxa essa checagem.
    """
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".sql", prefix="mcp_consulta_", delete=False, encoding="utf-8"
    ) as tmp:
        tmp.write(sql)
        tmp_path = tmp.name

    try:
        cmd = [
            _oracle_python(), str(DIRECT), "query",
            "--host", host, "--port", str(port), "--service", service, "--username", username,
            "--prompt", "macos",
            "--sql-file", tmp_path,
        ] + _vault_flags(credential_source, vault_namespace, vault_mount, vault_path)
        return _run(cmd, timeout=120)
    finally:
        Path(tmp_path).unlink(missing_ok=True)


@mcp.tool()
def planejar(script_path: str, ctx: Context = None) -> dict[str, Any]:
    """Roda o preflight estático de um script/entrypoint (oracle_batch.py
    plan): NÃO conecta no Oracle. Valida binds, DEFINEs, ordenação e detecta
    COMMIT embutido incorreto. Use antes de 'aplicar' — e sempre que quiser
    checar um entrypoint novo sem qualquer risco.
    """
    script = _resolve_script(script_path)
    if not script.exists():
        return {"status": "SCRIPT_NAO_ENCONTRADO", "caminho": str(script)}
    return _run([_oracle_python(), str(BATCH), "plan", "--script", str(script)])


@mcp.tool()
def aplicar(
    script_path: str,
    host: str,
    port: int,
    service: str,
    username: str,
    execution_id: str,
    post_script_path: Optional[str] = None,
    credential_source: str = "auto",
    vault_namespace: Optional[str] = None,
    vault_mount: Optional[str] = None,
    vault_path: Optional[str] = None,
    ctx: Context = None,
) -> dict[str, Any]:
    """Executa um lote APROVADO contra o Oracle (oracle_batch.py apply).

    Continua exigindo a confirmação nativa única do macOS antes do primeiro
    comando — esta ferramenta nunca passa --preauthorized/--authorization.
    Quem confirma é sempre a pessoa no teclado do Mac. Log completo é
    gravado em 'Automacao/Logs/mcp_server/<execution_id>_<timestamp>.log'.
    """
    script = _resolve_script(script_path)
    if not script.exists():
        return {"status": "SCRIPT_NAO_ENCONTRADO", "caminho": str(script)}

    post_script = _resolve_script(post_script_path) if post_script_path else None
    if post_script is not None and not post_script.exists():
        return {"status": "POST_SCRIPT_NAO_ENCONTRADO", "caminho": str(post_script)}

    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    log_path = LOGS_DIR / f"{execution_id}_{int(time.time())}.log"

    cmd = [
        _oracle_python(), str(BATCH), "apply",
        "--host", host, "--port", str(port), "--service", service, "--username", username,
        "--prompt", "macos",
        "--script", str(script),
        "--execution-id", execution_id,
        "--log", str(log_path),
    ] + _vault_flags(credential_source, vault_namespace, vault_mount, vault_path)
    if post_script is not None:
        cmd += ["--post-script", str(post_script)]

    # Sem timeout curto: a confirmação nativa espera o clique da pessoa.
    return _run(cmd, timeout=900)


if __name__ == "__main__":
    mcp.run(transport="stdio")
