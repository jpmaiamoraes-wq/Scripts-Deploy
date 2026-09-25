from __future__ import annotations

import argparse
import json
import os
import subprocess
import unittest
from unittest.mock import patch

import vault_provider


def config() -> vault_provider.VaultConfig:
    return vault_provider.VaultConfig(
        address="https://vault.example.invalid",
        namespace="cliente.teste",
        mount="kv",
        path="base/prd",
        cli="vault",
        timeout=5,
    )


class VaultProviderTests(unittest.TestCase):
    def test_oracle_fields_supports_kv_v2_envelope(self) -> None:
        payload = {
            "data": {
                "data": {
                    "hostname": "10.0.0.10",
                    "port": "1521",
                    "servicename": "TESTEPRD",
                    "username": "USUARIO_TESTE",
                    "password": "VALOR_DE_TESTE",
                }
            }
        }
        completed = subprocess.CompletedProcess(
            ["vault"], 0, json.dumps(payload), ""
        )
        with patch.object(vault_provider, "_cli_path", return_value="/usr/bin/vault"), \
             patch("vault_provider.subprocess.run", return_value=completed):
            fields = vault_provider.oracle_fields(config())

        self.assertEqual(fields["host"], "10.0.0.10")
        self.assertEqual(fields["port"], 1521)
        self.assertEqual(fields["service"], "TESTEPRD")
        self.assertEqual(fields["username"], "USUARIO_TESTE")
        self.assertEqual(fields["password"], "VALOR_DE_TESTE")

    def test_metadata_does_not_expose_secret_values(self) -> None:
        payload = {
            "data": {
                "data": {
                    "hostname": "10.0.0.10",
                    "port": 1521,
                    "servicename": "TESTEPRD",
                    "username": "USUARIO_TESTE",
                    "password": "VALOR_DE_TESTE",
                }
            }
        }
        completed = subprocess.CompletedProcess(
            ["vault"], 0, json.dumps(payload), ""
        )
        with patch.object(vault_provider, "_cli_path", return_value="/usr/bin/vault"), \
             patch("vault_provider.subprocess.run", return_value=completed):
            result = vault_provider.metadata(config())

        serialized = json.dumps(result, ensure_ascii=False)
        self.assertNotIn("VALOR_DE_TESTE", serialized)
        self.assertNotIn("USUARIO_TESTE", serialized)
        self.assertEqual(result["status"], "VAULT_SEGREDO_VALIDADO_SEM_EXIBIR_VALORES")
        self.assertEqual(
            result["campos_oracle_detectados"],
            ["host", "password", "port", "service", "username"],
        )

    def test_cli_does_not_receive_vault_token_from_environment(self) -> None:
        completed = subprocess.CompletedProcess(["vault"], 0, '{"data": {}}', "")
        captured: dict[str, object] = {}

        def fake_run(command, *, env, **kwargs):
            captured["command"] = command
            captured["env"] = env
            return completed

        with patch.object(vault_provider, "_cli_path", return_value="/usr/bin/vault"), \
             patch.dict(os.environ, {"VAULT_TOKEN": "TOKEN_DE_TESTE"}), \
             patch("vault_provider.subprocess.run", side_effect=fake_run):
            vault_provider._run_cli(config(), ["status"])

        self.assertNotIn("VAULT_TOKEN", captured["env"])
        self.assertNotIn("TOKEN_DE_TESTE", captured["command"])

    def test_connection_mismatch_blocks_password_use(self) -> None:
        payload = {
            "data": {
                "data": {
                    "hostname": "10.0.0.11",
                    "port": 1521,
                    "servicename": "TESTEPRD",
                    "username": "USUARIO_TESTE",
                    "password": "VALOR_DE_TESTE",
                }
            }
        }
        completed = subprocess.CompletedProcess(
            ["vault"], 0, json.dumps(payload), ""
        )
        args = argparse.Namespace(
            host="10.0.0.10",
            port=1521,
            service="TESTEPRD",
            username="USUARIO_TESTE",
            vault_addr=config().address,
            vault_namespace=config().namespace,
            vault_mount=config().mount,
            vault_path=config().path,
            vault_cli=config().cli,
            vault_timeout=config().timeout,
        )
        with patch.object(vault_provider, "_cli_path", return_value="/usr/bin/vault"), \
             patch("vault_provider.subprocess.run", return_value=completed):
            with self.assertRaises(vault_provider.VaultProviderError):
                vault_provider.password_for_connection(args)


if __name__ == "__main__":
    unittest.main()
