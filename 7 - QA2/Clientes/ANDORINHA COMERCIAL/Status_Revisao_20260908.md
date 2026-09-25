# Revisão Andorinha Comercial — interrompida

## Pendência Sankhya Cloud — ticket #70566

Na etapa 31, a conexão `FRANCISCO_JUNIOR` não possuía `ALTER ANY PROCEDURE`. Permaneceram 49 funções inválidas no schema `SANKHYA`, relacionadas no log `Logs/Etapa_31_Isolada.log`. Foi aberto o chamado Sankhya Cloud **#70566** para análise e recompilação/correção. O relatório final deve registrar o ticket e o resultado do atendimento.

Evidência: saída do SQL Developer inspecionada em 08/09/2026, execução iniciada às 09:22:40. O arquivo SPOOL permaneceu vazio; este documento é uma síntese da saída observada, não o log integral.

Usuário: FRANCISCO_JUNIOR. Schema: SANKHYA. Matriz: ANDORINHA COMERCIAL LTDA (CODEMP=1).
ID_MASTER=RMD_RUN_20260908092241054

| Etapa | Resultado observado |
|---|---|
| 01 — Controle de objetos | RMD_CONTROLE_OBJETOS criado |
| 02 — Filtros dos portais | 4 registros de TSIPAR alterados; COMMIT concluído; backup BKP_RMD_01_TSIPAR; ID_EXECUCAO=RMD_PORT_20260908092242527 |
| 03 — DANFE das empresas | 2 registros de TGFEMP alterados; COMMIT concluído; backup BKP_RMD_02_TGFEMP; ID_EXECUCAO=RMD_DANF_20260908092243426 |
| 04 — Custo das TOPs de devolução | Concluída na retomada isolada; 136 registros alterados; backup BKP_RMD_03_TGFTOP; ID_EXECUCAO=RMD_TOPC_20260908094707797 |
| 05–31 | Não executadas |

Erro observado:
```
ERROR at line 5:
ORA-06550: line 5, column 14:
PL/SQL: ORA-01031: insufficient privileges
ORA-06550: line 5, column 2:
PL/SQL: SQL Statement ignored
```

O primeiro disparo do Master parou na etapa 04 com ORA-01031, mas os testes de leitura, inserção de uma linha e a retomada isolada foram concluídos. O Master integral não deve ser reexecutado desde a etapa 01, pois as etapas anteriores já têm commits. As etapas 05–31 continuam pendentes. Nenhuma concessão de privilégio foi realizada.

Para retomar, foi criado `Executar_Continuidade_Revisao_05_31.sql`. Ele preserva o `ID_MASTER=RMD_RUN_20260908092241054`, valida a existência do controle e chama somente as 27 etapas de 05 a 31.

Em 08/09/2026, a saída do SQL Developer exibiu o encerramento `REVISAO MASTER DEPLOY - CONTINUIDADE 05 A 31 CONCLUIDA SEM ERRO SQL NAO TRATADO`, após as etapas 26, 27, 28, 29, 30 e 31. A etapa 05 registrou `ID_EXECUCAO=RMD_GIRO_20260908095527114` e `REGISTROS_ALTERADOS=179`; a etapa 06 registrou `ID_EXECUCAO=RMD_PARC_20260908095528046` e `REGISTROS_ALTERADOS=17`. Porém, o SPOOL ficou limitado a 8 KB e não preservou os resultados das etapas 07–25. A conclusão dessas etapas, especialmente a 16, 29 e 30, permanece NÃO COMPROVADA até nova execução ou auditoria por consulta.

Diagnóstico posterior somente leitura, executado na conexão Andorinha em 08/09/2026, mostrou `no rows selected` para as tabelas `BKP_RMD%`/`RMD_%`, incluindo `RMD_CONTROLE_OBJETOS`, `BKP_RMD_01_TSIPAR`, `BKP_RMD_02_TGFEMP` e `BKP_RMD_03_TGFTOP`. Os backups e objetos auxiliares da revisão não estão presentes no schema atual. A continuidade 05–31 não deve ser retomada enquanto não for esclarecido se houve execução de `Limpar_Objetos_Revisao.sql`, refresh da base ou outra remoção dos objetos. Os backups anteriores não podem ser usados para rollback.

Nova rodada iniciada com `ID_MASTER=RMD_RUN_20260908102607051`. As etapas 01–07 recriaram o controle e os backups; etapas 05 e 06 registraram 0 alterações porque os valores já estavam padronizados. A etapa 08 parou com `ORA-00932: inconsistent datatypes: expected NUMBER got CHAR` ao atribuir o literal numérico `0` a `TGFCAB.NUMPROTOCCTE`. O script foi corrigido para usar `'0'`, preservando o tipo textual da coluna. A retomada deve começar na etapa 08 com o novo `ID_MASTER`.
