# Lições reutilizáveis — Card 09 por XML direto

Este padrão nasceu da execução controlada do Card 09 em uma base com variação
de nomes cadastrais (`Vitrine Direta`/`ACM Brasil`). A ambiguidade nominal foi
resolvida no cadastro da empresa e não alterou o critério técnico do Card 09.

## Fluxo recomendado

1. Confirmar identidade Oracle, schema e service; gerar um `ID_EXECUCAO` novo.
2. Aplicar a query de volumetria do dashboard em `TGFCAB`/`TGFTOP` antes de
   consultar `TGFNFE.XML`: `ATUALFIN<>0`, `TIPMOV<>'Z'` e `NOT EXISTS` em
   `TGFFIN`.
3. Persistir uma tabela base com `CREATE TABLE AS SELECT` e extrair diretamente
   de `TGFNFE.XML` por `XMLTABLE` os campos `vDup`, `dVenc` e `nDup` da tag
   `<dup>`.
4. Persistir a classificação de `TGFPPG`, mantendo aptos e não aptos no mesmo
   mapa. O executor só pode considerar
   `STATUS_MAPA='APTO_PARA_VALIDACAO_FINAL'`.
5. Revisar o mapa; executar o wrapper com `CONFIRMA_INSERCAO=NAO`; somente então
   repetir com `SIM` como confirmação operacional imediatamente anterior ao DML.
6. Antes do commit, manter os guards de `TGFTPV`, `TGFTIT`, unicidade por
   `NUNOTA`, existência de `TGFNUM` único e lock `FOR UPDATE WAIT`.
7. Auditar cada `NUFIN`/`NUNOTA`, validar `TGFFIN`, `TGFNUM`, duplicidades e aptos
   pendentes; deixar o rollback autocontido e não executado até ser necessário.
8. Antes de repetir qualquer etapa, executar o inventário de estado. Se a base
   foi criada e a classificação não, completar somente a classificação; se o
   mapa estiver completo, não recriar CTAS; se houver auditoria, seguir para
   pós-validação. Nunca apagar objetos para fazer uma reexecução parecer limpa.

## Regras de compatibilidade Oracle

- Use DDL direto para o CTAS que contém `XMLTABLE`. A forma dinâmica dentro de
  `EXECUTE IMMEDIATE` pode produzir `PLS-00103` em `PASSING`, embora a consulta
  SQL direta seja válida.
- Não use `SELECT M.*, C.DHTIPVENDA` quando `M.*` já possui essa coluna. O
  cursor do executor falha com `PLS-00402` por nomes duplicados; adicione apenas
  colunas que não existam no mapa.
- Crie nomes persistentes novos após qualquer tentativa parcial de criação de
  objeto. Não reutilize uma tabela que possa conter linhas de outra execução.
- Mantenha um spool limpo para o resultado final. Diagnósticos interativos com
  consultas incompletas não devem ser tratados como evidência final.
- O spool definitivo deve ser novo e não pode conter qualquer `ORA-`, `PLS-` ou
  `SP2-`, mesmo quando o erro veio depois de métricas corretas. A evidência
  final deve ser separada dos logs de tentativa, guarda ou diagnóstico.
- Mais de um registro `TGFNFE` para a mesma `NUNOTA` deve virar pendência
  `REVISAR_MULTIPLOS_XML`; não selecionar silenciosamente pelo `ROWID`.

## Segurança preservada

O caminho direto elimina apenas a dependência de compilação da function. Ele não
elimina a revisão do mapa, a confirmação do insert, o limite da volumetria, a
preservação dos financeiros existentes, o mapa/auditoria persistentes, o lock
do contador `TGFNUM`, a pós-validação ou o rollback. Nenhuma senha ou credencial
deve ser armazenada nos scripts ou logs.

Para a identidade da base, uma divergência entre o nome informado e
`TSIEMP.RAZAOSOCIAL` deve ser tratada em diagnóstico separado, listando todas as
variações de `NOMEFANTASIA`/`RAZAOSOCIAL`, a contagem efetiva e os nomes excluídos.
A autorização dessa exceção não libera automaticamente o `INSERT` financeiro.
