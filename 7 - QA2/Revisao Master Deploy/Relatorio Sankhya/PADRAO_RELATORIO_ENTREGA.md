# Padrão de Relatório de Entrega Técnica

## Fontes de dados

- Usar os resultados comprovados nos logs da execução e nos prechecks da base.
- Não reproduzir nomes de outras bases nos objetos ou no documento; referências
  técnicas devem usar nomenclatura neutra, preferencialmente `Modelo`.
- Ler e executar a `queryString` de `Base Relatório de Entrega/REL_ENTREGA_NOVO_05.jrxml` pela conexão Oracle direta, incluindo os indicadores normalmente ocultos na impressão.
- Consultar `Volumetria Deploy Agent.xml` para os cards complementares que não estejam na `queryString` do JRXML.
- Persistir a volumetria atual com identidade da sessão, fonte, data/hora, quantitativos e confirmação de que não houve DML/DDL. Não reutilizar quantitativos antigos sem nova consulta.
- Nunca transformar ausência de registro em log incompleto em conclusão de sucesso.
- Quando houver mais de um registro para a mesma etapa, considerar somente o último status validado; situações anteriores superadas não devem reaparecer como alerta no resumo final.
- No índice de reversão, manter cada etapa em uma linha própria.
- Na relação de objetos inválidos, manter cada objeto em uma linha própria.

## Estrutura do documento

1. Capa institucional contendo somente o título “RELATÓRIO TÉCNICO - REVISÃO MASTER DEPLOY”, a base, a data de conclusão e o nome do Gerente de Projetos. O conteúdo técnico começa na mesma primeira página após um resumo executivo curto; as demais seções começam na página seguinte.
2. Tabelas técnicas, mantendo uma linha para cada atividade (01 a 31) e, quando executada, a atividade regular 32, descrevendo o propósito da atividade, o último status comprovado, objetos e reversão. Usar tabelas também para os 21 cards de volumetria e demais quantitativos comparáveis, seguindo o padrão visual aplicado no relatório de Produtos Macalé.
3. Resultado das rotinas com tabelas, campos, parâmetros, quantidades, backups e IDs de execução.
4. Inventário dos objetos criados, com o propósito de cada objeto, e índice dos scripts de reversão por etapa.
5. Pontos de atenção, pendências e tickets relacionados.
6. Considerações finais com o estado real da revisão.

## Fluxo de aprovação

- Primeiro gerar um documento em texto simples, em UTF-8, com todo o conteúdo técnico e as orientações dos cards.
- Submeter o texto para revisão e aprovação do solicitante.
- Antes da aprovação e da geração do PDF, comprovar a conferência read-only do onboarding: fontes mais recentes no Drive contra `TSIEMP`/`TSICID`, `TSIPAR` e as tabelas correspondentes às planilhas. Sem esse comprovante, alertar o solicitante e não gerar o PDF.
- Gerar o PDF somente após a aprovação explícita do texto.
- Antes da aprovação do texto e novamente antes do PDF, validar os cards obrigatórios de resultado zero usando a volumetria atual: financeiros sem nota, itens sem cabeçalho, cabeçalhos sem itens e códigos fiscais de cidades duplicados.
- Se qualquer um dos quatro indicadores for maior que zero, bloquear o PDF até análise e decisão registrada.

## Orientações dos cards

- Incluir no relatório uma seção de orientação aos consultores com o propósito e a interpretação de cada um dos 21 cards.
- Usar o documento `ORIENTACOES_CARDS_VOLUMETRIA.md` como fonte padrão dessas orientações.
- Para o card 09 (Notas sem Financeiro), apresentar separadamente total, candidatos com `<Dup>`/`<dVenc>` válidos, processados, saldo elegível restante e casos sem `<Dup>`. Após a redução pela volumetria e a revisão do mapa, preferir o procedimento controlado de XML direto 32A/32B; usar a rotina nativa ou o caminho legado com function somente quando aplicável. Em todos os casos, exigir confirmação explícita, auditoria e rollback; não executar `INSERT` avulso em `TGFFIN` nem trocar TOP somente para ocultar o indicador.
- Os cards 08 (Financeiros sem Nota), 13 (Itens sem Cabeçalho), 14 (Cabeçalho sem Itens) e 15 (Cidades Duplicadas) devem ser zero.
- Se qualquer um desses quatro cards for maior que zero, destacar a ocorrência no documento de texto e interromper a preparação do PDF até a análise da incompletude ou aprovação de uma exceção.

## Identidade visual Sankhya

- Página A4.
- Primeira página com o fundo institucional Sankhya e o conteúdo restrito à área branca.
- Páginas seguintes com logo Sankhya, linha verde no cabeçalho e faixa institucional no rodapé.
- Títulos e subtítulos em verde Sankhya; título principal em 16 pt, subtítulo em 14 pt e corpo em 12 pt.
- Primeira página alinhada à esquerda para preservar a leitura na coluna estreita do template.
- Páginas internas e listas com alinhamento justificado.
- Títulos e subtítulos devem permanecer junto do primeiro conteúdo seguinte.
- Tabelas e cartões devem manter contraste, margens e legibilidade em todas as páginas.

## Links e publicação

- Somente o item da pasta de entrega do Google Drive deve ser um link clicável e azul no corpo do relatório; nomes de scripts, logs e rollbacks permanecem em texto preto.
- Publicar os artefatos em `Revisoes Deploy Agent/<base>` no Google Drive.
- Compartilhar somente com o domínio `sankhya.com.br`, como leitor, sem listagem pública ou pesquisa por domínio.
- O relatório deve conter o link clicável para a pasta da base.
- Disponibilizar no Drive o índice de rollbacks, o inventário de objetos e o arquivo master de limpeza.

## Validação antes da entrega

- Renderizar o PDF em imagens e conferir capa, tabelas, páginas internas, última página, cabeçalhos, rodapés, paginação e transições de seção.
- Confirmar que o PDF não contém cortes, sobreposições, caracteres ilegíveis ou conclusões sem evidência.
- Preservar no relatório as contagens e tickets necessários para rastrear cada resultado; manter IDs técnicos somente nos artefatos internos, salvo solicitação expressa.
