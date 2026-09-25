# Conferência read-only do onboarding — D-COMMERCE LTDA

Data da conferência: 14/09/2026

Gerente de Projetos: Adirvanildo da Silva Pinto (`adirvanildo.pinto@sankhya.com.br`)

## Fontes consultadas

- Pasta do cliente no Shared Drive: `8. Onboarding Deploy/D-COMMERCE LTDA [p_msdjhmii26x8]`.
- `01 - Dados da Empresa/Resumo - 01 - Dados da Empresa.pdf`.
- `07 - SMTP/Resumo - 07 - SMTP.pdf`.
- `08 - Planilhas/Resumo - 08 - Planilhas.pdf`.
- `08 - Planilhas/MODELO_SANKHYA_Contas_Bancarias_PREENCHIDO_1.xlsx`.
- `08 - Planilhas/Modelo_Sankhya_Usuarios_Preenchido.xlsx`.

## Método

A conexão read-only foi conferida no SQLcl com usuário `FRANCISCO_JUNIOR`, schema `SANKHYA` e serviço `inflowsofaprd.sankhyacloud.com.br`. O snapshot foi obtido sem DML/DDL, sem criação de tabelas auxiliares e sem exposição de credenciais SMTP. Foram confrontados os identificadores normalizados do onboarding com os campos nativos disponíveis na base.

## Resultado comprovado

### Dados das empresas

- O PDF relaciona 14 empresas/CNPJs.
- `TSIEMP` retornou 13 empresas.
- 13 CNPJs do onboarding foram localizados na base, com razão social e inscrição estadual compatíveis após a normalização de pontuação.
- O CNPJ `16.660.804/0001-57` — `RENTABENS PARTICIPACOES S.A` — consta no onboarding, mas não foi localizado em `TSIEMP`.
- A UF da base é armazenada como código em `TSICID.UF`; por isso a conferência desta prévia registra o CNPJ ausente como divergência objetiva e não infere divergência de UF sem a tabela de conversão correspondente.

### SMTP

- O onboarding informa provedor Gmail, servidor `smtp.gmail.com`, porta 587, TLS e remetente não informado.
- `TSIPAR.MSDSMTPPROP` está configurado com o endpoint `email-smtp.us-east-1.amazonaws.com:587`, remetente `noreply@sankhya.com.br` e credencial presente.
- Divergência objetiva: o provedor/endpoint e o remetente efetivos não coincidem com o onboarding. O valor sensível da credencial não foi reproduzido.

### Contas bancárias

- A planilha contém 48 contas preenchidas, excluída a aba de códigos bancários de referência.
- `TSICTA` retornou 17 registros; 2 são contas bancárias reais da empresa principal e 15 são contas operacionais/virtuais ou de apoio.
- 1 conta do onboarding coincide integralmente com banco, agência, conta/dígito, empresa e indicação de boleto.
- A segunda conta informada para `59.649.505/0001-24` mantém o mesmo número de conta/dígito, mas diverge em banco e agência quando comparada ao registro efetivo de `TSICTA`.
- As demais 46 contas do onboarding não possuem correspondência completa nos campos nativos consultados de `TSICTA`. Nenhuma conta foi incluída, alterada ou excluída.

### Usuários

- A planilha contém 55 usuários mapeados.
- A consulta read-only por e-mail nos domínios utilizados pelo onboarding retornou 55 registros, com correspondência de e-mail para a quantidade mapeada.
- Os 55 registros retornados estão com `CODGRUPO = 0` e `CODEMP = 1`. Portanto, os usuários existem, mas a parametrização de grupos do onboarding — que utiliza grupos 1 a 17 — não está refletida em `TSIUSU`, e a abrangência por empresas também não está refletida individualmente.
- A conferência não alterou nomes, grupos ou empresas dos usuários; a associação por empresa do arquivo é uma classificação funcional e não foi convertida automaticamente em `CODEMP`.

### Demais planilhas previstas

Não foram localizados, na pasta `08 - Planilhas`, arquivos aplicáveis de vendedores/compradores, grupos de produtos, centros de resultado, naturezas ou locais de estoque. Esses conjuntos foram classificados como sem fonte de onboarding aplicável nesta base, e não como divergência de dados.

## Conclusão operacional

A conferência de onboarding foi executada antes da aprovação do relatório e sem alteração na base. As divergências objetivamente comprovadas foram registradas para a fase de refinamento: empresa do onboarding ausente em `TSIEMP`, configuração SMTP efetiva diferente do formulário e contas bancárias não refletidas integralmente em `TSICTA`. O roteiro genérico `7 - QA2/Revisao Master Deploy/Verificacao_Onboarding_ReadOnly.sql` passa a ser o padrão para as próximas bases.
