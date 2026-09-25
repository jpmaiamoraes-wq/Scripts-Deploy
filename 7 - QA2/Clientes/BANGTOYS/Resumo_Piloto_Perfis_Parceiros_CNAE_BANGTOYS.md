# Piloto de perfis de parceiros por CNAE - BANGTOYS

Data: 03/09/2026

## Escopo

Diagnostico somente leitura. Nenhum registro de `TGFPAR` ou `TGFTPP` foi criado ou atualizado.

## Universo identificado

- 68.035 parceiros distintos com operacao de venda (`TGFCAB.TIPMOV = 'V'`).
- 3.566 pessoas juridicas.
- 3.308 cadastros de pessoa juridica com documento no formato de 14 digitos.
- 3.300 CNPJs distintos nesse conjunto.
- 3.308 parceiros elegiveis ainda sem `TGFPAR.CODTIPPARC`.
- 52 perfis analiticos ativos na arvore `10100000 - Segmento de atuacao`.

## Consulta externa da amostra

Foram consultados dez CNPJs de raizes distintas no OpenCNPJ, com autorizacao explicita. As dez consultas retornaram com sucesso e situacao cadastral ativa. Para minimizar dados, o artefato do piloto conserva apenas CNPJ, parceiro, CNAE de referencia e classificacao sugerida.

O array `cnaes` retornado pelo endpoint consultado nao identifica cada item com um marcador explicito de atividade principal. Para este piloto, o primeiro item foi tratado como CNAE de referencia, de acordo com a ordenacao observada. Antes da automacao em escala, essa premissa deve ser validada contra uma fonte que exponha explicitamente CNAE principal e secundarios.

## Resultado da classificacao

- 2 parceiros possuem correspondencia direta de alta confianca com perfis existentes.
- 7 parceiros apontam para perfis analiticos novos, repetindo quatro sugestoes: brinquedos, cosmeticos, eletronicos e consultoria/logistica.
- 1 parceiro evidencia a necessidade de decidir se a arvore deve ganhar um ramo proprio para atacado/distribuicao.

## Recomendacao tecnica

Nao atualizar `TGFPAR.CODTIPPARC` com base apenas em palavras da razao social. A regra deve priorizar CNAE principal confirmado, usar CNAEs secundarios apenas como evidencia complementar e encaminhar ambiguidades para revisao.

Antes de executar em escala:

1. validar o digito verificador dos 3.308 CNPJs, nao apenas o tamanho;
2. obter CNAE principal e secundarios em campos inequivocos;
3. aprovar um mapa versionado `CNAE -> CODTIPPARC`;
4. definir os novos perfis e sua posicao na hierarquia;
5. consultar cada CNPJ distinto apenas uma vez e reutilizar o resultado entre filiais/cadastros quando aplicavel;
6. gerar tabela de staging, backup persistente, identificador de execucao e script de reversao antes de qualquer `UPDATE`.

## Perfis atuais com correspondencia direta na amostra

- `10101016 - Computadores e perifericos`.
- `10101014 - Moveis e utensilios`.

## Novos conceitos sugeridos pela amostra

- Brinquedos e artigos recreativos.
- Cosmeticos e perfumaria.
- Eletronicos e eletrodomesticos.
- Consultoria empresarial.
- Logistica e armazenagem.
- Atacado e distribuicao, sujeito a revisao estrutural da arvore.

## Evolucao da proposta

Foi recomendada uma nova ramificacao sintetica `10104000 - Atacado e distribuicao`, diretamente subordinada a `10100000 - Segmento de atuacao`. A proposta detalhada e o mapa inicial de CNAEs foram registrados em artefatos separados. Nenhum cadastro ou parceiro foi alterado nesta etapa.
