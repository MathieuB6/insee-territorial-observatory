/*
Objectif :
Contrôler que les vues enrichies avec les noms de communes sont complètes.
*/

SELECT
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT codgeo) AS nb_communes_distinctes,
    COUNT(nom_commune) AS nb_communes_avec_nom,
    COUNT(*) - COUNT(nom_commune) AS nb_communes_sans_nom
FROM insee_obs.v_commune_observatory_named;


SELECT
    COUNT(*) AS nb_lignes,
    COUNT(DISTINCT codgeo) AS nb_communes_distinctes,
    COUNT(nom_commune) AS nb_communes_avec_nom,
    COUNT(*) - COUNT(nom_commune) AS nb_communes_sans_nom
FROM insee_obs.v_commune_typology_named;


SELECT
    codgeo,
    nom_commune,
    code_departement,
    population_2022,
    typologie_commune,
    score_fragilite_100,
    score_attractivite_100,
    taux_chomage_2022,
    niveau_vie_median_euros
FROM insee_obs.v_commune_typology_named
ORDER BY population_2022 DESC
LIMIT 30;