WITH onboarding (email, nomeusu, codigo_usuario) AS (
    SELECT 'vitor.junklaus@moveenergia.com', 'Vitor Vechi Junklaus', '1' FROM dual UNION ALL
    SELECT 'gabriel.nogueira@moveenergia.com', 'Gabriel Nogueira', '1' FROM dual UNION ALL
    SELECT 'cristina.engelke@moveenergia.com', 'Cristina Rabelo Engelke', '4' FROM dual UNION ALL
    SELECT 'klara.holleben@moveenergia.com', 'Klara Holleben', '4' FROM dual UNION ALL
    SELECT 'tatiane.batista@moveenergia.com', 'Tatiane Batista', '4' FROM dual UNION ALL
    SELECT 'viviane.kriger@moveenergia.com', 'Viviane Kriger', '4' FROM dual UNION ALL
    SELECT 'camila.fragas@moveenergia.com', 'Camila Cristina de Fragas', '13' FROM dual UNION ALL
    SELECT 'daniel.midoes@moveenergia.com', 'daniel midões', '13' FROM dual UNION ALL
    SELECT 'elaine.martins@moveenergia.com', 'elaine elisa martins', '13' FROM dual UNION ALL
    SELECT 'rafael.porte@moveenergia.com', 'Rafael Porte', '13' FROM dual UNION ALL
    SELECT 'rodrigo.pes@moveenergia.com', 'Rodrigo de Souza Pes', '13' FROM dual UNION ALL
    SELECT 'stefane.bernardi@moveenergia.com', 'Stefane Bernardi', '13' FROM dual UNION ALL
    SELECT 'vitor.martins@moveenergia.com', 'Vitor Martins', '13' FROM dual UNION ALL
    SELECT 'gabriella.santos@moveenergia.com', 'gabriella santos', 'Atendimento?' FROM dual UNION ALL
    SELECT 'hideaki.mateus@moveenergia.com', 'Hideaki Hisamatsu', 'Atendimento?' FROM dual UNION ALL
    SELECT 'kamila.amorim@moveenergia.com', 'Kamila Amorim', 'Atendimento?' FROM dual UNION ALL
    SELECT 'kathlyn.santos@moveenergia.com', 'Kathlyn Santos', 'Atendimento?' FROM dual UNION ALL
    SELECT 'priscila.souza@moveenergia.com', 'Priscila Souza', 'Atendimento?' FROM dual
), oracle_users AS (
    SELECT u.codusU u_codus,
           LOWER(TRIM(u.email)) AS email,
           TRIM(u.nomeusu) AS nomeusu,
           u.codemp,
           u.codgrupo
      FROM tsiusu u
     WHERE TRIM(u.email) IS NOT NULL
       AND NVL(u.codgrupo, 0) > 0
)
SELECT 'USUARIO' AS tipo,
       COALESCE(o.email, u.email) AS email,
       o.nomeusu AS nome_onboarding,
       o.codigo_usuario AS codigo_usuario_onboarding,
       CAST(NULL AS VARCHAR2(1)) AS empresa_onboarding,
       CAST(NULL AS VARCHAR2(1)) AS codgrupo_onboarding,
       TO_CHAR(u.u_codus) AS codusu_oracle,
       u.nomeusu AS nome_oracle,
       TO_CHAR(u.codemp) AS codemp_oracle,
       TO_CHAR(u.codgrupo) AS codgrupo_oracle,
       CASE
         WHEN o.email IS NULL THEN 'APENAS_NO_ORACLE'
         WHEN u.email IS NULL THEN 'APENAS_NO_ONBOARDING'
         WHEN UPPER(TRIM(o.nomeusu)) <> UPPER(TRIM(u.nomeusu))
           THEN 'DIVERGENCIA_DE_NOME'
         ELSE 'CORRESPONDENTE_POR_EMAIL'
       END AS classificacao
  FROM onboarding o
  FULL OUTER JOIN oracle_users u ON u.email = LOWER(TRIM(o.email))
UNION ALL
SELECT 'RESUMO' AS tipo,
       'TOTAL_ORACLE=' || TO_CHAR(COUNT(*)) AS email,
       'COM_GRUPO=' || TO_CHAR(SUM(CASE WHEN NVL(codgrupo, 0) > 0 THEN 1 ELSE 0 END)) AS nome_onboarding,
       'SEM_GRUPO=' || TO_CHAR(SUM(CASE WHEN NVL(codgrupo, 0) <= 0 THEN 1 ELSE 0 END)) AS codigo_usuario_onboarding,
       'ONBOARDING_LINHAS=18' AS empresa_onboarding,
       'ONBOARDING_EMPRESA_PREENCHIDA=0, ONBOARDING_CODGRUPO_PREENCHIDO=0' AS codgrupo_onboarding,
       CAST(NULL AS VARCHAR2(30)) AS codusu_oracle,
       CAST(NULL AS VARCHAR2(4000)) AS nome_oracle,
       CAST(NULL AS VARCHAR2(30)) AS codemp_oracle,
       CAST(NULL AS VARCHAR2(30)) AS codgrupo_oracle,
       'RESUMO' AS classificacao
  FROM tsiusu
ORDER BY tipo, email
