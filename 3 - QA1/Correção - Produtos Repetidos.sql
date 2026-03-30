/*
================================================================================
SCRIPT DE CONSOLIDAÇÃO DE PRODUTOS DUPLICADOS
--------------------------------------------------------------------------------
Objetivo: Tratar produtos duplicados sem criar objetos permanentes no banco.

Lógica Principal:
1.  Usa um cursor ordenado para ler e agrupar produtos com a mesma descrição.
2.  Valida se todos no grupo têm o mesmo NCM. Se não, ignora o grupo.
3.  Aplica regras de negócio em ordem de prioridade:
    a. REGRA 1 (AD_IDEXTERNO): Mantém produtos com AD_IDEXTERNO.
    b. NOVA REGRA (REFERENCIA MISTA): Se não há AD_IDEXTERNO, mantém produtos
       que possuem REFERENCIA em detrimento dos que não possuem.
    c. REGRA 2 (REFERENCIAS DIFERENTES): Se todos ou nenhum têm REFERENCIA,
       e elas são diferentes, mantém o de menor código.
    d. REGRA 4 (CAMPOS NULOS): Se todas as referências são nulas, mantém
       o de menor código.
4.  Consolida, atualiza e exclui registros, registrando tudo em logs.

================================================================================
*/
SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    -- Tipos
    TYPE r_produto IS RECORD (
        CODPROD       TGFPRO.CODPROD%TYPE, REFERENCIA    TGFPRO.REFERENCIA%TYPE,
        AD_IDEXTERNO  TGFPRO.AD_IDEXTERNO%TYPE, NCM           TGFPRO.NCM%TYPE,
        DESCRPROD     TGFPRO.DESCRPROD%TYPE
    );
    TYPE t_produto_table IS TABLE OF r_produto INDEX BY BINARY_INTEGER;

    -- Cursor
    CURSOR c_produtos_duplicados IS
        SELECT p.CODPROD, p.DESCRPROD, p.REFERENCIA, p.AD_IDEXTERNO, p.NCM
        FROM TGFPRO p
        JOIN (SELECT DESCRPROD FROM TGFPRO GROUP BY DESCRPROD HAVING COUNT(*) > 1) dup
        ON p.DESCRPROD = dup.DESCRPROD
        ORDER BY p.DESCRPROD, p.CODPROD;

    grupo_atual          t_produto_table;
    v_descrprod_anterior VARCHAR2(4000) := CHR(0);
    v_count_grupo        NUMBER;

    PROCEDURE processar_grupo(p_grupo IN OUT NOCOPY t_produto_table) IS
        v_ids_externos_distintos   NUMBER := 0;
        v_refs_distintas           NUMBER := 0;
        v_refs_nao_nulas           NUMBER := 0;
        produtos_a_manter          t_produto_table;
        produtos_a_excluir         t_produto_table;
        v_codprod_mestre_principal TGFPRO.CODPROD%TYPE;
    BEGIN
        IF p_grupo.COUNT <= 1 THEN RETURN; END IF;
        DBMS_OUTPUT.PUT_LINE('======================================================');
        DBMS_OUTPUT.PUT_LINE('Analisando grupo: "' || p_grupo(p_grupo.FIRST).DESCRPROD || '" (' || p_grupo.COUNT || ' produtos)');

        DECLARE v_ncm_base TGFPRO.NCM%TYPE := p_grupo(p_grupo.FIRST).NCM;
        BEGIN
            FOR i IN p_grupo.FIRST..p_grupo.LAST LOOP
                IF NVL(p_grupo(i).NCM, CHR(0)) <> NVL(v_ncm_base, CHR(0)) THEN
                    DBMS_OUTPUT.PUT_LINE('-> IGNORANDO: Grupo possui NCMs diferentes.'); p_grupo.DELETE; RETURN;
                END IF;
            END LOOP;
        END;
        
        DECLARE
           TYPE t_id_set IS TABLE OF BOOLEAN INDEX BY TGFPRO.AD_IDEXTERNO%TYPE;
           set_ids t_id_set;
           TYPE t_ref_set IS TABLE OF BOOLEAN INDEX BY TGFPRO.REFERENCIA%TYPE;
           set_refs t_ref_set;
        BEGIN
            FOR i IN p_grupo.FIRST..p_grupo.LAST LOOP
                IF p_grupo(i).AD_IDEXTERNO IS NOT NULL AND NOT set_ids.EXISTS(p_grupo(i).AD_IDEXTERNO) THEN
                   set_ids(p_grupo(i).AD_IDEXTERNO) := TRUE; v_ids_externos_distintos := v_ids_externos_distintos + 1;
                END IF;
                IF p_grupo(i).REFERENCIA IS NOT NULL THEN
                   v_refs_nao_nulas := v_refs_nao_nulas + 1;
                   IF NOT set_refs.EXISTS(p_grupo(i).REFERENCIA) THEN
                      set_refs(p_grupo(i).REFERENCIA) := TRUE; v_refs_distintas := v_refs_distintas + 1;
                   END IF;
                END IF;
            END LOOP;
        END;

        IF v_ids_externos_distintos > 0 THEN
            FOR i IN p_grupo.FIRST..p_grupo.LAST LOOP
                IF p_grupo(i).AD_IDEXTERNO IS NOT NULL THEN produtos_a_manter(produtos_a_manter.COUNT + 1) := p_grupo(i);
                ELSE produtos_a_excluir(produtos_a_excluir.COUNT + 1) := p_grupo(i); END IF;
            END LOOP;
        ELSIF v_refs_nao_nulas > 0 AND v_refs_nao_nulas < p_grupo.COUNT THEN
            FOR i IN p_grupo.FIRST..p_grupo.LAST LOOP
                IF p_grupo(i).REFERENCIA IS NOT NULL THEN produtos_a_manter(produtos_a_manter.COUNT + 1) := p_grupo(i);
                ELSE produtos_a_excluir(produtos_a_excluir.COUNT + 1) := p_grupo(i); END IF;
            END LOOP;
        ELSIF v_refs_distintas > 1 THEN
            produtos_a_manter(1) := p_grupo(p_grupo.FIRST);
            FOR i IN p_grupo.FIRST + 1 .. p_grupo.LAST LOOP produtos_a_excluir(produtos_a_excluir.COUNT + 1) := p_grupo(i); END LOOP;
        ELSE 
            IF v_refs_distintas = 1 THEN NULL;
            ELSE
                produtos_a_manter(1) := p_grupo(p_grupo.FIRST);
                FOR i IN p_grupo.FIRST + 1 .. p_grupo.LAST LOOP produtos_a_excluir(produtos_a_excluir.COUNT + 1) := p_grupo(i); END LOOP;
            END IF;
        END IF;

        IF produtos_a_excluir.COUNT > 0 AND produtos_a_manter.COUNT > 0 THEN
            v_codprod_mestre_principal := produtos_a_manter(1).CODPROD;
            FOR i IN 1..produtos_a_excluir.COUNT LOOP
                DECLARE v_prod_excluir r_produto := produtos_a_excluir(i); v_prod_mestre r_produto := produtos_a_manter(1);
                BEGIN
                    IF v_prod_mestre.AD_IDEXTERNO IS NOT NULL AND v_prod_mestre.REFERENCIA IS NULL AND v_prod_excluir.REFERENCIA IS NOT NULL THEN
                         UPDATE TGFPRO SET REFERENCIA = v_prod_excluir.REFERENCIA WHERE CODPROD = v_prod_mestre.CODPROD;
                    END IF;
                    UPDATE TGFITE SET CODPROD = v_codprod_mestre_principal WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFGIR1 WHERE CODPROD = v_prod_excluir.CODPROD; DELETE FROM TGFCUS WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFEXC WHERE CODPROD = v_prod_excluir.CODPROD; DELETE FROM TGFEST WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFPAP WHERE CODPROD = v_prod_excluir.CODPROD; DELETE FROM TGFPRO WHERE CODPROD = v_prod_excluir.CODPROD;
                END;
            END LOOP;
        END IF;
        p_grupo.DELETE;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- INÍCIO DO PROCESSO DE CONSOLIDAÇÃO DE PRODUTOS ---');
    v_count_grupo := 0;
    FOR rec IN c_produtos_duplicados LOOP
        IF rec.DESCRPROD <> v_descrprod_anterior AND v_count_grupo > 0 THEN
            processar_grupo(grupo_atual);
            v_count_grupo := 0; 
        END IF;
        
        v_count_grupo := v_count_grupo + 1;
        
        -- **CORREÇÃO PRINCIPAL: Atribuição manual, campo a campo**
        grupo_atual(v_count_grupo).CODPROD       := rec.CODPROD;
        grupo_atual(v_count_grupo).DESCRPROD     := rec.DESCRPROD;
        grupo_atual(v_count_grupo).REFERENCIA    := rec.REFERENCIA;
        grupo_atual(v_count_grupo).AD_IDEXTERNO  := rec.AD_IDEXTERNO;
        grupo_atual(v_count_grupo).NCM           := rec.NCM;
        
        v_descrprod_anterior := rec.DESCRPROD;
    END LOOP;
    
    IF v_count_grupo > 0 THEN processar_grupo(grupo_atual); END IF;
    DBMS_OUTPUT.PUT_LINE('======================================================');
    DBMS_OUTPUT.PUT_LINE('--- PROCESSO FINALIZADO ---');
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN
        DECLARE
            error_msg VARCHAR2(32767); error_btrace VARCHAR2(32767); chunk_size NUMBER := 250;
        BEGIN
            error_msg := SQLERRM; error_btrace := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!! ERRO INESPERADO !!!!!!!!!!!!!');
            DBMS_OUTPUT.PUT_LINE('--- MENSAGEM DO ERRO ---');
            FOR i IN 0 .. (TRUNC(LENGTH(error_msg) / chunk_size)) LOOP
                DBMS_OUTPUT.PUT_LINE(SUBSTR(error_msg, (i * chunk_size) + 1, chunk_size));
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('--- BACKTRACE ---');
            FOR i IN 0 .. (TRUNC(LENGTH(error_btrace) / chunk_size)) LOOP
                DBMS_OUTPUT.PUT_LINE(SUBSTR(error_btrace, (i * chunk_size) + 1, chunk_size));
            END LOOP;
            ROLLBACK;
        END;
END;
/
