UPDATE TGFPRO
   SET DESCRPROD =
         REGEXP_REPLACE(                          -- 7) remove hífen inicial
           REGEXP_REPLACE(                        -- 6b) remove '>' final se tiver vindo de "<...>"
             REGEXP_REPLACE(                      -- 6a) remove '<' inicial
               REGEXP_REPLACE(                    -- 5) remove "0 " inicial
                 REGEXP_REPLACE(                  -- 4) remove "+" inicial
                   REGEXP_REPLACE(                -- 3) remove "# " isolado
                     REGEXP_REPLACE(              -- 2) remove "#1700501#18069000#"
                       REGEXP_REPLACE(            -- 1) remove códigos numéricos longos (com ponto)
                         DESCRPROD,
                         '^\s*[0-9]{3,}[0-9\.]*\s+', ''
                       ),
                       '^\s*#[0-9#]+\s+', ''
                     ),
                     '^\s*#\s+', ''
                   ),
                   '^\s*\+\s*', ''
                 ),
                 '^\s*0\s+', ''
               ),
               '^\s*<\s*', ''
             ),
             '>\s*$', ''
           ),
           '^\s*-\s*', ''
         ),
       COMPLDESC =
         REGEXP_REPLACE(
           REGEXP_REPLACE(
             REGEXP_REPLACE(
               REGEXP_REPLACE(
                 REGEXP_REPLACE(
                   REGEXP_REPLACE(
                     REGEXP_REPLACE(
                       REGEXP_REPLACE(COMPLDESC,
                         '^\s*[0-9]{3,}[0-9\.]*\s+', ''
                       ),
                       '^\s*#[0-9#]+\s+', ''
                     ),
                     '^\s*#\s+', ''
                   ),
                   '^\s*\+\s*', ''
                 ),
                 '^\s*0\s+', ''
               ),
               '^\s*<\s*', ''
             ),
             '>\s*$', ''
           ),
           '^\s*-\s*', ''
         )
 WHERE
      REGEXP_LIKE(DESCRPROD, '^\s*[0-9]{3,}[0-9\.]*\s+')
   OR REGEXP_LIKE(COMPLDESC, '^\s*[0-9]{3,}[0-9\.]*\s+')
   OR REGEXP_LIKE(DESCRPROD, '^\s*#[0-9#]+\s+')
   OR REGEXP_LIKE(DESCRPROD, '^\s*#\s+')
   OR REGEXP_LIKE(DESCRPROD, '^\s*\+\s*')
   OR REGEXP_LIKE(DESCRPROD, '^\s*0\s+')
   OR REGEXP_LIKE(DESCRPROD, '^\s*<')
   OR REGEXP_LIKE(DESCRPROD, '^\s*-\s*');

COMMIT;