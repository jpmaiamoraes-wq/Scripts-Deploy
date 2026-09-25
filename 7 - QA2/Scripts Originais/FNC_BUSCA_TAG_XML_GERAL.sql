CREATE OR REPLACE FUNCTION FNC_BUSCA_TAG_XML_GERAL (
  p_nunota      IN NUMBER,   -- NUNOTA na TGFNFE
  p_tag         IN VARCHAR2, -- nome da tag (ex.: 'xNome', 'CNPJ', 'UF', 'vNF')
  p_parent_tag  IN VARCHAR2 DEFAULT NULL -- nome da tag pai (ex.: 'emit', 'dest', 'ide')
) RETURN VARCHAR2
IS
  v_val VARCHAR2(4000);
BEGIN
  /*
    Se p_parent_tag for informado, procura:
      qualquer nó cujo local-name() = p_tag
      E cujo pai imediato tenha local-name() = p_parent_tag.

    Se p_parent_tag for NULL, procura apenas qualquer nó com local-name() = p_tag,
    como na função geral anterior.

    Comparação é case-insensitive usando upper-case(local-name()).
  */
  SELECT valor
    INTO v_val
    FROM (
      SELECT xt.valor
        FROM TGFNFE n,
             XMLTABLE(
               '//*[ upper-case(local-name()) = upper-case($tag)
                    and ( string-length($parent) = 0
                          or upper-case(local-name(parent::*)) = upper-case($parent)
                        )
                 ][1]'
               PASSING XMLTYPE(n.XML),
                       p_tag                 AS "tag",
                       NVL(p_parent_tag, '') AS "parent"
               COLUMNS valor VARCHAR2(4000) PATH 'string(.)'
             ) xt
       WHERE n.nunota = p_nunota
    )
   WHERE ROWNUM = 1;

  RETURN v_val;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/