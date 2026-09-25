SELECT DISTINCT f.nufin,
       f.NUNOTA,
       f.codtipoper,
       (SELECT MAX(descroper)
          FROM tgftop
         WHERE codtipoper = f.codtipoper) AS descroper
  FROM TGFFIN f
 WHERE NOT EXISTS (
           SELECT 1
             FROM TGFCAB c
            WHERE c.NUNOTA = f.NUNOTA
       )
 ORDER BY f.nufin, f.NUNOTA;
