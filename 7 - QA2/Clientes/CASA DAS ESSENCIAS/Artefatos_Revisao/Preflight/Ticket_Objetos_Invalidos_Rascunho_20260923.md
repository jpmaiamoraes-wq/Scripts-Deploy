# Rascunho de ticket — objetos Oracle inválidos

## Retorno da skill

- `status`: `ENVIADO_COMPLETO`
- base operacional: `CASA DAS ESSENCIAS` (rótulo derivado do service name; o campo `<BASE>` não veio preenchido no handoff)
- `ID_EXECUCAO` do fechamento da atividade 31: `RMD_CASA_20260923101547_13_31`
- schema: `SANKHYA`
- usuário: `FRANCISCO_JUNIOR`
- serviço: `casadasessenciasprd.sankhyacloud.com.br`
- objetos inválidos: `43 FUNCTIONs`
- privilégio ausente: `ALTER ANY PROCEDURE` não aparece nos 24 privilégios retornados por `SESSION_PRIVS`
- `ALL_ERRORS`: 0 linhas de erro para cada objeto na leitura atual
- organização real no portal: `CASA DAS ESSENCIAS-10251`
- duplicidade de ticket: `VERIFICADA_NO_PORTAL_SEM_TICKET_IDENTIFICAVEL_PARA_CASA_DAS_ESSENCIAS`
- status da atividade 31: `IGNORADO_SEM_PRIVILEGIO`
- envio externo: `ENVIADO_TICKET_712840_ABERTO`

## Resultado do envio

- número: `#712840`
- URL: `https://ajuda.sankhya.com.br/hc/pt-br/requests/712840`
- status observado: `aberto`
- organização: `CASA DAS ESSENCIAS-10251`
- prioridade: `Normal`
- categoria: `Cloud/SaaS` → `Solicitação Cloud` → `Executar Script de Banco de Dados` → `Personalizar Objeto de Banco de Dados`
- ambiente: `Produção`
- banco: `Oracle`
- anexos: nenhum
- correção publicada: `SNK_GET_CODCFO` foi adicionada ao histórico do ticket; a lista ficou completa com 43 funções.

## Campos padrão a conferir no portal

- Organização: organização real do cliente; não usar `SANKHYA JIVA`.
- Prioridade: `Normal`.
- Categoria: `Cloud/SaaS` → `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`.
- Ambiente: `Produção`.
- Banco: `Oracle`.
- Anexos: nenhum.

## Assunto

Objetos nativos Oracle inválidos — CASA DAS ESSENCIAS

## Descrição pronta

Olá, equipe Sankhya Cloud.

Durante a Revisão Master Deploy da base CASA DAS ESSENCIAS, foram identificados 43 objetos nativos Oracle com STATUS=INVALID no schema SANKHYA.

A conexão utilizada não possui o privilégio ALTER ANY PROCEDURE. Por isso, a Atividade 31 foi registrada como IGNORADO_SEM_PRIVILEGIO; nenhuma recompilação foi afirmada como realizada.

Solicito a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos nativos inválidos abaixo:

## Lista completa

```text
ACL_GET_ALIQPART
FSP_DATA_DIA_UTIL
FSP_RETURN_DATAS_UTEIS
F_OBTEMPRECO_DATA
F_OBTEM_SALDO_INDENIZ
GET_CODPROD_REF
GET_INDICE_AJUSTE_NOTA
GET_PREVISAO_CREDITO_DEBITO
GET_PROXIMO_DIA_UTIL
QTDEVOLPADRAO
QTDEVOLPADRAO2
SNK_GETCODPRODALT
SNK_GETDTBAIXABEM
SNK_GETMESESSEMPIS
SNK_GETPRODUTOAGRUPADOGIRO
SNK_GETVLRREA
SNK_GET_BASEFINESTOQUERENEGGOL
SNK_GET_CENTROCUSTO_EFD
SNK_GET_CFO_NOTA
SNK_GET_CODCFO
SNK_GET_CODIGO_PRODUTO
SNK_GET_CONTACONTABIL_EFD
SNK_GET_CONTACONTABIL_IMOB_EFD
SNK_GET_CTACTB_CADASTROS_EFD
SNK_GET_CUS_VAR_TIT
SNK_GET_DENTRO_FORA_ESTADO
SNK_GET_ICMS_ESPECIAL_CAB
SNK_GET_INDITENS
SNK_GET_NUFIN
SNK_GET_NUNOTA
SNK_GET_SATUSCONFERENCIA
SNK_GET_ST_RECUPERAR
SNK_MATGIR_GET_MULTCPA
SNK_MATGIR_GET_QTDTOTALMULTCPA
SNK_PRECO
TIM_ASSINAFIADOR
TIM_ASSINAINQUILINO
TIM_ASSINALOCADOR
TIM_MONTAFIADOR
TIM_MONTAFORMAREPASSE
TIM_MONTAINQUILINO
TIM_MONTAPROPRIETARIOS
TIM_POSSUI_FIN_JUR
```

## Evidências consultadas

- `Preflight/00_Identidade_Versao_READONLY.sql`
- `Preflight/01_Privilegios_Quota_READONLY.sql`
- `Preflight/02_Objetos_Invalidos_READONLY.sql`
- `Preflight/07_Objetos_Invalidos_Erros_READONLY.sql`
- `Preflight/Resumo_Preflight_READONLY_20260923.json`

Este arquivo é registro interno. Não anexar este rascunho, logs ou credenciais ao ticket.
