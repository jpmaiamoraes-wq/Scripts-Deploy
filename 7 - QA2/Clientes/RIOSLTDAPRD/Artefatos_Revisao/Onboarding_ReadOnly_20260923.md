# Conferência de onboarding — RIOSLTDAPRD

status: CONCLUIDA_READ_ONLY_COM_DIVERGENCIAS

## Fonte primária

O registro mais recente exibido no portal `Onboarding Deploy — Sankhya` foi `RIO'S DISTRIBUIDORA DE AGUA E BEBIDAS LTDA`, CNPJ `58.364.248/0001-11`, situação `Concluído`. A fonte de usuários usada foi `[MODELO SANKHYA] Usuarios (1).xlsx`, enviada em `2026-08-26 12:19`, com 7 registros.

## Identidade Oracle

- Usuário da sessão: `FRANCISCO_JUNIOR`.
- Schema atual: `SANKHYA`.
- Serviço: `riosltdaprd.sankhyacloud.com.br`.
- Base: `RIOSLTDAPRD`.
- Correspondência da identidade: confirmada.
- As consultas foram executadas pelo executor Oracle direto, somente leitura.

## Resultado executivo

- Empresas: 1 empresa do onboarding localizada em `TSIEMP.CODEMP=1` pelo CNPJ; não há empresa ausente nem adicional. Há apenas variação nominal entre `LTDA` no onboarding e `LT` no Oracle.
- Usuários: 7 registros do arquivo, todos localizados por e-mail nos 7 usuários Oracle com `CODGRUPO > 0`.
- Usuários de modelo: 11 registros Oracle com `CODGRUPO=0`, excluídos da comparação ativa conforme o critério da revisão.
- Nomes: correspondentes após normalização de caixa, pontuação e acentuação.
- Grupos: os 7 usuários apresentam divergência informativa, pois o onboarding lista conjuntos de grupos e `TSIUSU` apresenta um único `CODGRUPO` por registro.
- Não foram executadas inclusões, exclusões ou alterações na base.

## Próxima ação

Preservar as divergências de grupo para decisão funcional; não executar DML automaticamente. Os detalhes estão em `Artefatos_Revisao/Onboarding_Empresas_Comparacao_20260923.md` e `Artefatos_Revisao/Onboarding_Usuarios_Comparacao_20260923.md`.

## Evidências

- JSON consolidado: `Logs/Onboarding_ReadOnly_20260923_1409.json`.
- Consulta de empresas: `Clientes/RIOSLTDAPRD/Onboarding_Empresas_ReadOnly.sql`.
- Consulta de usuários: `Clientes/RIOSLTDAPRD/Onboarding_Usuarios_ReadOnly.sql`.
- `dml_executado=false`.
- `ddl_executado=false`.
