# Precheck da Revisao Deploy Agent

- Base confirmada: `MACALEPRD.SANKHYACLOUD.COM.BR`
- Usuario da sessao: `FRANCISCO_JUNIOR`
- Schema atual: `SANKHYA`
- Data da verificacao: 2026-09-09
- Natureza: somente leitura; nenhuma alteracao realizada

## Unidades

- Candidatos de conversao automatica de codigo: 0
- Descricao a converter para maiusculas: `CT | Cento | CENTO`
- Ambiguidade impeditiva: nao identificada

## Volumes cadastrais

- `TGFPAR`: 2.372 registros
- `TGFPRO`: 1.949 registros
- `TGFTIT`: 66 registros
- `TSICID`: 5.573 registros
- `TGFTPV`: 20 registros

## Colisoes previstas

- `TSIBAI`: 46.515 registros e 429 grupos de colisao
- `TSIEND`: 6.962 grupos de colisao
- Consequencia prevista: as etapas 29 e 30 devem registrar `STATUS=IGNORADO_COLISAO` e nao alterar bairros ou enderecos.

## Objetos invalidos

- Objetos invalidos no schema: 31
- Privilegio `ALTER ANY PROCEDURE`: ausente
- Consequencia prevista: a recompilacao pode registrar `STATUS=IGNORADO_SEM_PRIVILEGIO`; o relatorio final dependera de chamado ao Sankhya Cloud se os objetos invalidos permanecerem.

## Etapas 01 a 16

- Objetos obrigatorios: 13 encontrados e validos; a trigger `TRG_UPT_TGFITE` esta `ENABLED`.
- Etapa 02: 4 parametros de filtros de portais preenchidos.
- Etapa 03: 0 empresas fora da matriz para ajuste de DANFE.
- Etapa 04: 136 TOPs de devolucao candidatas.
- Etapa 05: 12 produtos candidatos ao calculo de giro.
- Etapa 06: 17 condicoes de pagamento candidatas.
- Etapa 07: 0 notas com `DTMOV` ausente.
- Etapas 08 e 09: 6.918 notas/protocolos e itens legados candidatos.
- Etapa 10: 6 produtos candidatos ao ICMS gerencial; etapa 11: 7 produtos candidatos a ruptura.
- Etapa 12: tabela de segmentacao presente; 0 empresas candidatas a ruptura por segmentacao.
- Etapa 13: 1.448 TOPs na base; etapa 14: 1 configuracao de analise de giro 848; etapa 15: 443 produtos com rastro sem controle; etapa 16: 889 registros em `TSICFG`.

## Cobertura consolidada

- Prechecks executados, somente leitura: etapas 01 a 16, etapa 17 (unidades) e etapas 18 a 31.
- O Master permanece pendente de confirmacao e, quando executado, aplicara as etapas 01 a 31.

## Execucao realizada em 2026-09-09

- Etapas 01 a 11: concluidas; principais alteracoes registradas nos backups por ID de execucao.
- Etapa 12: tratamento isolado concluido com `STATUS=CONCLUIDO`, ID `RMD_RUPE_20260909090955021`; 0 empresas alteradas (backup preservado).
- Etapas 13 a 16: concluidas; etapa 13 ajustou 1.448 TOPs, etapa 15 ajustou 443 produtos.
- Etapa 17: tratamento isolado concluído com sucesso; ID `RMD_UNID_20260909091500000`, `REGISTROS_BACKUP=1`, `DESCRICOES_TGFVOL_MAIUSCULAS=1`, mapa atualizado com 122 mapeamentos e 11 inválidos removidos.
- Aprendizado: para tratamentos isolados executados pelo VS Code/JDBC, usar script sem diretivas SQL*Plus e com IDs de execução literais; reservar `VARIABLE`, `WHENEVER` e `SPOOL` para o fluxo SQL*Plus/SQLcl do Master.
- Etapas 18 a 28: executadas ate `SPOOL OFF`. A etapa 19 registrou erro na criacao preventiva do backup, mas seu ajuste principal concluiu com 1 parceiro ajustado.
- Etapas 29 e 30: concluídas com sucesso pelo merge controlado; 437 bairros obsoletos e 7.302 endereços obsoletos foram mapeados, com 18 linhas dependentes em `TGFCPL` respaldadas e atualizadas (incluindo `CODBAIENTREGA` e `CODENDENTREGA`). Execução `MACALE_20260909_153000`; validação final sem referências remanescentes e sem duplicidades normalizadas.
- Etapa 31: `STATUS=IGNORADO_SEM_PRIVILEGIO`, com 31 objetos invalidos e ausencia de `ALTER ANY PROCEDURE`. Tratativa registrada no ticket #70636.
