---
name: sankhya-ticket-objetos-invalidos
description: Prepare and validate a Sankhya Cloud support-ticket draft when a Master Deploy review finds native Oracle objects invalid and the session lacks the privilege required to recompile them. Do not use for ordinary support requests or for submitting the ticket itself.
---

# Ticket de objetos inválidos

Use esta skill como procedimento reutilizável para qualquer base da revisão Master Deploy quando a etapa 31 registrar objetos nativos Oracle `INVALID` sem `ALTER ANY PROCEDURE`.

## Objetivo

Entregar ao agente principal um rascunho verificável do ticket, sem executar DML/DDL, sem manipular credenciais e sem enviar comunicação externa.

## Evidências mínimas

Leia os artefatos da base e confirme, sem inferência:

- cliente informado e `ID_EXECUCAO`/`ID_MASTER`;
- `SESSION_USER`, `CURRENT_SCHEMA`, serviço e versão, quando já registrados;
- contagem e lista completa dos objetos inválidos;
- mensagem que comprova a ausência de `ALTER ANY PROCEDURE`;
- existência de ticket anterior para a mesma base e execução.

Se a lista, a contagem ou a identidade do cliente estiverem ambíguas, retorne a pendência em vez de inventar ou escolher silenciosamente.

## Padrão do formulário

Prepare os valores abaixo para conferência do agente principal:

- organização: organização real do cliente no portal; nunca aceitar `SANKHYA JIVA` para este motivo;
- prioridade: `Normal`, salvo evidência objetiva para outra prioridade;
- categoria/produto: `Cloud/SaaS` → `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`;
- ambiente: `Produção`;
- ambiente do banco: `Oracle`;
- anexos: nenhum por padrão; não anexar logs, credenciais ou arquivos sem solicitação e autorização específica.

## Descrição padrão

Use linguagem enxuta, ajustando apenas os campos entre colchetes:

```text
Olá, equipe Sankhya Cloud.

Durante a Revisão Master Deploy da base [CLIENTE], foram identificados [N] objetos nativos Oracle com STATUS=INVALID no schema [SCHEMA].

A conexão utilizada não possui o privilégio ALTER ANY PROCEDURE. Por isso, a Atividade 31 foi registrada como IGNORADO_SEM_PRIVILEGIO; nenhuma recompilação foi afirmada como realizada.

Solicito a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos nativos inválidos abaixo:

[LISTA DE OBJETOS]
```

## Retorno obrigatório ao agente principal

Retorne somente um resumo estruturado contendo:

- `status`: `PRONTO`, `PENDENTE_AMBIGUIDADE` ou `TICKET_EXISTENTE`;
- base, execução, schema e usuário;
- quantidade e lista dos objetos;
- privilégio ausente e evidência do log;
- assunto e descrição prontos;
- organização esperada e campos padrão do formulário;
- caminho dos artefatos consultados;
- bloqueios ou risco de duplicidade.

Não invente número, URL ou status de ticket. O agente principal é responsável pelo navegador, pela confirmação final, pelo envio e pelo registro pós-envio.
