/*
========================================================================================
-- SCRIPT UNIFICADO PARA CONSOLIDAÇÃO DE IPI DUPLICADO
--
-- OBJETIVO:
-- 1. Identificar alíquotas de IPI (PERCENTUAL) duplicadas na TGFIPI.
-- 2. Manter apenas o registro com o menor CODIPI para cada alíquota duplicada.
-- 3. Atualizar a tabela de produtos (TGFPRO) para apontar para o CODIPI mantido.
-- 4. Excluir os registros de CODIPI duplicados da TGFIPI.
--
-- Autor: Seu Assistente de IA
-- Data: '31/03/2026'
========================================================================================
*/
SET SERVEROUTPUT ON;

DECLARE
    v_total_produtos_atualizados NUMBER := 0;
    v_total_ipi_removidos      NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('================================================================');
    DBMS_OUTPUT.PUT_LINE('-- INICIANDO PROCESSO DE UNIFICAÇÃO DE IPI DUPLICADO --');
    DBMS_OUTPUT.PUT_LINE('================================================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-- RELATÓRIO DE SUBSTITUIÇÕES PLANEJADAS --');

    -- Cursor para iterar sobre os grupos de IPI duplicados
    FOR rec IN (
        WITH IpiMap AS (
            -- Mapeia qual CODIPI será mantido (o menor) e quais serão removidos
            SELECT
                CODIPI,
                PERCENTUAL,
                MIN(CODIPI) OVER (PARTITION BY PERCENTUAL) AS CODIPI_MANTER
            FROM TGFIPI
            WHERE PERCENTUAL IN (
                SELECT PERCENTUAL FROM TGFIPI GROUP BY PERCENTUAL HAVING COUNT(*) > 1
            )
        )
        SELECT
            PERCENTUAL,
            CODIPI AS CODIPI_REMOVER,
            CODIPI_MANTER
        FROM IpiMap
        WHERE CODIPI <> CODIPI_MANTER -- Processa apenas os que serão removidos
        ORDER BY PERCENTUAL, CODIPI_REMOVER
    )
    LOOP
        -- Exibe o status do que será feito
        DBMS_OUTPUT.PUT_LINE(
            'Alíquota ' || TO_CHAR(rec.PERCENTUAL, '990.99') || '%: O código ' || rec.CODIPI_REMOVER ||
            ' será substituído pelo código ' || rec.CODIPI_MANTER || '.'
        );

        -- Passo 1: UPDATE na TGFPRO
        UPDATE TGFPRO
        SET CODIPI = rec.CODIPI_MANTER
        WHERE CODIPI = rec.CODIPI_REMOVER;

        v_total_produtos_atualizados := v_total_produtos_atualizados + SQL%ROWCOUNT;

        -- Passo 2: DELETE na TGFIPI
        DELETE FROM TGFIPI
        WHERE CODIPI = rec.CODIPI_REMOVER;

        v_total_ipi_removidos := v_total_ipi_removidos + SQL%ROWCOUNT;

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('================================================================');
    DBMS_OUTPUT.PUT_LINE('-- PROCESSO FINALIZADO --');
    DBMS_OUTPUT.PUT_LINE('================================================================');
    DBMS_OUTPUT.PUT_LINE('Total de registros de produtos atualizados na TGFPRO: ' || v_total_produtos_atualizados);
    DBMS_OUTPUT.PUT_LINE('Total de registros de IPI duplicados removidos da TGFIPI: ' || v_total_ipi_removidos);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Operação concluída com sucesso. Confirmando alterações (COMMIT).');

    -- Se tudo correu bem, confirma as alterações
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de qualquer erro, desfaz tudo
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        DBMS_OUTPUT.PUT_LINE('!! OCORREU UM ERRO DURANTE A EXECUÇÃO !!');
        DBMS_OUTPUT.PUT_LINE('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Nenhuma alteração foi salva. Desfazendo transação (ROLLBACK).');
        ROLLBACK;
END;
/
