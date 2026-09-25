# Classificacao de parceiros por CNAE

Estes arquivos estruturam a futura implementacao sem depender de `INSERT` e `UPDATE` soltos.

## Fluxo previsto

1. `Perfis_CNAE_01_Prepara_Staging.sql`: cria staging e backups persistentes. Executar somente quando a implementacao for autorizada.
2. Carregar em `STG_PPC_PERFIL` os perfis novos aprovados.
3. Carregar em `STG_PPC_PARCEIRO` somente CNPJs consultados, com CNAE principal confirmado, perfil sugerido, confianca e fonte.
4. `Perfis_CNAE_02_Valida_e_Gera_DML.sql`: somente leitura; mostra inconsistencias, simulacao e os comandos que seriam aplicados.
5. Revisar e marcar `STATUS_VALIDACAO = 'APROVADO'` no processo de carga, nunca diretamente pelo script de aplicacao.
6. `Perfis_CNAE_03_Aplica_Aprovados.sql`: exige frase de confirmacao, cria backup por `ID_EXECUCAO`, cadastra perfis aprovados e atualiza apenas parceiros ainda sem perfil.
7. `Perfis_CNAE_04_Reverte.sql`: restaura os parceiros e remove somente os perfis criados pela execucao informada, desde que estejam sem referencias.

## Separacao de responsabilidades

- A consulta externa de CNAE acontece fora do Oracle.
- O banco recebe somente o resultado minimo necessario, sem telefones, e-mails ou quadro societario.
- O mapa `CNAE -> CODTIPPARC` deve ser versionado e aprovado.
- O CNAE principal e obrigatorio para aplicacao automatica.
- CNAE secundario, nome e razao social servem apenas como evidencias complementares.
- Casos de confianca media ou baixa ficam pendentes ate aprovacao humana.

## Estado atual

Os scripts foram apenas gerados e validados estaticamente. Nenhum deles foi executado e nada foi criado ou alterado no banco.

