# Rascunho de ticket — MOVE GESTAO DE ENERGIA LTDA

**Situação:** enviado. Ticket Sankhya Cloud [#712638](https://ajuda.sankhya.com.br/hc/pt-br/requests/712638), status `Aberto`. O usuário confirmou que o ticket da MOVE ainda não havia sido aberto; a organização `MOVE GESTAO DE ENERGIA LTDA-83992` foi selecionada no formulário.

Base Oracle: MOVE GESTAO DE ENERGIA LTDA  
Execução revisada: `RMD_RUN_20260922163852951`  
Usuário/schema: `FRANCISCO_JUNIOR` / `SANKHYA`  
Serviço: `moveenergiaprd.sankhyacloud.com.br`
Versão Sankhya: `4.36b151` (compilação 151), consultada em `TSIPAR.CHAVE=VERSAOSKWBIN`.

Foram identificadas quatro funções Oracle com `STATUS=INVALID`: `FSP_DATA_DIA_UTIL`, `FSP_RETURN_DATAS_UTEIS`, `GET_PREVISAO_CREDITO_DEBITO` e `GET_PROXIMO_DIA_UTIL`. A conexão não possui o privilégio `ALTER ANY PROCEDURE`; a atividade 31 ficou como `IGNORADO_SEM_PRIVILEGIO`. Nenhuma recompilação foi afirmada como realizada.

Campos do formulário:

- Prioridade: `Normal`
- Produto/categoria/motivo: `Cloud/SaaS` → `Solicitação Cloud` → `Executar Script de Banco de Dados` → `Personalizar Objeto de Banco de Dados`
- Ambiente: `Produção`
- Banco: `Oracle`
- Organização: `MOVE GESTAO DE ENERGIA LTDA-83992`
- Anexos: nenhum

Assunto:

```text
MOVE GESTAO DE ENERGIA LTDA — Objetos nativos Oracle inválidos — Revisão Master Deploy
```

Descrição:

```text
Olá, equipe Sankhya Cloud.

Durante a Revisão Master Deploy da base MOVE GESTAO DE ENERGIA LTDA, foram identificados 4 objetos nativos Oracle com STATUS=INVALID no schema SANKHYA.

A conexão utilizada não possui o privilégio ALTER ANY PROCEDURE. Por isso, a Atividade 31 foi registrada como IGNORADO_SEM_PRIVILEGIO; nenhuma recompilação foi afirmada como realizada.

Solicito a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos nativos inválidos abaixo:

FUNCTION:FSP_DATA_DIA_UTIL
FUNCTION:FSP_RETURN_DATAS_UTEIS
FUNCTION:GET_PREVISAO_CREDITO_DEBITO
FUNCTION:GET_PROXIMO_DIA_UTIL
```

Checagem de solicitações anteriores: `#709492` é Instituto Moreira Salles; `#706365` é Produtos Macalé; `#705666` é Andorinha; `#711178` é Vitrini; `#711939` é HIGIEPAM; `#711447` é JCLM. `#708737` e `#708010` estavam fechados e sem identificação de base visível; antes do envio, o usuário confirmou que a solicitação da MOVE ainda não havia sido aberta.

Fontes técnicas: `31_Preflight_Objetos_Invalidos_READONLY_20260923.json` e `Logs/MOVE_MAS_20260922_163600.log`. Nenhum arquivo será anexado.
