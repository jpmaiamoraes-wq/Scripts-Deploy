# Conferência do onboarding — MEDCHAP DISTRIBUIDORA DE MEDICAMENTOS CHAPECO LTDA

- Fonte: `Artefatos_Revisao/Onboarding - MEDCHAP DISTRIBUIDORA DE MEDICAMENTOS CHAPECO LTDA.zip` (botão "Baixar Tudo", 25/09/2026 09:30). API do Onboarding indisponível (HTTP 403; aguardando retorno do Adelcione).
- Base: FRANCISCO_JUNIOR / SANKHYA / medchapprd (MEDCHAPPRD). Consultas somente leitura O01–O03 (`Preflight/Onboarding/`), `dml_executado=false`, `ddl_executado=false`.
- Evidência completa: `Onboarding_Comparacao_ReadOnly_MEDCHAP.json` (script `Preflight/Onboarding/comparar_onboarding_MEDCHAP.py`).

## Empresas (informação de escopo, não é gate)
| CNPJ | Onboarding | Oracle | Resultado |
|---|---|---|---|
| 00.577.604/0001-03 | Matriz, SC | CODEMP 1, Chapecó/SC | Corresponde (IE e UF) |
| 00.577.604/0003-67 | Filial, SC | CODEMP 2, Curitibanos/SC | Corresponde |
| 00.577.604/0004-48 | Filial, PR | CODEMP 3, São José dos Pinhais/PR | Corresponde |
| 31.794.188/0001-10 PROWIN | "Filial", UF não informada | CODEMP 4, Chapecó/SC | Divergência documental: é outra empresa (outra raiz de CNPJ), não filial; IE confere |
| 42.824.603/0001-58 SALUTH | "Filial", UF não informada | CODEMP 5, Chapecó/SC | Divergência documental: outra empresa; IE ISENTO confere |

Nenhuma empresa ausente ou adicional.

## Usuários (somente `TSIUSU.CODGRUPO > 0`, chave e-mail + nome)
- Planilha: 93 linhas. Oracle: 104 usuários, 93 com grupo; 11 sem grupo (usuários de modelo/integração: SUP, COTACAOB2B, SKWCLOUD, VENDEDOR, GERENTE, SANKHYA, LIBERADOR, INTEGRAÇÃO.PONTOTEL/MINDSIGHT/VIXTING, SKWCLOUDAPI) excluídos.
- 80 correspondem integralmente; 0 ausentes; 0 extras.
- Grupos: equivalência planilha → Oracle consistente (cada nome da planilha aponta para um único grupo; ex.: "Callcenter" → 18 CALL CENTER OPERACIONAL, "Comercial" → 15 VENDAS OPERACIONAL).
- **Divergência que exige decisão (12 usuários):** os usuários marcados na planilha como **FILIAL - CBS** (Curitibanos, CODEMP 2) estão na base com **CODEMP 4 (PROWIN COMPANY LTDA)**: armazenamento, expedição, faturamento (2), gerente, segregação, responsável técnico, logística auxiliar, agendamento, logística, recebimento e RH `.cbs@medchap.com.br`. Os 11 de **FILIAL - SJP** estão corretamente em CODEMP 3.
- Divergência nominal (1): `logistica01.sjp@medchap.com.br` — na base o nome está gravado como `JOAO.GON¿ALVES` (caractere "Ç" corrompido).

## Contas bancárias (agência/conta comparadas por hash; nada exibido em claro)
| Conta | Banco | Resultado |
|---|---|---|
| 1 | Banco do Brasil (001), final da conta ..52 | Conta encontrada na empresa 1; **agência não confere** com a planilha — verificar formato/dígito da agência cadastrada |
| 2 | Santander (033) | Corresponde |
| 3 | Itaú (341) | Corresponde |
| 4 | Sicoob (756) | Corresponde |

Contas adicionais na base: 101 CAIXA PDV, 102 CAIXA TESOURARIA (ativas, empresa 1) e 103 CAIXA TESOURARIA (inativa, sem empresa) — contas internas de caixa, não bancárias.

## SMTP
Onboarding: remetente Medchap, servidor smtp.office365.com, porta 587, TLS (senha não lida nem copiada). Confronto com `TSIPAR` não executado nesta rodada.

## Pendências para decisão
1. Usuários CBS em CODEMP 4 (PROWIN) em vez de CODEMP 2 (Curitibanos): confirmar com o GP/cliente antes de qualquer ajuste (fora do escopo automático da revisão).
2. Agência do Banco do Brasil: conferir o cadastro em TSICTA/TSIAGE.
3. Onboarding classifica PROWIN e SALUTH como "Filial": apenas registro documental.

## Evidência para "FILIAL - CBS" (conferida em 25/09/2026, somente leitura do zip do onboarding)
- Os SPEDs enviados pelo cliente com o rótulo **CBS** ("SPED - CBS 072025 a 072026.zip" e "SPED - CBS 082026.zip") trazem, no registro |0000|, o CNPJ **00.577.604/0003-67**, IE 258178124, município IBGE 4204806 (Curitibanos/SC) = **CODEMP 2** na base.
- O mesmo critério confirma **SJP** = 00.577.604/0004-48 (São José dos Pinhais/PR) = CODEMP 3, onde os 11 usuários SJP já estão corretamente.
- A PROWIN (CODEMP 4) tem SPED próprio ("Prowin matriz.zip", CNPJ 31.794.188/0001-10, Chapecó). Logo, os 12 usuários CBS com CODEMP 4 são, com base nos documentos do próprio cliente, uma divergência provável; a correção (CODEMP 4 → 2) fica condicionada à confirmação do GP/cliente.

## Tratamento (25/09/2026)
- Usuários CBS: corrigidos na atividade 34 (`MEDCHAP_USUEMP_20260925_01`) — CODEMP 4 → 2 para CODUSU 81..92, com backup `BKP_RMD_MDCH_USUEMP01` (12) e reversão `Reverter_34_Ajuste_Usuarios_Empresa_MEDCHAP.sql`. Pós-validação: 0 usuários CBS fora da empresa 2.
- Nome corrompido: corrigido na atividade 33 (`MEDCHAP_CAR_20260925_02`) — login JOAO.GONCALVES.
- Pendente: agência do Banco do Brasil.
- Agência do Banco do Brasil: **confere**. A base grava a agência com o dígito verificador "X" substituído por "0" (padrão bancário informado pelo usuário em 25/09/2026); a comparação por hash de agência+"0" coincide com a TSICTA (conta 104). O script de comparação passou a considerar essa regra. Onboarding sem pendências de dados.
- SMTP (confronto feito em 25/09/2026, sem ler senhas): o onboarding informa smtp.office365.com, porta 587, TLS, remetente envio@medchap.com.br; na base (TSIEMP/TGFEMP) nenhuma das 5 empresas tem servidor SMTP configurado (porta padrão 25, sem segurança) e não há SMTP de XML vinculado. Pendência de configuração para o refinamento (exige a senha do cliente; não configurada pela revisão).
- SMTP (correção da análise acima, 25/09/2026): a conta principal do sistema fica no parâmetro TSIPAR MSDSMTPPROP e **já corresponde** ao onboarding (smtp.office365.com:587, envio@medchap.com.br). A TSISMTP tinha apenas a conta interna de testes do Deploy Agent, removida na atividade 35 (`MEDCHAP_SMTP_20260925_01`). Sem pendência de SMTP.
