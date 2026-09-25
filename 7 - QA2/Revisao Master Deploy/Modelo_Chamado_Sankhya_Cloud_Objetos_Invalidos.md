# Modelo de chamado — objetos inválidos

## Padrão do formulário para a revisão

- **Organização:** selecionar a organização real do cliente exibida no formulário. Nunca usar a organização padrão `SANKHYA JIVA` para este motivo; se ela aparecer, corrigir antes de prosseguir.
- **Prioridade:** `Normal`, salvo evidência objetiva para outra prioridade.
- **Categoria/Produto:** `Cloud/SaaS` → `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`.
- **Ambiente:** `Produção`.
- **Ambiente do Banco de Dados:** `Oracle`.
- **Anexos:** não anexar logs, credenciais ou outros artefatos por padrão; enviar somente se o suporte solicitar e houver autorização específica.

## Descrição padrão

Olá, equipe Sankhya Cloud.

Durante a Revisão Master Deploy da base **[CLIENTE]**, foram identificados **[N] objetos nativos Oracle** com status `INVALID` no schema **[SCHEMA]**.

A conexão utilizada não possui o privilégio `ALTER ANY PROCEDURE`. Por isso, a Atividade 31 foi registrada como `IGNORADO_SEM_PRIVILEGIO`; nenhuma recompilação foi afirmada como realizada.

Solicito a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos nativos inválidos abaixo:

[LISTA DE OBJETOS]
