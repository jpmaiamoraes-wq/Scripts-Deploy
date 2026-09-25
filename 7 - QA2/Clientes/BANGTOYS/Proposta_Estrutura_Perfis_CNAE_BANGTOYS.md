# Proposta de estrutura de perfis por CNAE - BANGTOYS

Data: 03/09/2026

## Situacao desta etapa

Proposta documental baseada na arvore atual da `TGFTPP` e no piloto com dez CNPJs. Nenhuma gravacao foi realizada no banco.

## Decisao recomendada

Criar `10104000 - Atacado e distribuicao` como ramo sintetico diretamente abaixo de `10100000 - Segmento de atuacao`.

Atacado nao deve ser tratado como varejo: o varejista vende predominantemente ao consumidor final, enquanto atacadistas e distribuidores abastecem outras empresas e exercem papel diferente na cadeia comercial. Manter os conceitos separados melhora filtros, analises de carteira e futuras segmentacoes comerciais.

## Estrutura minima proposta

```text
10100000 Segmento de atuacao
|-- 10101000 Varejo
|   |-- 10101024 Brinquedos e artigos recreativos (novo)
|   |-- 10101025 Cosmeticos e perfumaria (novo)
|   `-- 10101026 Eletronicos e eletrodomesticos (novo)
|-- 10102000 Industria
|-- 10103000 Servicos
|   |-- 10103012 Consultoria empresarial (novo)
|   `-- 10103013 Logistica e armazenagem (novo)
`-- 10104000 Atacado e distribuicao (novo)
    |-- 10104001 Alimentos e bebidas
    |-- 10104002 Cosmeticos e perfumaria
    |-- 10104003 Brinquedos e papelaria
    |-- 10104004 Material eletrico e eletronicos
    |-- 10104005 Ferragens e materiais de construcao
    |-- 10104006 Autopecas, pneus e acessorios
    |-- 10104007 Moveis e utilidades domesticas
    |-- 10104008 Maquinas e equipamentos
    |-- 10104009 Produtos agropecuarios
    `-- 10104010 Outros produtos atacadistas
```

## Regras propostas para o mapeamento

1. Usar somente perfis analiticos e ativos como destino de `TGFPAR.CODTIPPARC`.
2. Priorizar o CNAE principal confirmado por uma fonte que o identifique explicitamente.
3. Usar CNAEs secundarios apenas para desempate ou revisao, nunca para sobrescrever automaticamente um CNAE principal conclusivo.
4. Exigir correspondencia direta ou regra de faixa previamente aprovada para classificacao de alta confianca.
5. Encaminhar CNAEs residuais, multiplas atividades conflitantes e empresas de marketplace para revisao humana.
6. Nao usar razao social ou nome fantasia como unica evidencia; esses campos podem auxiliar somente a revisao.
7. Versionar o mapa `CNAE -> CODTIPPARC`, mantendo data, justificativa e responsavel pela aprovacao.

## Cuidados antes de cadastrar

- Confirmar definitivamente que os codigos propostos estao livres na base modelo, nao apenas na BANGTOYS.
- Validar campos obrigatorios, restricoes, triggers e o mecanismo oficial de geracao/manutencao da `TGFTPP`.
- Corrigir, se desejado, descricoes existentes como `Esruturas metalicas` e `Trasportadoras` em atividade separada e controlada.
- Aprovar a granularidade com a equipe funcional para evitar crescimento excessivo da arvore.

## Proxima validacao sugerida

Ampliar o mapa de CNAEs usando a tabela oficial de subclasses e produzir uma simulacao para todos os parceiros elegiveis, com totais por perfil e uma fila separada de casos inconclusivos. Essa simulacao deve permanecer fora do banco ou em artefato de staging ate aprovacao expressa.

## Implementacao preparada, ainda nao executada

Os scripts genericos foram mantidos na raiz de `7 - QA2`:

- `Perfis_CNAE_01_Prepara_Staging.sql`;
- `Perfis_CNAE_02_Valida_e_Gera_DML.sql`;
- `Perfis_CNAE_03_Aplica_Aprovados.sql`;
- `Perfis_CNAE_04_Reverte.sql`;
- `Perfis_CNAE_README.md`.

O fluxo exige staging, simulacao, aprovacao, frase de confirmacao, backup persistente por identificador e reversao. Nenhum desses scripts foi executado na BANGTOYS.
