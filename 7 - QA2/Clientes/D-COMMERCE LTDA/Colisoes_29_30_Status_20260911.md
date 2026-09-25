# Atividades 29 e 30 — D-COMMERCE LTDA

Data: 11/09/2026

Status concluído: merge estrutural, correção de referências por FK e exclusão dos pais obsoletos executados com backup, mapa persistente e rollback disponível.

Evidencias read-only executadas na conexao `FRANCISCO_JUNIOR`, schema `SANKHYA`, servico `INFLOWSOFAPRD.SANKHYACLOUD.COM.BR`:

- `TSIBAI`: 64 grupos de nomes repetidos e 64 registros potencialmente obsoletos, considerando `UPPER(TRIM(NOMEBAI))`.
- `TSIEND`: 8.079 grupos de nomes repetidos e 8.666 registros potencialmente obsoletos, considerando `UPPER(TRIM(NOMEEND))`.
- Quando o tipo de endereco e incluido na chave de agrupamento, permanecem grupos em quatro tipos (`Al`, `Av`, `Bc`, `Eq`); portanto, tipo e parte da decisao de precedencia e nao pode ser descartado.

Decisao: nao executar `UPDATE` ou `DELETE` generico. O merge depende do mapa completo de PK/UK/FK, inclusive chaves compostas, das referencias reais de `CODBAI`/`CODEND`, de backups persistentes e de precedencia por tabela. Aplicar somente apos esses mapas e a validacao de zero conflitos remanescentes.

O procedimento padrao foi atualizado nos READMEs da Revisao Master Deploy para exigir essa etapa antes de considerar 29/30 concluido.

Retomada histórica: o merge foi executado na conexão D-COMMERCE usando o ID `DCOMMERCE_20260911_MERGE_01`; as tabelas de backup, mapa, dependência e exceção foram validadas antes da exclusão.

## Retomada em 14/09/2026

- ID_EXECUCAO: `DCOMMERCE_20260911_MERGE_01`.
- Mapa persistente: 419 colisões de `TSIBAI` e 7.095 colisões de `TSIEND`.
- Dependências auditadas: 59.708 registros; exceções persistentes: 0.
- Ramos alterados: `TSICEP.CODBAI=11.416`, `TSICEP.CODEND=47.840`, `TSIEMP.CODBAI=2`, `TSIEMP.CODEND=1`, `TGFPAR.CODBAI=30`, `TGFPAR.CODEND=184`, `BKP_RMD_PAD_TGFPAR.CODBAI=3`, `BKP_RMD_PAD_TGFPAR.CODEND=16`, `BKP_RMD_PAD_TSIEND.CODEND=2`, `BKP_TGFPAR_NOVO.CODBAI=30`, `BKP_TGFPAR_NOVO.CODEND=184`.
- Diagnóstico físico pós-merge: zero referências de `TSICEP.CODEND` para códigos obsoletos; a consulta de amostra gerou `ORA-00979` apenas por sintaxe auxiliar (`ROWNUM` com `GROUP BY`), sem alteração de dados.
- A primeira tentativa de exclusão foi revertida automaticamente por `FK_TGFCPL_TSIEND1`, sem commit. Esse bloqueio incorporou a regra antifrágil de inventariar também FKs reais, inclusive colunas com nomes diferentes de `CODBAI`/`CODEND`.
- A fase genérica `29_30_Corrigir_Referencias_FK_Antifragil.sql` foi executada com backup na trilha existente; percorreu `TGFCPL.CODENDENTREGA` e demais FKs relevantes, corrigiu 0 registros adicionais e terminou com 0 exceções.
- A exclusão controlada foi concluída por `29_30_Excluir_Pais_Obsoletos_DCOMMERCE.sql`: `REFERENCIAS_FISICAS_REMANESCENTES=0`, `TSIBAI` removidos=419 e `TSIEND` removidos=7.095.
- Backups persistentes validados no encerramento: `BKP_RMD_MRG_DCOM_20260911_BAI=830` e `BKP_RMD_MRG_DCOM_20260911_END=13.892`; exceções=0. O rollback pareado permanece disponível em `29_30_Rollback_DCOMMERCE_20260911.sql`.

## Chamado de objetos inválidos

- Chamado Sankhya Cloud: `#70801`.
- Escopo: análise de dependências, erros de compilação e recompilação/correção das 31 funções inválidas identificadas na atividade 31.
- Privilégio necessário informado: `ALTER ANY PROCEDURE`.
