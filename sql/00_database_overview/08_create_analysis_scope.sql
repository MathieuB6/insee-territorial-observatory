/*
Objectif :
Créer le périmètre d'analyse du projet.

La table population contient 34 903 codes géographiques.
Le fichier revenus Filosofi 2021 contient 34 804 communes.

Les 99 codes absents des revenus correspondent notamment :
- aux arrondissements municipaux de Paris, Lyon et Marseille ;
- à des communes de Guadeloupe et de Guyane non couvertes par le fichier revenus utilisé.

Pour construire des scores fiables, l'observatoire final se limite aux communes disposant
des données sociodémographiques principales et des données de revenus.
*/

CREATE OR REPLACE VIEW insee_obs.ref_communes_analysis AS
SELECT
    p.codgeo
FROM insee_raw.cc_population_2022 p
INNER JOIN insee_raw.cc_revenu_com_2021 r
    ON p.codgeo = r.codgeo;


/*
Vue de documentation des communes exclues du périmètre d'analyse.
*/

CREATE OR REPLACE VIEW insee_obs.v_excluded_communes_analysis_scope AS
SELECT
    p.codgeo,
    p.population_2022,
    CASE
        WHEN p.codgeo BETWEEN '75101' AND '75120'
            THEN 'Arrondissement municipal de Paris'
        WHEN p.codgeo BETWEEN '13201' AND '13216'
            THEN 'Arrondissement municipal de Marseille'
        WHEN p.codgeo BETWEEN '69381' AND '69389'
            THEN 'Arrondissement municipal de Lyon'
        WHEN p.codgeo LIKE '971%'
            THEN 'Guadeloupe - revenu non disponible dans le fichier utilisé'
        WHEN p.codgeo LIKE '973%'
            THEN 'Guyane - revenu non disponible dans le fichier utilisé'
        ELSE 'Autre territoire absent du fichier revenus'
    END AS exclusion_reason
FROM insee_raw.cc_population_2022 p
LEFT JOIN insee_raw.cc_revenu_com_2021 r
    ON p.codgeo = r.codgeo
WHERE r.codgeo IS NULL;