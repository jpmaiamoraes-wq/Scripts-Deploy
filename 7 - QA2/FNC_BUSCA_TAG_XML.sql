CREATE OR REPLACE FUNCTION FNC_BUSCA_TAG_XML (
  p_nunota IN NUMBER,         -- NUNOTA na TGFNFE
  p_seq    IN NUMBER,         -- nItem desejado (ex.: 4)
  p_tag    IN VARCHAR2        -- nome da tag (ex.: 'cProd', 'xProd', 'NCM', 'CFOP')
) RETURN VARCHAR2
IS
  v_val VARCHAR2(4000);
BEGIN
  /* Procura qualquer <det nItem="p_seq"> e, abaixo dele, a primeira ocorrência
     de um elemento cuja local-name() case com p_tag (case-insensitive).
     Ex.: //det[@nItem=4]//*[local-name()='cProd'] → valor do cProd desse item. */
  SELECT val
    INTO v_val
  FROM (
    SELECT xt.val
      FROM TGFNFE n,
           XMLTABLE(
             '//*[local-name()="det"][@nItem=$seq]
               //*[upper-case(local-name())=upper-case($tag)][1]'
             PASSING XMLTYPE(n.XML),
                     p_seq AS "seq",
                     p_tag AS "tag"
             COLUMNS val VARCHAR2(4000) PATH 'string(.)'
           ) xt
     WHERE n.nunota = p_nunota
  )
  WHERE ROWNUM = 1;

  RETURN v_val;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;  -- não achou a tag para esse nItem
END;
/