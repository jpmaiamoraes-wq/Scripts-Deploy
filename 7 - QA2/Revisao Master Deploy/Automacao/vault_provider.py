#!/usr/bin/env python3
"""Leitura controlada de credenciais Oracle a partir do HashiCorp Vault.

O módulo usa somente o cliente oficial ``vault`` instalado localmente. A
autenticação OIDC e o token ficam sob responsabilidade do próprio cliente;
este módulo nunca recebe, imprime, registra ou persiste token. O segredo KV é
lido em JSON, validado em memória e reduzido à senha Oracle necessária para a
conexão.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
from dataclasses import dataclass, replace
from typing import Any


DEFAULT_VAULT_ADDR = "https://vault-external.sankhyacloud.com.br"
DEFAULT_TIMEOUT_SECONDS = 30.0
DEFAULT_OIDC_TIMEOUT_SECONDS = 300.0
DEFAULT_OIDC_PORT = 8250


class VaultProviderError(RuntimeError):
    """Falha segura ao localizar, autenticar ou validar um segredo Vault."""


class VaultNotConfigured(VaultProviderError):
    """O comando não recebeu namespace/mount/path suficientes para o Vault."""


class VaultCliUnavailable(VaultProviderError):
    """O cliente oficial do Vault não está disponível no PATH informado."""


@dataclass(frozen=True)
class VaultConfig:
    address: str
    namespace: str
    mount: str
    path: str
    cli: str
    timeout: float

    @property
    def configured(self) -> bool:
        return bool(self.mount and self.path)


FIELD_ALIASES: dict[str, tuple[str, ...]] = {
    "host": ("hostname", "host"),
    "port": ("port",),
    "service": ("servicename", "service_name", "service"),
    "username": ("username", "user"),
    "password": ("password", "senha"),
}


def _arg_or_env(args: Any, attribute: str, *environment_names: str) -> str:
    value = getattr(args, attribute, None)
    if value is not None and str(value).strip():
        return str(value).strip()
    for name in environment_names:
        value = os.environ.get(name)
        if value and value.strip():
            return value.strip()
    return ""


def config_from_args(args: Any) -> VaultConfig:
    timeout_value = getattr(args, "vault_timeout", DEFAULT_TIMEOUT_SECONDS)
    try:
        timeout = float(timeout_value)
    except (TypeError, ValueError) as exc:
        raise VaultProviderError("Timeout do Vault inválido.") from exc
    if timeout <= 0 or timeout > 300:
        raise VaultProviderError("Timeout do Vault deve estar entre 0 e 300 segundos.")
    return VaultConfig(
        address=_arg_or_env(args, "vault_addr", "VAULT_ADDR") or DEFAULT_VAULT_ADDR,
        namespace=_arg_or_env(args, "vault_namespace", "SANKHYA_VAULT_NAMESPACE"),
        mount=_arg_or_env(args, "vault_mount", "SANKHYA_VAULT_MOUNT"),
        path=_arg_or_env(args, "vault_path", "SANKHYA_VAULT_PATH"),
        cli=_arg_or_env(args, "vault_cli", "SANKHYA_VAULT_CLI") or "vault",
        timeout=timeout,
    )


def add_vault_arguments(parser, *, include_source: bool = True) -> None:
    """Adiciona apenas configuração não sensível do provedor Vault."""
    if include_source:
        parser.add_argument(
            "--credential-source",
            choices=("auto", "keychain", "vault"),
            default="auto",
            help=(
                "fonte da credencial; auto tenta Vault configurado e usa "
                "Keychain como fallback (padrão)"
            ),
        )
    parser.add_argument(
        "--vault-addr",
        help="endereço do Vault (também pode ser VAULT_ADDR)",
    )
    parser.add_argument(
        "--vault-namespace",
        help="namespace do Vault, por exemplo francisco.junior",
    )
    parser.add_argument(
        "--vault-mount",
        help="mount do segredo KV, por exemplo kv",
    )
    parser.add_argument(
        "--vault-path",
        help="caminho do segredo, por exemplo solidamerica/prd",
    )
    parser.add_argument(
        "--vault-cli",
        help="caminho ou nome do cliente oficial vault (padrão: vault)",
    )
    parser.add_argument(
        "--vault-timeout",
        type=float,
        default=DEFAULT_TIMEOUT_SECONDS,
        help="timeout das chamadas ao cliente Vault, em segundos",
    )


def _cli_path(config: VaultConfig) -> str:
    path = shutil.which(config.cli)
    if path:
        return path
    if os.path.isfile(config.cli) and os.access(config.cli, os.X_OK):
        return config.cli
    raise VaultCliUnavailable(
        "Cliente oficial do Vault não encontrado. Instale-o e autentique via OIDC "
        "antes de usar --credential-source vault."
    )


def _base_environment(config: VaultConfig) -> dict[str, str]:
    environment = os.environ.copy()
    # Nunca aceitar VAULT_TOKEN vindo do ambiente do processo. O token deve ser
    # administrado pelo mecanismo padrão do cliente Vault, fora deste executor.
    environment.pop("VAULT_TOKEN", None)
    environment["VAULT_ADDR"] = config.address
    return environment


def _run_cli(config: VaultConfig, arguments: list[str]) -> subprocess.CompletedProcess[str]:
    cli = _cli_path(config)
    try:
        return subprocess.run(
            [cli, *arguments],
            env=_base_environment(config),
            capture_output=True,
            text=True,
            check=False,
            timeout=config.timeout,
        )
    except subprocess.TimeoutExpired as exc:
        raise VaultProviderError("O cliente Vault excedeu o tempo limite.") from exc
    except OSError as exc:
        raise VaultProviderError("Não foi possível executar o cliente Vault.") from exc


def _namespace_arguments(config: VaultConfig) -> list[str]:
    if config.namespace:
        return [f"-namespace={config.namespace}"]
    return []


def read_secret(config: VaultConfig) -> dict[str, Any]:
    if not config.configured:
        raise VaultNotConfigured(
            "Vault requer --vault-mount e --vault-path; nenhum segredo foi consultado."
        )
    result = _run_cli(
        config,
        [
            "kv",
            "get",
            "-format=json",
            *_namespace_arguments(config),
            f"-mount={config.mount}",
            config.path,
        ],
    )
    if result.returncode != 0:
        # Não propagar stdout/stderr: uma mensagem de erro do CLI pode conter
        # detalhes de autenticação, caminhos locais ou dados indevidos.
        raise VaultProviderError(
            "O Vault recusou a leitura ou a sessão OIDC não está autenticada "
            f"(código {result.returncode})."
        )
    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise VaultProviderError("O Vault retornou uma resposta JSON inválida.") from exc

    outer_data = payload.get("data") if isinstance(payload, dict) else None
    if not isinstance(outer_data, dict):
        raise VaultProviderError("O segredo Vault não possui o envelope esperado.")
    secret_data = outer_data.get("data", outer_data)
    if not isinstance(secret_data, dict):
        raise VaultProviderError("O segredo Vault não possui dados estruturados.")
    return secret_data


def _lookup(data: dict[str, Any], logical_name: str) -> Any:
    normalized = {str(key).strip().lower(): value for key, value in data.items()}
    for alias in FIELD_ALIASES[logical_name]:
        if alias in normalized:
            return normalized[alias]
    raise VaultProviderError(
        f"O segredo Vault não possui o campo obrigatório para {logical_name}."
    )


def oracle_fields(config: VaultConfig) -> dict[str, Any]:
    data = read_secret(config)
    fields = {name: _lookup(data, name) for name in FIELD_ALIASES}
    for name in ("host", "service", "username", "password"):
        if fields[name] is None or not str(fields[name]).strip():
            raise VaultProviderError(f"O campo {name} do segredo Vault está vazio.")
    try:
        port = int(fields["port"])
    except (TypeError, ValueError) as exc:
        raise VaultProviderError("O campo port do segredo Vault não é numérico.") from exc
    if not 1 <= port <= 65535:
        raise VaultProviderError("O campo port do segredo Vault está fora do intervalo válido.")
    fields["port"] = port
    return fields


def password_for_connection(args) -> str:
    config = config_from_args(args)
    fields = oracle_fields(config)

    expected = {
        "host": str(args.host).strip().lower(),
        "port": int(args.port),
        "service": str(args.service).strip().upper(),
        "username": str(args.username).strip().upper(),
    }
    actual = {
        "host": str(fields["host"]).strip().lower(),
        "port": fields["port"],
        "service": str(fields["service"]).strip().upper(),
        "username": str(fields["username"]).strip().upper(),
    }
    for field in expected:
        if actual[field] != expected[field]:
            raise VaultProviderError(
                f"O campo {field} do Vault não corresponde à conexão informada; "
                "login Oracle bloqueado."
            )
    return str(fields["password"])


def metadata(config: VaultConfig) -> dict[str, Any]:
    data = read_secret(config)
    normalized = {str(key).strip().lower() for key in data}
    fields = sorted(
        logical_name
        for logical_name, aliases in FIELD_ALIASES.items()
        if any(alias in normalized for alias in aliases)
    )
    return {
        "status": "VAULT_SEGREDO_VALIDADO_SEM_EXIBIR_VALORES",
        "vault_addr": config.address,
        "namespace": config.namespace or None,
        "mount": config.mount,
        "path": config.path,
        "campos_oracle_detectados": fields,
        "senha_exibida": False,
        "senha_em_arquivo_do_projeto": False,
    }


def oidc_login(
    config: VaultConfig,
    role: str = "",
    port: int = DEFAULT_OIDC_PORT,
    listen_address: str = "localhost",
) -> None:
    if not config.address:
        raise VaultProviderError("Endereço do Vault não informado.")
    if not 1 <= port <= 65535:
        raise VaultProviderError("Porta OIDC inválida.")
    if not listen_address.strip():
        raise VaultProviderError("Endereço local de escuta OIDC inválido.")
    arguments = [
        "login",
        "-method=oidc",
        "-format=json",
        f"port={port}",
        f"listenaddress={listen_address.strip()}",
    ]
    arguments.extend(_namespace_arguments(config))
    if role.strip():
        arguments.append(f"-role={role.strip()}")
    # O login OIDC depende de uma interação no navegador e pode ultrapassar o
    # timeout curto usado para leituras KV. Nunca interromper uma autenticação
    # válida por expiração prematura do processo local.
    login_config = replace(
        config,
        timeout=max(config.timeout, DEFAULT_OIDC_TIMEOUT_SECONDS),
    )
    result = _run_cli(login_config, arguments)
    if result.returncode != 0:
        raise VaultProviderError(
            "O login OIDC no Vault não foi concluído; nenhum token foi exibido ou registrado."
        )
