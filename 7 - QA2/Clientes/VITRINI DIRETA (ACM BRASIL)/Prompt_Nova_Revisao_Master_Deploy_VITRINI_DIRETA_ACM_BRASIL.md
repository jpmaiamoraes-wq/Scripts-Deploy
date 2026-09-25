# Prompt — Nova Revisão Master Deploy

Inicie uma nova Revisão Master Deploy completa, autônoma, contínua e antifrágil para a base abaixo, carregando o conhecimento acumulado das revisões anteriores e aplicando as regras deste prompt.

## Base e conexão

- Base: `VITRINI DIRETA (ACM BRASIL)`
- Host Oracle: `10.110.106.12`
- Porta: `1521`
- Service name: `VITRINEDIRETAPRD.SANKHYACLOUD.COM.BR`
- Usuário informado: `FRANCISCO_JUNIOR`
- GP: será informado posteriormente

Não solicite, grave, exiba ou reproduza senha, token ou qualquer segredo em arquivos, logs, prompts, relatórios ou mensagens. A senha deve ser informada somente na tela de conexão manual do VS Code ou pelo mecanismo autorizado da própria conexão.

Não consulte o Vault para esta base. A conexão será obtida exclusivamente pelos dados deste prompt e pela conexão manual salva no VS Code. Se os dados de conexão estiverem ausentes em uma próxima execução, solicite somente os dados faltantes e nunca solicite senha no chat.

Quando eu informar:

`EXECUTAR VITRINI DIRETA (ACM BRASIL)`

retome a execução a partir do preflight, sem reiniciar etapas comprovadamente concluídas e sem apagar backups, mapas ou logs existentes.

## Ambiente obrigatório

Use sempre o VS Code como ambiente padrão. Abra a pasta efetiva do workspace:

`/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy`

Abra e execute os scripts como SCRIPT (`F5`) na conexão Oracle correta do VS Code. Não use SQL Developer.

Use o Master Deploy ativo em:

`7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql`

Execute a partir do diretório correto, preservando os includes relativos `@@`. Não transforme includes relativos em cópias obsoletas, não use Masters legados e não execute arquivos fora do Master ativo sem registrar a justificativa.

Mantenha todos os artefatos desta base em:

`7 - QA2/Clientes/VITRINI DIRETA (ACM BRASIL)/`

Use nomenclatura consistente:

- Card: tópico originado no dashboard de volumetria do Deploy Agent.
- Atividade: script ou procedimento executado no Master Deploy.

Nem todo Card exige uma Atividade; Cards informativos devem ser registrados sem criar DML desnecessário.

## Preflight obrigatório — somente leitura

Antes de qualquer alteração, deleção, inserção, recálculo, criação de objeto ou desativação temporária:

1. Confirme o workspace, diretório efetivo, Master ativo e todos os includes.
2. Inspecione os scripts antes de executá-los, corrigindo previamente erros de sintaxe, SQL*Plus/SQLcl, includes e mensagens `Error starting at line`.
3. Anexe no VS Code a conexão salva correspondente ao host, porta, service name e usuário informados.
4. Valide a identidade Oracle com `SESSION_USER`, `CURRENT_SCHEMA`, `SERVICE_NAME`, `DB_NAME` e, quando disponível, a rota da conexão.
5. Valide a empresa com:

```sql
SELECT CODEMP, RAZAOSOCIAL
  FROM TSIEMP
 WHERE UPPER(TRIM(RAZAOSOCIAL)) = 'VITRINI DIRETA (ACM BRASIL)';
```

Confirme que a empresa existe uma única vez e que o nome efetivo retornado corresponde à base informada.

6. Consulte a versão exclusivamente por:

```sql
SELECT TEXTO FROM TSIPAR WHERE CHAVE = 'VERSAOSKWBIN';
```

Registre somente a versão curta, por exemplo `4.36b142`.

7. Consulte quota, privilégios relevantes, objetos inválidos, dependências, triggers e estado de objetos temporários. Objetos inválidos devem ser listados um por linha.
8. Se faltar privilégio como `ALTER ANY PROCEDURE`, `ALTER ANY TRIGGER`, `CREATE ANY TABLE` ou equivalente, registre o erro exato, não afirme execução não realizada e isole o item.
9. Gere um ID único da execução, por exemplo `RMD_VDA_<YYYYMMDDHH24MISS>`, antes de qualquer alteração.
10. Registre o preflight em log persistente e atualize `Dados_Revisao.json`.

O preflight não pode executar DML/DDL de negócio. Ele pode apenas criar artefatos de controle quando isso for explicitamente necessário para a execução posterior e estiver registrado como etapa preparatória.

## Política de backup, reversão e rastreabilidade

### UPDATE e DELETE

Antes de cada `UPDATE` ou `DELETE`:

- crie backup persistente somente dos registros impactados;
- registre tabela, chaves, filtros, contagens antes/depois, ID de execução e usuário;
- valide a quantidade do backup antes da alteração;
- preserve valores anteriores suficientes para restauração;
- prepare e valide o rollback correspondente.

Não faça backup genérico da tabela inteira quando apenas um subconjunto será alterado.

### INSERT

Para inserção de novos registros, não é necessário backup prévio dos registros inexistentes. É obrigatório:

- registrar o mapa dos registros inseridos, suas chaves e o ID de execução;
- criar auditoria persistente da inserção;
- criar antes da execução um script de reversão que remova somente os registros inseridos por aquele ID;
- impedir deleção genérica por tabela, chave parcial ou critério amplo;
- validar quantidade, duplicidade e referências após a inserção.

### Reversão individual

Para cada script executado, crie um script de reversão individual, com todas as tabelas, nomes, chaves e filtros já preenchidos. Não exija parâmetros de ID ou nome de tabela para execução normal.

O único parâmetro permitido no rollback é a confirmação:

- `S`: executa a reversão após validar a auditoria e a quantidade;
- `N`: cancela sem alteração.

Scripts somente leitura também devem ter um registro individual de reversão/no-op, declarando que não houve mutação.

Não execute rollbacks automaticamente durante a revisão sem que a condição de erro os exija. Nunca apague backups, mapas ou logs existentes.

### Objetos criados na revisão

Registre todos os objetos Oracle criados exclusivamente durante esta revisão em um inventário persistente. Para função, trigger, tabela, sequência, view, procedure ou objeto auxiliar, preserve o estado anterior; se estava ausente, registre `AUSENTE`.

Ao final, somente se todas as atividades e Cards estiverem concluídos sem pendência ou conclusão parcial, gere o script:

`Limpar_Objetos_Revisao_VITRINI_DIRETA_ACM_BRASIL.sql`

Esse script deve conter somente objetos comprovadamente criados nesta revisão, nunca objetos preexistentes, e possuir apenas a trava `S/N` para confirmação. O script deve ser gerado, revisado e entregue; não o execute automaticamente.

Não execute `Limpar_Objetos_Revisao.sql` legado enquanto houver possibilidade de rollback ou enquanto o inventário de objetos não estiver validado.

## Execução autônoma e contínua

Execute de forma contínua a primeira onda de atividades e Cards independentes, sem parar para confirmação manual de cada etapa.

Para cada atividade:

1. Abra o script conhecido no VS Code.
2. Revise includes, variáveis, nomes de tabelas, IDs e condições destrutivas.
3. Execute como SCRIPT (`F5`).
4. Valide cada bloco, cada atividade e o log individual; não aceite o banner final como evidência.
5. Se houver erro de sintaxe, SQL*Plus/SQLcl ou `Error starting at line`, corrija previamente o script local, registre a correção e execute novamente.
6. Se houver erro funcional, privilégio, quota, conexão ou dependência externa, faça rollback apenas da transação/objeto temporário atual quando aplicável, registre o erro exato, marque o item como isolado e continue com as atividades independentes.
7. Não deixe um erro de uma atividade interromper silenciosamente a primeira onda inteira.
8. Use uma segunda onda apenas para itens isolados, após a primeira onda independente estar concluída.

`WHENEVER SQLERROR CONTINUE` só pode ser usado com controles explícitos por bloco, status persistente, contagem de erros e validação final. Uma mensagem posterior de sucesso nunca pode mascarar um bloco anterior com erro.

Após `ORA-17002`, `ORA-17008`, `ORA-12170` ou perda de sessão, reconecte no VS Code e valide novamente `SESSION_USER`, `CURRENT_SCHEMA` e `SERVICE_NAME` antes de retomar. Não confunda falha de transporte com sucesso lógico.

## Atividades do Master Deploy

Execute e valide as atividades aplicáveis do Master ativo, incluindo as atividades 01 a 31. Preserve a ordem e os includes do Master. Registre para cada uma:

- número da Atividade;
- Card relacionado, quando existir;
- script executado;
- início/fim;
- status real;
- contagens;
- backup e rollback;
- erros ou bloqueios;
- pós-validação.

Não marque atividade como concluída somente porque o Master chegou ao banner final.

## Card 09 — notas sem financeiro

Use primeiro o caminho direto, sem depender de function: execute
`7 - QA2/32A_Card09_Mapear_Direto_XML.sql`, aplicando a volumetria do dashboard
(`ATUALFIN<>0`, `TIPMOV<>'Z'` e ausência de `TGFFIN`) antes de ler
`TGFNFE.XML` com `XMLTABLE`. Persista o mapa base e a classificação `TGFPPG`
com `CREATE TABLE AS SELECT` direto e mantenha linhas não aptas para auditoria.

1. Gere `ID_EXECUCAO` e nomes de tabelas novos para cada tentativa.
2. Considere para o DML somente
   `STATUS_MAPA='APTO_PARA_VALIDACAO_FINAL'`.
3. Use o wrapper parametrizado com `CONFIRMA_INSERCAO=NAO` durante a revisão e
   altere para `SIM` apenas na confirmação operacional imediatamente anterior
   ao `INSERT`.
4. Mantenha `TGFNUM ... FOR UPDATE`, auditoria persistente, pós-validação e
   rollback autocontido.

O caminho legado com `FNC_BUSCA_TAG_XML_GERAL` é fallback. Só o utilize se a
leitura direta não for viável; então valide `ALL_OBJECTS`, `ALL_ARGUMENTS` e
`ALL_ERRORS`, compile a fonte versionada apenas com autorização e isole o Card
se faltar privilégio ou a function permanecer inválida.

Para candidatos do Card 09:

- validar XML, incluindo `<Dup>`, `<vDup>`, `<dVenc>` e `<nDup>`;
- criar backup/mapa persistente dos registros impactados e auditoria do ID;
- preservar `TGFFIN` existente;
- derivar `CODTIPTIT` exclusivamente de `TGFPPG.CODTIPTITPAD`;
- validar `TGFTPV` pela versão exata usada no cabeçalho;
- alocar `NUFIN` com bloqueio seguro de `TGFNUM.ULTCOD` (`FOR UPDATE`), somente com uma linha válida de `TGFNUM`;
- registrar mapa de auditoria de cada `NUNOTA`, `NUFIN`, valor, vencimento e origem XML;
- inserir somente linhas aptas, únicas e totalmente rastreáveis;
- usar o rollback individual de inserção para remover somente o ID auditado;
- executar pós-validação de quantidade, duplicidade, referências, auditoria e continuidade de `TGFNUM`.

Não inserir ou deletar genericamente. Se não houver candidato XML válido, concluir o Card como `SEM_CANDIDATOS_APTOS`, preservando backup, mapa, auditoria vazia e pós-validação.

## Cards 29 e 30 — colisões de bairros e endereços

A tratativa deve ser automática, sem confirmação manual prévia, porque a decisão operacional já está estabelecida. Isso não elimina os controles técnicos.

- identificar grupos de colisão;
- escolher determinísticamente o registro retido;
- criar mapa persistente e backup somente dos registros impactados;
- descobrir todas as FKs com `ALL_CONSTRAINTS` e `ALL_CONS_COLUMNS`, incluindo chaves compostas;
- mapear `origem -> destino` por tabela e coluna;
- atualizar referências antes de deletar obsoletos;
- impedir deleção genérica;
- validar quota e registrar `ORA-01950` ou erro equivalente se ocorrer;
- validar referências remanescentes, duplicidades, integridade e contagens ao final;
- preparar rollback individual com o mapa e os valores anteriores.

Se houver ambiguidade real de retenção, FK não mapeada, colisão não determinística, quota insuficiente ou divergência de contagem, isole o grupo/atividade com evidência e continue os itens seguros.

## Objetos inválidos e suporte externo

Liste todos os objetos inválidos, um por linha. Tente recompilar automaticamente somente quando o privilégio estiver disponível. Se não houver privilégio, registre o bloqueio exato e não afirme que houve recompilação.

Se necessário, prepare ticket para o Sankhya Cloud, capturando número e URL somente quando efetivamente disponíveis. Não invente ticket, número ou URL.

## Custos e consolidação do GOL

Investigue em modo somente leitura se existe objeto de banco para recálculo de custos ou consolidação do GOL. Se existir, registre os objetos e não execute recálculo sem escopo definido. Se não existir, forneça os `CODPROD` envolvidos separados por vírgula para uso na aplicação.

Qualquer trigger ou objeto temporariamente desativado deve ter estado anterior registrado, restauração garantida em fluxo normal e de erro, e validação independente no final.

## Onboarding e dados disponibilizados

Compare a configuração da base com os arquivos de onboarding disponíveis no Drive, somente leitura. Não faça upload, edição, compartilhamento ou exposição de credenciais.

Classifique cada achado somente como:

- dado ausente;
- divergência de configuração;
- arquivo-fonte indisponível;
- correspondente/sem divergência comprovada.

Não trate arquivo não localizado como divergência. O GP pode permanecer pendente até ser informado e isso não deve bloquear o preflight técnico.

Consolide o resultado no relatório textual principal, em seção própria de comparação de onboarding, e registre a fonte consultada e as limitações da comparação.

## Encerramento e relatório

Produza primeiro o relatório textual. Não gere PDF automaticamente; PDF somente será produzido após solicitação explícita e quando todas as atividades e Cards bloqueantes estiverem resolvidos, sem erro ou conclusão parcial.

O relatório final deve informar claramente:

- atividades concluídas e isoladas;
- Cards informativos;
- Cards bloqueantes resolvidos ou formalmente bloqueados por dependência externa;
- identidade Oracle, empresa, schema, service name e versão curta;
- objetos inválidos;
- erros e correções de scripts;
- tickets efetivamente existentes;
- backups, mapas, auditorias e rollbacks;
- objetos criados na revisão;
- script final de limpeza de objetos;
- comparação de onboarding;
- recálculo de custos/GOL;
- pendências externas;
- tudo que ainda depender do usuário.

Atualize também `Dados_Revisao.json` com o ID da execução, status por Card/Atividade, logs, quantidades e pendências.

Cards 08, 13, 14, 15, 29, 30 e 09 devem estar comprovadamente resolvidos, informativos ou formalmente isolados antes da conclusão. Não declare “sem pendências” se houver dependência externa, quota não regularizada, arquivo-fonte indisponível ou atividade isolada.

Mantenha Pushcut, notificações no iPhone e Apple Watch pausados.

Execute o mínimo de interação possível. Pare somente para senha/conexão manual, privilégio indispensável, quota impeditiva, ambiguidade destrutiva, erro de transporte sem sessão válida ou aprovação formal realmente necessária.
