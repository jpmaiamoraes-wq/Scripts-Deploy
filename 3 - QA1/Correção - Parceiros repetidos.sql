BEGIN
  FOR i IN (
    SELECT 
      P.CODPARC,
      P.CGC_CPF,
      P.IDENTINSCESTAD,
      (
        SELECT MIN(P2.CODPARC)
        FROM TGFPAR P2
        WHERE P2.CGC_CPF = P.CGC_CPF
          AND NVL(P2.IDENTINSCESTAD, '0') = NVL(P.IDENTINSCESTAD, '0')
      ) AS MENOR
    FROM TGFPAR P
    WHERE EXISTS (
      -- Verifica se existe mais de um parceiro com o mesmo CNPJ e mesma IE
      SELECT 1
      FROM TGFPAR P3
      WHERE P3.CGC_CPF = P.CGC_CPF
        AND NVL(P3.IDENTINSCESTAD, '0') = NVL(P.IDENTINSCESTAD, '0')
      GROUP BY P3.CGC_CPF, P3.IDENTINSCESTAD
      HAVING COUNT(*) > 1
    )
    -- Garante que só vamos processar os códigos maiores (os duplicados)
    AND P.CODPARC > (
      SELECT MIN(P4.CODPARC)
      FROM TGFPAR P4
      WHERE P4.CGC_CPF = P.CGC_CPF
        AND NVL(P4.IDENTINSCESTAD, '0') = NVL(P.IDENTINSCESTAD, '0')
    )
  )
  LOOP
    -- Etapa 1: Atualiza o parceiro "mestre" para ser Cliente e Fornecedor (Opcional)
    UPDATE TGFPAR SET FORNECEDOR = 'S', CLIENTE = 'S' WHERE CODPARC = i.MENOR;
    
    -- Etapa 2: Move o histórico de outras tabelas para o parceiro "mestre"
    UPDATE TGFCAB SET CODPARC = i.MENOR WHERE CODPARC = i.CODPARC;
    UPDATE TGFFIN SET CODPARC = i.MENOR WHERE CODPARC = i.CODPARC;
    UPDATE TGFPRO SET CODPARCFORN = i.MENOR WHERE CODPARCFORN = i.CODPARC;
    
    -- Etapa 3: Deleta o parceiro duplicado
    DELETE FROM TGFPAR WHERE CODPARC = i.CODPARC AND NOMEPARC NOT LIKE '%CONSUMIDOR%';
      
  END LOOP;
  
  COMMIT;
END;
