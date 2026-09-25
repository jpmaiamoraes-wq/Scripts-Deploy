# Orientações padrão dos cards de volumetria

Esta orientação acompanha o relatório de entrega técnica e deve ser apresentada aos consultores responsáveis pelas etapas finais de refinamento. Os quantitativos representam os registros presentes na base a partir dos artefatos processados pelo Deploy Agent; devem ser validados com o cliente quando indicado.

## 01 — Financeiro

Mostra a quantidade de títulos extraídos dos artefatos disponibilizados. Financeiros que não estejam vinculados a artefatos processados, como folha de pagamento e outras despesas sem XML ou EFD correspondente, não estarão presentes na base. O montante representa exclusivamente os artefatos disponibilizados. Para completar registros financeiros legados, pode ser utilizada a ferramenta **Cadastro da Posição Financeira**, em **Assistente de Melhores práticas > Configurações Globais > Gerenciais**.

## 02 — Entradas e Saídas

Apresenta uma visão panorâmica dos registros existentes, analítica por TOP (tipo de operação), para apoiar a validação com o cliente. A associação de TOPs durante o processamento dos artefatos pelo Deploy Agent pode ser imprecisa em determinados cenários.

## 03 — Produtos por Usoprod

Apresenta produtos e serviços agrupados pelo tipo de uso na empresa. A classificação deve ser validada com o cliente, pois a definição do tipo de uso pode ser imprecisa em determinados cenários.

## 04 — Produtos por Grupo

Apresenta os produtos conforme os grupos enviados na fase de onboarding. Esse cadastro não é feito automaticamente pela rotina regular do Deploy Agent: depende de importação manual, quando os dados são disponibilizados e estão elegíveis conforme a arquitetura do cadastro. Mesmo com o cadastro dos grupos, a associação dos produtos será realizada no refinamento do projeto.

## 05 — Referências Duplicadas

Separa itens com a mesma referência para tratamento posterior no refinamento. A duplicidade pode representar reaproveitamento de referência nas emissões, item obsoleto, controle adicional de estoque, produto equivalente ou outra regra de negócio.

## 06 — Descrições Duplicadas

Aplica o mesmo objetivo do card de referências duplicadas, considerando descrições e os critérios complementares de identificação. A duplicidade pode representar reaproveitamento, obsolescência, controle adicional, equivalência ou outra regra de negócio.

## 07 — CNPJ/CPF Repetidos

Relaciona parceiros que compartilham o mesmo CNPJ ou CPF, mas apresentam alguma variação cadastral, como inscrição estadual ou endereço.

## 08 — Financeiros sem Nota

Relaciona registros financeiros sem cabeçalho associado. O resultado esperado é zero; qualquer quantidade maior que zero deve ser tratada como alerta de possível incompletude da revisão.

## 09 — Notas sem Financeiro

É um diagnóstico de notas cujo TOP está configurado para atualizar o financeiro, mas não há linha correspondente na `TGFFIN`. O quantitativo do card não comprova, sozinho, que a ausência é legítima.

Durante a revisão, separar os registros em três grupos: (a) candidatos com `<Dup>` e `<dVenc>` válidos no XML, que devem passar pelo preflight e mapa 32A; depois da validação, podem seguir pela rotina nativa ou pelo insert controlado 32B, com confirmação explícita e auditoria; (b) registros sem `<Dup>`, que permanecem pendentes para validação do negócio; e (c) registros com XML incompleto ou inválido, que devem ser analisados antes de qualquer ação.

Não fazer inserts avulsos em `TGFFIN` e não trocar o TOP apenas para retirar o registro do card. Quando o procedimento 32B for usado, registrar seu `ID_EXECUCAO`, tabelas de auditoria, quantidade inserida, quantidade que já possuía financeiro, saldo elegível restante e casos sem `<Dup>`. A data de vencimento deve seguir a negociação e o XML; ela pode não representar a data operacional real.

## 10 — Produtos Vendidos

Mostra itens com movimentação de saída, mas sem movimentação de entrada. Pode indicar duplicidade cadastral quando não é possível associar compras e vendas por uma chave confiável, inclusive em situações de produtos equivalentes.

## 11 — Produtos com Custo Zero

Mostra itens com linha na TGFCUS, porém com valor zerado. Durante a revisão pode ser utilizada a rotina **Gerente On Line (GOL) > Configurações > Margem de Contribuição > Atualizar Tabela de Custos para Produtos sem Custos**.

## 12 — Produtos sem Custo

Mostra itens sem qualquer linha de custo na TGFCUS. Isso pode ocorrer em produtos importados por planilha, cadastros manuais ou itens inseridos via EFD sem movimentação correspondente no período. Como não possuem registros na TGFITE, esses itens não são tratados pela rotina nativa de atualização de custos.

## 13 — Itens sem Cabeçalho

Relaciona registros de movimentação na TGFITE sem cabeçalho correspondente. O resultado esperado é zero; qualquer quantidade maior que zero deve bloquear a conclusão do relatório até a análise.

## 14 — Cabeçalho sem Itens

Relaciona registros na TGFCAB sem item associado na TGFITE. O resultado esperado é zero; qualquer quantidade maior que zero deve bloquear a conclusão do relatório até a análise.

## 15 — Cidades Duplicadas

Relaciona eventuais duplicações de cidades. O resultado esperado é zero; qualquer quantidade maior que zero deve bloquear a conclusão do relatório até a análise.

## 16 — Classificação Fiscal

Relaciona parceiros cuja classificação fiscal atual pode estar divergente. O ajuste deve ser avaliado na revisão quando houver dúvida sobre a completude do cadastro, inclusive ausência de inscrição estadual que possa influenciar a classificação correta.

## 17 — Itens sem Tabela de Preço

Relaciona itens para os quais não foi possível gravar tabela de preços por não haver movimentação de saída elegível, como baixa de estoque, geração de receita a receber ou uso do tipo venda/revenda.

## 18 — Itens com Descrições Similares

Relaciona itens com grande possibilidade de duplicidade quando não é possível fazer o vínculo entre entrada e venda. São listadas descrições com similaridade de caracteres igual ou superior a 95% para tratamento no refinamento.

## 19 — CNPJ Matrizes

Relaciona parceiros pessoa jurídica que compartilham o mesmo radical de CNPJ, formado pelos oito primeiros dígitos. O menor código é definido como matriz e associado aos demais parceiros do agrupamento.

## 20 — Produtos Comprados

Apresenta o inverso do card de Produtos Vendidos: itens com movimentação de entrada, mas sem movimentação de saída. É um resultado coerente para matérias-primas, uso e consumo e outros itens sem venda.

## 21 — Regras Tributárias Inseridas

Apresenta uma compilação das regras tributárias cadastradas pelo Deploy Agent, incluindo ICMS, PIS, COFINS, IPI e ISS.

## Regra de bloqueio dos cards críticos

Antes de solicitar aprovação do texto e antes de gerar o PDF, conferir os cards 08, 13, 14 e 15. Qualquer resultado maior que zero deve aparecer como alerta destacado, com a etapa relacionada e a recomendação de análise. O PDF não deve ser concluído enquanto a ocorrência não for tratada ou formalmente aprovada como exceção.
