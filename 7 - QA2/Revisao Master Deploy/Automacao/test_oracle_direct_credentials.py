from __future__ import annotations

import unittest
from types import SimpleNamespace
from unittest.mock import Mock, patch

import oracle_direct


class OracleDirectCredentialTests(unittest.TestCase):
    def setUp(self) -> None:
        self.args = SimpleNamespace(
            host="db.example.test",
            port=1521,
            service="SVC",
            username="TEST_USER",
            prompt="macos",
            credential_source="keychain",
        )
        self.connection = Mock()
        self.oracle = SimpleNamespace(connect=Mock(return_value=self.connection))

    def test_first_successful_connection_saves_and_later_connection_reuses(self) -> None:
        keychain: dict[str, str | None] = {"password": None}

        def read_keychain(_args) -> str | None:
            return keychain["password"]

        def write_keychain(_args, password: str) -> None:
            keychain["password"] = password

        with (
            patch.object(oracle_direct, "load_driver", return_value=self.oracle),
            patch.object(oracle_direct, "keychain_get", side_effect=read_keychain),
            patch.object(oracle_direct, "macos_password_dialog", return_value="test-only-password") as prompt,
            patch.object(oracle_direct, "keychain_set", side_effect=write_keychain) as save,
        ):
            oracle_direct.connect(self.args)
            oracle_direct.connect(self.args)

        prompt.assert_called_once()
        save.assert_called_once_with(self.args, "test-only-password")
        self.assertEqual(self.oracle.connect.call_count, 2)
        self.assertEqual(
            [call.kwargs["password"] for call in self.oracle.connect.call_args_list],
            ["test-only-password", "test-only-password"],
        )

    def test_failed_oracle_authentication_does_not_save_password(self) -> None:
        self.oracle.connect.side_effect = RuntimeError("ORA-01017")

        with (
            patch.object(oracle_direct, "load_driver", return_value=self.oracle),
            patch.object(oracle_direct, "keychain_get", return_value=None),
            patch.object(oracle_direct, "macos_password_dialog", return_value="test-only-password") as prompt,
            patch.object(oracle_direct, "keychain_set") as save,
        ):
            with self.assertRaisesRegex(RuntimeError, "ORA-01017"):
                oracle_direct.connect(self.args)

        prompt.assert_called_once()
        save.assert_not_called()

    def test_keychain_write_failure_closes_session_before_query(self) -> None:
        with (
            patch.object(oracle_direct, "load_driver", return_value=self.oracle),
            patch.object(oracle_direct, "keychain_get", return_value=None),
            patch.object(oracle_direct, "macos_password_dialog", return_value="test-only-password"),
            patch.object(oracle_direct, "keychain_set", side_effect=RuntimeError("write denied")),
        ):
            with self.assertRaisesRegex(RuntimeError, "sessão foi encerrada"):
                oracle_direct.connect(self.args)

        self.connection.close.assert_called_once()

    def test_terminal_prompt_does_not_save_to_keychain(self) -> None:
        self.args.prompt = "terminal"

        with (
            patch.object(oracle_direct, "load_driver", return_value=self.oracle),
            patch.object(oracle_direct, "getpass") as getpass,
            patch.object(oracle_direct, "keychain_set") as save,
        ):
            getpass.getpass.return_value = "test-only-password"
            oracle_direct.connect(self.args)

        getpass.getpass.assert_called_once()
        save.assert_not_called()

    def test_vault_password_is_not_copied_to_keychain(self) -> None:
        self.args.credential_source = "vault"

        with (
            patch.object(oracle_direct, "load_driver", return_value=self.oracle),
            patch.object(oracle_direct, "password_for_connection", return_value="vault-test-password"),
            patch.object(oracle_direct, "keychain_get") as read_keychain,
            patch.object(oracle_direct, "keychain_set") as save,
        ):
            oracle_direct.connect(self.args)

        read_keychain.assert_not_called()
        save.assert_not_called()


if __name__ == "__main__":
    unittest.main()
