# Comparação de onboarding — VITRINI DIRETA (ACM BRASIL)

Status: `SNAPSHOT_ORACLE_CONCLUIDO_COMPARACAO_DOCUMENTAL_PARCIAL`

## Fonte consultada

- Pasta raiz: [8. Onboarding Deploy](https://drive.google.com/drive/folders/1akmvn36k5cP6O2orcOrZxpAfZd7RzSou)
- Pasta do cliente: [ACM BRASIL [p_mrj9q43737l]](https://drive.google.com/drive/folders/1NsukP3ahDBtX0dF4bpFyckBdnY9TgVY7)
- Consulta: leitura de metadados/listagem e leitura dos PDFs-resumo; nenhuma edição, upload, compartilhamento ou exclusão foi feita.

## Inventário encontrado

| Etapa | Fonte | Resultado da leitura |
|---|---|---|
| 01 — Dados da Empresa | `Resumo - 01 - Dados da Empresa.pdf` | Arquivo disponível; contém empresas ACM/ACMINAS/VITRINE DIRETA e contatos de onboarding. |
| 02 — SPEDs | 6 arquivos, incluindo ZIPs de SPED | Arquivos disponíveis; não necessários para o preflight técnico inicial. |
| 03 — XMLs | 25 arquivos, incluindo ZIPs XML | Arquivos disponíveis; serão apenas fonte documental do Card 09, nunca credencial. |
| 04 — Fiscal | `Resumo - 04 - Fiscal.pdf` | Arquivo-resumo disponível; comparação Oracle pendente. |
| 05 — Produtos | `Resumo - 05 - Produtos.pdf` | Arquivo-resumo disponível; comparação Oracle pendente. |
| 06 — Certificados Digitais | resumo + 8 arquivos `.pfx` | Fonte indicada; conteúdo não lido nem exposto. |
| 07 — SMTP | `Resumo - 07 - SMTP.pdf` | Metadados de servidor/porta/criptografia disponíveis; senhas não consultadas nem registradas. |
| 08 — Planilhas | resumo + 4 planilhas | Contas bancárias, usuários e produtos indicados; comparação com `TSICTA`, `TSIUSU` e tabelas relacionadas pendente. |
| 09 — Logotipos | resumo + 2 imagens | Fonte disponível; sem impacto no preflight técnico. |
| 10 — Integrações | `Resumo - 10 - Integracoes.pdf` | Arquivo-resumo disponível; comparação Oracle pendente. |
| 11 — Revisão | `Resumo - 11 - Revisao.pdf` | Onboarding indicado como revisado/concluído pelo cliente. |

## Snapshot Oracle executado

- Script wrapper: `Verificacao_Onboarding_ReadOnly_VITRINI_DIRETA_ACM_BRASIL.sql`.
- Log integral: `Logs/Verificacao_Onboarding_ReadOnly_VDA_20260918_R02.log`.
- Execução: somente leitura, sem DML, DDL, `COMMIT` ou exposição de credenciais SMTP.
- Identidade comprovada: usuário `FRANCISCO_JUNIOR`, schema `SANKHYA`, serviço `vitrinediretaprd.sankhyacloud.com.br`.

| Fonte Oracle | Linhas retornadas |
|---|---:|
| `TSIEMP` — empresas e cidade/UF | 6 |
| `TSIPAR` — SMTP global | 1 |
| `TSIEMP` — SMTP por empresa | 6 |
| `TSICTA` — contas bancárias | 5 |
| `TSIUSU` — usuários | 24 |
| `TGFVEN` — vendedores/compradores | 3 |
| `TGFGRU` — grupos de produto | 3 |
| `TSICUS` — centros de resultado | 1 |
| `TGFNAT` — naturezas | 209 |
| `TGFLOC` — locais de estoque | 1 |

### Identidade empresarial observada

O Oracle retornou seis empresas: `CODEMP 1/4` com razão social `ACM BRASIL LTDA`, `CODEMP 2` como `ACMINAS SUPRIMENTOS PARA COMUNICACAO VISUAL` e `CODEMP 3/5/7` como `VITRINE DIRETA S.A.`. A variação entre ACM Brasil, Vitrine Direta e VITRINI DIRETA (ACM BRASIL) foi registrada como ambiguidade nominal autorizada pelo solicitante, não como divergência impeditiva.

O `Resumo - 01 - Dados da Empresa.pdf` lista sete empresas. A linha documental com CNPJ `25.300.362/0002-00` não foi localizada nas seis linhas retornadas por `TSIEMP`. Esta é uma diferença de quantidade/identidade a confirmar; não foi transformada em DML nem tratada como bloqueio automático. A variação nominal permanece autorizada pelo solicitante.

### SMTP e segurança

O parâmetro global retornou servidor `email-smtp.us-east-1.amazonaws.com:587`, remetente `noreply@sankhya.com.br` e credencial marcada como presente sem exibição. Nas seis linhas de SMTP por empresa, usuário e senha aparecem como ausentes. Nenhuma senha, certificado ou arquivo `.pfx` foi lido ou registrado.

### Usuários, produtos e contas bancárias

- A planilha de usuários contém 15 linhas de usuários de negócio. Foram encontrados 15 e-mails correspondentes no Oracle; há um usuário adicional no Oracle, `daniel@vitrinedireta.com.br` (`CODUSU=23`). As contas técnicas/sistêmicas foram excluídas dessa comparação de negócio.
- A planilha de produtos foi lida em modo somente leitura, com seis seções identificadas e 1.467 linhas na seção principal. A comparação detalhada com `TGFPRO` ainda está pendente porque o snapshot técnico executado não consulta essa tabela.
- O arquivo legado de contas bancárias está disponível, mas a leitura por linhas não é suportada pelo conector sem conversão. Nenhuma conversão, importação ou alteração foi feita; por isso, o confronto detalhado com as cinco linhas de `TSICTA` permanece pendente.

## Classificação atual

- `dado ausente`: CNPJ `25.300.362/0002-00` consta no onboarding, mas não apareceu nas seis linhas de `TSIEMP`; confirmar se representa empresa não implantada, cadastro omitido ou informação documental desatualizada.
- `divergência de configuração`: a diferença 7 empresas no onboarding versus 6 no Oracle está registrada para confirmação; a variação nominal ACM/Vitrine foi autorizada e não é tratada como divergência impeditiva.
- `arquivo-fonte indisponível`: não identificado nas etapas inventariadas acima.
- `correspondente/sem divergência comprovada`: 15 usuários de negócio coincidem por e-mail; a existência do usuário adicional no Oracle e as contas técnicas foram preservadas como observação, não como erro automático.

## Limitações e guardas

- O resumo da etapa 01 usa `VITRINE DIRETA S.A.`, enquanto o alvo técnico informado é `VITRINI DIRETA (ACM BRASIL)`. Isso é uma ambiguidade documental, não uma divergência comprovada; a identidade efetiva será definida exclusivamente pelo retorno de `TSIEMP.RAZAOSOCIAL` na conexão Oracle.
- O GP permanece pendente conforme o prompt da revisão; o nome exibido no resumo de onboarding não foi adotado como GP operacional.
- O gate Oracle somente leitura foi executado e está preservado no log indicado acima.
- Permanece a comparação detalhada das etapas 04, 05, 07, 08 e 10, especialmente `TGFPRO`, `TSICTA` versus a planilha bancária e o PDF de SMTP. O arquivo `.xls` não foi convertido e o PDF de SMTP não retornou texto pelo conector; ausência de confirmação não será convertida automaticamente em divergência.
