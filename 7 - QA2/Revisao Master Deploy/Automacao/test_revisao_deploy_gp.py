import unittest
import revisao_deploy as r


class ParseGpTests(unittest.TestCase):
    def test_formatos_aceitos(self):
        self.assertEqual(r.parse_gp("Marcelo Borel <marcelo.borel@sankhya.com.br>"), ("Marcelo Borel", "marcelo.borel@sankhya.com.br"))
        self.assertEqual(r.parse_gp("Marcelo Borel (Marcelo.Borel@sankhya.com.br)"), ("Marcelo Borel", "marcelo.borel@sankhya.com.br"))
        self.assertEqual(r.parse_gp("marcelo.borel@sankhya.com.br"), (None, "marcelo.borel@sankhya.com.br"))
        self.assertEqual(r.parse_gp("Marcelo Borel"), ("Marcelo Borel", None))

    def test_formatos_invalidos(self):
        for v in ("", "   ", "a@b", "Nome <a@b>"):
            with self.assertRaises(ValueError):
                r.parse_gp(v)


class AssistenteTests(unittest.TestCase):
    GP = "gp@sankhya.com.br"

    def test_normalizar(self):
        self.assertEqual(r.normalizar_assistente(" 1 "), "1")
        self.assertEqual(r.normalizar_assistente("2"), "2")
        self.assertIsNone(r.normalizar_assistente(None))
        self.assertIsNone(r.normalizar_assistente(""))
        for v in ("3", "0", "ana", "12"):
            with self.assertRaises(ValueError):
                r.normalizar_assistente(v)

    def test_somente_duas_assistentes(self):
        self.assertEqual(r.ASSISTENTES["1"], ("Ana Paula Rodrigues", "ana.rodrigues@sankhya.com.br"))
        self.assertEqual(r.ASSISTENTES["2"], ("Gabriela Stabile Lemos", "gabriela.lemos@sankhya.com.br"))
        self.assertEqual(set(r.ASSISTENTES), {"1", "2"})

    def test_ana_somente_ela_sem_gp(self):
        plano = r.plano_destinatarios("1", self.GP)
        self.assertEqual(plano["status"], "DEFINIDO")
        self.assertEqual(plano["para"], ["ana.rodrigues@sankhya.com.br"])
        self.assertEqual(plano["cc"], [])

    def test_gabriela_para_gp_com_ela_em_copia(self):
        plano = r.plano_destinatarios("2", self.GP)
        self.assertEqual(plano["status"], "DEFINIDO")
        self.assertEqual(plano["para"], [self.GP])
        self.assertEqual(plano["cc"], ["gabriela.lemos@sankhya.com.br"])

    def test_gabriela_sem_email_do_gp_fica_pendente(self):
        plano = r.plano_destinatarios("2", None)
        self.assertEqual(plano["status"], "GP_EMAIL_PENDENTE")
        self.assertEqual(plano["para"], [])

    def test_sem_assistente_fica_pendente(self):
        self.assertEqual(r.plano_destinatarios(None, self.GP)["status"], "ASSISTENTE_PENDENTE")

    def test_pergunta_terminal(self):
        respostas = iter(["x", "2"])
        self.assertEqual(r.perguntar_assistente(lambda _: next(respostas)), "2")
        with self.assertRaises(ValueError):
            r.perguntar_assistente(lambda _: "9")

    def test_argumento_cli(self):
        args = r.parser().parse_args(["prepare", "--client", "X", "--hostname", "10.0.0.1", "--service", "A.B",
                                      "--username", "u", "--gp", self.GP, "--assistente", "1"])
        self.assertEqual(args.assistente, "1")


if __name__ == "__main__":
    unittest.main()
