# Ticket enviado — objetos Oracle inválidos

status: ENVIADO_ABERTO

## Atendimento no portal

- Número: `#712780`
- URL: <https://ajuda.sankhya.com.br/hc/pt-br/requests/712780>
- Status no envio: `Aberto`
- Organização confirmada: `RIO'S DISTRIBUIDORA DE AGUA E BEBIDAS LTDA-83657`
- Duplicidade: busca por `RIOSLTDAPRD` com status `Aberto` não encontrou solicitação ativa em `2026-09-23`.

## Evidência

- Base: `RIOSLTDAPRD`
- Execução: `RMD_RIOSLTDAPRD_20260923_101000`
- Usuário: `FRANCISCO_JUNIOR`
- Schema: `SANKHYA`
- Serviço: `riosltdaprd.sankhyacloud.com.br`
- Banco: `RIOSLTDAPRD`
- Objetos inválidos: `46`
- Evidência do privilégio ausente: `STATUS=IGNORADO_SEM_PRIVILEGIO; OBJETOS_INVALIDOS=46; USUARIO=FRANCISCO_JUNIOR; SCHEMA=SANKHYA; PRIVILEGIO_NECESSARIO=ALTER ANY PROCEDURE`
- Ticket anterior para a mesma base e execução: não localizado nos artefatos locais; a busca no portal por `RIOSLTDAPRD` com status `Aberto` não encontrou solicitação ativa.

## Organização e campos do formulário

- Organização: `RIO'S DISTRIBUIDORA DE AGUA E BEBIDAS LTDA-83657`.
- Prioridade: `Normal`
- Categoria: `Cloud/SaaS`
- Produto/solicitação: `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`
- Ambiente: `Produção`
- Banco: `Oracle`
- Anexos: nenhum por padrão.

## Assunto

`Objetos Oracle inválidos — RIOSLTDAPRD — 46 funções no schema SANKHYA`

## Descrição pronta

Olá, equipe Sankhya Cloud.

Durante a Revisão Master Deploy da base RIOSLTDAPRD, foram identificados 46 objetos nativos Oracle com `STATUS=INVALID` no schema SANKHYA.

A conexão utilizada não possui o privilégio `ALTER ANY PROCEDURE`. Por isso, a Atividade 31 foi registrada como `IGNORADO_SEM_PRIVILEGIO`; nenhuma recompilação foi afirmada como realizada.

Solicito a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos nativos inválidos abaixo:

```text
SANKHYA.ACL_GET_ALIQPART (FUNCTION)
SANKHYA.FSP_DATA_DIA_UTIL (FUNCTION)
SANKHYA.FSP_RETURN_DATAS_UTEIS (FUNCTION)
SANKHYA.F_OBTEMPRECO_DATA (FUNCTION)
SANKHYA.F_OBTEM_SALDO_INDENIZ (FUNCTION)
SANKHYA.GET_CODPROD_REF (FUNCTION)
SANKHYA.GET_INDICE_AJUSTE_NOTA (FUNCTION)
SANKHYA.GET_PREVISAO_CREDITO_DEBITO (FUNCTION)
SANKHYA.GET_PROXIMO_DIA_UTIL (FUNCTION)
SANKHYA.QTDEVOLPADRAO (FUNCTION)
SANKHYA.QTDEVOLPADRAO2 (FUNCTION)
SANKHYA.RECEBIMENTO_M3_TOTAL (FUNCTION)
SANKHYA.RECEBIMENTO_PESO_TOTAL (FUNCTION)
SANKHYA.SNK_GETCODPRODALT (FUNCTION)
SANKHYA.SNK_GETDTBAIXABEM (FUNCTION)
SANKHYA.SNK_GETMESESSEMPIS (FUNCTION)
SANKHYA.SNK_GETPRODUTOAGRUPADOGIRO (FUNCTION)
SANKHYA.SNK_GETVLRREA (FUNCTION)
SANKHYA.SNK_GET_BASEFINESTOQUERENEGGOL (FUNCTION)
SANKHYA.SNK_GET_CENTROCUSTO_EFD (FUNCTION)
SANKHYA.SNK_GET_CFO_NOTA (FUNCTION)
SANKHYA.SNK_GET_CODCFO (FUNCTION)
SANKHYA.SNK_GET_CODIGO_PRODUTO (FUNCTION)
SANKHYA.SNK_GET_CONTACONTABIL_EFD (FUNCTION)
SANKHYA.SNK_GET_CONTACONTABIL_IMOB_EFD (FUNCTION)
SANKHYA.SNK_GET_CTACTB_CADASTROS_EFD (FUNCTION)
SANKHYA.SNK_GET_CUS_VAR_TIT (FUNCTION)
SANKHYA.SNK_GET_DENTRO_FORA_ESTADO (FUNCTION)
SANKHYA.SNK_GET_ICMS_ESPECIAL_CAB (FUNCTION)
SANKHYA.SNK_GET_INDITENS (FUNCTION)
SANKHYA.SNK_GET_NUFIN (FUNCTION)
SANKHYA.SNK_GET_NUNOTA (FUNCTION)
SANKHYA.SNK_GET_SATUSCONFERENCIA (FUNCTION)
SANKHYA.SNK_GET_ST_RECUPERAR (FUNCTION)
SANKHYA.SNK_GET_VLRITENS (FUNCTION)
SANKHYA.SNK_GET_VLRTOT_SERVICO (FUNCTION)
SANKHYA.SNK_MATGIR_GET_QTDTOTALMULTCPA (FUNCTION)
SANKHYA.SNK_PRECO (FUNCTION)
SANKHYA.TIM_ASSINAFIADOR (FUNCTION)
SANKHYA.TIM_ASSINAINQUILINO (FUNCTION)
SANKHYA.TIM_ASSINALOCADOR (FUNCTION)
SANKHYA.TIM_MONTAFIADOR (FUNCTION)
SANKHYA.TIM_MONTAFORMAREPASSE (FUNCTION)
SANKHYA.TIM_MONTAINQUILINO (FUNCTION)
SANKHYA.TIM_MONTAPROPRIETARIOS (FUNCTION)
SANKHYA.TIM_POSSUI_FIN_JUR (FUNCTION)
```

## Artefatos consultados

- `Logs/Oracle_Direto_RMD_RIOSLTDAPRD_20260923_101000.log` — linha 1172.
- `Logs/Objetos_Invalidos_20260923.json` — consulta independente com 46 linhas.
- `Logs/PosValidacao_Master_20260923.json` — pós-validação independente.

## Bloqueio

O envio fica pendente até confirmar no portal a organização real do cliente e verificar a inexistência de ticket aberto duplicado. Não há número, URL ou status de ticket inventado neste artefato.
