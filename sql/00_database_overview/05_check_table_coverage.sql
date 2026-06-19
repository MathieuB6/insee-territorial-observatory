/*
Objectif :
Vérifier la couverture des tables par rapport à la table de référence population.

La population 2022 sert de table de référence car elle contient toutes les communes du projet.
*/

WITH population_ref AS (
    SELECT DISTINCT codgeo
    FROM insee_raw.cc_population_2022
),

coverage AS (
    SELECT
        'cc_emploi_2022' AS table_name,
        COUNT(p.codgeo) AS communes_reference,
        COUNT(e.codgeo) AS communes_presentes,
        COUNT(p.codgeo) - COUNT(e.codgeo) AS communes_manquantes
    FROM population_ref p
    LEFT JOIN insee_raw.cc_emploi_2022 e
        ON p.codgeo = e.codgeo

    UNION ALL

    SELECT
        'cc_diplome_2022' AS table_name,
        COUNT(p.codgeo) AS communes_reference,
        COUNT(d.codgeo) AS communes_presentes,
        COUNT(p.codgeo) - COUNT(d.codgeo) AS communes_manquantes
    FROM population_ref p
    LEFT JOIN insee_raw.cc_diplome_2022 d
        ON p.codgeo = d.codgeo

    UNION ALL

    SELECT
        'cc_logement_2022' AS table_name,
        COUNT(p.codgeo) AS communes_reference,
        COUNT(l.codgeo) AS communes_presentes,
        COUNT(p.codgeo) - COUNT(l.codgeo) AS communes_manquantes
    FROM population_ref p
    LEFT JOIN insee_raw.cc_logement_2022 l
        ON p.codgeo = l.codgeo

    UNION ALL

    SELECT
        'cc_menages_familles_2022' AS table_name,
        COUNT(p.codgeo) AS communes_reference,
        COUNT(m.codgeo) AS communes_presentes,
        COUNT(p.codgeo) - COUNT(m.codgeo) AS communes_manquantes
    FROM population_ref p
    LEFT JOIN insee_raw.cc_menages_familles_2022 m
        ON p.codgeo = m.codgeo

    UNION ALL

    SELECT
        'cc_caracteristiques_emploi_2022' AS table_name,
        COUNT(p.codgeo) AS communes_reference,
        COUNT(c.codgeo) AS communes_presentes,
        COUNT(p.codgeo) - COUNT(c.codgeo) AS communes_manquantes
    FROM population_ref p
    LEFT JOIN insee_raw.cc_caracteristiques_emploi_2022 c
        ON p.codgeo = c.codgeo

    UNION ALL

    SELECT
        'cc_revenu_com_2021' AS table_name,
        COUNT(p.codgeo) AS communes_reference,
        COUNT(r.codgeo) AS communes_presentes,
        COUNT(p.codgeo) - COUNT(r.codgeo) AS communes_manquantes
    FROM population_ref p
    LEFT JOIN insee_raw.cc_revenu_com_2021 r
        ON p.codgeo = r.codgeo
)

SELECT *
FROM coverage
ORDER BY table_name;