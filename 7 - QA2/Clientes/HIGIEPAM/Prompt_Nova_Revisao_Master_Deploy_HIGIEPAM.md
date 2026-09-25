# Prompt — Nova Revisão Master Deploy — HIGIEPAM

Inicie uma nova Revisão Master Deploy completa, contínua, base-wide, controlada e baseada em evidências para a base abaixo. Aplique o AGENTS.md vigente, os guias de 7 - QA2/Revisao Master Deploy e os aprendizados consolidados nas revisões VITRINI DIRETA e JCLM.

Este documento é um handoff operacional. Não iniciar conexão, DML ou DDL apenas por ler o prompt. Começar a execução quando o usuário informar:

EXECUTAR HIGIEPAM

## Base, conexão e comunicação

- Cliente/base: HIGIEPAM
- Host Oracle: 10.100.106.5
- Porta: 1521
- Service name: HIGIEPAMPRD.SANKHYACLOUD.COM.BR
- Usuário Oracle: FRANCISCO_JUNIOR
- Gerente de Projetos: ronan.junior@sankhya.com.br
- Analista informada: Ana Rodrigues
- E-mail da analista: ainda não informado; solicitar e registrar nome completo e e-mail antes do encerramento. Nunca inferir por histórico, nome de arquivo ou domínio.

Não solicitar, gravar, exibir ou reproduzir senha, token, código de autenticação ou qualquer segredo no chat, prompt, arquivo, log, relatório ou memória. A credencial Oracle somente pode ser recuperada pelo Keychain do macOS ou pelo mecanismo autorizado da conexão. A VPN continua sendo um requisito técnico manual.

## Escopo e autorização

A revisão é vinculada à base de dados inteira, BASE_INTEIRA, e não à quantidade de empresas cadastradas em TSIEMP. Não usar contagem de empresas como gate, não pedir confirmação por causa de múltiplas empresas e não restringir a revisão por CODEMP sem decisão específica.

Validar somente se a sessão Oracle conectada corresponde com segurança à base informada. Variações entre o nome da conexão, o service name e as razões sociais de TSIEMP são aceitáveis quando houver correspondência segura. Se não houver correspondência segura, interromper e pedir validação antes de qualquer mutação.

A frase EXECUTAR HIGIEPAM é a autorização operacional prévia para a revisão desta base, inclusive para as confirmações nativas repetidas do lote aprovado. Autorizar as solicitações da mesma onda sem interromper o usuário a cada tela. Manter plano, hash, ID_EXECUCAO, backup, auditoria, pós-validação e reversão. Uma reescrita ou retomada exige novo plano, hash e ID, mas não nova pergunta quando permanecer dentro do escopo autorizado.

Parar somente por base/serviço diferente, identidade ambígua, senha ou VPN, privilégio indispensável, quota impeditiva para persistência segura, duplicidade de ticket, alteração fora do escopo, risco sem backup/mapa/reversão ou impedimento técnico que exija decisão.

## Rota, artefatos e segurança

Usar como rota principal o executor Oracle direto:

7 - QA2/Revisao Master Deploy/Automacao/oracle_direct.py

O executor direto é limitado a self-check, identidade e consultas SELECT/WITH explicitamente read-only. Para alterações usar:

7 - QA2/Revisao Master Deploy/Automacao/oracle_batch.py

Executar plan, validar o plano expandido e somente depois executar apply. O lote deve registrar identidade efetiva, schema, service name, privilégios, quota diagnóstica, hash dos arquivos, log completo, erros, contagens, ID_EXECUCAO e pós-validação read-only.

Somente entradas versionadas e homologadas dentro de 7 - QA2 podem ser aplicadas: Master 01–31, mapa inicial compartilhado do Card 09, fases por cliente com prefixos 29_30_Merge_Antifragil_ e 32A_Card09_Mapear_Direto_XML_. O INSERT financeiro do Card 09 permanece separado, após revisão do mapa. Não aplicar arquivos arbitrários, scripts de limpeza ou reversões no lote normal.

Preparar a pasta:

7 - QA2/Clientes/HIGIEPAM/

Manter:

- Executar_Revisao_HIGIEPAM.sql
- ROTEIRO_FALLBACK_LEGADO_VSCODE.md
- Dados_Revisao.json
- Logs/
- Artefatos_Revisao/
- backups, mapas, auditorias, scripts de reversão e fontes usadas

A abordagem legada pelo VS Code é apenas fallback. Se o executor direto falhar antes de qualquer mutação, o wrapper legado poderá ser usado após reconfirmação da identidade. Se houver possível alteração parcial, consultar o estado antes de retomar ou reverter. Não trocar de rota automaticamente para esconder erro.

## Primeira etapa: preparação e preflight

Antes de qualquer conexão ou alteração:

1. Ler o AGENTS.md efetivo e os guias do projeto.
2. Confirmar o checkout:
   /Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy
3. Ler o Master ativo em:
   7 - QA2/Revisao Master Deploy/Revisao_Master_Deploy.sql
4. Confirmar todos os includes @ e @@ dentro da raiz homologada.
5. Preparar os artefatos da base e o Dados_Revisao.json sem segredos.
6. Gerar ID_EXECUCAO único antes de qualquer alteração, por exemplo RMD_HIGIEPAM_YYYYMMDDHH24MISS.
7. Consultar o limite disponível antes de iniciar a revisão completa.

O preflight read-only deve validar SESSION_USER, CURRENT_SCHEMA, SERVICE_NAME, DB_NAME, versão curta, rota, privilégios, quota diagnóstica, objetos inválidos, dependências físicas, triggers, objetos temporários e possíveis tentativas anteriores.

Quota é diagnóstico, não gate universal. Não solicitar provisão de cotas nem bloquear atividades independentes por USER_TS_QUOTAS=0. Se uma etapa mutável precisar de persistência e não houver tabela/auditoria segura disponível, bloquear apenas esse ramo e registrar a razão.

Após ORA-17002, ORA-17008, ORA-12170 ou perda de sessão, reconectar e validar novamente usuário, schema e service name. Nunca tratar erro de transporte como sucesso.

## Onboarding automático

Iniciar a conferência do onboarding automaticamente no começo da revisão, em paralelo às atividades independentes, sem esperar solicitação posterior.

- Usar primeiro a fonte mais recente exibida no site Onboarding Deploy.
- Usar documentos locais somente para complementar algo que o site não expõe e registrar a fonte efetivamente usada.
- Comparar CNPJs/razões sociais com TSIEMP apenas como informação de escopo. Não incluir, remover ou alterar empresas.
- Para usuários, considerar somente registros com grupo preenchido, CODGRUPO > 0. Registros sem grupo pertencem ao modelo e não devem gerar divergência automática.
- Em arquivos repetidos, considerar o mais recente.
- Comparar usuários por e-mail e registrar divergências de grupo, empresa, nome e registros extras/ausentes.
- Persistir fonte, data, quantidade, critérios, correspondências, divergências e consultas read-only.

A quantidade de empresas não bloqueia a revisão. Bloqueios ficam restritos a identidade ou escopo ambíguos e divergências que exigem decisão.

## Primeira onda sem reescrita emergencial

Antes do primeiro apply, validar todos os blocos e includes aprovados com plano expandido, binds efetivamente usados por cada bloco, schema/proprietário explícitos, ordem de criação e leitura de artefatos, guards de estado e ausência de colunas repetidas.

Aplicar previamente estes aprendizados:

- Quando uma tabela de backup é criada e consultada no mesmo bloco, usar referência dinâmica válida ou separar os blocos para evitar ORA-00942.
- Inicializar binds SQL*Plus antes do uso para evitar SP2-0552.
- Filtrar binds por bloco para evitar DPY-4008.
- Usar DML dinâmico somente onde a role exigir e registrar o motivo de eventual ORA-01031.
- Remover DEFINE internos que sobrescrevam parâmetros do lote.
- Preferir CTAS/XMLTABLE direto em vez de EXECUTE IMMEDIATE que gere PLS-00103.
- Não repetir colunas em cursores para evitar PLS-00402.
- Inventariar tabelas físicas e dependências por FK; views não são dependências físicas.
- Após erro de transporte, reconectar e validar identidade, schema e serviço antes da retomada.

Preservar cada erro no log original, isolar o ramo afetado, transformar a causa em guarda ou correção genérica e não repetir o Master inteiro após commit parcial.

## Backup, auditoria e reversão

Para cada UPDATE ou DELETE:

- criar backup persistente somente dos registros impactados;
- registrar tabela, chaves, filtro, contagens antes/depois, usuário e ID_EXECUCAO;
- preparar e validar a reversão antes da alteração;
- preservar valores anteriores suficientes para restauração.

Para cada INSERT:

- persistir mapa das linhas inseridas e auditoria com o ID_EXECUCAO;
- validar quantidade, duplicidade, referências e continuidade de sequências;
- preparar reversão que remova somente as linhas daquele ID.

Não fazer exclusão genérica, não apagar evidências e não apresentar DDL confirmado como automaticamente revertido por ROLLBACK. Usar o script de reversão autocontido adequado.

## Execução do Master 01–31

Executar as atividades aplicáveis preservando ordem e includes. Para cada atividade registrar código, propósito, script, início/fim, status comprovado, contagens, backup, auditoria, reversão, erros, correções e pós-validação read-only.

Não marcar uma atividade como concluída somente pelo banner final. Um erro deve ser isolado com evidência, sem interromper silenciosamente atividades independentes.

## Card 09 — notas sem financeiro

Usar como caminho principal a leitura direta de TGFNFE.XML com XMLTABLE, sem depender de function. Aplicar a redução de volumetria do dashboard considerando ATUALFIN<>0, TIPMOV<>'Z' e ausência de TGFFIN. Persistir mapa base e classificação de TGFPPG.

Separar sempre:

- BASE_TOTAL: ocorrências identificadas;
- APTO_PARA_VALIDACAO_FINAL: aptos após todas as validações;
- SEM_VDUP_XML: ausência de vDup/XML utilizável;
- inserções efetivadas;
- saldo pós-validação.

Não chamar uma ocorrência apenas diagnosticada de elegível quando APTO_PARA_VALIDACAO_FINAL=0.

Regras:

- usar ID_EXECUCAO, mapa e auditoria novos;
- manter candidatos não aptos no mapa para auditoria;
- validar Dup, vDup, dVenc e nDup;
- classificar múltiplos XML como REVISAR_MULTIPLOS_XML;
- não alterar candidato sem XML válido ou vínculo financeiro determinístico;
- derivar CODTIPTIT exclusivamente de TGFPPG.CODTIPTITPAD;
- validar TGFTPV pela versão exata do cabeçalho;
- alocar NUFIN com bloqueio seguro de TGFNUM.ULTCOD;
- revisar o mapa e aplicar INSERT somente em fase separada;
- registrar pós-validação e reversão autocontida.

A function FNC_BUSCA_TAG_XML_GERAL é fallback e só deve ser considerada após validar ALL_OBJECTS, ALL_ARGUMENTS e ALL_ERRORS e confirmar que a leitura direta não é viável.

## Atividades 29 e 30 — bairros e endereços

Quando houver colisões:

- identificar grupos e escolher determinísticamente o registro retido;
- criar mapa e backup somente dos registros impactados;
- descobrir todas as FKs com ALL_CONSTRAINTS e ALL_CONS_COLUMNS, inclusive compostas;
- atualizar referências antes de excluir obsoletos;
- validar referências remanescentes, duplicidades e integridade;
- gerar novo plano, hash e ID_EXECUCAO após a versão final;
- preparar reversão individual com mapa e valores anteriores.

Isolar ambiguidades reais, FK não mapeada, quota insuficiente ou divergência de contagem com evidência.

## Objetos inválidos e ticket Sankhya Cloud

Se a etapa 31 identificar objetos nativos INVALID e ausência de ALTER ANY PROCEDURE:

- delegar o preparo ao agente ticket_objetos_invalidos usando a skill sankhya-ticket-objetos-invalidos;
- exigir contagem, lista completa, schema, evidência do privilégio ausente, organização e formulário;
- não permitir que o subagente faça DML/DDL, login, upload ou envio externo;
- confirmar visualmente a organização real, nunca SANKHYA JIVA para este motivo;
- usar prioridade Normal, Cloud/SaaS → Solicitação Cloud → Personalizar Objeto de Banco de Dados, Produção e Oracle;
- não anexar logs, credenciais ou artefatos por padrão;
- verificar duplicidade por base e ID_EXECUCAO.

Com retorno PRONTO, organização confirmada, sem duplicidade e sem erro do portal, o agente principal pode preencher e enviar o ticket automaticamente, sem nova autorização ou clique solicitado ao usuário. Se houver ambiguidade, ticket existente, divergência de formulário ou impedimento do portal, parar e pedir decisão.

Depois do envio efetivo registrar número, URL, status e campos em Dados_Revisao.json, no relatório e no registro da base.

## Volumetria obrigatória e relatório

Antes de redigir qualquer relatório:

1. Ler 7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/REL_ENTEGA_NOVO_05.jrxml e executar a queryString com os indicadores de integridade.
2. Ler 7 - QA2/Revisao Master Deploy/Base Relatório de Entrega/Volumetria Deploy Agent.xml e executar os complementos necessários.
3. Persistir os resultados na pasta da base sem credenciais, com identidade, schema, serviço, data/hora, fonte, quantitativos, dml_executado=false e ddl_executado=false.
4. Usar os mesmos quantitativos no TXT e no PDF.
5. Validar quatro indicadores: financeiros sem nota, itens sem cabeçalho, cabeçalhos sem itens e códigos fiscais de cidades duplicados.

Se qualquer indicador obrigatório retornar valor acima de zero, interromper a preparação do PDF, registrar o resultado e informar o agente principal para análise.

A prévia textual e o PDF final devem manter a estrutura completa de referência da Vitrini Direta:

- resumo executivo;
- resultado técnico das atividades, com propósito e resultado comprovado;
- tratamento de notas sem financeiro;
- padronização de bairros e endereços, Cards 29 e 30, quando aplicável;
- Cards de volumetria e orientação aos consultores;
- tabela completa de volumetria;
- indicadores obrigatórios de integridade;
- objetos inválidos e ticket;
- conferência de onboarding;
- inventário resumido de objetos e artefatos persistidos;
- índice de reversão com código, descrição e artefato;
- pendências finais;
- fontes e conclusão.

Não substituir a seção de Cards de volumetria e orientação aos consultores por uma seção genérica de resultado da volumetria. A prévia só pode omitir capa, paginação, destinatários e elementos próprios da apresentação final.

Escrever para gerentes de projeto e consultores. Informar descrição ou propósito além do número do card. Evitar estrangeirismos técnicos. Não criar seção sobre barreiras internas, não incluir GP ausente, Drive ou PENDENTE_VALIDACAO. Não incluir na capa ou no texto de entrega ID_EXECUCAO, ID do Master ou estado do artefato, salvo solicitação expressa.

## Aprovação e envio

Usar a skill artifact-template-relatorios-corporativos-sankhya. Gerar TXT antes do PDF. Após aprovação do TXT, gerar o PDF, renderizar e conferir visualmente todas as páginas.

Antes do encerramento, confirmar o nome completo e e-mail da analista. Não inferir o e-mail de Ana Rodrigues. Se a analista confirmada for Ana Paula Rodrigues, usar ana.rodrigues@sankhya.com.br e enviar somente para ela, sem cópia para o Gerente de Projetos. Para qualquer outra analista, confirmar explicitamente os destinatários.

Priorizar o envio pelo conector do Gmail, se estiver disponível, conectado à conta corporativa e habilitado para envio com anexo. Como fallback, usar o Gmail gráfico pelo navegador. Em qualquer rota, validar destinatário, assunto, corpo e anexo antes do envio, mantendo aprovação final para a comunicação externa.

Enviar somente o PDF final. Não anexar logs, credenciais, mapas, scripts ou arquivos internos.

Assunto:

Conclusão da revisão Master Deploy — HIGIEPAM

Corpo:

Olá,

Concluímos a etapa de revisão Master Deploy da base HIGIEPAM.

Encaminho em anexo o relatório de entrega técnica com o resumo do que foi executado.

Atenciosamente,

## Critério de conclusão

Concluir somente com evidência final de cada atividade/Card executado ou isolado, identidade Oracle comprovada, logs completos, volumetria persistida, indicadores obrigatórios tratados, backups/mapas/auditorias/reversões preservados, onboarding registrado, TXT aprovado, PDF validado visualmente e comunicação enviada ou registrada como aguardando ação manual.

Não declarar sem pendências enquanto houver dependência externa relevante. Atualizar Dados_Revisao.json com o estado real, fontes, quantitativos, ticket, destinatários e envio.

Manter Pushcut, notificações no iPhone e Apple Watch pausados durante a revisão. Executar o mínimo de interação possível e interromper somente nos gates técnicos ou de decisão definidos neste handoff.
