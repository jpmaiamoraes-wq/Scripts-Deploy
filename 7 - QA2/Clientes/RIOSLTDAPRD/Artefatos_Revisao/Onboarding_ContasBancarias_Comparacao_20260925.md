# Comparação de contas bancárias do onboarding — RIOSLTDAPRD

## Fonte e critério

- Arquivo de origem: pacote local do Onboarding Deploy, planilha `[MODELO SANKHYA] Contas Bancarias (1).xlsx`.
- Escopo Oracle: contas cadastradas em `TSICTA` para `CODEMP=1`, empresa identificada pelo CNPJ correspondente ao onboarding.
- Comparação: hash SHA-256 dos dígitos de agência e conta. O valor da agência ou da conta e os hashes não foram exibidos nem persistidos.
- A regra de dígito `X` de agência do Banco do Brasil foi considerada no algoritmo de comparação quando aplicável.

## Resultado

- Contas informadas no arquivo: `1`.
- Registros localizados em `TSICTA` para a empresa 1: `3`.
- Correspondências por hash: `1`.
- Contas do onboarding sem correspondência na Oracle: `0`.
- Registros adicionais na Oracle fora da única conta listada no arquivo: `2`.
- Nenhuma conta foi incluída, alterada ou removida.

## Evidência

- Consulta de hash: `Relatorio_Preview_ContasBancarias_Hash_ReadOnly.sql`.
- Resultado agregado e horário Oracle: `Logs/Relatorio_Preview_ReadOnly_20260925.json`.
- `dml_executado=false`; `ddl_executado=false`.
