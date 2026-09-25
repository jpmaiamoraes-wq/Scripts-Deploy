# Verificação de onboarding — JCLM INDUSTRIA E COMERCIO LTDA

## Estado

`CONCLUIDA_READ_ONLY_COM_DIVERGENCIAS_DOCUMENTAIS`

A fonte documental foi localizada e inventariada no Drive. A consulta Oracle específica do onboarding foi executada após a VPN ser ativada, sem DML ou DDL.

## Fontes documentais localizadas

- Pasta principal: `JCLM INDUSTRIA E COMERCIO LTDA (Matriz)` — `https://drive.google.com/drive/folders/1GRYQxhUp0pxz6DuWHD80GvgQqBWRNsQl`.
- Pasta adicional/importada: `JCLM INDUSTRIA E COMERCIO LTDA [imp_76]` — `https://drive.google.com/drive/folders/1VM3cV7BYZSEf7fhlQ53PbOCVKhhz3hLE`.
- `dados-iniciais.pdf`, gerado em 24/08/2026.
- `Resumo - 01 - Dados da Empresa.pdf`, localizado na pasta adicional e criado em 15/09/2026.
- `fiscal-info.pdf`, `produtos-info.pdf`, `resumo-xmls.pdf` e `CONTAS_BANCARIAS_MODELO_VAL_2026_06_V3 (1).xlsx`.
- `smtp-config.pdf` foi localizado; seus dados sensíveis não foram reproduzidos.

## Resultado do confronto

Os dois documentos de dados da empresa não apresentam a mesma composição:

- `Resumo - 01 - Dados da Empresa.pdf`: três CNPJs, todos descritos como JCLM INDUSTRIA E COMERCIO LTDA.
- `dados-iniciais.pdf`: JCLM, FUTURA PRODUTOS ALIMENTICIOS LTDA e INDUSTRIA DE SUCOS SUMO INDUSTRIAL LTDA, com CNPJs diferentes para a matriz e filiais.

Os três CNPJs de `dados-iniciais.pdf` foram localizados no Oracle. No resumo mais recente, dois CNPJs foram localizados e o CNPJ `33.649.134/0003-59` não foi localizado. O resultado foi classificado como `DADO_AUSENTE_E_DIVERGENCIA_DOCUMENTAL_A_CONFIRMAR`, sem alteração automática na base.

O onboarding informa SMTP próprio (`smtp.jclm.com.br`, porta 587, TLS, remetente `nfe@jclm.com.br`). A configuração global Oracle está em outro endpoint/remetente (`email-smtp.us-east-1.amazonaws.com:587`, `noreply@sankhya.com.br`) e os campos SMTP por empresa estão ausentes. Resultado: `DIVERGENCIA_DE_CONFIGURACAO_COMPROVADA`. Credenciais não foram reproduzidas.

A planilha bancária localizada informa uma conta para o CNPJ `33.649.134/0001-97`; o Oracle possui duas contas para essa empresa. O confronto detalhado dos dados bancários não foi reproduzido neste resumo.

Os documentos de produtos informam 467, 3.862 e 51 produtos por empresa; o Oracle retornou 5.565 registros globais em `TGFPRO`. Como o cadastro consultado não fornece uma chave de empresa para esse confronto simples, a diferença foi mantida como ponto de conferência, sem classificação automática de erro.

## Evidência Oracle

O snapshot read-only de 21/09/2026 confirmou seis empresas em `TSIEMP`, com CNPJs, cidade/UF e contas por empresa. Os dados completos e as classificações estão no log-resumo.

Evidência: `Logs/Verificacao_Onboarding_ReadOnly_JCLM_20260921.json`.

## Conferência realizada no site Onboarding Deploy

Na versão mais recente exibida no site, o arquivo `USUARIOS_MODELO_VAL_2026_06_V2.xls`, enviado em 11/09/2026 às 18:55, possui 27 usuários, todos com grupo preenchido. Na base Oracle há 33 usuários, dos quais 25 possuem grupo e 8 são usuários de modelo sem grupo; estes 8 foram excluídos da comparação conforme solicitado.

Foram localizados 25 dos 27 usuários por e-mail. Estão ausentes na base:

- `comercial@sumobrasil.com.br` — Jeferson Costa — SUMO — grupo 15;
- `controle@sumobrasil.com.br` — Vanessa Oliveira Sandes — SUMO — grupo 13.

Não foram identificados usuários extras na base por e-mail, nem divergências de grupo nos 25 usuários encontrados. Os 25 usuários com grupo no Oracle estão vinculados ao `CODEMP=1`; 15 deles aparecem como FUTURA ou SUMO no onboarding, ponto que deve ser confirmado antes de qualquer ajuste.

A comparação detalhada está em `Onboarding_Comparacao_Usuarios_20260921.md`. O confronto de empresas está em `Onboarding_Comparacao_Empresas_20260921.md`: 3 empresas no onboarding, todas localizadas na base, e 3 CNPJs adicionais no Oracle (`33.649.134/0001-97`, `05.334.986/0001-50` e `04.816.115/0001-00`) a confirmar.

## Consultas preparadas

- `Artefatos_Revisao/Preflight/52_Onboarding_Identidade_Empresas_READONLY.sql`
- `Artefatos_Revisao/Preflight/53_Onboarding_SMTP_READONLY.sql`
- `Artefatos_Revisao/Preflight/53A_Onboarding_SMTP_Global_READONLY.sql`
- `Artefatos_Revisao/Preflight/54_Onboarding_Contagens_READONLY.sql`
- `Artefatos_Revisao/Preflight/55_Onboarding_Contas_por_Empresa_READONLY.sql`
- `Artefatos_Revisao/Preflight/56_Onboarding_Empresas_Fontes_READONLY.sql`
- `Artefatos_Revisao/Preflight/57_Onboarding_Usuarios_Grupo_READONLY.sql`
- `Artefatos_Revisao/Preflight/58_Onboarding_Usuarios_Resumo_READONLY.sql`
- `Artefatos_Revisao/Preflight/59_Onboarding_Usuarios_Ausentes_READONLY.sql`

## Evidência e próximo passo

Log-resumo: `Logs/Verificacao_Onboarding_ReadOnly_JCLM_20260921.json`. A conferência read-only está concluída, mas as divergências documentais de empresa, SMTP e contas devem constar no relatório e ser tratadas como pendências de confirmação/refinamento. O PDF final não deve ser gerado até os demais gates de volumetria, aprovação textual e destinatária também estarem atendidos.
