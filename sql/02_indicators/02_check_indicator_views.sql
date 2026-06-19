/*
Objectif :
Contrôler que les vues d'indicateurs sont bien créées
et qu'elles ont toutes le bon nombre de lignes.
*/

SELECT 'ind_population' AS view_name, COUNT(*) AS nb_lignes FROM insee_obs.ind_population
UNION ALL
SELECT 'ind_emploi', COUNT(*) FROM insee_obs.ind_emploi
UNION ALL
SELECT 'ind_diplome', COUNT(*) FROM insee_obs.ind_diplome
UNION ALL
SELECT 'ind_logement', COUNT(*) FROM insee_obs.ind_logement
UNION ALL
SELECT 'ind_menages_familles', COUNT(*) FROM insee_obs.ind_menages_familles
UNION ALL
SELECT 'ind_caracteristiques_emploi', COUNT(*) FROM insee_obs.ind_caracteristiques_emploi
UNION ALL
SELECT 'ind_revenu', COUNT(*) FROM insee_obs.ind_revenu
ORDER BY view_name;


/*
Aperçu de quelques indicateurs clés.
*/

SELECT
    p.codgeo,
    p.population_2022,
    p.evol_population_2016_2022_pct,
    p.part_60_ans_plus_2022,
    e.taux_chomage_2022,
    d.part_diplomes_superieur_2022,
    l.part_logements_vacants_2022,
    r.niveau_vie_median_euros
FROM insee_obs.ind_population p
LEFT JOIN insee_obs.ind_emploi e
    ON p.codgeo = e.codgeo
LEFT JOIN insee_obs.ind_diplome d
    ON p.codgeo = d.codgeo
LEFT JOIN insee_obs.ind_logement l
    ON p.codgeo = l.codgeo
LEFT JOIN insee_obs.ind_revenu r
    ON p.codgeo = r.codgeo
ORDER BY p.population_2022 DESC
LIMIT 20;