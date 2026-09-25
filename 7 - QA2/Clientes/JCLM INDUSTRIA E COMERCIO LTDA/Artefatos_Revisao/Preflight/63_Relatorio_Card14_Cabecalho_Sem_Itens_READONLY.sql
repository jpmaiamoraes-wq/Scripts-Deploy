SELECT c.NUNOTA,
       c.codtipoper,
       t.descroper,
       tipmov_desc.OPCAO AS DESC_TIPMOV,
       C.DTNEG,
       C.AD_ORIGDEPLOY
  FROM TGFCAB c
  INNER JOIN TGFTOP T
    ON C.CODTIPOPER = T.CODTIPOPER
   AND C.DHTIPOPER = T.DHALTER
  LEFT JOIN TDDCAM cam_tipmov
    ON cam_tipmov.NOMETAB = 'TGFCAB'
   AND cam_tipmov.NOMECAMPO = 'TIPMOV'
  LEFT JOIN TDDOPC tipmov_desc
    ON tipmov_desc.NUCAMPO = cam_tipmov.NUCAMPO
   AND tipmov_desc.VALOR = c.TIPMOV
 WHERE NOT EXISTS (
           SELECT 1
             FROM TGFITE i
            WHERE i.NUNOTA = c.NUNOTA
       )
   AND c.TIPMOV <> 'Z'
 ORDER BY c.NUNOTA;
