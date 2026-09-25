# Prompt — Nova Revisão Master Deploy — JCLM INDUSTRIA E COMERCIO LTDA

Inicie uma nova Revisão Master Deploy completa, contínua, controlada e baseada em evidências para a base abaixo. Aplique as instruções do `AGENTS.md`, os guias atuais do repositório e os aprendizados consolidados nas revisões anteriores, especialmente a evolução registrada na base VITRINI DIRETA (ACM BRASIL).

## Base, conexão e comunicação

- Base/cliente: `JCLM INDUSTRIA E COMERCIO LTDA`
- Host Oracle: `10.100.86.2`
- Porta: `1521`
- Service name: `JCLMPRD.SANKHYACLOUD.COM.BR`
- Usuário Oracle: `FRANCISCO_JUNIOR`
- Gerente de Projetos: confirmar/registrar `jessika.andrade@sankhya.com.br`
- Assistente de projetos informada: `Ana Rodrigues`

Antes do encerramento, solicite e registre o nome completo e o e-mail da assistente de projetos. Não infira o e-mail por histórico, nome de arquivo ou domínio. Se a assistente confirmada for Ana Paula Rodrigues (`ana.rodrigues@sankhya.com.br`), enviar o e-mail somente para ela, sem cópia para o GP. Se o nome/e-mail confirmado for diferente, interromper somente o envio e solicitar confirmação explícita dos destinatários.

Nunca solicite, grave, exiba ou reproduza senha, token, código de autenticação ou qualquer segredo no chat, prompt, arquivo, log, relatório ou memória. A credencial Oracle somente pode ser recuperada pelo Keychain do macOS ou pelo mecanismo autorizado da conexão; a VPN continua manual pelo FortiClient.

## Frase de retomada

Quando eu informar:

`EXECUTAR JCLM INDUSTRIA E COMERCIO LTDA`

retome a execução a partir do estado persistido, sem reiniciar etapas comprovadamente concluídas e sem apagar backups, mapas, auditorias, logs ou reversões existentes.

## Ambiente e rota padrão

Use como caminho padrão o executor Oracle direto:

`7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py`

Não use VS Code, SQL Developer ou outro aplicativo externo para consultas ou execução normal. O executor direto fica limitado a `self-check`, identidade e consultas `SELECT`/`WITH` explicitamente somente leitura.

Para alterações, use:

`7 - QA2/Revisao Master Deploy/Automacao/oracle_batch.py`

O modo `plan` deve ser executado e validado antes do modo `apply`. O lote deve abrir uma sessão, registrar identidade, privilégios/quota, hash dos arquivos, log completo, contagens, erros e pós-validação. Deve haver uma única confirmação nativa imediatamente antes das alterações do lote; não solicitar confirmação por instrução escrita a cada linha.

Somente entradas versionadas e homologadas dentro de `7 - QA2` podem ser aplicadas. O Master 01–31, o mapa inicial compartilhado do Card 09 e as fases por cliente com os prefixos `29_30_Merge_Antifragil_` e `32A_Card09_Mapear_Direto_XML_` são entradas aprovadas. O INSERT financeiro do Card 09 permanece em fase separada, após revisão do mapa. Não incluir no lote normal scripts de limpeza, reversões ou arquivos arbitrários.

Cada nova pasta preparada deve manter:

- `Executar_Revisao_JCLM_INDUSTRIA_E_COMERCIO_LTDA.sql`;
- `ROTEIRO_FALLBACK_LEGADO_VSCODE.md`;
- `Dados_Revisao.json`;
- logs, mapas, backups, auditorias e reversões em `Logs/` e `Artefatos_Revisao/`.

A abordagem legada pelo VS Code é apenas fallback operacional. Se a falha direta ocorrer antes de DML/DDL, pode usar o wrapper após reconfirmar identidade. Se houver possível alteração parcial, primeiro consultar o estado e decidir por retomada ou reversão. Não trocar de rota automaticamente para encobrir erro.

## Política de custo e delegação

- Consultar o limite atual antes de iniciar a revisão completa.
- Agente principal: `gpt-5.6-luna`, esforço `xhigh`.
- No máximo um subagente simultâneo, sempre `gpt-5.6-luna`, esforço `medium`.
- Delegar `ticket_objetos_invalidos` somente quando a etapa 31 encontrar objetos nativos `INVALID` e ausência comprovada de `ALTER ANY PROCEDURE`.
- Delegar `relatorio_entrega_tecnica` somente depois de finalizados os artefatos técnicos, para preparar o TXT e, após aprovação explícita, o PDF.
- Não ativar Ultra automaticamente. Usar modelo superior somente com evidência de ambiguidade, falha de script ou validação crítica que o Luna não consiga fechar.
- Preservar preflight, backup/mapa, auditoria, pós-validação e reversão mesmo quando houver paralelismo.

## Primeira etapa: leitura do projeto e preparação

Antes de qualquer conexão ou alteração:

1. Ler o `AGENTS.md` efetivo e os guias em `7 - QA2/Revisao Master Deploy/`.
2. Confirmar o checkout e o diretório efetivo:
   `/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy`
3. Ler o Master ativo:
   `7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql`
4. Confirmar todos os includes `@@` no mesmo diretório.
5. Preparar os artefatos da base em:
   `7 - QA2/Clientes/JCLM INDUSTRIA E COMERCIO LTDA/`
6. Gerar um identificador único antes de qualquer alteração, por exemplo `RMD_JCLM_<YYYYMMDDHH24MISS>`.
7. Atualizar `Dados_Revisao.json` sem senha, contendo cliente, conexão sem segredo, GP, assistente quando confirmada, estado da rota, identidade, IDs de execução, logs, quantitativos, pendências e comunicação.

## Preflight obrigatório — somente leitura

Antes de qualquer UPDATE, DELETE, INSERT, DDL, recálculo, criação de objeto ou desativação temporária:

- validar `SESSION_USER`, `CURRENT_SCHEMA`, `SERVICE_NAME`, `DB_NAME`, versão curta, rota, quota e privilégios;
- validar a identidade da empresa em `TSIEMP`;
- se a razão social exata não retornar uma linha, executar diagnóstico read-only das variações de `RAZAOSOCIAL`/`NOMEFANTASIA`, listar todas as linhas e solicitar autorização específica antes de qualquer DML;
- verificar objetos inválidos e dependências, listando cada objeto em uma linha;
- verificar triggers, objetos temporários, tabelas, chaves estrangeiras e estado de possíveis tentativas anteriores;
- registrar resultado em log persistente e em `Dados_Revisao.json`;
- não interpretar erro de rota, VPN, privilégio, quota ou transporte como sucesso lógico.

Após `ORA-17002`, `ORA-17008`, `ORA-12170` ou perda de sessão, reconectar e validar novamente usuário, schema e serviço antes de retomar. Se a conexão direta estiver limitada, solicitar o ajuste necessário explicando a limitação objetiva; não trocar automaticamente para outro aplicativo.

## Backup, auditoria e reversão

Para cada UPDATE ou DELETE:

- criar backup persistente somente dos registros impactados;
- registrar tabela, chaves, filtro, contagens antes/depois, usuário e ID de execução;
- preparar e validar a reversão antes da alteração;
- preservar valores anteriores suficientes para restauração.

Para cada INSERT:

- persistir mapa das linhas inseridas e auditoria com o ID de execução;
- preparar reversão que remova somente as linhas daquele ID;
- validar quantidade, duplicidades, referências e continuidade das sequências após a inserção.

Não fazer exclusão genérica, não apagar evidências e não apresentar DDL confirmado como automaticamente revertido por `ROLLBACK`. Usar o roteiro de reversão autocontido adequado.

## Execução do Master 01–31

Executar e validar as atividades aplicáveis do Master ativo, preservando ordem e includes. Para cada atividade, registrar:

- código e propósito;
- script, início e fim;
- último status comprovado;
- contagens;
- backup, auditoria e reversão;
- erros e correções efetivamente realizadas;
- pós-validação somente leitura.

Não marcar atividade como concluída apenas pelo banner final. Um erro deve ser isolado com evidência, sem interromper silenciosamente as atividades independentes.

## Card 09 — Notas sem Financeiro

Usar como caminho principal a leitura direta de `TGFNFE.XML` com `XMLTABLE`, sem depender de function. Primeiro aplicar a redução de volumetria do dashboard, considerando `ATUALFIN<>0`, `TIPMOV<>'Z'` e ausência de `TGFFIN`; depois persistir mapa base e classificação de `TGFPPG`.

Regras obrigatórias:

- gerar nomes de mapa, auditoria e ID novos para a base;
- classificar todos os candidatos, mantendo os não aptos para auditoria;
- considerar DML somente para `APTO_PARA_VALIDACAO_FINAL`;
- validar `<Dup>`, `<vDup>`, `<dVenc>` e `<nDup>`;
- classificar múltiplos XML como `REVISAR_MULTIPLOS_XML`;
- não alterar candidatos sem XML válido ou sem vínculo financeiro determinístico;
- derivar `CODTIPTIT` exclusivamente de `TGFPPG.CODTIPTITPAD`;
- validar `TGFTPV` pela versão exata do cabeçalho;
- alocar `NUFIN` com bloqueio seguro de `TGFNUM.ULTCOD` e somente uma linha válida;
- revisar mapa e aplicar o INSERT em fase separada, com confirmação operacional imediatamente anterior;
- registrar auditoria persistente, pós-validação e reversão autocontida;
- se não houver aptos, concluir como `SEM_CANDIDATOS_APTOS`, preservando mapa e pós-validação.

A function `FNC_BUSCA_TAG_XML_GERAL` é fallback. Só compilar fonte versionada se a leitura direta não for viável, após consultar `ALL_OBJECTS`, `ALL_ARGUMENTS` e `ALL_ERRORS` e obter a autorização necessária.

## Atividades 29 e 30 — bairros e endereços

Se houver colisões:

- identificar grupos e escolher determinísticamente o registro retido;
- criar mapa e backup somente dos registros impactados;
- descobrir todas as FKs com `ALL_CONSTRAINTS` e `ALL_CONS_COLUMNS`, inclusive compostas;
- atualizar referências antes de excluir obsoletos;
- validar quota, referências remanescentes, duplicidades e integridade;
- gerar novo plano/hash e novo ID de execução após a versão final;
- preparar reversão individual com mapa e valores anteriores.

Isolar ambiguidades reais, FKs não mapeadas, quota insuficiente ou divergências de contagem com evidência.

## Objetos inválidos e ticket Sankhya Cloud

Se a etapa 31 identificar objetos nativos `INVALID` sem `ALTER ANY PROCEDURE`:

- delegar o preparo ao agente `ticket_objetos_invalidos` com a skill `sankhya-ticket-objetos-invalidos`;
- exigir contagem, lista completa, schema, usuário, evidência do privilégio ausente, organização e rascunho do formulário;
- não permitir DML/DDL, login, upload ou envio externo ao subagente;
- confirmar visualmente a organização real do cliente, nunca `SANKHYA JIVA` para este motivo;
- usar prioridade `Normal`, categoria `Cloud/SaaS` → `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`, ambiente `Produção` e banco `Oracle`;
- não anexar logs, credenciais ou artefatos por padrão;
- verificar se já existe ticket para a mesma base/execução antes de criar outro;
- solicitar confirmação imediatamente antes do envio;
- somente após o envio efetivo registrar número, URL, status e campos no `Dados_Revisao.json`, no relatório e no registro da base.

## Volumetria obrigatória

Antes de redigir qualquer relatório, usar a conexão direta do executor Oracle para:

1. Ler `7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml` e executar a `queryString` com os indicadores de integridade.
2. Ler `7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/Volumetria Deploy Agent.xml` e executar os complementos necessários.
3. Persistir o resultado na pasta da base, sem credenciais, com sessão, schema, serviço, data/hora, fontes, quantitativos, `dml_executado=false` e `ddl_executado=false`.
4. Usar os mesmos quantitativos no TXT e no PDF.
5. Confirmar que retornaram zero: financeiros sem nota, itens sem cabeçalho, cabeçalhos sem itens e códigos fiscais de cidades duplicados.
6. Confirmar também os cards críticos 08, 13, 14 e 15. Se qualquer indicador crítico for maior que zero, interromper o PDF e informar o agente principal.

## Onboarding

Executar a verificação Oracle do onboarding em modo somente leitura e comparar as fontes documentais disponíveis com as tabelas correspondentes. Classificar cada achado como dado ausente, divergência de configuração, arquivo-fonte indisponível ou correspondente/sem divergência comprovada. Não tratar arquivo não localizado como divergência e não expor credenciais SMTP ou certificados.

Registrar fontes, datas, quantidades, correspondências e pontos de conferência em artefato próprio e no relatório. Sem evidência da verificação necessária, não gerar PDF.

## Relatório, aprovação e envio

Após finalizar os artefatos técnicos:

1. Delegar ao agente `relatorio_entrega_tecnica`, no máximo um subagente simultâneo, para consumir somente as evidências finalizadas.
2. Usar a skill `artifact-template-relatorios-corporativos-sankhya`.
3. Gerar primeiro o TXT completo, com a volumetria atual, 21 cards, atividades 01–31 e etapa regular do Card 09, onboarding, objetos inválidos, tickets efetivos, backups, mapas, auditorias e índice de reversão.
4. Escrever para GP e consultores: não citar apenas números de cards; informar descrição ou propósito. Evitar estrangeirismos ou explicar o termo na primeira ocorrência.
5. Não destacar tentativas superadas, barreiras internas, ausência de GP, compartilhamento no Drive ou `PENDENTE_VALIDACAO`.
6. Não incluir na capa/texto de entrega “ID da execução”, “ID do Master” ou “Estado deste artefato”, salvo solicitação expressa.
7. Submeter o TXT para aprovação explícita.
8. Após aprovação, gerar o PDF Sankhya, renderizar e conferir visualmente todas as páginas; não enviar arquivo sem essa validação.
9. O agente principal deve conferir base, assistente, GP, conta corporativa, destinatários e anexo antes do envio.
10. Enviar somente o PDF final, com:

   - assunto: `Conclusão da revisão Master Deploy — JCLM INDUSTRIA E COMERCIO LTDA`;
   - corpo:

     `Olá,`

     `Concluímos a etapa de revisão Master Deploy da base JCLM INDUSTRIA E COMERCIO LTDA.`

     `Encaminho em anexo o relatório de entrega técnica com o resumo do que foi executado.`

     `Atenciosamente,`

Use exclusivamente a conta corporativa `francisco.junior@sankhya.com.br`. Nunca enviar pela conta pessoal. Não anexar logs, credenciais, mapas, scripts ou outros artefatos. Se a conta corporativa não estiver autenticada ou o anexo não puder ser carregado, deixar o rascunho preparado e solicitar ação manual; não enviar sem o PDF.

## Critério de conclusão

Concluir somente quando houver evidência final de cada atividade/Card executado ou isolado, identidade Oracle comprovada, logs completos, volumetria atual persistida, quatro indicadores de integridade zerados, backups/mapas/auditorias/reversões preservados, onboarding registrado, TXT aprovado, PDF validado visualmente e comunicação enviada ou claramente registrada como aguardando ação manual. Nunca declarar “sem pendências” enquanto houver dependência externa relevante.

Mantenha Pushcut, notificações no iPhone e Apple Watch pausados durante a revisão.

Execute o mínimo de interação possível e pare apenas para conexão/senha manual, privilégio ou quota impeditivos, ambiguidade destrutiva, erro de transporte sem sessão válida, confirmação do cliente ou aprovação formal necessária.
