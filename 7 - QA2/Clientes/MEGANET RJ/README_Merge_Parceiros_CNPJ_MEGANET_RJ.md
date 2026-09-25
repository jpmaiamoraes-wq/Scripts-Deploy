# Merge de parceiros repetidos — MEGANET RJ

Escopo aprovado para preparação (ainda não executado):

- `2667 -> 1619` — CPF `002.628.577-07`;
- `2689/481` ficou fora do escopo por divergências em `NOMEPARC` e `RAZAOSOCIAL`.

Os parceiros `1` e `5` (`11.953.467/0001-72`, MEGANET RJ) não fazem parte do merge.

## Ordem segura

1. Executar `01_Diagnostico...sql` e guardar a saída.
2. Confirmar `DIFERENCAS=0` no par `2667/1619`, desconsiderando apenas `DTCAD` e `DTALTER`, e revisar toda linha `NAO_LIDA`.
3. Somente após nova autorização, executar `02_Executar...sql` como script (F5).
4. Validar que não restou referência a `2667` e que `1619` permanece. `2689` e `481` não são alterados.
5. Se necessário, executar `03_Reverter...sql` antes de operações que movam/reorganizem linhas das tabelas envolvidas.

Identificador vigente: `MEGANET_20260909_MPC02`. O identificador `MPC01` pertence à tentativa que sofreu rollback automático e permanece somente para auditoria.

Colisão conhecida na `TGFCPP`: para `CODPROD=300003` e `TIPMOV=V`, o executor preserva o registro do parceiro `1619`, com `DTULT=30/07/2026`, por ser posterior ao registro do parceiro `2667`, com `DTULT=29/05/2026`. As duas versões são copiadas para `BKP_MPC_TGFCPP_MEGANET` antes da alteração.

## Proteções

- bloqueio pelo service name `MEGANETRJPRD`;
- validação dos documentos e comparação cadastral antes do DML;
- descoberta de FKs simples para `TGFPAR.CODPARC` e de colunas nominais `CODPARC`;
- mapas e backups persistentes por `ID_EXECUCAO`;
- atualizações e exclusões em uma única transação;
- rollback automático das alterações funcionais em qualquer erro;
- rollback operacional separado e auditável.

Limites deliberados: FKs compostas são apenas diagnosticadas fora do executor; referências sem FK e com outro nome além de `CODPARC` só entram se apontarem formalmente para `TGFPAR`. Qualquer `NAO_LIDA`, tipo incompatível, colisão única ou divergência cadastral bloqueia a execução e deve ser tratada antes.
