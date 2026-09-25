# Ticket Sankhya Cloud — objetos nativos inválidos

- **Número:** [#711178](https://ajuda.sankhya.com.br/hc/pt-br/requests/711178)
- **Status no momento da abertura:** aberto
- **Data de abertura:** 2026-09-18
- **Organização:** ACM BRASIL-81357
- **Prioridade:** Normal
- **Categoria/Produto:** Cloud/SaaS → Solicitação Cloud → Personalizar Objeto de Banco de Dados
- **Ambiente:** Produção
- **Banco:** Oracle
- **Assunto:** Recompilação de 49 objetos nativos inválidos — VITRINI DIRETA (ACM BRASIL)

## Escopo enviado

Durante a Revisão Master Deploy da base VITRINI DIRETA (ACM BRASIL), foram identificados 49 objetos nativos Oracle com `STATUS=INVALID` no schema `SANKHYA`.

A conexão utilizada não possui o privilégio `ALTER ANY PROCEDURE`. Por isso, a Atividade 31 foi registrada como `IGNORADO_SEM_PRIVILEGIO`; nenhuma recompilação foi afirmada como realizada.

Foi solicitada a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos inválidos listados abaixo:

`ACL_GET_ALIQPART`; `FSP_DATA_DIA_UTIL`; `FSP_RETURN_DATAS_UTEIS`; `FTIM_EXECUTAR`; `F_OBTEMPRECO_DATA`; `F_OBTEM_SALDO_INDENIZ`; `F_WMS_GETESTOQUEDOCA_PARC`; `GET_CODPROD_REF`; `GET_INDICE_AJUSTE_NOTA`; `GET_PREVISAO_CREDITO_DEBITO`; `GET_PROXIMO_DIA_UTIL`; `QTDEVOLPADRAO`; `QTDEVOLPADRAO2`; `RECEBIMENTO_M3_TOTAL`; `RECEBIMENTO_PESO_TOTAL`; `SNK_GETCODPRODALT`; `SNK_GETDTBAIXABEM`; `SNK_GETMESESSEMPIS`; `SNK_GETPRODUTOAGRUPADOGIRO`; `SNK_GETSOMAPARTILHA2`; `SNK_GETSOMAVLRTGFDIN`; `SNK_GETVLRREA`; `SNK_GETVLRTGFDIN`; `SNK_GET_CENTROCUSTO_EFD`; `SNK_GET_CFO_NOTA`; `SNK_GET_CODCFO`; `SNK_GET_CODIGO_PRODUTO`; `SNK_GET_COD_LEGAL`; `SNK_GET_CONTACONTABIL_EFD`; `SNK_GET_CONTACONTABIL_IMOB_EFD`; `SNK_GET_CTACTB_CADASTROS_EFD`; `SNK_GET_DENTRO_FORA_ESTADO`; `SNK_GET_ICMS_ESPECIAL_CAB`; `SNK_GET_INDITENS`; `SNK_GET_NUNOTA`; `SNK_GET_SATUSCONFERENCIA`; `SNK_GET_ST_RECUPERAR`; `SNK_GET_VLRITENS`; `SNK_GET_VLRTOT_SERVICO`; `SNK_MATGIR_GET_MULTCPA`; `SNK_MATGIR_GET_QTDTOTALMULTCPA`; `SNK_PRECO`; `TIM_ASSINAFIADOR`; `TIM_ASSINAINQUILINO`; `TIM_ASSINALOCADOR`; `TIM_MONTAFIADOR`; `TIM_MONTAFORMAREPASSE`; `TIM_MONTAINQUILINO`; `TIM_MONTAPROPRIETARIOS`.

Não foram anexados logs, credenciais ou outros arquivos.
