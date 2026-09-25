# Gerador de PDFs Sankhya

Este pacote gera PDFs com a identidade visual extraida do template `Template Sankhya - Papel Timbrado.docx`.

## Como usar

1. Cole o texto em um arquivo `.md` ou `.txt`.
2. Use `#` para titulo, `##` para subtitulo, `###` para secoes menores e `-` para listas.
3. Rode:

```bash
/Users/spadarojr/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 sankhya_documentos/gerar_pdf_sankhya.py seu-texto.md -o documento-sankhya.pdf
```

## Padrao aplicado

- Pagina A4.
- Primeira pagina com fundo institucional verde e `sankhya.com.br`.
- Paginas seguintes com logo Sankhya no cabecalho.
- Faixa institucional no rodape.
- Titulo em verde escuro, 16 pt, negrito.
- Subtitulo em preto, 14 pt, negrito.
- Corpo em 12 pt.
- No relatório de entrega, somente o item da pasta do Google Drive deve usar link clicável azul; demais scripts, logs e rollbacks devem ser citados em texto preto.

## Estrutura dos relatórios de entrega

- Resumo executivo com cliente, responsável, data e indicadores.
- Uma linha para cada etapa (01 a 31), com o propósito da etapa e somente o último status validado.
- Volumetria baseada na `queryString` de `Base Relatório de Entrega/REL_ENTREGA_NOVO_05.jrxml`, executada pela conexão Oracle direta, com consulta complementar ao dashboard `Volumetria Deploy Agent.xml` quando necessário. Registrar a fonte e os quantitativos atuais; não reutilizar valores antigos sem nova consulta.
- Inventário de tabelas/objetos criados, propósito de cada objeto, alterações, backups e índice de roteiros de reversão por etapa.
- Arquivo master de limpeza dos objetos de revisão, citado no relatório e publicado junto aos demais artefatos.
- Pontos de atenção e pendências, com tickets e referências em texto; somente a pasta do Drive recebe link clicável.
- Situações anteriores superadas não devem permanecer como alertas quando o último status da etapa já estiver concluído.
- O índice de reversão deve apresentar uma etapa por linha, e a relação de objetos inválidos deve apresentar um objeto por linha.
- QA visual do PDF renderizado antes da entrega.

Quando voce colar o texto aqui na conversa, eu posso gerar o PDF diretamente usando este gerador.

## Fluxo obrigatório de entrega

- Gerar primeiro o documento em texto simples (`.txt`) com o conteúdo completo.
- Submeter o texto para revisão e aprovação explícita.
- Conferir os cards críticos 08, 13, 14 e 15; qualquer resultado acima de zero deve ser alertado e tratado antes do PDF.
- Os quatro indicadores de integridade — financeiros sem nota, itens sem cabeçalho, cabeçalhos sem itens e códigos fiscais de cidades duplicados — devem estar comprovadamente zerados na prévia TXT e novamente no PDF.
- Gerar o PDF somente após a aprovação do texto e da validação dos cards críticos.

## Comunicação de encerramento

- Assistentes de projetos: somente 1 = Ana Paula Rodrigues ou 2 = Gabriela Stabile Lemos, perguntada no `prepare` (terminal) ou no chat antes do encerramento, se pendente.
- Depois da aprovação do texto, validação visual do PDF e confirmação dos destinatários, o agente principal envia somente o PDF final anexado.
- Para Ana Paula Rodrigues (`ana.rodrigues@sankhya.com.br`), enviar somente para ela, sem o Gerente de Projetos. Para Gabriela Stabile Lemos (`gabriela.lemos@sankhya.com.br`), enviar para o Gerente de Projetos, com ela em cópia.
- Assunto: `Conclusão da revisão Master Deploy — <BASE>`.
- Corpo: `Olá,\n\nConcluímos a etapa de revisão Master Deploy da base <BASE>.\n\nEncaminho em anexo o relatório de entrega técnica com o resumo do que foi executado.\n\nAtenciosamente,`.

As orientações de interpretação dos 21 cards estão em `ORIENTACOES_CARDS_VOLUMETRIA.md` e devem ser incorporadas ao texto de cada relatório.

## Gate obrigatório de onboarding antes do PDF

- Antes de aprovar o texto ou iniciar a geração do PDF, executar o roteiro genérico `Verificacao_Onboarding_ReadOnly.sql` na base e conferir os arquivos mais recentes da pasta do cliente em `8. Onboarding Deploy`.
- Comparar o PDF de dados da empresa com `TSIEMP`/`TSICID`, o SMTP com `TSIPAR` sem reproduzir credenciais e as planilhas com as tabelas correspondentes.
- Registrar por base as fontes consultadas, datas, quantidades comparadas, correspondências, divergências comprovadas e linhas de modelo/extra classificadas.
- Se não houver evidência dessa conferência, a geração do PDF deve ser interrompida e o solicitante deve ser alertado antes de qualquer conversão.
