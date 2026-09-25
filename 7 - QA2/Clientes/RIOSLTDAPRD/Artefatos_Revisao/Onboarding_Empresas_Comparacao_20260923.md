# Comparação de empresas do onboarding — RIOSLTDAPRD

status: CONCLUIDA_READ_ONLY_COM_DIVERGENCIA_NOMINAL

## Fonte

- Portal: `Onboarding Deploy — Sankhya`
- Registro: `RIO'S DISTRIBUIDORA DE AGUA E BEBIDAS LTDA`
- CNPJ exibido: `58.364.248/0001-11`
- Situação: `Concluído`
- Fonte primária: registro mais recente exibido no portal em `2026-09-23`.

## Comparação

| CNPJ normalizado | Onboarding | Oracle CODEMP | Oracle razão social | Resultado |
|---|---|---:|---|---|
| `58364248000111` | RIO'S DISTRIBUIDORA DE AGUA E BEBIDAS LTDA | 1 | RIO'S DISTRIBUIDORA DE AGUA E BEBIDAS LT | Localizado |

- CNPJs do onboarding localizados no Oracle: `1`.
- CNPJs do onboarding ausentes no Oracle: `0`.
- CNPJs adicionais na base fora do onboarding exibido: `0`.
- Divergência nominal: a razão social do Oracle está abreviada/truncada com `LT`; o CNPJ confirma a correspondência segura.
- Nenhuma empresa foi incluída, removida ou alterada.

## Evidência Oracle

- Consulta: `Clientes/RIOSLTDAPRD/Onboarding_Empresas_ReadOnly.sql`.
- Sessão: `FRANCISCO_JUNIOR` / schema `SANKHYA` / serviço `riosltdaprd.sankhyacloud.com.br` / base `RIOSLTDAPRD`.
- Quantidade retornada de `TSIEMP`: `1`.
- `dml_executado=false`; `ddl_executado=false`.
