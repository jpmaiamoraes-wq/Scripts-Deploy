# Backup de preestado — Card 09 / função XML

- ID de execução: `RMD_ALH_FNC09_2026091701`
- Base: `PRODUTOS ALHEIRO LTDA`
- Sessão preflight: `FRANCISCO_JUNIOR` / schema efetivo `SANKHYA`
- Service name: `alheiroprd.sankhyacloud.com.br`
- Objeto: `FNC_BUSCA_TAG_XML_GERAL`
- Estado anterior confirmado no preflight: **ausente** em `ALL_OBJECTS`, `ALL_ARGUMENTS` e `ALL_ERRORS`
- Fonte versionada aprovada: `7 - QA2/Scripts Originais/FNC_BUSCA_TAG_XML_GERAL.sql`
- SHA-256 da fonte: `53f52da7455e3717e6d7a5e991d792921136c671cb1d2ceb2516d8618df0de0b`
- Escopo: criação controlada da função ausente; nenhum `TGFFIN` será alterado nesta atividade.
- Rollback explícito preparado: `Artefatos_Revisao/Rollback/Reverter_Card09_Funcao_XML_ALHEIRO_20260917.sql`

Como o objeto estava ausente, não havia corpo PL/SQL anterior para copiar. O preflight e este manifesto preservam o estado anterior; o rollback remove somente a função criada por este ID, após validação manual do estado.
