---
name: sankhya-onboarding-readonly
description: Compare the latest Sankhya Onboarding Deploy site data with the connected Oracle base in read-only mode during a Master Deploy review, without using company count as a scope gate.
---

# Conferência automática de onboarding

Use esta skill automaticamente no início de toda revisão Master Deploy, sem esperar solicitação do usuário. O objetivo é produzir evidência comparável do onboarding e da base Oracle, não alterar o banco nem decidir inclusão ou exclusão de empresas/usuários.

## Fonte e identidade

- Use primeiro a página/arquivos mais recentes exibidos no site Onboarding Deploy para a base em execução. Não use o Drive como fonte primária quando o site estiver disponível.
- Registre nome do arquivo, data/hora de envio, quantidade de registros e a tela/registro da base consultada. Quando houver versões repetidas, use a mais recente.
- Na conexão Oracle direta, registre `SESSION_USER`, `CURRENT_SCHEMA`, `SERVICE_NAME` e a base. Valide se o nome da base conectada corresponde de forma segura ao nome informado. Não use a quantidade de empresas como gate; múltiplas empresas são parte normal do escopo `BASE_INTEIRA`.
- Se identidade, serviço ou fonte do site estiverem ambíguos, registre o bloqueio e peça decisão apenas sobre a ambiguidade. Não faça DML/DDL como tentativa de correção.

## Comparações obrigatórias

### Empresas

Compare CNPJ normalizado e razão social entre a composição do onboarding e `TSIEMP`. Informe:

- CNPJs do onboarding localizados no Oracle;
- CNPJs do onboarding ausentes no Oracle;
- CNPJs adicionais na base fora do conjunto exibido no onboarding;
- `CODEMP` e razão social Oracle para cada resultado.

Não incluir, remover ou alterar empresa automaticamente. A quantidade de empresas serve apenas para o relatório de divergência de escopo.

### Usuários

Compare por e-mail a planilha mais recente do site com `TSIUSU`, considerando na base somente `CODGRUPO > 0`.

- Separe e informe a quantidade total de usuários Oracle e a quantidade sem grupo, classificando estes últimos como usuários de modelo excluídos da comparação.
- Relacione e-mail, nome, empresa e grupo de cada usuário ausente, extra ou divergente.
- Compare o grupo do onboarding com `CODGRUPO` Oracle.
- Registre diferenças de nome como divergência nominal quando o e-mail corresponder.
- Compare também a empresa informada no onboarding com `CODEMP` Oracle; não altere `CODEMP` sem decisão específica.

## Evidência e saída

Persistir, sem credenciais:

- log JSON com fonte, data, identidade, consultas, quantidades, correspondências e divergências;
- resumo Markdown da conferência;
- arquivos separados para comparação de empresas e usuários quando houver divergências;
- marcações explícitas `dml_executado=false` e `ddl_executado=false`.

As consultas Oracle devem ser `SELECT`/`WITH` executadas pelo executor direto autorizado. Não usar VS Code, SQL Developer ou terminal SQL genérico para substituir o executor.

## Continuidade

A conferência pode ocorrer em paralelo às atividades independentes da revisão. Falha de arquivo aplicável ou de uma comparação não deve interromper automaticamente a revisão inteira; registrar o ramo pendente e continuar os ramos seguros. Interromper somente por identidade/base ambígua, VPN/conexão inválida ou risco de produzir uma conclusão sem evidência.
