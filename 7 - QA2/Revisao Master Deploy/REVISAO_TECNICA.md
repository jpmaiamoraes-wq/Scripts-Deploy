# Revisao tecnica dos scripts do Master anterior

| Rotina de origem | Risco principal | Diretriz de reescrita |
|---|---|---|
| Scripts_Variados.sql | quinze responsabilidades e commits intermediarios | desmembrar por assunto, backup filtrado e rollback individual |
| 16_Aplicar_Higienizacao_TSICFG.sql (referência Modelo) | exclusao integral de TSICFG e configuracoes historicas | manter substituicao integral aprovada, com snapshot completo, validacao e rollback |
| Padrao_Dados.sql | atualizacoes massivas e colisoes de unicidade | preflight, mapas de duplicidade e backup por tabela |
| Limpeza_Unidades.sql | DDL, trigger desabilitada e exclusao de unidades | mapa versionado, `EXCEPTION` que sempre reabilite trigger e backups filtrados |
| AJUSTE_TGFCGM.sql | varios assuntos e commits independentes | separar preferencias TSIPAR, TGFCGM e TGFCMV |
| Ajusta_CODPARCMATRIZ.sql | atualiza todos os parceiros elegiveis | calcular proposta, salvar apenas divergentes e validar raiz de CNPJ |
| Ajusta_Cards_Deploy.sql | subconsultas escalares e dependencia de tabelas TTK | pre-validar objetos, atualizar somente a linha esperada e salvar estado anterior |
| Classificacao_ICMS.sql | criterio automatico depende de cadastro completo | manter idempotencia, restringir a casos deterministas e reversao por ID |
| Recompila_Objetos_Invalidos.sql | privilegios podem impedir recompilacao | separar diagnostico de tentativa e nunca confundir falta de privilegio com causa |
| Ajuste_nomes_parceros_numeros.sql | expressao regular e alteracao cadastral | preservar algoritmo validado, reforcar preflight e rollback pareado |

## Diretiva permanente — Card 09 por XML direto

O fluxo padrao deve preferir a leitura direta de `TGFNFE.XML`, sem depender de
`FNC_BUSCA_TAG_XML_GERAL`. Primeiro aplicar a volumetria do dashboard em
`TGFCAB`/`TGFTOP` (`ATUALFIN<>0`, `TIPMOV<>'Z'` e ausencia de `TGFFIN`) e só
depois extrair `<Dup>`, `vDup`, `dVenc` e `nDup` com `XMLTABLE`. O mapa deve ser
persistido por `CREATE TABLE AS SELECT` direto, pois o parser Oracle pode
rejeitar `XMLTABLE` dentro de um `EXECUTE IMMEDIATE` com `PLS-00103` em
`PASSING`.

1. Gerar `ID_EXECUCAO` novo, criar mapa base e classificação `TGFPPG` e manter
   no mapa tanto aptos quanto não aptos para auditoria.
2. Encaminhar ao executor somente
   `STATUS_MAPA='APTO_PARA_VALIDACAO_FINAL'`; os guards devem preservar notas
   com `TGFFIN`, validar `TGFTPV`/`TGFTIT`, usar `TGFNUM` com `FOR UPDATE WAIT` e
   gravar auditoria persistente.
3. Usar o wrapper parametrizado com `CONFIRMA_INSERCAO=NAO` durante a revisão e
   mudar para `SIM` apenas na confirmação operacional imediatamente anterior
   ao DML. Pós-validação e rollback autocontido continuam obrigatórios.
4. O caminho legado com `FNC_BUSCA_TAG_XML_GERAL` só deve ser usado quando a
   leitura direta não for viável. Nesse caso, validar `ALL_OBJECTS`,
   `ALL_ARGUMENTS` e `ALL_ERRORS`; compilar a fonte versionada somente com
   autorização e registrar schema, DDL, status e erros. Se faltar privilégio ou
   a function continuar inválida, isolar o Card 09 sem criar mapa nem inserir
   `TGFFIN`.
5. Antes de qualquer retomada, executar o inventário read-only de estado. A
   rotina deve distinguir ausência total, base criada sem classificação, mapa
   completo sem DML e DML auditado aguardando pós-validação; não consultar
   tabelas que ainda não existem nem repetir CTAS protegido.
6. O spool definitivo de cada fase deve ser novo, isolado e sem erros `ORA-`,
   `PLS-` ou `SP2-`. Diagnósticos interativos e tentativas anteriores ficam em
   arquivos separados e não podem ser usados como evidência final.
7. Divergências de identidade devem ser tratadas por diagnóstico read-only de
   `NOMEFANTASIA`/`RAZAOSOCIAL`, preservando a contagem e exigindo autorização
   específica. Essa autorização não libera automaticamente o DML de negócio.

## Encerramento opcional

`Limpar_Objetos_Revisao.sql` nao integra o Master. Ele identifica no
`CURRENT_SCHEMA` somente objetos reservados para a revisao (`BKP_RMD_%`,
`RMD_%`, `BKP_AJNP_TGFPAR` e `BKP_CLASSICMS_TGFPAR`), apresenta o inventario e
exige a frase `EXCLUIR OBJETOS` antes dos `DROP`s. A exclusao e definitiva do
ponto de vista da rotina e elimina a possibilidade de executar os rollbacks.

A versao revisada da normalizacao utiliza `RMD_MAP_UNIDADES`, evitando apagar
por engano uma eventual `MAP_UNIDADES` preexistente criada por outro processo.

## Objetos temporariamente desabilitados

`31_Recompilar_Objetos_Invalidos.sql` nao detecta nem corrige objetos
desabilitados: uma trigger pode estar valida em `ALL_OBJECTS` e desabilitada em
`ALL_TRIGGERS`. Por isso, o Master cria `RMD_CONTROLE_OBJETOS`, registra cada
objeto que estava habilitado antes do `DISABLE` e termina executando
`23_Validar_Reabilitar_Objetos.sql`. Essa etapa tenta reabilitar somente os
objetos afetados pela revisao e interrompe a conclusao se algum permanecer
desabilitado.

## Blocos identificados em Scripts_Variados.sql

1. Limites de data dos portais (`TSIPAR`).
2. Parametros fiscais e logo das empresas (`TGFEMP`).
3. Precificacao de TOPs de devolucao (`TGFTOP`).
4. Calculo de giro dos produtos (`TGFPRO`).
5. Numero de parcelas dos tipos de negociacao (`TGFTPV`).
6. Data de movimento ausente (`TGFCAB`).
7. Protocolos de NFe e CTe legados (`TGFCAB`).
8. Status de itens migrados, com controle da trigger (`TGFITE`).
9. ICMS gerencial dos produtos (`TGFPRO`).
10. Ruptura de estoque dos produtos (`TGFPRO`).
11. Ruptura de estoque das empresas (`TGFEMP`).
12. Sinais de TOP para giro e Gerente On-Line (`TGFTOP`) - manter cobertura parcial aprovada e registrar a limitacao.
13. Configuracao da analise de giro 848 (`TSIIMP`) - manter o modelo aprovado da base de referencia, com backup pontual.
14. Rastreamento de lote sem controle adicional (`TGFPRO`).
