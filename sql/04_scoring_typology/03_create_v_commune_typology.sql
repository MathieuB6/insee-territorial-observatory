/*
Objectif :
Créer une typologie synthétique des communes à partir des scores et indicateurs.

La typologie est volontairement simple et lisible pour un usage portfolio :
- Pôle urbain / pôle d'emploi
- Commune fragile
- Commune vieillissante
- Commune résidentielle favorisée
- Commune dynamique / attractive
- Commune intermédiaire
*/

CREATE OR REPLACE VIEW insee_obs.v_commune_typology AS
WITH thresholds AS (
    SELECT *
    FROM insee_obs.v_scoring_thresholds
),

base AS (
    SELECT
        o.*,
        s.score_fragilite_brut,
        s.score_fragilite_100,
        s.nb_indicateurs_fragilite_disponibles,
        s.score_attractivite_brut,
        s.score_attractivite_100,
        s.nb_indicateurs_attractivite_disponibles,
        t.population_p90,
        t.densite_emploi_p75,
        t.part_60_ans_plus_p75
    FROM insee_obs.v_commune_observatory o
    LEFT JOIN insee_obs.v_commune_scoring s
        ON o.codgeo = s.codgeo
    CROSS JOIN thresholds t
)

SELECT
    *,

    CASE
        WHEN population_2022 >= population_p90
             AND emplois_lieu_travail_2022 / NULLIF(population_2022, 0) >= densite_emploi_p75
            THEN 'Pôle urbain / pôle d''emploi'

        WHEN score_fragilite_100 >= 60
            THEN 'Commune fragile'

        WHEN part_60_ans_plus_2022 >= part_60_ans_plus_p75
             AND evol_population_2016_2022_pct <= 0
            THEN 'Commune vieillissante'

        WHEN score_attractivite_100 >= 60
             AND part_proprietaires_2022 >= 70
            THEN 'Commune résidentielle favorisée'

        WHEN score_attractivite_100 >= 60
            THEN 'Commune dynamique / attractive'

        ELSE 'Commune intermédiaire'
    END AS typologie_commune

FROM base;