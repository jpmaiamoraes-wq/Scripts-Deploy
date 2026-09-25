import json, tempfile, unittest
from pathlib import Path
import fila_execucao as f

BASE = f.SUITE_ROOT / "Clientes" / "FOCUSFINTAXPRD"
REL = str(BASE.relative_to(f.REPO_ROOT))


class FilaTests(unittest.TestCase):
    def cmd(self, job, auth=None):
        return f.build_command(job, BASE, auth)

    def test_leitura_permitida(self):
        c, out, log = self.cmd({"id": "t_ident_01", "tipo": "identity"})
        self.assertIn("identity", c); self.assertIn("FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR", c); self.assertIsNone(log)

    def test_query_fora_da_suite(self):
        with self.assertRaises(f.JobError):
            self.cmd({"id": "t_q_01", "tipo": "query", "sql_file": "/etc/passwd"})

    def test_campo_extra_recusado(self):
        with self.assertRaises(f.JobError):
            self.cmd({"id": "t_x_01", "tipo": "identity", "host": "1.2.3.4"})

    def test_apply_sem_autorizacao(self):
        with self.assertRaises(f.JobError):
            self.cmd({"id": "t_a_01", "tipo": "batch_apply", "script": "7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql", "execution_id": "X_TESTE_01"})

    def test_reversao_recusada(self):
        with self.assertRaises(f.JobError):
            self.cmd({"id": "t_r_01", "tipo": "batch_apply", "script": REL + "/Artefatos_Revisao/Rollback/29_30_Rollback_FOCUS_MRG_20260923_01.sql", "execution_id": "X_TESTE_02"}, "EXECUTAR FOCUSFINTAXPRD")

    def test_execution_id_reutilizado(self):
        with self.assertRaises(f.JobError):
            self.cmd({"id": "t_a_02", "tipo": "batch_apply", "script": "7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql", "execution_id": "FOCUS_MAS_20260923_150347"}, "EXECUTAR FOCUSFINTAXPRD")

    def test_apply_autorizado_monta_comando(self):
        c, out, log = self.cmd({"id": "t_a_03", "tipo": "batch_apply", "script": "7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql", "execution_id": "X_TESTE_NOVO_99"}, "EXECUTAR FOCUSFINTAXPRD")
        self.assertIn("--preauthorized", c); self.assertTrue(str(log).endswith("X_TESTE_NOVO_99.log"))


if __name__ == "__main__":
    unittest.main()
