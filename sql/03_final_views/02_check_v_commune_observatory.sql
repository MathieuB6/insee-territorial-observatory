/*
Objectif :
Contrôler la vue finale de l'observatoire territorial.
*/

SELECT
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT codgeo) AS nb_communes_distinctes
FROM insee_obs.v_commune_observatory;


SELECT *
FROM insee_obs.v_commune_observatory
ORDER BY population_2022 DESC
LIMIT 20;


SELECT
    COUNT(*) AS nb_lignes_sans_revenu_median
FROM insee_obs.v_commune_observatory
WHERE niveau_vie_median_euros IS NULL;


SELECT
    MIN(population_2022) AS population_min,
    MAX(population_2022) AS population_max,
    ROUND(AVG(population_2022)::numeric, 2) AS population_moyenne,
    ROUND(AVG(taux_chomage_2022)::numeric, 2) AS taux_chomage_moyen,
    ROUND(AVG(niveau_vie_median_euros)::numeric, 2) AS revenu_median_moyen,
    ROUND(AVG(part_logements_vacants_2022)::numeric, 2) AS vacance_logement_moyenne
FROM insee_obs.v_commune_observatory;