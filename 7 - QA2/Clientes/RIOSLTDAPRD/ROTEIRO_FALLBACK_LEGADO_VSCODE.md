# Roteiro de fallback — execução legada pelo VS Code

Base: `RIOSLTDAPRD`  
Serviço esperado: `RIOSLTDAPRD.SANKHYACLOUD.COM.BR`

## Quando usar

Este roteiro preserva a abordagem anterior caso o executor Oracle direto não
possa ser utilizado. Ele deve ser acionado somente quando:

- a falha ocorreu antes de qualquer DML/DDL; ou
- o estado da execução parcial foi conferido, a identidade foi reconfirmada e
  a continuação pelo fluxo legado foi autorizada.

Se o executor direto já iniciou alterações e o estado não estiver comprovado,
pare. Não execute o wrapper legado por tentativa. Preserve o log, faça o
inventário do estado e escolha entre retomada segura ou reversão específica.

## Rota legada preservada

Wrapper gerado para esta base:

`/Users/spadarojr/Documents/Trabalho/Sankhya/Deploy Agent/Scripts-Deploy/7 - QA2/Clientes/RIOSLTDAPRD/Executar_Revisao_RIOSLTDAPRD.sql`

Abra o arquivo no VS Code, conecte manualmente o perfil Oracle correto e execute
como script (`F5`). A senha deve ser informada somente pela tela segura da
conexão manual; nunca deve ser copiada para arquivo, terminal, chat ou log.

## Procedimento rápido

1. Interrompa o executor direto e preserve o log da tentativa.
2. Confirme a VPN FortiClient e a conexão salva no VS Code.
3. Execute primeiro a identidade/preflight em modo leitura.
4. Confira `SESSION_USER`, `CURRENT_SCHEMA`, `SERVICE_NAME` e a base esperada.
5. Execute o wrapper legado somente se não houver alteração parcial sem análise.
6. Grave o resultado em um log novo, separado da tentativa direta.
7. Analise o log com `revisao_deploy.py analyze` e preserve todos os artefatos.

## Regras de segurança

- Não repetir uma fase que já tenha `ID_EXECUCAO` concluído.
- Não remover backups, mapas ou logs da tentativa direta.
- Não trocar de rota para encobrir erro de transporte ou erro lógico.
- Para Card 09, manter mapa, confirmação financeira, auditoria e pós-validação
  como fases separadas.

O fallback é uma rota de continuidade operacional, não uma autorização para
reexecutar scripts ou ignorar os gates de identidade, backup e reversão.
