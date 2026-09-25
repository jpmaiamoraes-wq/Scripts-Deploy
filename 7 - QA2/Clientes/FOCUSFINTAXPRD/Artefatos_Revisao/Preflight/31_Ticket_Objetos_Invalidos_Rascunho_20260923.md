# Rascunho de ticket — FOCUSFINTAXPRD

**Situação:** rascunho técnico pronto para conferência do agente principal. Nenhum ticket foi aberto, enviado ou consultado no portal por este preparador (subagente read-only, sem acesso a navegador/portal). A organização abaixo é candidata e precisa ser confirmada/selecionada no formulário pelo agente principal antes do envio.

Base Oracle: FOCUSFINTAXPRD
Execução revisada (lote): `FOCUS_MAS_20260923_150347`
ID_MASTER: `RMD_RUN_20260923150349432`
Usuário/schema: `FRANCISCO_JUNIOR` / `SANKHYA`
Serviço: `focusfintaxprd.sankhyacloud.com.br` (esperado: `FOCUSFINTAXPRD.SANKHYACLOUD.COM.BR`)

Foram identificadas 27 funções Oracle com `STATUS=INVALID` no schema `SANKHYA` (lista completa abaixo). A conexão não possui o privilégio `ALTER ANY PROCEDURE`; a Atividade 31 ficou registrada como `IGNORADO_SEM_PRIVILEGIO`. Nenhuma recompilação foi afirmada como realizada.

Campos do formulário:

- Prioridade: `Normal`
- Produto/categoria/motivo: `Cloud/SaaS` → `Solicitação Cloud` → `Personalizar Objeto de Banco de Dados`
- Ambiente: `Produção`
- Banco: `Oracle`
- Organização: **candidata** `FOCUS FINTAX LTDA` (CNPJ `50.654.800/0001-02`) — confirmar/selecionar a entrada exata no formulário do portal (ex.: pode existir sufixo numérico, como visto em outras organizações); **nunca** usar `SANKHYA JIVA` para este motivo.
- Anexos: nenhum

Assunto:

```text
FOCUSFINTAXPRD — Objetos nativos Oracle inválidos — Revisão Master Deploy
```

Descrição:

```text
Olá, equipe Sankhya Cloud.

Durante a Revisão Master Deploy da base FOCUSFINTAXPRD, foram identificados 27 objetos nativos Oracle com STATUS=INVALID no schema SANKHYA.

A conexão utilizada não possui o privilégio ALTER ANY PROCEDURE. Por isso, a Atividade 31 foi registrada como IGNORADO_SEM_PRIVILEGIO; nenhuma recompilação foi afirmada como realizada.

Solicito a análise das dependências e dos erros de compilação e a recompilação ou correção dos objetos nativos inválidos abaixo:

FUNCTION:ACL_GET_ALIQPART
FUNCTION:F_OBTEMPRECO_DATA
FUNCTION:F_OBTEM_SALDO_INDENIZ
FUNCTION:GET_CODPROD_REF
FUNCTION:GET_INDICE_AJUSTE_NOTA
FUNCTION:QTDEVOLPADRAO
FUNCTION:QTDEVOLPADRAO2
FUNCTION:SNK_GETCODPRODALT
FUNCTION:SNK_GETDTBAIXABEM
FUNCTION:SNK_GETMESESSEMPIS
FUNCTION:SNK_GETPRODUTOAGRUPADOGIRO
FUNCTION:SNK_GETVLRREA
FUNCTION:SNK_GET_CENTROCUSTO_EFD
FUNCTION:SNK_GET_CFO_NOTA
FUNCTION:SNK_GET_CODCFO
FUNCTION:SNK_GET_CODIGO_PRODUTO
FUNCTION:SNK_GET_CONTACONTABIL_EFD
FUNCTION:SNK_GET_CONTACONTABIL_IMOB_EFD
FUNCTION:SNK_GET_CTACTB_CADASTROS_EFD
FUNCTION:SNK_GET_ICMS_ESPECIAL_CAB
FUNCTION:SNK_GET_INDITENS
FUNCTION:SNK_GET_NUNOTA
FUNCTION:SNK_GET_SATUSCONFERENCIA
FUNCTION:SNK_GET_ST_RECUPERAR
FUNCTION:SNK_MATGIR_GET_MULTCPA
FUNCTION:SNK_MATGIR_GET_QTDTOTALMULTCPA
FUNCTION:SNK_PRECO
```

Checagem de ticket anterior/duplicidade: **não realizada por este preparador** — este subagente não possui acesso a navegador/portal (somente leitura de artefatos locais). O agente principal deve verificar no portal Sankhya Cloud se já existe solicitação aberta para a base FOCUSFINTAXPRD/execução `RMD_RUN_20260923150349432` antes de enviar, seguindo o mesmo critério usado no precedente da MOVE GESTAO DE ENERGIA LTDA.

Fontes técnicas:
- `Logs/FOCUS_MAS_20260923_150347.log` (linha 1172: `DBMS_OUTPUT=STATUS=IGNORADO_SEM_PRIVILEGIO; OBJETOS_INVALIDOS=27; USUARIO=FRANCISCO_JUNIOR; SCHEMA=SANKHYA; PRIVILEGIO_NECESSARIO=ALTER ANY PROCEDURE`; linha 17/1085: `DBMS_OUTPUT=ID_MASTER=RMD_RUN_20260923150349432`; linha 1: `ID_EXECUCAO_LOTE=FOCUS_MAS_20260923_150347`)
- `Logs/P13_Etapa31_Lista_Objetos_Invalidos_20260923_145754.json` (27 objetos, todos `FUNCTION`, `STATUS=INVALID`)
- `Logs/P12_Etapa31_Invalidos_Privilegio_20260923_145754.json` (`OBJETOS_INVALIDOS=27`; `QTD_PRIVS_ANY_PROCEDURE=3` — apenas CREATE/DROP/EXECUTE, sem ALTER)
- `Logs/P02_Privilegios_Roles_20260923_145754.json` (lista de privilégios da sessão contém `CREATE ANY PROCEDURE`, `DROP ANY PROCEDURE`, `EXECUTE ANY PROCEDURE`; `ALTER ANY PROCEDURE` ausente da lista)
- `Onboarding_Comparacao_ReadOnly_FOCUSFINTAXPRD.json` (onboarding do portal Mitralab identifica a empresa principal como `FOCUS FINTAX LTDA`, CNPJ `50654800000102`, correspondente ao Oracle CODEMP=1)
- `Dados_Revisao.json` (`cliente_informado=FOCUSFINTAXPRD`; GP: `marcelo.borel@sankhya.com.br`)

Nenhum arquivo será anexado. Nenhum SQL foi executado por este preparador (somente leitura).
