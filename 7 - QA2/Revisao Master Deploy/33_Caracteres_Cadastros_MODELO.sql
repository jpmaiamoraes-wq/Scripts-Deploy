-- MODELO da Atividade 33 - Correcao de caracteres corrompidos em cadastros essenciais (TGFPRO, TGFPAR, TGFVEN, TSIUSU).
-- NAO e entrada do lote: copie para Clientes/<BASE>/33_Caracteres_Cadastros_<BASE>.sql e substitua os marcadores:
--   __ID_EXECUCAO__ (ex.: BASE_CAR_AAAAMMDD_01)  __MAPA__ (ex.: RMD_BASE_CAR_AAAAMMDD)  __BKP__ (prefixo curto, ex.: BKP_RMD_BASE_CAR01_)
--   __BKP_LIKE__ (o mesmo prefixo com \_ para LIKE)  __SESSION_USER__  __SCHEMA__  __SERVICE__
-- Antes: rodar o diagnostico read-only (C01/C02 da base de referencia MEDCHAP) e revisar o resultado.
-- Regras automaticas (somente sem ambiguidade):
--   MOJIBAKE_UTF8           texto UTF-8 lido como WIN1252 (ex.: "Ã§" -> "ç"); mapeamento fixo e reversivel.
--   INTERROGACAO_DICIONARIO "¿" no lugar de uma letra, resolvido quando exatamente UMA candidata (letras acentuadas e
--                           tambem a letra sem acento, pois 29/30 padronizam enderecos/bairros sem acento) existe como
--                           palavra inteira no dicionario da propria base. Nenhuma ou mais de uma = REVISAR.
-- Colunas protegidas (login TSIUSU.NOMEUSU): nunca corrigidas automaticamente; so por DECISAO_USUARIO (bloco opcional abaixo).
-- Reversao: modelo em Clientes/MEDCHAP DISTRIBUIDORA DE MEDICAMENTOS CHAPECO LTDA/Artefatos_Revisao/Rollback/Reverter_33_Caracteres_Cadastros_MEDCHAP.sql
-- Licao MEDCHAP 25/09/2026: DECODE nao pode ser usado em expressao PL/SQL (PLS-00204); use comparacao explicita.
SET DEFINE OFF
SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  v_n NUMBER;
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') <> '__SESSION_USER__'
     OR SYS_CONTEXT('USERENV','CURRENT_SCHEMA') <> '__SCHEMA__'
     OR UPPER(SYS_CONTEXT('USERENV','SERVICE_NAME')) <> '__SERVICE__' THEN
    RAISE_APPLICATION_ERROR(-20450,'Identidade da base divergente; atividade 33 bloqueada.');
  END IF;
  SELECT COUNT(*) INTO v_n FROM ALL_TABLES
   WHERE OWNER=SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
     AND (TABLE_NAME='__MAPA__' OR TABLE_NAME LIKE '__BKP_LIKE__%' ESCAPE '\');
  IF v_n>0 THEN
    RAISE_APPLICATION_ERROR(-20451,'Artefatos da atividade 33 ja existem; gere novo ID antes de repetir.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('IDENTIDADE_VALIDADA=__SESSION_USER__/__SCHEMA__/__SERVICE__; ARTEFATOS_AUSENTES_OK');
END;
/

CREATE TABLE __MAPA__ (
  ID_EXECUCAO  VARCHAR2(40)   NOT NULL,
  TABELA       VARCHAR2(30)   NOT NULL,
  COLUNA       VARCHAR2(30)   NOT NULL,
  CHAVE        VARCHAR2(60),
  RID          VARCHAR2(30)   NOT NULL,
  VALOR_ANTES  VARCHAR2(4000),
  VALOR_DEPOIS VARCHAR2(4000),
  REGRA        VARCHAR2(60),
  STATUS       VARCHAR2(20),
  DETALHE      VARCHAR2(1000),
  DTREG        DATE DEFAULT SYSDATE
)
/

DECLARE
  c_id  CONSTANT VARCHAR2(40) := '__ID_EXECUCAO__';
  c_map CONSTANT VARCHAR2(30) := '__MAPA__';
  TYPE t_list IS TABLE OF VARCHAR2(200);
  v_scope  t_list := t_list('TGFPRO|CODPROD|DESCRPROD|A','TGFPRO|CODPROD|COMPLDESC|A','TGFPRO|CODPROD|DESCRANP|A',
                            'TGFPAR|CODPARC|NOMEPARC|A','TGFPAR|CODPARC|RAZAOSOCIAL|A','TGFPAR|CODPARC|COMPLEMENTO|A',
                            'TGFVEN|CODVEND|APELIDO|A','TSIUSU|CODUSU|NOMEUSUCPLT|A','TSIUSU|CODUSU|NOMEUSU|P');
  v_corpus t_list := t_list('TSIEND|NOMEEND','TSIBAI|NOMEBAI','TSICID|NOMECID','TGFPAR|NOMEPARC','TGFPAR|RAZAOSOCIAL','TGFPRO|DESCRPROD');
  v_owner VARCHAR2(128) := SYS_CONTEXT('USERENV','CURRENT_SCHEMA');
  v_inv VARCHAR2(8);
  v_a3  VARCHAR2(8);
  v_a2  VARCHAR2(8);
  v_moj_set VARCHAR2(400);
  v_tab VARCHAR2(30); v_key VARCHAR2(30); v_col VARCHAR2(30); v_flag VARCHAR2(1);
  v_len NUMBER; v_exists NUMBER;
  cur SYS_REFCURSOR;
  v_rid VARCHAR2(30); v_chave VARCHAR2(60); v_val VARCHAR2(4000);
  v_new VARCHAR2(4000); v_tmp VARCHAR2(4000); v_rule VARCHAR2(60); v_status VARCHAR2(20); v_det VARCHAR2(1000);
  v_lidos NUMBER := 0; v_mapeados NUMBER := 0;

  FUNCTION u(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN TO_CHAR(UNISTR(p)); END;

  FUNCTION has_moj(p VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN REGEXP_LIKE(p, v_a3||'['||u('\00A0')||'-'||u('\00BF')||v_moj_set||']')
        OR REGEXP_LIKE(p, v_a2||'['||u('\00A0')||'-'||u('\00BF')||']');
  END;

  FUNCTION fix_moj(p VARCHAR2) RETURN VARCHAR2 IS
    s VARCHAR2(4000) := p;
    TYPE t_pair IS TABLE OF VARCHAR2(40);
    v_from t_pair := t_pair('\00C3\00A7','\00C3\2021','\00C3\00A3','\00C3\0192','\00C3\00A1','\00C3\00A9','\00C3\2030',
                            '\00C3\00AA','\00C3\0160','\00C3\00AD','\00C3\00B3','\00C3\201C','\00C3\00B4','\00C3\201D',
                            '\00C3\00B5','\00C3\2022','\00C3\00BA','\00C3\0161','\00C3\00BC','\00C3\0153','\00C3\00A2',
                            '\00C3\201A','\00C3\00A0','\00C3\20AC','\00C2\00BA','\00C2\00AA','\00C2\00B0');
    v_to   t_pair := t_pair('\00E7','\00C7','\00E3','\00C3','\00E1','\00E9','\00C9',
                            '\00EA','\00CA','\00ED','\00F3','\00D3','\00F4','\00D4',
                            '\00F5','\00D5','\00FA','\00DA','\00FC','\00DC','\00E2',
                            '\00C2','\00E0','\00C0','\00BA','\00AA','\00B0');
  BEGIN
    FOR i IN 1..v_from.COUNT LOOP
      s := REPLACE(s, u(v_from(i)), u(v_to(i)));
    END LOOP;
    RETURN s;
  END;

  FUNCTION corpus_has(p_word VARCHAR2) RETURN BOOLEAN IS
    v_t VARCHAR2(30); v_c VARCHAR2(30); v_hit NUMBER;
  BEGIN
    FOR i IN 1..v_corpus.COUNT LOOP
      v_t := REGEXP_SUBSTR(v_corpus(i),'[^|]+',1,1); v_c := REGEXP_SUBSTR(v_corpus(i),'[^|]+',1,2);
      SELECT COUNT(*) INTO v_hit FROM ALL_TAB_COLUMNS WHERE OWNER=v_owner AND TABLE_NAME=v_t AND COLUMN_NAME=v_c;
      IF v_hit=1 THEN
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||v_t||' WHERE ROWNUM=1 AND INSTR('' ''||UPPER(REGEXP_REPLACE('||v_c||',''[ .,/()-]'','' ''))||'' '', :w)>0'
          INTO v_hit USING ' '||p_word||' ';
        IF v_hit>0 THEN RETURN TRUE; END IF;
      END IF;
    END LOOP;
    RETURN FALSE;
  END;

  FUNCTION resolve_inv(p_val VARCHAR2, o_det IN OUT VARCHAR2) RETURN VARCHAR2 IS
    v_res VARCHAR2(4000) := p_val; v_tok VARCHAR2(400); v_pos PLS_INTEGER := 1;
    v_cands VARCHAR2(100); v_c VARCHAR2(400); v_hit VARCHAR2(400); v_hits PLS_INTEGER;
  BEGIN
    LOOP
      v_tok := REGEXP_SUBSTR(p_val, '[^ .,/()-]+', 1, v_pos);
      EXIT WHEN v_tok IS NULL;
      IF INSTR(v_tok, v_inv) > 0 THEN
        IF LENGTH(v_tok) - LENGTH(REPLACE(v_tok, v_inv)) <> 1 THEN
          o_det := SUBSTR(o_det||'palavra com mais de um caractere corrompido: '||v_tok||'. ', 1, 1000); RETURN NULL;
        END IF;
        IF v_tok = UPPER(v_tok) THEN v_cands := u('\00C7\00C3\00C1\00C0\00C2\00C9\00CA\00CD\00D3\00D4\00D5\00DA\00DC')||'CAEIOU';
        ELSE v_cands := u('\00E7\00E3\00E1\00E0\00E2\00E9\00EA\00ED\00F3\00F4\00F5\00FA\00FC')||'caeiou'; END IF;
        v_hits := 0; v_hit := NULL;
        FOR i IN 1..LENGTH(v_cands) LOOP
          v_c := REPLACE(v_tok, v_inv, SUBSTR(v_cands, i, 1));
          IF corpus_has(UPPER(v_c)) THEN v_hits := v_hits + 1; v_hit := v_c; END IF;
        END LOOP;
        IF v_hits <> 1 THEN
          o_det := SUBSTR(o_det||'palavra '||v_tok||' com '||v_hits||' candidatas no dicionario. ', 1, 1000); RETURN NULL;
        END IF;
        v_res := REPLACE(v_res, v_tok, v_hit);
        o_det := SUBSTR(o_det||v_tok||' -> '||v_hit||' (dicionario da base). ', 1, 1000);
      END IF;
      v_pos := v_pos + 1;
    END LOOP;
    RETURN v_res;
  END;
BEGIN
  v_inv := u('\00BF'); v_a3 := u('\00C3'); v_a2 := u('\00C2');
  v_moj_set := u('\20AC\201A\0192\201E\2026\2020\2021\02C6\2030\0160\2039\0152\017D\2018\2019\201C\201D\2022\2013\2014\02DC\2122\0161\203A\0153\017E\0178');
  FOR s IN 1..v_scope.COUNT LOOP
    v_tab := REGEXP_SUBSTR(v_scope(s),'[^|]+',1,1); v_key := REGEXP_SUBSTR(v_scope(s),'[^|]+',1,2);
    v_col := REGEXP_SUBSTR(v_scope(s),'[^|]+',1,3); v_flag := REGEXP_SUBSTR(v_scope(s),'[^|]+',1,4);
    SELECT COUNT(*), MAX(DATA_LENGTH) INTO v_exists, v_len FROM ALL_TAB_COLUMNS
     WHERE OWNER=v_owner AND TABLE_NAME=v_tab AND COLUMN_NAME IN (v_col) ;
    IF v_exists = 0 THEN
      DBMS_OUTPUT.PUT_LINE('COLUNA_AUSENTE|'||v_tab||'|'||v_col); CONTINUE;
    END IF;
    OPEN cur FOR 'SELECT ROWIDTOCHAR(ROWID), TO_CHAR('||v_key||'), '||v_col||' FROM '||v_tab||
                 ' WHERE INSTR('||v_col||',:1)>0 OR INSTR('||v_col||',:2)>0 OR INSTR('||v_col||',:3)>0'
      USING v_inv, v_a3, v_a2;
    LOOP
      FETCH cur INTO v_rid, v_chave, v_val;
      EXIT WHEN cur%NOTFOUND;
      v_lidos := v_lidos + 1;
      v_new := v_val; v_rule := NULL; v_status := NULL; v_det := NULL;
      IF has_moj(v_val) THEN
        v_new := fix_moj(v_val); v_rule := 'MOJIBAKE_UTF8';
      END IF;
      IF INSTR(v_new, v_inv) > 0 THEN
        v_tmp := resolve_inv(v_new, v_det);
        IF v_tmp IS NULL THEN
          v_status := 'REVISAR'; v_rule := CASE WHEN v_rule IS NULL THEN 'INTERROGACAO_AMBIGUA' ELSE v_rule||'+INTERROGACAO_AMBIGUA' END;
        ELSE
          v_new := v_tmp; v_rule := CASE WHEN v_rule IS NULL THEN 'INTERROGACAO_DICIONARIO' ELSE v_rule||'+INTERROGACAO_DICIONARIO' END;
        END IF;
      END IF;
      IF v_rule IS NOT NULL THEN
        IF v_status IS NULL THEN
          IF has_moj(v_new) OR INSTR(v_new, v_inv) > 0 THEN v_status := 'REVISAR';
          ELSIF LENGTHB(v_new) > v_len THEN v_status := 'REVISAR'; v_det := SUBSTR(v_det||'novo valor excede o tamanho da coluna. ',1,1000);
          ELSIF v_new = v_val THEN v_status := NULL;
          ELSIF v_flag = 'P' THEN v_status := 'PROTEGIDO'; v_det := SUBSTR(v_det||'coluna de login: exige decisao do usuario. ',1,1000);
          ELSE v_status := 'APLICAR';
          END IF;
        END IF;
        IF v_status IS NOT NULL THEN
          EXECUTE IMMEDIATE 'INSERT INTO '||c_map||' (ID_EXECUCAO,TABELA,COLUNA,CHAVE,RID,VALOR_ANTES,VALOR_DEPOIS,REGRA,STATUS,DETALHE) VALUES (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10)'
            USING c_id, v_tab, v_col, v_chave, v_rid, v_val, CASE WHEN v_status='REVISAR' THEN NULL ELSE v_new END, v_rule, v_status, v_det;
          v_mapeados := v_mapeados + 1;
        END IF;
      END IF;
    END LOOP;
    CLOSE cur;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('VARREDURA_CONCLUIDA; REGISTROS_LIDOS='||v_lidos||'; MAPEADOS='||v_mapeados);
END;
/

-- Decisoes do usuario (OPCIONAL): para cada login/coluna protegida decidida explicitamente no chat, inclua um bloco
-- como o da MEDCHAP (33_Caracteres_Cadastros_MEDCHAP.sql): localizar o registro pelo valor atual exato, checar unicidade do
-- novo valor e marcar a linha do mapa como APLICAR com REGRA=DECISAO_USUARIO. Sem decisao, a linha fica PROTEGIDO.

-- Backup somente dos registros que serao alterados (chave, ROWID e colunas do escopo), uma tabela por cadastro.
DECLARE
  c_id  CONSTANT VARCHAR2(40) := '__ID_EXECUCAO__';
  c_map CONSTANT VARCHAR2(30) := '__MAPA__';
  c_bkp CONSTANT VARCHAR2(30) := '__BKP__';
  v_cols VARCHAR2(4000); v_key VARCHAR2(30); v_map_n NUMBER; v_bkp_n NUMBER;
  TYPE t_tabs IS TABLE OF VARCHAR2(30);
  v_tabs t_tabs;
BEGIN
  EXECUTE IMMEDIATE 'SELECT DISTINCT TABELA FROM '||c_map||' WHERE ID_EXECUCAO=:1 AND STATUS=''APLICAR''' BULK COLLECT INTO v_tabs USING c_id;
  FOR i IN 1..v_tabs.COUNT LOOP
    v_key := CASE v_tabs(i) WHEN 'TGFPRO' THEN 'CODPROD' WHEN 'TGFPAR' THEN 'CODPARC' WHEN 'TGFVEN' THEN 'CODVEND' WHEN 'TSIUSU' THEN 'CODUSU' END;
    v_cols := CASE v_tabs(i) WHEN 'TGFPRO' THEN 'DESCRPROD,COMPLDESC,DESCRANP' WHEN 'TGFPAR' THEN 'NOMEPARC,RAZAOSOCIAL,COMPLEMENTO'
                             WHEN 'TGFVEN' THEN 'APELIDO' WHEN 'TSIUSU' THEN 'NOMEUSU,NOMEUSUCPLT' END;
    EXECUTE IMMEDIATE 'CREATE TABLE '||c_bkp||v_tabs(i)||' AS SELECT '''||c_id||''' ID_EXECUCAO, SYSDATE DT_BACKUP, ROWIDTOCHAR(t.ROWID) RID_ORIGINAL, t.'||v_key||', '||
                      REGEXP_REPLACE(v_cols,'([A-Z_]+)','t.\1')||' FROM '||v_tabs(i)||' t WHERE ROWIDTOCHAR(t.ROWID) IN (SELECT RID FROM '||c_map||
                      ' WHERE ID_EXECUCAO='''||c_id||''' AND TABELA='''||v_tabs(i)||''' AND STATUS=''APLICAR'')';
    EXECUTE IMMEDIATE 'SELECT COUNT(DISTINCT RID) FROM '||c_map||' WHERE ID_EXECUCAO=:1 AND TABELA=:2 AND STATUS=''APLICAR''' INTO v_map_n USING c_id, v_tabs(i);
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM '||c_bkp||v_tabs(i) INTO v_bkp_n;
    IF v_map_n <> v_bkp_n THEN
      RAISE_APPLICATION_ERROR(-20454,'Backup '||v_tabs(i)||' divergente do mapa ('||v_bkp_n||' x '||v_map_n||').');
    END IF;
    DBMS_OUTPUT.PUT_LINE('BACKUP_CRIADO|'||c_bkp||v_tabs(i)||'|'||v_bkp_n);
  END LOOP;
  IF v_tabs.COUNT = 0 THEN DBMS_OUTPUT.PUT_LINE('BACKUP=NAO_NECESSARIO (0 registros a aplicar)'); END IF;
END;
/

-- Aplicacao: somente STATUS=APLICAR, por ROWID e valor anterior identico.
DECLARE
  c_id  CONSTANT VARCHAR2(40) := '__ID_EXECUCAO__';
  c_map CONSTANT VARCHAR2(30) := '__MAPA__';
  TYPE t_row IS RECORD (tabela VARCHAR2(30), coluna VARCHAR2(30), rid VARCHAR2(30), antes VARCHAR2(4000), depois VARCHAR2(4000));
  TYPE t_rows IS TABLE OF t_row;
  v_rows t_rows; v_ok NUMBER := 0; v_cur VARCHAR2(4000);
BEGIN
  EXECUTE IMMEDIATE 'SELECT TABELA, COLUNA, RID, VALOR_ANTES, VALOR_DEPOIS FROM '||c_map||' WHERE ID_EXECUCAO=:1 AND STATUS=''APLICAR'' ORDER BY TABELA, COLUNA, RID'
    BULK COLLECT INTO v_rows USING c_id;
  FOR i IN 1..v_rows.COUNT LOOP
    EXECUTE IMMEDIATE 'UPDATE '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_rows(i).tabela)||' SET '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_rows(i).coluna)||'=:1 WHERE ROWID=CHARTOROWID(:2) AND '||DBMS_ASSERT.SIMPLE_SQL_NAME(v_rows(i).coluna)||'=:3'
      USING v_rows(i).depois, v_rows(i).rid, v_rows(i).antes;
    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20455,'Registro '||v_rows(i).tabela||'.'||v_rows(i).coluna||' mudou desde o mapa; lote revertido.');
    END IF;
    EXECUTE IMMEDIATE 'SELECT '||v_rows(i).coluna||' FROM '||v_rows(i).tabela||' WHERE ROWID=CHARTOROWID(:1)' INTO v_cur USING v_rows(i).rid;
    IF v_cur IS NULL OR v_cur <> v_rows(i).depois THEN
      RAISE_APPLICATION_ERROR(-20456,'Valor gravado diverge do mapa em '||v_rows(i).tabela||'.'||v_rows(i).coluna||'; lote revertido.');
    END IF;
    EXECUTE IMMEDIATE 'UPDATE '||c_map||' SET STATUS=''APLICADO'' WHERE ID_EXECUCAO=:1 AND TABELA=:2 AND COLUNA=:3 AND RID=:4'
      USING c_id, v_rows(i).tabela, v_rows(i).coluna, v_rows(i).rid;
    v_ok := v_ok + 1;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('ID_EXECUCAO='||c_id||'; APLICADOS='||v_ok||'; PREVISTOS='||v_rows.COUNT);
  DBMS_OUTPUT.PUT_LINE('STATUS=CARACTERES_CADASTROS_APLICADO');
END;
/
