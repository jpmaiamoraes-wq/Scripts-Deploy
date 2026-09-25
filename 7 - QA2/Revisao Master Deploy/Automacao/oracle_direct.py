#!/usr/bin/env python3
"""Executor Oracle direto para diagnóstico read-only e credencial controlada.

Não recebe senha por argumento e não habilita DML/DDL. A senha pode ser lida
de um caminho KV aprovado do Vault, em memória, ou do Keychain do macOS como
fallback. Nenhum valor sensível é escrito no projeto, variável de ambiente,
log ou saída do executor.
"""

from __future__ import annotations

import argparse
import getpass
import hashlib
import json
import os
import pty
import re
import select
import signal
import socket
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from vault_provider import (
    VaultCliUnavailable,
    VaultProviderError,
    add_vault_arguments,
    config_from_args,
    metadata as vault_metadata,
    oidc_login,
    password_for_connection,
)

KEYCHAIN_SERVICE_PREFIX = "Sankhya Deploy Agent Oracle"
KEYCHAIN_BINARY = "/usr/bin/security"


def load_driver():
    try:
        import oracledb
    except ModuleNotFoundError as exc:
        raise SystemExit(
            "Driver ausente. Prepare o ambiente com: "
            "python3 -m venv .venv && .venv/bin/python -m pip install -r "
            "'7 - QA2/Revisao Master Deploy/Automacao/requirements-oracle-direct.txt'"
        ) from exc
    return oracledb


def dsn(host: str, port: int, service: str) -> str:
    return f"{host}:{port}/{service}"


def tcp_check(host: str, port: int, timeout: float = 3.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def macos_password_dialog(message: str) -> str:
    """Solicita a senha em uma janela nativa, sem eco no terminal."""
    if sys.platform != "darwin":
        raise RuntimeError("A janela nativa de senha está disponível somente no macOS.")

    escaped_message = message.replace("\\", "\\\\").replace('"', '\\"')
    script = f'''
        display dialog "{escaped_message}" ¬
            default answer "" with hidden answer ¬
            buttons {{"Cancelar", "Continuar"}} ¬
            default button "Continuar" cancel button "Cancelar"
        return text returned of result
    '''
    try:
        completed = subprocess.run(
            ["osascript", "-e", script],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as exc:
        raise RuntimeError("Entrada de senha cancelada.") from exc
    except OSError as exc:
        raise RuntimeError("Não foi possível abrir a janela nativa de senha.") from exc

    return completed.stdout.rstrip("\r\n")


def keychain_identity(args) -> tuple[str, str, str]:
    """Cria uma chave estável sem armazenar a senha ou expor a conexão inteira."""
    material = "\x1f".join((
        args.host.strip().lower(),
        str(args.port),
        args.service.strip().upper(),
        args.username.strip().upper(),
    ))
    digest = hashlib.sha256(material.encode("utf-8")).hexdigest()[:40]
    service = f"{KEYCHAIN_SERVICE_PREFIX} {digest}"
    account = args.username.strip()
    label = f"Sankhya Oracle {account}@{args.service.strip()}"
    return service, account, label


def _keychain_command(args, action: str, *, include_password: bool = False) -> list[str]:
    """Monta comandos do utilitário oficial sem incluir a senha em argv."""
    if sys.platform != "darwin":
        raise RuntimeError("O armazenamento seguro desta versão requer o Keychain do macOS.")
    service, account, _ = keychain_identity(args)
    command = [KEYCHAIN_BINARY, action, "-a", account, "-s", service]
    if include_password:
        command.append("-w")
    return command


def _keychain_item_missing(result: subprocess.CompletedProcess[str]) -> bool:
    """Reconhece somente a ausência; outros erros continuam sendo bloqueios."""
    text = f"{result.stdout}\n{result.stderr}".lower()
    return result.returncode != 0 and any(
        marker in text
        for marker in (
            "could not be found",
            "item not found",
            "no such item",
            "-25300",
        )
    )


def _run_keychain_query(command: list[str]) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
            timeout=10,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise RuntimeError("Não foi possível consultar o Keychain do macOS.") from exc


def keychain_get(args) -> str | None:
    result = _run_keychain_query(_keychain_command(args, "find-generic-password", include_password=True))
    if _keychain_item_missing(result):
        return None
    if result.returncode != 0:
        raise RuntimeError("Não foi possível consultar a credencial no Keychain do macOS.")
    password = result.stdout.rstrip("\r\n")
    if not password:
        raise RuntimeError("A credencial encontrada no Keychain está vazia.")
    return password


def _write_pty_password(fd: int, password: str) -> None:
    # O utilitário security desabilita o eco no prompt. A senha nunca vai para
    # argv, ambiente, arquivo, saída do processo ou log.
    os.write(fd, password.encode("utf-8") + b"\n")


def keychain_set(args, password: str) -> None:
    """Cria ou atualiza o item usando os prompts protegidos do security(1)."""
    command = _keychain_command(args, "add-generic-password")
    command.extend(("-l", keychain_identity(args)[2], "-T", KEYCHAIN_BINARY, "-U", "-w"))
    if not os.path.exists(KEYCHAIN_BINARY):
        raise RuntimeError("O utilitário security do macOS não foi encontrado.")

    pid, fd = pty.fork()
    if pid == 0:
        try:
            os.execv(KEYCHAIN_BINARY, command)
        except OSError:
            os._exit(127)

    started = time.monotonic()
    first_sent_at = None
    sent = 0
    transcript = ""
    child_status = None
    try:
        while time.monotonic() - started < 15:
            now = time.monotonic()
            try:
                ready, _, _ = select.select([fd], [], [], 0.25)
            except (OSError, ValueError):
                ready = []

            if ready:
                try:
                    chunk = os.read(fd, 4096)
                except OSError:
                    chunk = b""
                if chunk:
                    transcript = (transcript + chunk.decode("utf-8", "replace"))[-512:]

            # security(1) pede a senha duas vezes ao criar um item. O fallback
            # por tempo também cobre versões do macOS que não exibem o prompt
            # através do pty.
            if sent == 0 and (
                re.search(r"password data for new item\s*:\s*$", transcript, re.I)
                or now - started >= 0.75
            ):
                _write_pty_password(fd, password)
                sent = 1
                first_sent_at = now
            elif sent == 1 and first_sent_at is not None and (
                re.search(r"retype password for new item\s*:\s*$", transcript, re.I)
                or now - first_sent_at >= 0.75
            ):
                _write_pty_password(fd, password)
                sent = 2

            waited_pid, status = os.waitpid(pid, os.WNOHANG)
            if waited_pid == pid:
                child_status = status
                break

        if child_status is None:
            raise RuntimeError("O Keychain não concluiu o cadastro no tempo esperado; a operação foi encerrada.")
    except (OSError, RuntimeError) as exc:
        if isinstance(exc, RuntimeError):
            raise
        raise RuntimeError("Não foi possível gravar a credencial no Keychain do macOS.") from exc
    finally:
        if child_status is None:
            try:
                os.kill(pid, signal.SIGKILL)
            except OSError:
                pass
            try:
                os.waitpid(pid, 0)
            except OSError:
                pass
        try:
            os.close(fd)
        except OSError:
            pass

    if os.waitstatus_to_exitcode(child_status) != 0:
        raise RuntimeError("O Keychain recusou o cadastro da credencial; nenhuma senha foi gravada pelo executor.")


def keychain_delete(args) -> bool:
    result = _run_keychain_query(_keychain_command(args, "delete-generic-password"))
    if _keychain_item_missing(result):
        return False
    if result.returncode != 0:
        raise RuntimeError("Não foi possível remover a credencial do Keychain do macOS.")
    return True


def resolve_credential(args) -> tuple[str, bool]:
    """Retorna a senha e se ela deve ser salva após autenticação Oracle."""
    credential_source = getattr(args, "credential_source", "auto")
    if credential_source == "vault":
        try:
            return password_for_connection(args), False
        except VaultProviderError as exc:
            raise RuntimeError(f"Credencial Vault bloqueada: {exc}") from exc

    if credential_source == "auto":
        try:
            vault_config = config_from_args(args)
            if vault_config.configured:
                try:
                    return password_for_connection(args), False
                except VaultCliUnavailable:
                    # Sem o cliente oficial instalado, preserva o fallback
                    # local já homologado no Keychain.
                    pass
                except VaultProviderError as exc:
                    # Com Vault configurado, erro de autenticação, caminho ou
                    # identidade não deve ser mascarado por outra credencial.
                    raise RuntimeError(f"Credencial Vault bloqueada: {exc}") from exc
        except VaultProviderError as exc:
            raise RuntimeError(f"Configuração Vault inválida: {exc}") from exc

    if args.prompt == "terminal":
        return getpass.getpass("Senha Oracle (não será gravada): "), False

    stored_password = keychain_get(args)
    if stored_password is not None:
        return stored_password, False

    password = macos_password_dialog(
        "Primeiro acesso a esta conexão Oracle. Informe a senha uma vez; "
        "após a autenticação bem-sucedida, ela será salva no Keychain deste Mac."
    )
    if not password:
        raise RuntimeError("A senha informada está vazia.")
    return password, True


def connect(args):
    oracledb = load_driver()
    password, save_to_keychain = resolve_credential(args)
    connection = None
    try:
        connection = oracledb.connect(
            user=args.username,
            password=password,
            dsn=dsn(args.host, args.port, args.service),
        )
        if save_to_keychain:
            try:
                keychain_set(args, password)
            except RuntimeError as exc:
                raise RuntimeError(
                    "A autenticação Oracle foi aceita, mas não foi possível "
                    "salvar a credencial no Keychain. A sessão foi encerrada "
                    "antes de executar consultas; verifique o acesso ao Keychain."
                ) from exc
        return oracledb, connection
    except Exception:
        if connection is not None:
            connection.close()
        raise
    finally:
        password = None


def identity(args) -> int:
    if not tcp_check(args.host, args.port):
        print(json.dumps({
            "status": "BLOQUEADO_REDE",
            "host": args.host,
            "port": args.port,
            "mensagem": "A porta não está acessível neste ambiente; não houve tentativa de login.",
        }, ensure_ascii=False, indent=2))
        return 2

    oracledb, connection = connect(args)
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    SYS_CONTEXT('USERENV','SESSION_USER') AS SESSION_USER,
                    SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA,
                    SYS_CONTEXT('USERENV','SERVICE_NAME') AS SERVICE_NAME,
                    SYS_CONTEXT('USERENV','DB_NAME') AS DB_NAME
                FROM DUAL
            """)
            session_user, current_schema, service_name, db_name = cursor.fetchone()

            cursor.execute("""
                SELECT CODEMP, TRIM(RAZAOSOCIAL)
                  FROM TSIEMP
                 ORDER BY CODEMP
            """)
            companies = [
                {"codemp": row[0], "razao_social": row[1]}
                for row in cursor.fetchall()
            ]

        result = {
            "status": "IDENTIDADE_VALIDADA_READ_ONLY",
            "executado_em_utc": datetime.now(timezone.utc).isoformat(),
            "session_user": session_user,
            "current_schema": current_schema,
            "service_name": service_name,
            "db_name": db_name,
            "service_esperado": args.service,
            "service_compativel": str(service_name or "").upper() == args.service.upper(),
            "empresas": companies,
            "dml_executado": False,
            "ddl_executado": False,
        }
        print(json.dumps(result, ensure_ascii=False, indent=2, default=str))
        return 0 if result["service_compativel"] else 3
    finally:
        connection.close()


def self_check(args) -> int:
    oracledb = load_driver()
    result = {
        "status": "AMBIENTE_PYTHON_OK",
        "python": sys.version.split()[0],
        "oracledb": getattr(oracledb, "__version__", "desconhecida"),
        "modo_planejado": "thin",
        "dml_habilitado": False,
        "ddl_habilitado": False,
        "senha_em_arquivo": False,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


def credential_set(args) -> int:
    password = macos_password_dialog(
        "Informe a senha Oracle para armazená-la no Keychain deste Mac."
    )
    if not password:
        raise RuntimeError("A senha informada está vazia.")
    try:
        keychain_set(args, password)
    finally:
        password = None
    print(json.dumps({
        "status": "CREDENCIAL_KEYCHAIN_ATUALIZADA",
        "host": args.host,
        "port": args.port,
        "service": args.service,
        "username": args.username,
        "senha_em_arquivo": False,
    }, ensure_ascii=False, indent=2))
    return 0


def credential_status(args) -> int:
    result = _run_keychain_query(_keychain_command(args, "find-generic-password"))
    if _keychain_item_missing(result):
        status = "CREDENCIAL_KEYCHAIN_AUSENTE"
    elif result.returncode == 0:
        status = "CREDENCIAL_KEYCHAIN_PRESENTE"
    else:
        raise RuntimeError("Não foi possível consultar a credencial no Keychain do macOS.")
    print(json.dumps({
        "status": status,
        "host": args.host,
        "port": args.port,
        "service": args.service,
        "username": args.username,
        "senha_em_arquivo": False,
    }, ensure_ascii=False, indent=2))
    return 0 if status.endswith("PRESENTE") else 1


def credential_delete(args) -> int:
    deleted = keychain_delete(args)
    print(json.dumps({
        "status": "CREDENCIAL_KEYCHAIN_REMOVIDA" if deleted else "CREDENCIAL_KEYCHAIN_JA_AUSENTE",
        "host": args.host,
        "port": args.port,
        "service": args.service,
        "username": args.username,
        "senha_em_arquivo": False,
    }, ensure_ascii=False, indent=2))
    return 0


def vault_check(args) -> int:
    config = config_from_args(args)
    print(json.dumps(vault_metadata(config), ensure_ascii=False, indent=2))
    return 0


def vault_login(args) -> int:
    config = config_from_args(args)
    oidc_login(
        config,
        getattr(args, "vault_role", ""),
        getattr(args, "vault_oidc_port", 8250),
        getattr(args, "vault_oidc_listen_address", "localhost"),
    )
    print(json.dumps({
        "status": "VAULT_OIDC_AUTENTICADO",
        "vault_addr": config.address,
        "namespace": config.namespace or None,
        "token_exibido": False,
        "token_registrado_pelo_executor": False,
    }, ensure_ascii=False, indent=2))
    return 0


def strip_sql_comments(sql: str) -> str:
    sql = re.sub(r"/\*.*?\*/", " ", sql, flags=re.S)
    return re.sub(r"--[^\r\n]*", " ", sql)


def load_jrxml_query(path: Path, include_excluded: bool) -> str:
    content = path.read_text(encoding="utf-8")
    match = re.search(
        r"<queryString>\s*<!\[CDATA\[(.*?)\]\]>\s*</queryString>",
        content,
        flags=re.S | re.I,
    )
    if not match:
        raise SystemExit("Não foi encontrada uma queryString CDATA no JRXML informado.")
    sql = match.group(1).strip()
    if include_excluded:
        expected = "WHERE ORDEM NOT IN (3, 10, 12, 14, 16, 21, 22, 23)"
        if expected not in sql:
            raise SystemExit("Não foi localizado o filtro padrão de indicadores excluídos no JRXML.")
        sql = sql.replace(expected, "WHERE 1 = 1", 1)
    return sql


def query_rows(args, sql: str, source: str) -> int:
    sql = read_read_only_sql_from_text(sql)
    if not tcp_check(args.host, args.port):
        print(json.dumps({
            "status": "BLOQUEADO_REDE",
            "host": args.host,
            "port": args.port,
            "mensagem": "A porta não está acessível neste ambiente; não houve tentativa de login.",
        }, ensure_ascii=False, indent=2))
        return 2

    oracledb, connection = connect(args)
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    SYS_CONTEXT('USERENV','SESSION_USER') AS SESSION_USER,
                    SYS_CONTEXT('USERENV','CURRENT_SCHEMA') AS CURRENT_SCHEMA,
                    SYS_CONTEXT('USERENV','SERVICE_NAME') AS SERVICE_NAME,
                    SYS_CONTEXT('USERENV','DB_NAME') AS DB_NAME
                FROM DUAL
            """)
            session_user, current_schema, service_name, db_name = cursor.fetchone()
            if str(service_name or "").upper() != args.service.upper():
                result = {
                    "status": "IDENTIDADE_INCOMPATIVEL",
                    "session_user": session_user,
                    "current_schema": current_schema,
                    "service_name": service_name,
                    "service_esperado": args.service,
                    "dml_executado": False,
                    "ddl_executado": False,
                }
                print(json.dumps(result, ensure_ascii=False, indent=2, default=str))
                return 3

            cursor.execute(sql)
            columns = [description[0] for description in cursor.description]
            rows = [dict(zip(columns, row)) for row in cursor.fetchall()]

        result = {
            "status": "CONSULTA_READ_ONLY_CONCLUIDA",
            "executado_em_utc": datetime.now(timezone.utc).isoformat(),
            "source": source,
            "session_user": session_user,
            "current_schema": current_schema,
            "service_name": service_name,
            "db_name": db_name,
            "service_esperado": args.service,
            "qtd_linhas": len(rows),
            "colunas": columns,
            "linhas": rows,
            "dml_executado": False,
            "ddl_executado": False,
        }
        print(json.dumps(result, ensure_ascii=False, indent=2, default=str))
        return 0
    finally:
        connection.close()


def read_read_only_sql_from_text(sql: str) -> str:
    without_comments = strip_sql_comments(sql).strip()
    if without_comments.endswith(";"):
        without_comments = without_comments[:-1].rstrip()
    if ";" in without_comments:
        raise SystemExit("Consulta rejeitada: o texto contém mais de uma instrução.")
    if not re.match(r"^(SELECT|WITH)\b", without_comments, flags=re.I):
        raise SystemExit("Consulta rejeitada: somente SELECT/WITH são aceitos neste modo.")
    forbidden = re.search(
        r"\b(INSERT|UPDATE|DELETE|MERGE|ALTER|DROP|TRUNCATE|CREATE|GRANT|REVOKE|COMMIT|ROLLBACK|BEGIN|DECLARE|EXECUTE\s+IMMEDIATE)\b",
        without_comments,
        flags=re.I,
    )
    if forbidden:
        raise SystemExit(f"Consulta rejeitada: comando não permitido ({forbidden.group(1)}).")
    return without_comments


def query(args) -> int:
    path = Path(args.sql_file).expanduser().resolve()
    if not path.is_file():
        raise SystemExit(f"Arquivo SQL não encontrado: {path}")
    return query_rows(args, path.read_text(encoding="utf-8"), str(path))


def query_jrxml(args) -> int:
    path = Path(args.jrxml_file).expanduser().resolve()
    if not path.is_file():
        raise SystemExit(f"Arquivo JRXML não encontrado: {path}")
    sql = load_jrxml_query(path, args.include_excluded)
    source = f"{path} :: queryString"
    if args.include_excluded:
        source += " :: indicadores excluídos incluídos"
    return query_rows(args, sql, source)


def parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Diagnóstico Oracle direto e read-only")
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("self-check", help="verifica Python e driver sem acessar Oracle").set_defaults(func=self_check)

    identity_parser = sub.add_parser("identity", help="valida conexão e identidade Oracle em modo read-only")
    identity_parser.add_argument("--host", required=True)
    identity_parser.add_argument("--port", type=int, default=1521)
    identity_parser.add_argument("--service", required=True)
    identity_parser.add_argument("--username", required=True)
    identity_parser.add_argument(
        "--prompt",
        choices=("macos", "terminal"),
        default="macos",
        help="forma de solicitar a senha; macos abre uma janela oculta (padrão)",
    )
    add_vault_arguments(identity_parser)
    identity_parser.set_defaults(func=identity)

    for command_name, help_text in (
        ("query", "executa um arquivo SELECT/WITH em modo read-only"),
        ("query-jrxml", "executa a queryString de um JRXML em modo read-only"),
    ):
        query_parser = sub.add_parser(command_name, help=help_text)
        query_parser.add_argument("--host", required=True)
        query_parser.add_argument("--port", type=int, default=1521)
        query_parser.add_argument("--service", required=True)
        query_parser.add_argument("--username", required=True)
        query_parser.add_argument(
            "--prompt",
            choices=("macos", "terminal"),
            default="macos",
            help="forma de solicitar a senha; macos abre uma janela oculta (padrão)",
        )
        add_vault_arguments(query_parser)
        if command_name == "query":
            query_parser.add_argument("--sql-file", required=True)
            query_parser.set_defaults(func=query)
        else:
            query_parser.add_argument("--jrxml-file", required=True)
            query_parser.add_argument(
                "--include-excluded",
                action="store_true",
                help="inclui os indicadores que o relatório Jasper normalmente oculta",
            )
            query_parser.set_defaults(func=query_jrxml)

    vault_check_parser = sub.add_parser(
        "vault-check",
        help="valida o segredo KV aprovado sem exibir seus valores",
    )
    add_vault_arguments(vault_check_parser, include_source=False)
    vault_check_parser.set_defaults(func=vault_check)

    vault_login_parser = sub.add_parser(
        "vault-login",
        help="inicia o login OIDC pelo cliente oficial Vault sem exibir o token",
    )
    add_vault_arguments(vault_login_parser, include_source=False)
    vault_login_parser.add_argument(
        "--vault-role",
        default="",
        help="role OIDC, quando exigida pela configuração do Vault",
    )
    vault_login_parser.add_argument(
        "--vault-oidc-port",
        type=int,
        default=8250,
        help="porta local do callback OIDC (padrão: 8250)",
    )
    vault_login_parser.add_argument(
        "--vault-oidc-listen-address",
        default="localhost",
        help="endereço local do callback OIDC (padrão: localhost)",
    )
    vault_login_parser.set_defaults(func=vault_login)

    credential_parser = sub.add_parser(
        "credential",
        help="administra a credencial Oracle no Keychain do macOS",
    )
    credential_sub = credential_parser.add_subparsers(
        dest="credential_command",
        required=True,
    )
    for credential_command, help_text, func in (
        ("set", "solicita e atualiza a senha no Keychain", credential_set),
        ("status", "verifica se existe uma senha no Keychain", credential_status),
        ("delete", "remove a credencial do Keychain", credential_delete),
    ):
        command_parser = credential_sub.add_parser(credential_command, help=help_text)
        command_parser.add_argument("--host", required=True)
        command_parser.add_argument("--port", type=int, default=1521)
        command_parser.add_argument("--service", required=True)
        command_parser.add_argument("--username", required=True)
        command_parser.set_defaults(func=func)
    return parser


def main() -> int:
    args = parser().parse_args()
    try:
        return args.func(args)
    except RuntimeError as exc:
        print(json.dumps({
            "status": "EXECUTOR_BLOQUEADO",
            "mensagem": str(exc),
            "senha_em_arquivo": False,
            "dml_executado": False,
            "ddl_executado": False,
        }, ensure_ascii=False, indent=2))
        return 4


if __name__ == "__main__":
    raise SystemExit(main())
