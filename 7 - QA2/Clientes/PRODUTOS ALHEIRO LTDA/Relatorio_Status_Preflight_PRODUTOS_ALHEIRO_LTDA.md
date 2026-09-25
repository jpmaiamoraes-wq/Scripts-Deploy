# Revisão Master Deploy — PRODUTOS ALHEIRO LTDA

## Status atual

**Status:** atividades 01–31 executadas, Card 09 tratado e pós-validação independente concluída sem erros; nenhum `TGFFIN` foi alterado porque não havia candidato apto.  
**ID da análise somente leitura:** `RMD-ALHEIRO-20260916-RO-01`  
**Data:** 16–17/09/2026  
**Executor padrão:** VS Code, com a conexão Oracle anexada ao editor.

As atividades 01–28 foram concluídas na execução principal. A retomada executou somente o merge qualificado dos Cards 29/30 e a Atividade 31. A pós-validação independente foi executada em sessão Oracle restabelecida, somente leitura, sem nova alteração na base.

O preflight anterior registrou `USER_TS_QUOTAS=0` e `ORA-20502`. Nesta retomada, por autorização explícita do usuário, o bloqueio preventivo foi removido do runner. As tabelas/mapas de backup previstos nos includes continuam obrigatórios; qualquer falha de gravação será registrada como erro da atividade e impedirá a declaração de conclusão.

## Preflight e rota

- Diretório efetivo validado no workspace `Scripts-Deploy`, com os includes relativos `@@` preservados. O runner usa o preflight leve `00_Preflight_Gate_ALHEIRO.sql`; o diagnóstico detalhado permanece em `00_Preflight_ALHEIRO.sql` e nos artefatos read-only anteriores.
- Master ativo confirmado: `7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql`.
- Rota somente leitura validada: `10.100.76.5:1521` acessível; nenhuma alteração de rota foi feita.
- Sessão Oracle confirmada no VS Code: usuário `FRANCISCO_JUNIOR`.
- Schema operacional efetivo: `SANKHYA`; o schema esperado informado pelo usuário (`FRANCISCO_JUNIOR`) não é o schema efetivo da sessão. Isso foi registrado como evidência operacional, sem uso de `ALTER SESSION` e sem classificar como divergência de configuração.
- Service name confirmado: `ALHEIROPRD.SANKHYACLOUD.COM.BR`.
- Banco/instância observados: `ALHEIROPRD`.
- Empresa exata: `TSIEMP.CODEMP=1`, `PRODUTOS ALHEIRO LTDA`, quantidade exata `1`.
- Versão curta registrada pela consulta de `TSIPAR`: `4.36b146`.
- `USER_TS_QUOTAS`: **0 linhas**. O gate preventivo foi dispensado por aprovação explícita do usuário; a gravação dos backups efetivamente usados nos Cards 29/30 foi confirmada no log da retomada. A quota continua sendo risco técnico para futuras alterações.
- Privilégios observados: `ALTER ANY TRIGGER`, `CREATE ANY TABLE` e `DROP ANY TABLE`; não foi constatado `ALTER ANY PROCEDURE`.
- Objetos inválidos: **0**. Não houve recompilação; portanto não há afirmação de recompilação realizada.

As consultas de preflight da base foram corrigidas localmente antes da execução: a versão usa `V$VERSION`, a dependência usa as colunas válidas `ALL_DEPENDENCIES.NAME` e `ALL_DEPENDENCIES.TYPE`, e a saída de dependências foi resumida por objeto para evitar truncamento do log. O diagnóstico auxiliar de FKs dos Cards 29/30 revelou, na primeira passagem, `ORA-00904: "NOME": invalid identifier`; o script foi corrigido para as colunas reais `NOMEBAI` e `NOMEEND`. A consulta resumida anterior ficou sem retorno além do primeiro `SELECT` e foi interrompida; portanto, ela não é considerada evidência concluída. As alterações efetivas estão evidenciadas nos logs do Master e da retomada.

## Master e atividades

O Master ativo foi revisado e contém os includes relativos das atividades 01 a 31. A Atividade 18 prepara os backups de 18 a 30 antes dos ajustes subsequentes.

- Atividades 01–28: concluídas na execução principal, com marcadores de início/fim no log `Revisao_Master_20260916_1358.log`; esse log contém dois blocos históricos `Error starting at line` (Atividades 17 e 19), registrados como ocorrências corrigidas/contornadas na retomada, e não como execução limpa.
- Atividades 29–30: os scripts nominais registraram `STATUS=CONCLUIDO; REGISTROS=0` na segunda tentativa; o merge antifrágil específico da base concluiu com mapa, backup, descoberta de FKs, zero exceções e zero referências remanescentes.
- Atividade 31: `STATUS=CONCLUIDO; OBJETOS_INVALIDOS=0`.
- Backups persistentes no Oracle: confirmados para o escopo antifrágil: `MAPA_BAI=428`, `BACKUP_BAI=848`, `MAPA_END=7283`, `BACKUP_END=14226`.
- Card 09: backup persistente `BKP_RMD_ALH_DUP_20260917=1`, mapa persistente `BKP_RMD_ALH_DUP_PPG_20260917=1` e auditoria `BKP_RMD_ALH_DUP_INS_20260917=0`, todos associados ao ID `RMD_FDUP_ALH_2026091701`.
- Rollbacks locais: cópias preparadas em `Artefatos_Revisao/Rollback/`; não aplicadas e sem efeito na base.
- `Limpar_Objetos_Revisao.sql`: **não executado**.
- Logs preservados: execução principal `Logs/Revisao_Master_20260916_1358.log`; tentativa com include sem aspas `Logs/Revisao_Master_20260916_Retomada_29_31.log`; retry com erro de compilação de auditoria `Logs/Revisao_Master_20260916_Retomada_29_31_retry.log`; retry2 concluído `Logs/Revisao_Master_20260916_Retomada_29_31_retry2.log`; pós-validação independente concluída em `Logs/Pos_Validacao_Retomada_20260916.log`.
- Logs do Card 09 preservados: `Logs/Card09_Preflight_Funcao_XML_20260917.log`, `Logs/Card09_Compilacao_Funcao_XML_20260917.log`, `Logs/Card09_Preflight_20260917.log`, `Logs/Card09_Mapa_20260917.log`, `Logs/Card09_32B_Insert_20260917.log` e `Logs/Card09_Posvalidacao_20260917.log`.
- Correções aplicadas antes do retry2: includes relativos com espaços foram protegidos por aspas; a criação das tabelas de auditoria foi separada do bloco PL/SQL que as consulta. Os erros históricos permanecem documentados e não foram apagados.

## Cards

### Card 08 — Protocolamento de documentos legados

Consulta somente leitura encontrou **0 candidatos**. Card zerado informativamente; nenhuma Atividade foi necessária.

### Card 13 — TOPs GOL

Consulta somente leitura encontrou **0 candidatos**. Card zerado informativamente; nenhuma Atividade foi necessária.

### Card 14 — Análise 848

Consulta encontrou **1 candidato**. A Atividade 14 executou com backup pontual e registrou `ID_EXECUCAO=RMD_G848_20260916135626115` e `ANALISE_GIRO_848_ATUALIZADA=1`. A pós-validação independente confirmou a execução sem erro.

### Card 15 — Rastro sem controle

Consulta encontrou **24 candidatos**. A Atividade 15 executou com backup por execução e registrou `ID_EXECUCAO=RMD_RAST_20260916135627406` e `REGISTROS_ALTERADOS=24`. O script alterou somente `TGFPRO.TEMRASTROLOTE` para os registros qualificados; não desativou trigger ou objeto. A pós-validação independente confirmou a execução sem erro.

### Card 29 — Padronização de bairros

Consulta encontrou **420 grupos de colisão**. A retomada antifrágil concluiu com `MAPA_BAI=428`, `BACKUP_BAI=848`, `PAIS_BAI_EXCLUIDOS=428`, nenhuma exceção e nenhuma referência remanescente no pós-check interno.

### Card 30 — Padronização de endereços

Consulta encontrou **6.943 grupos de colisão**. A retomada antifrágil concluiu com `MAPA_END=7283`, `BACKUP_END=14226`, `PAIS_END_EXCLUIDOS=7283`, descoberta de FKs por `ALL_CONSTRAINTS`/`ALL_CONS_COLUMNS`, nenhuma exceção e nenhuma referência remanescente no pós-check interno. A pós-validação independente confirmou zero duplicidades e zero referências remanescentes.

Foram preparados os diagnósticos locais somente leitura `29_30_Preflight_FK_ReadOnly.sql` e `29_30_Resumo_ReadOnly.sql`; eles não criam mapa nem alteram a base. A primeira listagem revelou a coluna incorreta `NOME`, corrigida antes do merge final. O merge final executou a descoberta qualificada de FKs e o pós-check interno; a pós-validação independente confirmou zero duplicidades e zero referências remanescentes.

### Card 09 — Notas sem financeiro

O Card foi tratado no ID `RMD_FDUP_ALH_2026091701`, usando a fonte versionada `7 - QA2/Scripts Originais/FNC_BUSCA_TAG_XML_GERAL.sql` (SHA-256 `53f52da7455e3717e6d7a5e991d792921136c671cb1d2ceb2516d8618df0de0b`).

- Compilação automática: `SANKHYA.FNC_BUSCA_TAG_XML_GERAL` ficou `VALID`, com `0` erros em `ALL_ERRORS`. O preflight confirmou previamente que o objeto estava ausente; o estado anterior e o rollback explícito estão preservados em `Artefatos_Revisao/Backups/` e `Artefatos_Revisao/Rollback/`.
- Atividade 32 / preflight: criou o backup persistente `BKP_RMD_ALH_DUP_20260917` com `1` nota sem financeiro. A leitura XML de `<Dup>`/`<dVenc>` classificou a única linha como `SEM_DUP_XML`; não houve candidato XML válido.
- Atividade 32A / mapa: criou `BKP_RMD_ALH_DUP_PPG_20260917` com `1` linha, `0` aptas, `TGFNUM` consistente (`1` linha, `ULTCOD=38210`) e sem colisão de `TGFPPG` a encaminhar.
- Atividade 32B / tratamento controlado: criou a auditoria `BKP_RMD_ALH_DUP_INS_20260917`, registrou `STATUS=SEM_CANDIDATOS_APTOS` e `TGFFIN_ALTERADO=NAO`; não executou `INSERT`, `DELETE` ou atualização de `TGFNUM`.
- Pós-validação independente: `ERROS_VALIDACAO=0`, função válida, `0` auditorias de inclusão, `0` `TGFFIN` no escopo e `ULTCOD` preservado em `38210`.

O Card 09 está concluído para o estado atual da base. Uma nova nota somente poderá ser encaminhada se surgir em novo mapa auditável com XML válido, `CODTIPTIT` derivado de `TGFPPG.CODTIPTITPAD`, `NUFIN` alocado por `TGFNUM.ULTCOD` bloqueado e backup/rollback próprios.

## Custos e consolidação GOL

Foram localizados 8 objetos válidos no schema operacional para recálculo/consolidação:

`PFCM_CONSOLIDACAO`, `SNK_MATGIRCALCTOTAIS`, `STP_CALCCUSTOMEDIOPRODGENERICO`, `STP_CALCULARCUSTOMEDIODIA`, `STP_CALCULARCUSTOMEDIOFAMILIA`, `STP_CALCULARCUSTOPRODGENERICO`, `STP_PROCESSOATUALCUSTO`, `STP_EFETIVA_CONSOLIDACAO_GOL`.

Como há objetos candidatos, não foi necessário fornecer lista de `CODPROD`. Nenhum recálculo foi executado.

## Comparação de onboarding — somente leitura

A consulta foi feita no Drive na pasta de onboarding da base, usando os resumos disponíveis, sem upload, edição, compartilhamento ou exposição de credenciais.

| Dimensão | Resultado | Classificação |
|---|---|---|
| Nome da base e GP | Nome e GP do onboarding coerentes com a base informada e com a empresa encontrada no Oracle | Sem divergência comprovada |
| `CODEMP`/razão social | Oracle retornou uma única empresa exata, `CODEMP=1` | Correspondente |
| CNPJ, IE, UF, segmento e matriz | Informados no resumo de onboarding, mas não foram todos retornados pelo snapshot live usado nesta retomada | Dado ausente na consulta live; não tratar como divergência |
| SMTP | Metadados não sensíveis de servidor, porta e TLS coerentes entre snapshot e onboarding | Correspondente; credenciais omitidas |
| XMLs, produtos e integrações | Resumos existem, mas não há consulta live equivalente concluída para volume XML, codificação detalhada de produtos, kits ou integrações | Dado ausente/não confrontável; não tratar como divergência |
| Arquivos-fonte detalhados | O Drive forneceu resumos, não todos os arquivos detalhados necessários para validar cada atributo operacional | Arquivo-fonte detalhado indisponível para alguns confrontos |

Nenhum arquivo não localizado foi classificado como divergência de configuração.

## Backups, rollback e dependências externas

- Backup persistente Oracle: os backups do escopo 29/30 foram criados e validados no log da retomada e na pós-validação independente: `BKP_RMD_PAD_TSIBAI=45047`, `BKP_RMD_PAD_TSIEND=646115`, mapa identificado `7711` linhas, `RMD_ALH_2930_BAI_BKP=848`, `RMD_ALH_2930_END_BKP=14226`, dependências mapeadas `61263` e exceções `0`. `USER_TS_QUOTAS=0 linhas` permanece registrado como risco técnico para novas alterações.
- Rollback: mapa, backups e dependências do merge 29/30 permanecem preservados; o modelo local de rollback está preparado, não foi aplicado e não houve necessidade de acioná-lo. A pós-validação independente confirmou zero referências remanescentes.
- Ticket Sankhya Cloud: rascunho local em `Ticket_Sankhya_Cloud_Quota_Preparacao.md`; número e URL ainda não existem.
- Pendência externa principal: regularizar quota ou indicar caminho suportado pelo Cloud para backups persistentes.
- Pendências adicionais: nenhuma atividade ou Card bloqueante da revisão atual. Qualquer novo candidato do Card 09 exigirá novo mapa, backup, rollback e aprovação operacional específica.
- Pushcut, notificações no iPhone e Apple Watch: mantidos pausados; nenhuma alteração realizada.

## Validação independente concluída

O script somente leitura `Pos_Validacao_Retomada_20260916.sql` foi executado em sessão Oracle restabelecida, sem DML/DDL, e gerou o log `Logs/Pos_Validacao_Retomada_20260916.log` com 13.017 bytes. A confirmação independente registrou:

- identidade final: `SESSION_USER=FRANCISCO_JUNIOR`, `CURRENT_SCHEMA=SANKHYA`, `SERVICE_NAME=alheiroprd.sankhyacloud.com.br`, `DB_NAME=ALHEIROPRD`;
- empresa exata: `TSIEMP.CODEMP=1`, `PRODUTOS ALHEIRO LTDA`;
- versão curta: `4.36b146`;
- `TSIBAI_OBSOLETOS_REMANESCENTES=0` e `TSIEND_OBSOLETOS_REMANESCENTES=0`;
- `TSIBAI_GRUPOS_COLISAO_REMANESCENTES=0` e `TSIEND_GRUPOS_COLISAO_REMANESCENTES=0`;
- `REFERENCIAS_REMANESCENTES_FINAL=0; ERROS_VALIDACAO=0`;
- objetos inválidos: `0 rows selected`;
- estado temporário: três registros em `RMD_CONTROLE_OBJETOS`, todos restaurados para `ENABLED`;
- `USER_TS_QUOTAS=0` e `ALTER_ANY_PROCEDURE=0`.

As tentativas anteriores `ORA-12170` e `ORA-17008` permanecem como histórico operacional; não houve alteração na base por causa delas.

## Condição para novas revisões

Esta revisão está encerrada quanto às atividades 01–31, ao tratamento do Card 09 e às pós-validações independentes. Para uma nova revisão ou alteração futura, regularizar a quota ou indicar caminho suportado pelo Cloud, iniciar por novo preflight no VS Code e preservar os logs/backups existentes. A autenticação, se a sessão expirar, deve ser feita manualmente; nenhuma senha precisa ser enviada ao chat ou registrada em artefatos.
