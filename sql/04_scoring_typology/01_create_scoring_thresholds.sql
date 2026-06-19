/*
Objectif :
Créer une vue contenant les seuils statistiques utilisés pour le scoring.

Les seuils sont calculés à partir des quartiles :
- p25 : valeur basse
- p75 : valeur haute

Cette approche évite de fixer manuellement des seuils arbitraires.
*/

CREATE OR REPLACE VIEW insee_obs.v_scoring_thresholds AS
SELECT
    percentile_cont(0.25) WITHIN GROUP (ORDER BY taux_chomage_2022) AS taux_chomage_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY taux_chomage_2022) AS taux_chomage_p75,

    percentile_cont(0.25) WITHIN GROUP (ORDER BY niveau_vie_median_euros) AS revenu_median_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY niveau_vie_median_euros) AS revenu_median_p75,

    percentile_cont(0.25) WITHIN GROUP (ORDER BY part_sans_diplome_2022) AS sans_diplome_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY part_sans_diplome_2022) AS sans_diplome_p75,

    percentile_cont(0.25) WITHIN GROUP (ORDER BY part_diplomes_superieur_2022) AS diplomes_superieur_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY part_diplomes_superieur_2022) AS diplomes_superieur_p75,

    percentile_cont(0.25) WITHIN GROUP (ORDER BY part_logements_vacants_2022) AS logements_vacants_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY part_logements_vacants_2022) AS logements_vacants_p75,

    percentile_cont(0.25) WITHIN GROUP (ORDER BY part_familles_monoparentales_2022) AS familles_monoparentales_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY part_familles_monoparentales_2022) AS familles_monoparentales_p75,

    percentile_cont(0.25) WITHIN GROUP (ORDER BY evol_population_2016_2022_pct) AS evol_population_p25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY evol_population_2016_2022_pct) AS evol_population_p75,

    percentile_cont(0.75) WITHIN GROUP (ORDER BY part_60_ans_plus_2022) AS part_60_ans_plus_p75,

    percentile_cont(0.75) WITHIN GROUP (ORDER BY population_2022) AS population_p75,
    percentile_cont(0.90) WITHIN GROUP (ORDER BY population_2022) AS population_p90,

    percentile_cont(0.75) WITHIN GROUP (
        ORDER BY emplois_lieu_travail_2022 / NULLIF(population_2022, 0)
    ) AS densite_emploi_p75

FROM insee_obs.v_commune_observatory;