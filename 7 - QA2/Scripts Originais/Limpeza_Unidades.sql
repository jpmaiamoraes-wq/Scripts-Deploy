-------------------------------------------------------------------------------
-- NORMALIZAÇÃO DE UNIDADES (TGFPRO/TGFITE/TGFPAP/TGFCOI2/TGFGIR1 -> TGFVOA -> TGFVOL)
-- + GARANTE QUE MAP_UNIDADES SÓ TENHA TO_CODE EXISTENTES EM SANKHYA.TGFVOL
-------------------------------------------------------------------------------

SET DEFINE OFF;
SET SERVEROUTPUT ON;

-------------------------------------------------------------------------------
-- 1) CRIA MAP_UNIDADES SE NÃO EXISTIR
-------------------------------------------------------------------------------
DECLARE
  v_exists NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO v_exists
    FROM USER_TABLES
   WHERE TABLE_NAME = 'MAP_UNIDADES';

  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE '
      CREATE TABLE MAP_UNIDADES (
        FROM_CODE VARCHAR2(20) NOT NULL,
        TO_CODE   VARCHAR2(20) NOT NULL,
        CONSTRAINT PK_MAP_UNIDADES PRIMARY KEY (FROM_CODE)
      )';
    DBMS_OUTPUT.PUT_LINE('OK: Tabela MAP_UNIDADES criada.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('OK: Tabela MAP_UNIDADES já existe.');
  END IF;
END;
/
-------------------------------------------------------------------------------
-- 2) POPULA / ATUALIZA MAP_UNIDADES VIA MERGE (IDEMPOTENTE)
-------------------------------------------------------------------------------
MERGE INTO MAP_UNIDADES t
USING (
  SELECT 'CDA'    AS FROM_CODE, 'CD'  AS TO_CODE FROM dual UNION ALL
  SELECT 'CX5000','CX'  FROM dual UNION ALL
  SELECT 'CXA',   'CX'  FROM dual UNION ALL
  SELECT 'CX1',   'CX'  FROM dual UNION ALL
  SELECT 'CAIXA', 'CX'  FROM dual UNION ALL
  SELECT 'CX.',   'CX'  FROM dual UNION ALL
  SELECT 'CX,',   'CX'  FROM dual UNION ALL
  SELECT 'KLG',   'KG'  FROM dual UNION ALL
  SELECT 'KG/1',  'KG'  FROM dual UNION ALL
  SELECT 'KG1',   'KG'  FROM dual UNION ALL
  SELECT '1 KG',  'KG'  FROM dual UNION ALL
  SELECT 'KG.',   'KG'  FROM dual UNION ALL
  SELECT '.KG',   'KG'  FROM dual UNION ALL
  SELECT 'L',     'LT'  FROM dual UNION ALL
  SELECT 'LIT',   'LT'  FROM dual UNION ALL
  SELECT 'LTS',   'LT'  FROM dual UNION ALL
  SELECT 'LTRS',  'LT'  FROM dual UNION ALL
  SELECT 'LITRO', 'LT'  FROM dual UNION ALL
  SELECT 'LT1',   'LT'  FROM dual UNION ALL
  SELECT 'PEC',   'PC'  FROM dual UNION ALL
  SELECT 'PÇ',    'PC'  FROM dual UNION ALL
  SELECT 'PÇ.',   'PC'  FROM dual UNION ALL
  SELECT 'PÇ,',   'PC'  FROM dual UNION ALL
  SELECT 'PC,',   'PC'  FROM dual UNION ALL
  SELECT 'PECA',  'PC'  FROM dual UNION ALL
  SELECT 'PECAS', 'PC'  FROM dual UNION ALL
  SELECT 'PEÇA',  'PC'  FROM dual UNION ALL
  SELECT 'PC/1',  'PC'  FROM dual UNION ALL
  SELECT 'PC01PC','PC'  FROM dual UNION ALL
  SELECT 'PC1',   'PC'  FROM dual UNION ALL
  SELECT 'PCA',   'PC'  FROM dual UNION ALL
  SELECT 'PCS',   'PC'  FROM dual UNION ALL
  SELECT 'PÇS',   'PC'  FROM dual UNION ALL
  SELECT 'PEÇ',   'PC'  FROM dual UNION ALL
  SELECT 'PE',    'PC'  FROM dual UNION ALL
  SELECT 'PC.',   'PC'  FROM dual UNION ALL
  SELECT 'PC0',   'PC'  FROM dual UNION ALL
  SELECT 'PC0001','PC'  FROM dual UNION ALL
  SELECT 'PC01',  'PC'  FROM dual UNION ALL
  SELECT 'PÇS.',  'PC'  FROM dual UNION ALL  
  SELECT 'PC-',   'PC'  FROM dual UNION ALL  
  SELECT '..UN',  'UN'  FROM dual UNION ALL
  SELECT '1 UNID','UN'  FROM dual UNION ALL
  SELECT '1UN',   'UN'  FROM dual UNION ALL
  SELECT 'UND',   'UN'  FROM dual UNION ALL
  SELECT 'UNI',   'UN'  FROM dual UNION ALL
  SELECT 'UNIT.', 'UN'  FROM dual UNION ALL
  SELECT 'UNIT',  'UN'  FROM dual UNION ALL
  SELECT 'UNID',  'UN'  FROM dual UNION ALL
  SELECT 'UNIDA', 'UN'  FROM dual UNION ALL
  SELECT 'UNIDAD','UN'  FROM dual UNION ALL
  SELECT 'UN1',   'UN'  FROM dual UNION ALL
  SELECT 'UN.',   'UN'  FROM dual UNION ALL
  SELECT 'UN,',   'UN'  FROM dual UNION ALL
  SELECT 'U',     'UN'  FROM dual UNION ALL
  SELECT 'UD',    'UN'  FROM dual UNION ALL
  SELECT 'UN/1',  'UN'  FROM dual UNION ALL
  SELECT 'UND.',  'UN'  FROM dual UNION ALL
  SELECT 'UNID.', 'UN'  FROM dual UNION ALL
  SELECT 'UNN',   'UN'  FROM dual UNION ALL
  SELECT 'U.N',   'UN'  FROM dual UNION ALL
  SELECT 'UM',    'UN'  FROM dual UNION ALL
  SELECT 'UN0001','UN'  FROM dual UNION ALL
  SELECT 'UN0012','UN'  FROM dual UNION ALL
  SELECT 'UN9',   'UN'  FROM dual UNION ALL
  SELECT 'UND8',  'UN'  FROM dual UNION ALL
  SELECT 'UND9',  'UN'  FROM dual UNION ALL
  SELECT 'UNDI',  'UN'  FROM dual UNION ALL
  SELECT 'UN''',  'UN'  FROM dual UNION ALL
  SELECT 'U N',   'UN'  FROM dual UNION ALL
  SELECT 'UN000', 'UN'  FROM dual UNION ALL
  SELECT 'M',     'MT'  FROM dual UNION ALL
  SELECT 'METRO', 'MT'  FROM dual UNION ALL
  SELECT 'MTS',   'MT'  FROM dual UNION ALL
  SELECT 'PCT',   'PT'  FROM dual UNION ALL
  SELECT 'PACOTE','PT'  FROM dual UNION ALL
  SELECT 'PAC',   'PT'  FROM dual UNION ALL
  SELECT 'PCT.',  'PT'  FROM dual UNION ALL
  SELECT 'PCOT',  'PT'  FROM dual UNION ALL
  SELECT 'PCTE',  'PT'  FROM dual UNION ALL
  SELECT 'TO',    'TN'  FROM dual UNION ALL
  SELECT 'T',     'TN'  FROM dual UNION ALL
  SELECT 'TON',   'TN'  FROM dual UNION ALL
  SELECT 'RLRL',  'RL'  FROM dual UNION ALL
  SELECT 'RLO',   'RL'  FROM dual UNION ALL
  SELECT 'ROL',   'RL'  FROM dual UNION ALL
  SELECT 'ROLO',  'RL'  FROM dual UNION ALL
  SELECT 'RL1',   'RL'  FROM dual UNION ALL
  SELECT 'RL01RL','RL'  FROM dual UNION ALL
  SELECT 'BLOCO', 'BL'  FROM dual UNION ALL
  SELECT 'FRASCO','FR'  FROM dual UNION ALL
  SELECT 'FR1',   'FR'  FROM dual UNION ALL
  SELECT 'FR/1',  'FR'  FROM dual UNION ALL
  SELECT 'JOGO',  'JG'  FROM dual UNION ALL
  SELECT 'JGO',   'JG'  FROM dual UNION ALL
  SELECT 'JG1',   'JG'  FROM dual UNION ALL
  SELECT 'JGO8',  'JG'  FROM dual UNION ALL
  SELECT 'JGO9',  'JG'  FROM dual UNION ALL
  SELECT 'JOG',   'JG'  FROM dual UNION ALL
  SELECT 'SC/1',  'SC'  FROM dual UNION ALL
  SELECT 'SA',    'SC'  FROM dual UNION ALL
  SELECT 'SAC',   'SC'  FROM dual UNION ALL
  SELECT 'SACO',  'SC'  FROM dual UNION ALL
  SELECT 'CJT',   'CJ'  FROM dual UNION ALL
  SELECT 'CONJ',  'CJ'  FROM dual UNION ALL
  SELECT 'CONJ.', 'CJ'  FROM dual UNION ALL
  SELECT 'FLH',   'FL'  FROM dual UNION ALL
  SELECT 'DUZIA', 'DZ'  FROM dual UNION ALL
  SELECT 'DZ12',  'DZ'  FROM dual UNION ALL
  SELECT 'KIT',   'KT'  FROM dual UNION ALL
  SELECT 'BALDE', 'BD'  FROM dual UNION ALL
  SELECT 'BAG',   'BG'  FROM dual UNION ALL
  SELECT 'M²',    'M2'  FROM dual UNION ALL
  SELECT 'M³',    'M3'  FROM dual UNION ALL
  SELECT 'GRAMAS','GR'  FROM dual UNION ALL
  SELECT 'FARDO', 'FD'  FROM dual UNION ALL
  SELECT 'FARDOS','FD'  FROM dual UNION ALL
  SELECT 'PA',    'PAR' FROM dual UNION ALL
  SELECT 'PARES', 'PAR' FROM dual
) s
ON (t.FROM_CODE = s.FROM_CODE)
WHEN MATCHED THEN UPDATE SET t.TO_CODE = s.TO_CODE
WHEN NOT MATCHED THEN INSERT (FROM_CODE, TO_CODE) VALUES (s.FROM_CODE, s.TO_CODE);

COMMIT;
PROMPT OK: MAP_UNIDADES atualizado.

-------------------------------------------------------------------------------
-- 3) CRIA TABELAS DE BACKUP (SE NÃO EXISTIREM)
-------------------------------------------------------------------------------
DECLARE
  v_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM USER_TABLES WHERE TABLE_NAME = 'TGFVOL_BKP';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE TGFVOL_BKP AS SELECT * FROM SANKHYA.TGFVOL';
    DBMS_OUTPUT.PUT_LINE('OK: TGFVOL_BKP criada.');
  END IF;

  SELECT COUNT(*) INTO v_exists FROM USER_TABLES WHERE TABLE_NAME = 'TGFVOA_BKP';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE TGFVOA_BKP AS SELECT * FROM SANKHYA.TGFVOA';
    DBMS_OUTPUT.PUT_LINE('OK: TGFVOA_BKP criada.');
  END IF;
END;
/
-------------------------------------------------------------------------------
-- 4) REMOVE DO MAP_UNIDADES MAPEAMENTOS CUJO TO_CODE NÃO EXISTE EM TGFVOL
-------------------------------------------------------------------------------
DECLARE
  v_del NUMBER;
BEGIN
  DELETE FROM MAP_UNIDADES mpa
   WHERE mpa.TO_CODE IS NOT NULL
     AND NOT EXISTS (
           SELECT 1
             FROM SANKHYA.TGFVOL v
            WHERE v.CODVOL = TRIM(UPPER(mpa.TO_CODE))
         );

  v_del := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('OK: Mapeamentos removidos do MAP_UNIDADES (TO_CODE inexistente em TGFVOL): '||v_del);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ERRO ao limpar MAP_UNIDADES por TO_CODE inexistente em TGFVOL: '||SQLERRM);
    RAISE;
END;
/

-------------------------------------------------------------------------------
-- 5) NORMALIZAÇÃO NAS TABELAS DE CADASTRO/MOVIMENTO
-------------------------------------------------------------------------------
PROMPT Iniciando normalização de unidades...

BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INC_UPD_TGFITE DISABLE';
  DBMS_OUTPUT.PUT_LINE('OK: Trigger TRG_INC_UPD_TGFITE desabilitada.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Aviso: não foi possível desabilitar TRG_INC_UPD_TGFITE: '||SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE DISABLE';
  DBMS_OUTPUT.PUT_LINE('OK: Trigger TRG_UPT_TGFITE desabilitada.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Aviso: não foi possível desabilitar TRG_UPT_TGFITE: '||SQLERRM);
END;
/

DECLARE v_rows NUMBER;
BEGIN
  -- 5.0) TGFPRO
  UPDATE TGFPRO p
     SET p.CODVOL = (SELECT m.TO_CODE FROM MAP_UNIDADES m WHERE m.FROM_CODE = p.CODVOL)
   WHERE EXISTS (SELECT 1 FROM MAP_UNIDADES m WHERE m.FROM_CODE = p.CODVOL);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFPRO atualizados: '||v_rows);

  -- 5.1) TGFITE
  UPDATE TGFITE i
     SET i.CODVOL = (SELECT m.TO_CODE FROM MAP_UNIDADES m WHERE m.FROM_CODE = i.CODVOL)
   WHERE EXISTS (SELECT 1 FROM MAP_UNIDADES m WHERE m.FROM_CODE = i.CODVOL);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFITE atualizados: '||v_rows);

  -- 5.2) TGFPAP.UNIDADEPARC
  UPDATE TGFPAP p
     SET p.UNIDADEPARC = (SELECT m.TO_CODE FROM MAP_UNIDADES m WHERE m.FROM_CODE = p.UNIDADEPARC)
   WHERE EXISTS (SELECT 1 FROM MAP_UNIDADES m WHERE m.FROM_CODE = p.UNIDADEPARC);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFPAP atualizados: '||v_rows);

  -- 5.3) TGFCOI2
  UPDATE TGFCOI2 c
     SET c.CODVOL = (SELECT m.TO_CODE FROM MAP_UNIDADES m WHERE m.FROM_CODE = c.CODVOL)
   WHERE EXISTS (SELECT 1 FROM MAP_UNIDADES m WHERE m.FROM_CODE = c.CODVOL);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFCOI2 atualizados: '||v_rows);

  -- 5.4) TGFGIR1
  UPDATE TGFGIR1 g
     SET g.CODVOL = (SELECT m.TO_CODE FROM MAP_UNIDADES m WHERE m.FROM_CODE = g.CODVOL)
   WHERE EXISTS (SELECT 1 FROM MAP_UNIDADES m WHERE m.FROM_CODE = g.CODVOL);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFGIR1 atualizados: '||v_rows);

  COMMIT;
END;
/

-------------------------------------------------------------------------------
-- 6) LIMPA TGFVOA E TGFVOL A PARTIR DO MAP_UNIDADES (FROM_CODE)
-------------------------------------------------------------------------------
DECLARE
  v_rows NUMBER;
BEGIN
  DELETE FROM SANKHYA.TGFVOA v
   WHERE v.CODVOL IN (SELECT FROM_CODE FROM MAP_UNIDADES);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFVOA deletados (FROM_CODE): '||v_rows);
  COMMIT;

  DELETE FROM SANKHYA.TGFVOL t
   WHERE t.CODVOL IN (SELECT FROM_CODE FROM MAP_UNIDADES);
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('TGFVOL deletados (FROM_CODE): '||v_rows);
  COMMIT;
END;
/

-------------------------------------------------------------------------------
-- 7) REABILITA TRIGGER
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_INC_UPD_TGFITE ENABLE';
  DBMS_OUTPUT.PUT_LINE('OK: Trigger TRG_INC_UPD_TGFITE reabilitada.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Aviso: não foi possível reabilitar TRG_INC_UPD_TGFITE: '||SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'ALTER TRIGGER TRG_UPT_TGFITE ENABLE';
  DBMS_OUTPUT.PUT_LINE('OK: Trigger TRG_UPT_TGFITE reabilitada.');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Aviso: não foi possível reabilitar TRG_UPT_TGFITE: '||SQLERRM);
END;
/

PROMPT Concluído com sucesso.