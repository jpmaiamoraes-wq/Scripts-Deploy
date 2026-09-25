# Rascunho — objetos nativos Oracle inválidos

Status: rascunho preparado; organização real e duplicidade ainda precisam de verificação visual no portal. Nenhum ticket foi enviado.

Base: MOVE GESTAO DE ENERGIA LTDA  
ID da revisão Master: RMD_RUN_20260922163852951  
Usuário/schema: FRANCISCO_JUNIOR / SANKHYA  
Serviço: moveenergiaprd.sankhyacloud.com.br

Objetos `INVALID` identificados: 4 funções — `FSP_DATA_DIA_UTIL`, `FSP_RETURN_DATAS_UTEIS`, `GET_PREVISAO_CREDITO_DEBITO` e `GET_PROXIMO_DIA_UTIL`.

Privilégio ausente: `ALTER ANY PROCEDURE`. A atividade 31 foi registrada como `IGNORADO_SEM_PRIVILEGIO`; nenhuma recompilação foi afirmada como realizada.

Organização esperada: `MOVE GESTAO DE ENERGIA LTDA`. Confirmar visualmente no portal antes de preencher; não usar `SANKHYA JIVA` para este motivo.

Campos sugeridos: prioridade `Normal`; produto `Cloud/SaaS`; categoria `Solicitação Cloud`; motivo `Personalizar Objeto de Banco de Dados`; ambiente `Produção`; banco `Oracle`; anexos: nenhum.

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

Fontes: `Artefatos_Revisao/Preflight/31_Preflight_Objetos_Invalidos_READONLY_20260922.json`; `Logs/MOVE_MAS_20260922_163600.log`; `Dados_Revisao.json`.

Duplicidade: não há referência local encontrada; a consulta ao portal ainda está pendente. Não há número, URL ou status de ticket registrado.
