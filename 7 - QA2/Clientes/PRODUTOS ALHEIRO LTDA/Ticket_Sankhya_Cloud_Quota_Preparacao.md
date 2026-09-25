# Solicitação externa — quota para preparação da Revisão Master Deploy

**Status:** rascunho local; não enviado.

**Base:** PRODUTOS ALHEIRO LTDA  
**Serviço:** ALHEIROPRD.SANKHYACLOUD.COM.BR  
**Usuário da sessão:** FRANCISCO_JUNIOR  
**Schema operacional:** SANKHYA  
**Data da evidência:** 16/09/2026

## Evidência objetiva

- `USER_TS_QUOTAS`: 0 linhas para a sessão.
- A rota `10.100.76.5:1521` está acessível.
- O preflight somente leitura confirmou o serviço e a empresa esperados.
- Foram identificados privilégios de criação/alteração de alguns objetos, porém sem quota de armazenamento registrada.
- Não há objetos inválidos na consulta realizada; não foi executada recompilação.

## Solicitação

Regularizar a quota de armazenamento do schema operacional `SANKHYA`, ou indicar o procedimento suportado pelo Sankhya Cloud para criação de backups persistentes e execução controlada da Revisão Master Deploy.

Se a política do ambiente não permitir quota direta, informar uma alternativa aprovada que preserve backup, auditoria e rollback antes de qualquer DML.

## Escopo bloqueado até a regularização

As atividades 01 a 31, os Cards 09, 14, 15, 29 e 30 e qualquer desativação temporária permanecem sem execução. Nenhum backup persistente foi criado e nenhum dado foi alterado.

**Número do ticket:** ainda não atribuído.  
**URL:** ainda não atribuída.
