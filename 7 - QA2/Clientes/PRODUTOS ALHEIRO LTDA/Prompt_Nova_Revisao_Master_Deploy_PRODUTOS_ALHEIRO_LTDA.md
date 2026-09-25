# Prompt para nova Revisão Master Deploy

Inicie uma nova Revisão Master Deploy completa, autônoma e antifrágil para a base Oracle abaixo, carregando o conhecimento acumulado das revisões anteriores e aplicando também as melhorias descritas neste prompt.

## Base e responsável

- Empresa/base: **PRODUTOS ALHEIRO LTDA**
- GP: **dandara.leite@sankhya.com.br**
- Host Oracle: **10.100.76.5**
- Porta: **1521**
- Service name: **ALHEIROPRD.SANKHYACLOUD.COM.BR**
- Usuário/schema esperado: **FRANCISCO_JUNIOR**
- Banco esperado: **Oracle** — validar após a conexão

Não solicite, grave ou reproduza senha em arquivos, logs, prompts, relatórios ou mensagens. A senha deve ser obtida somente pela conexão manual já realizada pelo usuário ou pelo Vault/conector autorizado. Se a conexão não estiver disponível, pare apenas nesse ponto e solicite que eu reconecte.

## Comando de início

Quando eu informar:

`EXECUTAR PRODUTOS ALHEIRO LTDA`

retome a execução a partir do preflight, sem reiniciar etapas já comprovadamente concluídas e sem apagar backups ou logs existentes.

## Regras gerais

1. Use o Master Deploy ativo em:

   `7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql`

   Execute a partir do diretório correto, preservando os includes relativos `@@` e evitando o Master legado ou cópias obsoletas.

2. Diferencie os termos:

   - **Card**: tópico originado no dashboard de volumetria do Deploy Agent.
   - **Atividade**: script ou procedimento executado no Master Deploy.

   Nem todo Card exige uma Atividade; muitos são apenas informativos. Caso um Card seja tratado por uma Atividade, mantenha os dois vínculos documentados sem misturar a nomenclatura.

3. Faça primeiro um preflight completo e somente leitura, validando:

   - diretório, scripts e versão do Master ativo;
   - conexão, service name, usuário/schema e identidade da empresa;
   - acessibilidade da rota Oracle;
   - `TSIEMP.RAZAOSOCIAL`;
   - versão em `TSIPAR`, usando:

     `SELECT TEXTO FROM TSIPAR WHERE CHAVE = 'VERSAOSKWBIN'`

     No relatório, registrar somente a versão curta, como `4.36b142`, extraída do texto retornado.

   Não considerar uma execução concluída apenas porque o banner final foi exibido. Validar também os resultados de cada bloco e os logs.

4. Antes de qualquer alteração, deleção, recálculo ou desativação temporária de objeto:

   - criar backup persistente, identificado por cliente, data e ID de execução;
   - registrar contagem de linhas, chaves e escopo;
   - preparar rollback simples, explícito e seguro;
   - validar o backup antes de prosseguir.

   Não executar `Limpar_Objetos_Revisao.sql` enquanto houver possibilidade de rollback.

5. Em cada atividade, registrar status, ID de execução, contagens, exceções, backup, rollback e pós-validação. Corrigir localmente qualquer erro de sintaxe, erro de SQL*Plus/SQLcl ou mensagem `Error starting at line` antes de declarar a revisão sem erros não tratados.

6. Scripts que usem `WHENEVER SQLERROR CONTINUE`, commits intermediários ou blocos independentes devem manter evidência por bloco. Um erro posterior não pode ficar escondido por um status final aparentemente bem-sucedido.

7. Faça o mínimo de perguntas possível. Pare somente para senha/conexão, privilégio indispensável, ambiguidade com impacto destrutivo ou aprovação formal de alteração.

## Escopo técnico conhecido

Execute e valide as atividades aplicáveis do Master Deploy, incluindo as atividades 01 a 31, sem presumir que todas tenham correção necessária. Para cada Card informativo, registrar a situação e a justificativa.

### Cards 29 e 30 — registros obsoletos

- Trabalhar com mapa persistente de obsoleto para registro retido.
- Descobrir tabelas físicas e FKs com `ALL_CONSTRAINTS` e `ALL_CONS_COLUMNS`.
- Validar quota e privilégios antes de criar backups.
- Usar backups qualificados pelo proprietário/schema, com auditoria e rollback.
- Nunca fazer deleção genérica sem rastreabilidade.
- Validar referências remanescentes, duplicidade pós-tratamento e ausência dos obsoletos.

### Card 09 — notas sem financeiro

Tratar como atividade controlada e separada, somente se o diagnóstico comprovar necessidade. Preferir o mapa direto por XML:

- aplicar primeiro a volumetria do dashboard (`ATUALFIN<>0`, `TIPMOV<>'Z'` e ausência de `TGFFIN`);
- extrair `vDup`, `dVenc` e `nDup` diretamente de `TGFNFE.XML` com `XMLTABLE`;
- persistir o mapa por `CREATE TABLE AS SELECT` direto, sem envolver XMLTABLE em `EXECUTE IMMEDIATE`;
- manter linhas inelegíveis no mapa, mas encaminhar ao DML somente `APTO_PARA_VALIDACAO_FINAL`;
- usar wrapper com ID/tabelas novos, auditoria, `TGFNUM ... FOR UPDATE WAIT`, pós-validação e rollback.

Use a function somente como fallback quando a leitura direta não for viável:

- antes do preflight, validar `FNC_BUSCA_TAG_XML_GERAL` em `ALL_OBJECTS`, `ALL_ARGUMENTS` e `ALL_ERRORS`;
- se a função estiver ausente ou inválida, somente com autorização tentar a compilação controlada: `ALTER FUNCTION ... COMPILE` para objeto existente ou a fonte versionada `7 - QA2/Scripts Originais/FNC_BUSCA_TAG_XML_GERAL.sql` para objeto ausente;
- registrar `ID_EXECUCAO`, proprietário/schema, status anterior, DDL, status posterior e `ALL_ERRORS`; prosseguir somente com `STATUS=VALID` e zero erros;
- se faltar privilégio, a fonte estiver indisponível ou a função permanecer inválida, registrar a causa exata, preparar pendência/ticket Cloud e isolar o Card 09 sem interromper atividades independentes;

- validar XML, inclusive `<Dup>` e `<dVenc>`;
- preservar `TGFFIN` existente;
- derivar `CODTIPTIT` de `TGFPPG.CODTIPTITPAD`;
- alocar `NUFIN` de forma segura por `TGFNUM.ULTCOD` com bloqueio apropriado;
- gerar mapa de auditoria, backup e rollback;
- nunca executar inserção ou deleção genérica sem escopo, aprovação e rastreabilidade.

### Objetos inválidos

- Identificar e listar todos os objetos inválidos, um por linha.
- Se faltar `ALTER ANY PROCEDURE` ou outro privilégio necessário, registrar o bloqueio exato.
- Não afirmar que houve recompilação se ela não tiver sido efetivamente executada.
- Preparar, quando necessário, texto de ticket para o Sankhya Cloud solicitando a compilação, com organização, assunto, descrição em primeira pessoa, categoria/produto, versão curta e ambiente Oracle.
- Se o chamado for aberto, capturar o número e a URL para o relatório.

### Onboarding

Comparar a configuração efetiva da base com os arquivos-fonte de onboarding disponíveis no Drive, em modo de leitura, antes do relatório final. Classificar cada achado como:

- dado ausente;
- divergência de configuração;
- arquivo-fonte indisponível ou não localizado.

Não classificar a ausência de um arquivo como divergência de configuração. Não expor credenciais eventualmente presentes nos documentos do onboarding.

### GOL e recálculo de custos

Investigar primeiro, somente em leitura, se existe objeto de banco que execute o recálculo de custos ou o consolidador do Gerente On-Line. Se não existir ou não puder ser comprovado:

- apresentar a lista dos `CODPROD` envolvidos, separados por vírgula, para uso na rotina nativa da aplicação;
- não executar recálculo ou consolidação diretamente sem autorização específica;
- se houver desativação temporária de trigger/objeto, registrar o estado anterior, restaurar mesmo em caso de erro e validar o estado final de forma independente.

## Melhorias obrigatórias aprendidas nesta revisão

1. Resolver previamente problemas de script que gerem `Error starting at line`, incluindo erros de declaração `VARIABLE` e blocos de criação de tabelas de backup, com correções localizadas, idempotentes e auditáveis.
2. Não aceitar somente o status final do Master: cada atividade deve ter pós-validação própria e evidência no log.
3. Tratar backups de custos, referências, auditorias e triggers como itens persistentes até a conclusão definitiva.
4. Para qualquer alteração em tabelas históricas, atualizar todas as versões pertinentes e validar o histórico completo.
5. Para cards bloqueantes — especialmente 08, 13, 14 e 15 — comprovar resultado zero ou documentar objetivamente o bloqueio antes de considerar a revisão concluída.
6. Produzir primeiro um relatório textual de entrega para revisão. Não gerar PDF neste chat sem minha solicitação explícita e sem que todas as atividades e Cards bloqueantes estejam resolvidos, sem erro ou sem conclusão parcial.
7. Manter todos os artefatos específicos desta base em:

   `7 - QA2/Clientes/PRODUTOS ALHEIRO LTDA/`

8. Manter a ação de notificações Pushcut/iPhone/Apple Watch pausada. Não instalar, configurar ou disparar notificações móveis.
9. Como a execução ocorre no computador local, manter o Mac ligado, acordado e conectado; após bloqueio de tela, reconexão ou reinício do VS Code, revalidar a identidade da conexão antes de continuar.

## Critério de conclusão

A revisão somente poderá ser declarada concluída quando:

- todas as atividades aplicáveis tiverem status final `CONCLUIDO`, `CONCLUIDO_SEM_DIVERGENCIAS` ou equivalente devidamente comprovado;
- não houver atividade com erro, pendência ou conclusão parcial sem tratamento;
- Cards bloqueantes estiverem comprovadamente zerados ou formalmente bloqueados por dependência externa;
- backups, auditorias e rollbacks estiverem documentados;
- objetos inválidos e eventuais privilégios ausentes estiverem registrados;
- onboarding estiver comparado ou sua indisponibilidade estiver explicitamente documentada;
- a trigger e demais objetos temporariamente alterados estiverem no estado correto;
- o relatório textual estiver atualizado.

Ao final, informe de forma objetiva: atividades concluídas, Cards informativos, pendências externas, objetos inválidos, tickets, backups/rollbacks e o que ainda depende de mim. Não gere o PDF automaticamente.
