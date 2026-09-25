#!/usr/bin/env python3
"""Diagnóstico read-only das colisões das atividades 29 e 30.

O comando mede o resultado da mesma normalização usada pelos scripts de
padronização, identifica grupos que exigem merge e inventaria referências aos
identificadores obsoletos. Nenhuma tabela é criada e nenhum DML/DDL é aceito.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

from oracle_direct import add_vault_arguments, connect, tcp_check


TRANSLATE_FROM = (
    "ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ"
    "áàâãäéèêëíìîïóòôõöúùûüç"
    "ÃãÕõÂâÊêÎîÔôÛû"
)
TRANSLATE_TO = "AAAAAEEEEIIIIOOOOOUUUUCAAAAAEEEEIIIIOOOOOUUUUCAAAOOAAEIIOOUU"
MAX_SAMPLE_ROWS = 100


class PreflightError(RuntimeError):
    pass


def quote_identifier(value: str) -> str:
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_$#]*", value or ""):
        raise PreflightError(f"Identificador Oracle inesperado no catálogo: {value!r}")
    return f'"{value.upper()}"'


def qualified(schema: str, object_name: str) -> str:
    return f"{quote_identifier(schema)}.{quote_identifier(object_name)}"


def norm_expression(column: str) -> str:
    return (
        "REGEXP_REPLACE(TRIM(TRANSLATE(UPPER({column}), '{source}', '{target}')), "
        "' {{2,}}', ' ')"
    ).format(
        column=column,
        source=TRANSLATE_FROM,
        target=TRANSLATE_TO,
    )


def normalized_rows_sql(schema: str, table: str, code_column: str, name_column: str, type_column: str | None) -> str:
    source = [
        f"{quote_identifier(code_column)} AS CODIGO",
        f"{quote_identifier(name_column)} AS NOME",
        norm_expression(quote_identifier(name_column)) + " AS NORM",
    ]
    partition = "NORM"
    if type_column:
        source.insert(1, f"{quote_identifier(type_column)} AS TIPO")
        partition = "TIPO, NORM"
    return (
        "SELECT CODIGO, NOME, "
        + ("TIPO, " if type_column else "")
        + "NORM, COUNT(*) OVER (PARTITION BY "
        + partition
        + ") AS QTD_GRUPO, MIN(CODIGO) OVER (PARTITION BY "
        + partition
        + ") AS CODIGO_MANTIDO FROM (SELECT "
        + ", ".join(source)
        + f" FROM {qualified(schema, table)})"
    )


def collision_summary_sql(schema: str, table: str, code_column: str, name_column: str, type_column: str | None) -> str:
    rows = normalized_rows_sql(schema, table, code_column, name_column, type_column)
    group_key = "NORM"
    if type_column:
        group_key = (
            "NVL(TO_CHAR(LENGTH(TIPO)), '-1') || ':' || NVL(TIPO, '') || ':' || "
            "NVL(TO_CHAR(LENGTH(NORM)), '-1') || ':' || NVL(NORM, '')"
        )
    return f"""
        SELECT
            COUNT(*) AS TOTAL_REGISTROS,
            NVL(SUM(CASE WHEN NOME <> NORM AND QTD_GRUPO = 1 THEN 1 ELSE 0 END), 0) AS ALTERACOES_UNICAS,
            NVL(SUM(CASE WHEN QTD_GRUPO > 1 THEN 1 ELSE 0 END), 0) AS REGISTROS_EM_COLISAO,
            COUNT(DISTINCT CASE WHEN QTD_GRUPO > 1 THEN {group_key} END) AS GRUPOS_COLISAO,
            NVL(SUM(CASE WHEN NOME <> NORM AND QTD_GRUPO > 1 THEN 1 ELSE 0 END), 0) AS COLISOES_COM_ALTERACAO
        FROM ({rows})
    """


def collision_sample_sql(schema: str, table: str, code_column: str, name_column: str, type_column: str | None) -> str:
    rows = normalized_rows_sql(schema, table, code_column, name_column, type_column)
    projection = "TIPO, " if type_column else ""
    grouping = "TIPO, NORM" if type_column else "NORM"
    return f"""
        SELECT {projection} NORM, COUNT(*) AS QTD, MIN(CODIGO) AS CODIGO_MENOR,
               MAX(CODIGO) AS CODIGO_MAIOR
        FROM ({rows})
        GROUP BY {grouping}
        HAVING COUNT(*) > 1
        ORDER BY QTD DESC, {grouping}
    """


def obsolete_codes_sql(schema: str, table: str, code_column: str, name_column: str, type_column: str | None) -> str:
    rows = normalized_rows_sql(schema, table, code_column, name_column, type_column)
    return f"SELECT CODIGO AS CODIGO_OBSOLETO FROM ({rows}) WHERE QTD_GRUPO > 1 AND CODIGO <> CODIGO_MANTIDO"


def fetch_one(cursor, sql: str, binds: dict[str, object] | None = None) -> tuple[object, ...]:
    cursor.execute(sql, binds or {})
    row = cursor.fetchone()
    if row is None:
        raise PreflightError("Consulta read-only não retornou a linha esperada.")
    return tuple(row)


def fetch_all(cursor, sql: str, binds: dict[str, object] | None = None) -> list[tuple[object, ...]]:
    cursor.execute(sql, binds or {})
    return [tuple(row) for row in cursor.fetchall()]


def summary(cursor, schema: str, table: str, code_column: str, name_column: str, type_column: str | None) -> dict[str, object]:
    row = fetch_one(cursor, collision_summary_sql(schema, table, code_column, name_column, type_column))
    sample_rows = fetch_all(cursor, collision_sample_sql(schema, table, code_column, name_column, type_column))
    sample: list[dict[str, object]] = []
    for item in sample_rows[:MAX_SAMPLE_ROWS]:
        offset = 0
        record: dict[str, object] = {}
        if type_column:
            record["tipo"] = item[offset]
            offset += 1
        record.update({
            "norm": item[offset],
            "qtd": item[offset + 1],
            "codigo_menor": item[offset + 2],
            "codigo_maior": item[offset + 3],
        })
        sample.append(record)
    return {
        "tabela": table,
        "coluna_codigo": code_column,
        "coluna_descricao": name_column,
        "coluna_particao": type_column,
        "total_registros": int(row[0] or 0),
        "alteracoes_unicas": int(row[1] or 0),
        "registros_em_colisao": int(row[2] or 0),
        "grupos_colisao": int(row[3] or 0),
        "colisoes_com_alteracao": int(row[4] or 0),
        "amostra_grupos": sample,
        "amostra_limitada": len(sample_rows) > MAX_SAMPLE_ROWS,
    }


def dependency_catalog(cursor, schema: str) -> list[dict[str, object]]:
    rows = fetch_all(cursor, """
        SELECT DISTINCT c.TABLE_NAME, c.COLUMN_NAME
          FROM ALL_TAB_COLUMNS c
          JOIN ALL_TABLES t
            ON t.OWNER = c.OWNER AND t.TABLE_NAME = c.TABLE_NAME
         WHERE c.OWNER = :owner
           AND c.COLUMN_NAME IN ('CODBAI', 'CODEND')
           AND c.TABLE_NAME NOT IN ('TSIBAI', 'TSIEND')
           AND c.TABLE_NAME NOT LIKE 'BKP_RMD_%'
           AND c.TABLE_NAME NOT LIKE 'RMD_%'
         ORDER BY c.TABLE_NAME, c.COLUMN_NAME
    """, {"owner": schema})
    dependencies = [
        {
            "origem": "COLUNA_CONVENCIONAL",
            "tabela": row[0],
            "coluna": row[1],
            "tabela_referenciada": "TSIBAI" if row[1] == "CODBAI" else "TSIEND",
            "constraint_name": None,
            "colunas_na_constraint": None,
        }
        for row in rows
    ]
    fk_rows = fetch_all(cursor, """
        SELECT c.TABLE_NAME, c.CONSTRAINT_NAME, cc.COLUMN_NAME,
               p.TABLE_NAME AS TABELA_REFERENCIADA,
               COUNT(*) OVER (PARTITION BY c.OWNER, c.CONSTRAINT_NAME) AS QTD_COLUNAS
          FROM ALL_CONSTRAINTS c
          JOIN ALL_CONS_COLUMNS cc
            ON cc.OWNER = c.OWNER
           AND cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
           AND cc.TABLE_NAME = c.TABLE_NAME
          JOIN ALL_CONSTRAINTS p
            ON p.OWNER = c.R_OWNER
           AND p.CONSTRAINT_NAME = c.R_CONSTRAINT_NAME
         WHERE c.OWNER = :owner
           AND c.CONSTRAINT_TYPE = 'R'
           AND p.OWNER = :owner
           AND p.TABLE_NAME IN ('TSIBAI', 'TSIEND')
           AND cc.COLUMN_NAME NOT IN ('CODBAI', 'CODEND')
           AND c.TABLE_NAME NOT IN ('TSIBAI', 'TSIEND')
           AND c.TABLE_NAME NOT LIKE 'BKP_RMD_%'
           AND c.TABLE_NAME NOT LIKE 'RMD_%'
         ORDER BY c.TABLE_NAME, c.CONSTRAINT_NAME, cc.POSITION
    """, {"owner": schema})
    dependencies.extend({
        "origem": "CHAVE_ESTRANGEIRA",
        "tabela": row[0],
        "coluna": row[2],
        "tabela_referenciada": row[3],
        "constraint_name": row[1],
        "colunas_na_constraint": int(row[4] or 0),
    } for row in fk_rows)
    return dependencies


def count_dependency(cursor, schema: str, dependency: dict[str, object]) -> int:
    target_table = str(dependency["tabela_referenciada"])
    target_code = "CODBAI" if target_table == "TSIBAI" else "CODEND"
    target_name = "NOMEBAI" if target_table == "TSIBAI" else "NOMEEND"
    target_type = None if target_table == "TSIBAI" else "TIPO"
    obsolete = obsolete_codes_sql(schema, target_table, target_code, target_name, target_type)
    child = qualified(schema, str(dependency["tabela"]))
    column = quote_identifier(str(dependency["coluna"]))
    row = fetch_one(cursor, f"""
        SELECT COUNT(*)
          FROM {child} t
         WHERE EXISTS (
               SELECT 1
                 FROM ({obsolete}) o
                WHERE t.{column} = o.CODIGO_OBSOLETO
         )
    """)
    return int(row[0] or 0)


def identity(cursor, expected_service: str) -> dict[str, object]:
    row = fetch_one(cursor, """
        SELECT SYS_CONTEXT('USERENV','SESSION_USER'),
               SYS_CONTEXT('USERENV','CURRENT_SCHEMA'),
               SYS_CONTEXT('USERENV','SERVICE_NAME'),
               SYS_CONTEXT('USERENV','DB_NAME')
          FROM DUAL
    """)
    if str(row[2] or "").upper() != expected_service.upper():
        raise PreflightError(
            f"SERVICE_NAME incompatível: atual={row[2]!r}, esperado={expected_service!r}"
        )
    return {
        "session_user": row[0],
        "current_schema": row[1],
        "service_name": row[2],
        "db_name": row[3],
    }


def run(args: argparse.Namespace) -> tuple[int, dict[str, object]]:
    if not tcp_check(args.host, args.port):
        return 2, {
            "status": "PREFLIGHT_29_30_BLOQUEADO_REDE",
            "host": args.host,
            "port": args.port,
            "service_esperado": args.service,
            "mensagem": "A porta Oracle não está acessível; nenhum login foi tentado.",
            "dml_executado": False,
            "ddl_executado": False,
        }

    oracledb, connection = connect(args)
    try:
        cursor = connection.cursor()
        session = identity(cursor, args.service)
        schema = str(session["current_schema"] or session["session_user"]).upper()
        bairros = summary(cursor, schema, "TSIBAI", "CODBAI", "NOMEBAI", None)
        enderecos = summary(cursor, schema, "TSIEND", "CODEND", "NOMEEND", "TIPO")
        dependencies = dependency_catalog(cursor, schema)
        dependency_errors: list[dict[str, object]] = []
        for dependency in dependencies:
            try:
                dependency["linhas_referenciando_obsoletos"] = count_dependency(cursor, schema, dependency)
            except Exception as exc:
                dependency["linhas_referenciando_obsoletos"] = None
                dependency_errors.append({
                    "tabela": dependency["tabela"],
                    "coluna": dependency["coluna"],
                    "mensagem": f"{type(exc).__name__}: {exc}",
                })

        collision_exists = bool(
            bairros["grupos_colisao"] or enderecos["grupos_colisao"]
        )
        dependent_rows = sum(
            int(item["linhas_referenciando_obsoletos"] or 0)
            for item in dependencies
            if item["linhas_referenciando_obsoletos"] is not None
        )
        warnings: list[dict[str, object]] = []
        if collision_exists:
            warnings.append({
                "codigo": "MERGE_ANTIFRAGIL_NECESSARIO",
                "mensagem": "Há colisões após a normalização; não executar exclusão genérica. Revisar mapa e usar a fase antifrágil.",
            })
        if dependent_rows:
            warnings.append({
                "codigo": "REFERENCIAS_A_CODIGOS_OBSOLETOS",
                "mensagem": f"Foram encontradas {dependent_rows} referências a identificadores candidatos à substituição.",
            })
        if any(int(item["colunas_na_constraint"] or 0) > 1 for item in dependencies):
            warnings.append({
                "codigo": "FK_COMPOSTA",
                "mensagem": "Há chave(s) estrangeira(s) composta(s); a revisão do mapa deve considerar a constraint completa.",
            })

        if dependency_errors:
            status = "PREFLIGHT_29_30_BLOQUEADO"
            decision = "DIAGNOSTICO_INCOMPLETO"
        elif collision_exists:
            status = "PREFLIGHT_29_30_CONCLUIDO"
            decision = "MERGE_ANTIFRAGIL_OBRIGATORIO"
        elif bairros["alteracoes_unicas"] or enderecos["alteracoes_unicas"]:
            status = "PREFLIGHT_29_30_CONCLUIDO"
            decision = "PADRONIZACAO_UNICA_SEM_COLISOES"
        else:
            status = "PREFLIGHT_29_30_CONCLUIDO"
            decision = "SEM_CANDIDATOS_DE_ALTERACAO"

        result = {
            "status": status,
            "executado_em_utc": datetime.now(timezone.utc).isoformat(),
            "identidade": session,
            "regra_normalizacao": "PADRAO_ATIVIDADES_29_30_V1",
            "decisao": decision,
            "bairros": bairros,
            "enderecos": enderecos,
            "dependencias": dependencies,
            "avisos": warnings,
            "erros_diagnostico": dependency_errors,
            "dml_executado": False,
            "ddl_executado": False,
        }
        return (0 if status == "PREFLIGHT_29_30_CONCLUIDO" else 4), result
    finally:
        connection.close()


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description="Preflight read-only das colisões das atividades 29 e 30")
    root.add_argument("--host", required=True)
    root.add_argument("--port", type=int, default=1521)
    root.add_argument("--service", required=True)
    root.add_argument("--username", required=True)
    root.add_argument("--prompt", choices=("macos", "terminal"), default="macos")
    root.add_argument("--output", help="salva o JSON de evidência neste caminho")
    add_vault_arguments(root)
    return root


def main() -> int:
    try:
        args = parser().parse_args()
        code, result = run(args)
    except (PreflightError, RuntimeError, OSError, ValueError) as exc:
        code = 4
        result = {
            "status": "PREFLIGHT_29_30_BLOQUEADO",
            "mensagem": str(exc),
            "dml_executado": False,
            "ddl_executado": False,
        }
    print(json.dumps(result, ensure_ascii=False, indent=2, default=str))
    if args.output:
        output = Path(args.output).expanduser().resolve()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(result, ensure_ascii=False, indent=2, default=str) + "\n", encoding="utf-8")
    return code


if __name__ == "__main__":
    raise SystemExit(main())
