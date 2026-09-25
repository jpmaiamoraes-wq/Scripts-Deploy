# Etapa 32 — Card 09: Notas sem Financeiro

Esta etapa integra a revisão regular após a conclusão do Master (etapas 1 a
31). Ela trata somente notas cujo XML contenha a tag `<Dup>` e que estejam sem
registro correspondente na `TGFFIN`. A ausência da tag, vencimento inválido ou
condição de pagamento ambígua permanece no mapa como pendência auditável.

## Execução padrão — caminho direto por XML

1. Gere um `ID_EXECUCAO` exclusivo para a base e nomes exclusivos para as
   tabelas de mapa, classificação e inserções auditadas. Nunca reutilize um ID
   após uma tentativa que tenha criado algum objeto.
2. Execute [32_Card09_Estado_Execucao_MODELO.sql](../32_Card09_Estado_Execucao_MODELO.sql)
   antes de qualquer retomada. Se o estado não for `NAO_INICIADO`, não repita
   CTAS nem consulte tabelas ausentes: complete somente a fase faltante ou gere
   um ID novo após registrar o estado anterior.
3. Execute [32A_Card09_Mapear_Direto_XML.sql](../32A_Card09_Mapear_Direto_XML.sql)
   como script. Ele aplica primeiro a query de volumetria do dashboard
   (`ATUALFIN<>0`, `TIPMOV<>'Z'` e ausência de `TGFFIN`) e só então lê
   `TGFNFE.XML` com `XMLTABLE` para extrair `vDup`, `dVenc` e `nDup`. Se houver
   mais de um XML por `NUNOTA`, a classificação deve ser
   `REVISAR_MULTIPLOS_XML`.
4. Revise o mapa por `NUNOTA`, TOP, valor, vencimento XML, número da duplicata,
   tipo de título e regra de recebimento/despesa. O mapa pode conter linhas
   `SEM_VDUP_XML`, XML inválido, ausência de `TGFPPG` ou duplicidade de
   condição; somente `APTO_PARA_VALIDACAO_FINAL` pode seguir para o DML.
5. Prepare o wrapper a partir de
   [32B_Card09_Executor_Wrapper_MODELO.sql](../32B_Card09_Executor_Wrapper_MODELO.sql),
   conferindo `ID_EXECUCAO`, `TBL_BASE`, `TBL_PPG` e `TBL_INS`. Mantenha
   `CONFIRMA_INSERCAO=NAO` durante qualquer prévia.
6. Somente após a revisão e a confirmação operacional imediatamente anterior
   ao DML, altere `CONFIRMA_INSERCAO` para `SIM` e execute
   [32B_Card09_Inserir_Notas_Sem_Financeiro_DUP.sql](../32B_Card09_Inserir_Notas_Sem_Financeiro_DUP.sql).
   O executor filtra o mapa por `STATUS_MAPA='APTO_PARA_VALIDACAO_FINAL'`,
   preserva notas que já ganharam `TGFFIN`, bloqueia `TGFNUM` com `FOR UPDATE`
   e grava uma auditoria persistente por `NUFIN`/`NUNOTA`.
7. Execute a pós-validação read-only: quantidade inserida, ausência de mais de
   um financeiro por nota tratada, `DTVENC` e `VLRDESDOB` conforme XML, avanço
   do `TGFNUM.ULTCOD`, mapa sem aptos pendentes e card 09 recalculado. Use o
   modelo [32D_Card09_PosValidacao_MODELO.sql](../32D_Card09_PosValidacao_MODELO.sql)
   ou a cópia preenchida na pasta da base.
8. Em necessidade de reversão, use
   [32C_Card09_Rollback_Notas_Sem_Financeiro_DUP.sql](../32C_Card09_Rollback_Notas_Sem_Financeiro_DUP.sql),
   mantendo `CONFIRMA_ROLLBACK=NAO` até revisar a auditoria.

Este caminho não depende de `FNC_BUSCA_TAG_XML_GERAL` e, portanto, não precisa
interromper a execução para autorização de compilação de function. A confirmação
do `INSERT` continua obrigatória: a ausência dessa etapa não é substituída pela
leitura direta do XML.

## Caminho legado com function

Use [32_Card09_Preflight_Notas_Sem_Financeiro_DUP.sql](../32_Card09_Preflight_Notas_Sem_Financeiro_DUP.sql)
e [32A_Card09_Mapear_Notas_Sem_Financeiro_DUP.sql](../32A_Card09_Mapear_Notas_Sem_Financeiro_DUP.sql)
somente quando a leitura direta não for viável. Nesse caso, valide
`FNC_BUSCA_TAG_XML_GERAL` em `ALL_OBJECTS`, `ALL_ARGUMENTS` e `ALL_ERRORS`; se
ausente ou inválida, tente somente a fonte versionada quando houver autorização
e registre schema, DDL, status anterior/posterior e erros. Faltando privilégio ou
permanecendo inválida, isole o Card 09 sem criar mapa nem inserir `TGFFIN`.

## Regras consolidadas

- `CODTIPTIT` vem de `TGFPPG.CODTIPTITPAD`, relacionado à condição de venda da `TGFCAB`; o código deve existir em `TGFTIT`.
- `NUFIN` é alocado a partir de `TGFNUM.ULTCOD` para `ARQUIVO='TGFFIN'`, com bloqueio `FOR UPDATE`; o contador é atualizado a cada inclusão.
- `VLRDESDOB` e `DTVENC` são obtidos do XML (`vDup` e `dVenc`) com conversão explícita e validação do formato. `nDup` é preservado como número da duplicata.
- O texto de `TGFPPG.TIPRECDESP` é convertido para `TGFFIN.RECDESP`: `I/R/1` vira `1`, `D/P/-1` vira `-1`; quando ausente, aplica-se o sentido de `TIPMOV` (`V=1`, `C=-1`).
- `CODBCO` nulo recebe `0`; `TIPJURO` usa valor numérico `1` quando `TGFTPV` retornar o marcador textual `I`; `TIPMARCCHEQ` permanece no padrão nativo `I`.
- O insert usa os demais campos e padrões observados na rotina nativa de refazer financeiro, mantendo auditoria persistente por `ID_EXECUCAO`.
- A etapa não entra automaticamente no `Revisao_Master_Deploy.sql`: ela depende de mapa, validação funcional e confirmação explícita.

## Lições técnicas incorporadas

- O mapa que contém `XMLTABLE` deve ser criado por DDL direto. Envolver o CTAS
  em `EXECUTE IMMEDIATE` pode falhar no parser PL/SQL com `PLS-00103` em
  `PASSING`; a leitura do XML continua segura, mas precisa ser compilada pelo
  parser SQL como `CREATE TABLE ... AS SELECT`.
- Não selecionar `M.*` e repetir uma coluna do cabeçalho com o mesmo nome no
  cursor do executor. Isso provoca `PLS-00402`; o cursor deve manter `M.*` e
  adicionar apenas colunas sem alias duplicado, como `C.TIPMOV` e `V.TIPJURO`.
- Status inelegível não é erro de execução. Ele deve permanecer na classificação
  para explicar a volumetria, enquanto todos os guards e o DML filtram somente
  `APTO_PARA_VALIDACAO_FINAL`.
- A cada tentativa, persistir mapa, classificação, auditoria e logs/spools
  completos. O rollback deve validar as contagens e o estado do `TGFNUM` antes
  de excluir qualquer `TGFFIN`.
- Ao consultar detalhes pós-execução, qualificar colunas com o alias da tabela
  correta (`F.DTVENC`, `F.NUNOTA`, etc.) e manter um spool limpo separado do
  log operacional que possa conter tentativas de diagnóstico.
- O inventário de estado deve ser executado antes de qualquer consulta a mapa:
  ele diferencia ausência total, base criada sem classificação, mapa completo
  sem DML e DML auditado aguardando pós-validação.
- A identidade empresarial deve ter um diagnóstico read-only separado quando
  houver variações de nome. A confirmação da exceção de identidade e a
  confirmação do DML financeiro são gates independentes.

## Critério de encerramento

O card 09 deve ser recalculado após a execução. O relatório técnico deve registrar o status final, quantidade efetivamente inserida, notas que já possuíam `TGFFIN`, candidatos não aptos, tabelas de auditoria, `ID_EXECUCAO` e os links dos scripts de preflight, 32A, 32B e 32C.
