# Conferência do Onboarding — MOVE GESTAO DE ENERGIA LTDA

**Modo:** somente leitura. Nenhum dado foi alterado na base ou no portal.

## Fontes e critério

- Projeto MOVE no portal Onboarding Deploy — Sankhya, consultado em 23/09/2026.
- Empresas: relação de cinco organizações exibida no projeto; comparação por CNPJ normalizado com `TSIEMP`.
- Usuários: arquivo mais recente da categoria, `Usuarios.xlsx`, enviado em 14/09/2026 às 20:00 (fuso não exibido); 18 linhas. Comparação por e-mail normalizado com usuários Oracle que possuem `CODGRUPO > 0`; usuários sem grupo permanecem em categoria separada.
- Identidade Oracle: `FRANCISCO_JUNIOR` / `SANKHYA`, serviço `moveenergiaprd.sankhyacloud.com.br`, base `MOVEENERGIAPRD`.

## Empresas

Do total de cinco empresas do projeto, duas correspondem por CNPJ a registros da `TSIEMP` (MOVE GESTAO DE ENERGIA LTDA, `CODEMP=1`; MOVE COMERCIALIZADORA DE ENERGIA LTDA, `CODEMP=2`). As outras três — COOPERATIVA DE ENERGIA MOVE, COOPERATIVA DE ENERGIA COTESA AUTEN e MOVE ENERGIA HOLDING S.A. — não apareceram na `TSIEMP`; não houve empresas adicionais na Oracle. A diferença fica registrada para acompanhamento e não bloqueia a revisão da base inteira.

## Usuários

Os 18 e-mails do arquivo correspondem a 18 usuários Oracle com grupo preenchido. Não há e-mails ausentes nem usuários Oracle com grupo sem correspondência. Os 18 nomes divergem porque a Oracle apresenta `NOMEUSU` como identificador/login; não foi inferido nome canônico. Os 11 usuários Oracle sem grupo foram contabilizados separadamente.

`EMPRESA` e `CODGRUPO` estão vazios nas 18 linhas do arquivo, então esses campos não podem ser confrontados. Em cinco linhas, a coluna `CODIGO USUARIO` contém literalmente `Atendimento?`; isso foi registrado como ambiguidade da fonte, sem inferência.

## Evidências detalhadas

- Empresas: `00_Onboarding_Empresas_MOVE_Comparacao_20260923.json` e `00_Onboarding_Empresas_MOVE_READONLY.sql`.
- Usuários: `00_Onboarding_Usuarios_MOVE_Comparacao_20260923.json` e `00_Onboarding_Usuarios_MOVE_READONLY.sql`.
- Resultado consolidado: `00_Onboarding_READONLY_MOVE_20260923.json`.

**DML executado:** não. **DDL executado:** não.
