/*
Objectif :
Créer une vue de synthèse par typologie de commune.
*/

CREATE OR REPLACE VIEW insee_obs.v_typology_summary AS
SELECT
    typologie_commune,
    COUNT(*) AS nb_communes,
    SUM(population_2022) AS population_2022,

    ROUND(AVG(population_2022)::numeric, 0) AS population_moyenne,
    ROUND(AVG(score_fragilite_100)::numeric, 2) AS score_fragilite_moyen,
    ROUND(AVG(score_attractivite_100)::numeric, 2) AS score_attractivite_moyen,

    ROUND(AVG(taux_chomage_2022)::numeric, 2) AS taux_chomage_moyen,
    ROUND(AVG(niveau_vie_median_euros)::numeric, 2) AS revenu_median_moyen,
    ROUND(AVG(part_diplomes_superieur_2022)::numeric, 2) AS part_diplomes_superieur_moyenne,
    ROUND(AVG(part_logements_vacants_2022)::numeric, 2) AS part_logements_vacants_moyenne,
    ROUND(AVG(part_60_ans_plus_2022)::numeric, 2) AS part_60_ans_plus_moyenne

FROM insee_obs.v_commune_typology
GROUP BY typologie_commune
ORDER BY nb_communes DESC;