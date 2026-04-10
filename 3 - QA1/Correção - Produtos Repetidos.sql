/*
================================================================================
SCRIPT DE CONSOLIDAÇÃO DE PRODUTOS DUPLICADOS
-------------------------------------------------------------------------------
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
    TYPE r_produto IS RECORD (
        CODPROD      TGFPRO.CODPROD%TYPE, 
        REFERENCIA   TGFPRO.REFERENCIA%TYPE,
        AD_IDEXTERNO TGFPRO.AD_IDEXTERNO%TYPE, 
        NCM          TGFPRO.NCM%TYPE,
        DESCRPROD    TGFPRO.DESCRPROD%TYPE,
        DESCR_LIMPA  VARCHAR2(4000) -- Campo auxiliar para controle
    );
    TYPE t_produto_table IS TABLE OF r_produto INDEX BY BINARY_INTEGER;

    CURSOR c_produtos_duplicados IS
        SELECT 
            p.CODPROD, p.DESCRPROD, p.REFERENCIA, p.AD_IDEXTERNO, p.NCM,
            TRIM(REGEXP_REPLACE(p.DESCRPROD, '[[:space:]]+', ' ')) as DESCR_LIMPA
        FROM TGFPRO p
        JOIN (
            SELECT 
                TRIM(REGEXP_REPLACE(DESCRPROD, '[[:space:]]+', ' ')) as DESCR_LIMPA, 
                TRIM(NCM) as NCM_LIMPO
            FROM TGFPRO 
            GROUP BY TRIM(REGEXP_REPLACE(DESCRPROD, '[[:space:]]+', ' ')), TRIM(NCM)
            HAVING COUNT(*) > 1
        ) dup ON TRIM(REGEXP_REPLACE(p.DESCRPROD, '[[:space:]]+', ' ')) = dup.DESCR_LIMPA
              AND NVL(TRIM(p.NCM), ' ') = NVL(dup.NCM_LIMPO, ' ')
        ORDER BY DESCR_LIMPA, p.NCM, p.CODPROD;

    grupo_atual          t_produto_table;
    v_descr_anterior     VARCHAR2(4000) := CHR(0);
    v_ncm_anterior       TGFPRO.NCM%TYPE := CHR(0);
    v_count_grupo        NUMBER;

    PROCEDURE processar_grupo(p_grupo IN OUT NOCOPY t_produto_table) IS
        v_ids_distintos      NUMBER := 0;
        v_refs_distintas     NUMBER := 0;
        v_codprod_mestre     TGFPRO.CODPROD%TYPE;
        idx_mestre           NUMBER;
    BEGIN
        IF p_grupo.COUNT <= 1 THEN RETURN; END IF;

        -- Limpa contadores para cada novo grupo
        v_ids_distintos  := 0;
        v_refs_distintas := 0;

        DECLARE
           TYPE t_set IS TABLE OF BOOLEAN INDEX BY VARCHAR2(100);
           set_ids t_set;
           set_refs t_set;
        BEGIN
            FOR i IN 1..p_grupo.COUNT LOOP
                IF p_grupo(i).AD_IDEXTERNO IS NOT NULL AND NOT set_ids.EXISTS(p_grupo(i).AD_IDEXTERNO) THEN
                    set_ids(p_grupo(i).AD_IDEXTERNO) := TRUE; v_ids_distintos := v_ids_distintos + 1;
                END IF;
                -- Aplicando TRIM na referência para ignorar espaços em branco que parecem nulos
                IF TRIM(p_grupo(i).REFERENCIA) IS NOT NULL AND NOT set_refs.EXISTS(TRIM(p_grupo(i).REFERENCIA)) THEN
                    set_refs(TRIM(p_grupo(i).REFERENCIA)) := TRUE; v_refs_distintas := v_refs_distintas + 1;
                END IF;
            END LOOP;
        END;

        DBMS_OUTPUT.PUT_LINE('Analizando: "' || p_grupo(1).DESCR_LIMPA || '" (' || p_grupo.COUNT || ' itens)');

        IF v_ids_distintos > 1 THEN DBMS_OUTPUT.PUT_LINE('-> IGNORADO: IDs Externos conflitantes.'); RETURN; END IF;
        IF v_refs_distintas > 1 THEN DBMS_OUTPUT.PUT_LINE('-> IGNORADO: Referências distintas.'); RETURN; END IF;

        idx_mestre := 1;
        FOR i IN 1..p_grupo.COUNT LOOP
            IF p_grupo(i).AD_IDEXTERNO IS NOT NULL THEN idx_mestre := i; EXIT; END IF;
        END LOOP;
        
        v_codprod_mestre := p_grupo(idx_mestre).CODPROD;

        FOR i IN 1..p_grupo.COUNT LOOP
            IF i <> idx_mestre THEN
                DECLARE v_prod_excluir r_produto := p_grupo(i);
                BEGIN
                    IF p_grupo(idx_mestre).REFERENCIA IS NULL AND v_prod_excluir.REFERENCIA IS NOT NULL THEN
                        UPDATE TGFPRO SET REFERENCIA = v_prod_excluir.REFERENCIA WHERE CODPROD = v_codprod_mestre;
                    END IF;
                    UPDATE TGFITE SET CODPROD = v_codprod_mestre WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFGIR1 WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFCUS   WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFEXC   WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFEST   WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFPAP   WHERE CODPROD = v_prod_excluir.CODPROD;
                    DELETE FROM TGFPRO   WHERE CODPROD = v_prod_excluir.CODPROD;
                    DBMS_OUTPUT.PUT_LINE('   -> ' || v_prod_excluir.CODPROD || ' consolidado no ' || v_codprod_mestre);
                END;
            END IF;
        END LOOP;
        p_grupo.DELETE;
    END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================');
    DBMS_OUTPUT.PUT_LINE('--- INÍCIO DO PROCESSO ---');
    v_count_grupo := 0;
    
    FOR rec IN c_produtos_duplicados LOOP
        IF (rec.DESCR_LIMPA <> v_descr_anterior OR NVL(TRIM(rec.NCM), ' ') <> NVL(TRIM(v_ncm_anterior), ' ')) 
           AND v_count_grupo > 0 THEN
            processar_grupo(grupo_atual);
            
            -- CORREÇÃO: Limpar a coleção explicitamente aqui garante que o próximo
            -- grupo comece com um buffer totalmente vazio, mesmo se o procedimento deu RETURN.
            grupo_atual.DELETE; 
            v_count_grupo := 0; 
        END IF;
        
        v_count_grupo := v_count_grupo + 1;
        grupo_atual(v_count_grupo).CODPROD      := rec.CODPROD;
        grupo_atual(v_count_grupo).DESCRPROD    := rec.DESCRPROD;
        grupo_atual(v_count_grupo).REFERENCIA   := rec.REFERENCIA;
        grupo_atual(v_count_grupo).AD_IDEXTERNO := rec.AD_IDEXTERNO;
        grupo_atual(v_count_grupo).NCM          := rec.NCM;
        grupo_atual(v_count_grupo).DESCR_LIMPA  := rec.DESCR_LIMPA;
        
        v_descr_anterior := rec.DESCR_LIMPA;
        v_ncm_anterior   := rec.NCM;
    END LOOP;
    
    IF v_count_grupo > 0 THEN processar_grupo(grupo_atual); END IF;
    DBMS_OUTPUT.PUT_LINE('--- FINALIZADO ---');
EXCEPTION 
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
END;
/