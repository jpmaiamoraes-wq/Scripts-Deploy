# Comparação de usuários do onboarding — RIOSLTDAPRD

status: CONCLUIDA_READ_ONLY_COM_DIVERGENCIAS_DE_GRUPO

## Fonte

- Arquivo mais recente: `[MODELO SANKHYA] Usuarios (1).xlsx`.
- Enviado em: `2026-08-26 12:19`.
- Registros no arquivo: `7`.
- Critério Oracle: somente `TSIUSU.CODGRUPO > 0` entra na comparação ativa.

## Resultado

- Usuários Oracle totais: `18`.
- Usuários Oracle sem grupo (`CODGRUPO=0`): `11`, classificados como usuários de modelo e excluídos da comparação.
- Usuários Oracle com grupo: `7`.
- E-mails do onboarding localizados no Oracle: `7`.
- E-mails do onboarding ausentes no Oracle: `0`.
- Usuários ativos adicionais na base fora do arquivo: `0`.
- Nomes: correspondentes após normalização de caixa, pontuação e acentuação.
- Empresa: os 7 usuários estão em `CODEMP=1`, correspondente à empresa do CNPJ `58.364.248/0001-11`.

## Divergências de grupo

| E-mail | Nome | Grupos no onboarding | CODGRUPO Oracle | Resultado |
|---|---|---|---:|---|
| `julia.riosltda@gmail.com` | Júlia Soares / JULIA.SOARES | `1/2/4/8/10/15` | 1 | Divergência de grupo |
| `marcelo.riosltda@gmail.com` | Marcelo Pereira / MARCELO.PEREIRA | `1/2/3/4/5/6/10/15/17` | 1 | Divergência de grupo |
| `distribuicao@riosltda.com.br` | Carlos Henrique / CARLOS.HENRIQUE | `1/2/3/4/5/6/8/10/15/18` | 1 | Divergência de grupo |
| `joaomarcelo.riosltda@gmail.com` | João Marcelo / JOAO.MARCELO | `5/6/8/13` | 5 | Divergência de grupo |
| `vania.riosltda@gmail.com` | Vânia Soares / VANIA.SOARES | `15` | 1 | Divergência de grupo |
| `leticia.riosltda@gmail.com` | Letícia Morais / LETICIA.MORAIS | `15` | 1 | Divergência de grupo |
| `edna.riosltda@gmail.com` | Edna Rodrigues / EDNA.RODRIGUES | `8/13/14` | 8 | Divergência de grupo |

Os registros foram preservados como divergência informativa. Nenhum grupo, usuário, nome ou empresa foi alterado automaticamente.

## Evidência Oracle

- Consulta: `Clientes/RIOSLTDAPRD/Onboarding_Usuarios_ReadOnly.sql`.
- Sessão: `FRANCISCO_JUNIOR` / schema `SANKHYA` / serviço `riosltdaprd.sankhyacloud.com.br` / base `RIOSLTDAPRD`.
- Quantidade retornada de `TSIUSU`: `18`.
- `dml_executado=false`; `ddl_executado=false`.
