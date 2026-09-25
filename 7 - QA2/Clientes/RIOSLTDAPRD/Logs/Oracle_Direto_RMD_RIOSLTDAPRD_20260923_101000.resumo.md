# Resumo da Revisao Master Deploy

- Log: `Oracle_Direto_RMD_RIOSLTDAPRD_20260923_101000.log`
- Conclusao final encontrada: nao
- IDs de execucao encontrados: 27
- Colisoes ignoradas: 0
- Erros ORA/SP2 encontrados: 0
- Objetos invalidos sem privilegio: 1
- Ticket Sankhya Cloud: pendente
- Revisao manual necessaria: sim

## Chamado obrigatorio ao Sankhya Cloud

A base possui objetos invalidos que nao puderam ser recompilados pela conexao de revisao.
Solicitar ao Sankhya Cloud a recompilacao/correcao das funcoes do schema informado, anexando a lista de objetos invalidos e o log desta revisao.
Texto sugerido para o chamado:

> Durante a revisao da base, foram identificados objetos INVALID do schema informado. A conexao utilizada nao possui privilegio ALTER ANY PROCEDURE e a recompilacao nao foi realizada. Solicito a analise e recompilacao/correcao dos objetos listados no anexo, validando dependencias e erros de compilacao. Favor retornar o numero do chamado e o resultado do atendimento.

Objetos/saidas detectados:
- `DBMS_OUTPUT=STATUS=IGNORADO_SEM_PRIVILEGIO; OBJETOS_INVALIDOS=46; USUARIO=FRANCISCO_JUNIOR; SCHEMA=SANKHYA; PRIVILEGIO_NECESSARIO=ALTER ANY PROCEDURE`
