from __future__ import annotations

import unittest
from pathlib import Path

import oracle_29_30_preflight as preflight


class Oracle2930PreflightTests(unittest.TestCase):
    def test_normalization_expression_matches_rule_shape(self) -> None:
        expression = preflight.norm_expression('"NOMEBAI"')
        self.assertIn("TRANSLATE(UPPER(\"NOMEBAI\")", expression)
        self.assertIn("' {2,}'", expression)

    def test_summary_sql_is_read_only(self) -> None:
        sql = preflight.collision_summary_sql("SANKHYA", "TSIBAI", "CODBAI", "NOMEBAI", None)
        upper = sql.upper()
        self.assertIn("SELECT", upper)
        self.assertIn("TSIBAI", upper)
        self.assertNotRegex(upper, r"\b(INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER|DROP)\b")

    def test_address_rule_partitions_by_type(self) -> None:
        sql = preflight.collision_summary_sql("SANKHYA", "TSIEND", "CODEND", "NOMEEND", "TIPO")
        self.assertIn("PARTITION BY TIPO, NORM", sql)
        self.assertIn("LENGTH(TIPO)", sql)
        self.assertIn("LENGTH(NORM)", sql)
        self.assertIn("COUNT(DISTINCT CASE WHEN QTD_GRUPO > 1 THEN", sql)

    def test_neighborhood_collision_groups_do_not_add_a_type_partition(self) -> None:
        sql = preflight.collision_summary_sql("SANKHYA", "TSIBAI", "CODBAI", "NOMEBAI", None)
        self.assertIn("COUNT(DISTINCT CASE WHEN QTD_GRUPO > 1 THEN NORM END)", sql)
        self.assertNotIn("LENGTH(TIPO)", sql)

    def test_identifier_injection_is_rejected(self) -> None:
        with self.assertRaises(preflight.PreflightError):
            preflight.qualified("SANKHYA", "TSIBAI; DROP TABLE X")

    def test_obsolete_query_keeps_only_noncanonical_collision_rows(self) -> None:
        sql = preflight.obsolete_codes_sql("SANKHYA", "TSIBAI", "CODBAI", "NOMEBAI", None)
        self.assertIn("QTD_GRUPO > 1", sql)
        self.assertIn("CODIGO <> CODIGO_MANTIDO", sql)

    def test_merge_uses_same_normalization_tables(self) -> None:
        merge = (
            Path(__file__).resolve().parents[1]
            / "29_30_Merge_Antifragil.sql"
        ).read_text(encoding="utf-8")
        self.assertIn(preflight.TRANSLATE_FROM, merge)
        self.assertIn(preflight.TRANSLATE_TO, merge)


if __name__ == "__main__":
    unittest.main()
