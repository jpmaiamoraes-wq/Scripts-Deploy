# Conferência de onboarding — CASA DAS ESSENCIAS

## Estado

A identidade Oracle foi validada em modo somente leitura em 23/09/2026. A fonte primária do site Onboarding Deploy não estava disponível na sessão atual do navegador; nenhuma credencial foi inserida e nenhuma fonte documental foi inventada. A comparação documental de empresas e usuários permanece pendente da fonte mais recente do site.

## Snapshot Oracle

- `SESSION_USER=FRANCISCO_JUNIOR`, `CURRENT_SCHEMA=SANKHYA`, `SERVICE_NAME=casadasessenciasprd.sankhyacloud.com.br`, `DB_NAME=CASADASESSENCIASPRD`.
- 3 empresas em `TSIEMP`.
- 11 usuários em `TSIUSU`; 0 com `CODGRUPO > 0` e 11 classificados apenas como usuários de modelo sem grupo para fins da comparação.
- 5 contas em `TSICTA`, 36 vendedores, 1 grupo de produto, 1 centro de resultado, 210 naturezas e 1 local de estoque.
- 1 registro de metadado SMTP global e 0 empresas com SMTP próprio configurado; nenhum valor sensível foi exibido.

## Gate e próxima ação

`dml_executado=false` e `ddl_executado=false`. Para concluir a conferência, localizar no site Onboarding Deploy o registro mais recente da base e comparar CNPJs/razões sociais com `TSIEMP` e e-mails de usuários somente contra `TSIUSU.CODGRUPO > 0`, preservando ausentes, adicionais e divergências sem alterar a base.

Fonte técnica: `Preflight/06_Onboarding_Snapshot_READONLY.sql` e `Resumo_Preflight_READONLY_20260923.json`.
