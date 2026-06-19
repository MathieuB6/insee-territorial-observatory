/*
Objectif :
Requêtes métier finales de l'observatoire territorial.

Ces requêtes servent à exploiter la vue finale et la typologie :
- communes fragiles
- communes attractives
- communes vieillissantes
- pôles urbains / pôles d'emploi
- communes à forte vacance
- synthèse par typologie
*/


/* ============================================================
   1. Top communes les plus fragiles
   ============================================================ */

SELECT
    codgeo,
    population_2022,
    typologie_commune,
    score_fragilite_100,
    score_attractivite_100,
    taux_chomage_2022,
    niveau_vie_median_euros,
    part_sans_diplome_2022,
    part_logements_vacants_2022,
    part_familles_monoparentales_2022,
    evol_population_2016_2022_pct,
    part_60_ans_plus_2022
FROM insee_obs.v_commune_typology
WHERE nb_indicateurs_fragilite_disponibles >= 5
ORDER BY score_fragilite_100 DESC, population_2022 DESC
LIMIT 50;


/* ============================================================
   2. Top communes les plus attractives
   ============================================================ */

SELECT
    codgeo,
    population_2022,
    typologie_commune,
    score_fragilite_100,
    score_attractivite_100,
    evol_population_2016_2022_pct,
    niveau_vie_median_euros,
    part_diplomes_superieur_2022,
    taux_chomage_2022,
    part_logements_vacants_2022,
    emplois_lieu_travail_2022
FROM insee_obs.v_commune_typology
WHERE nb_indicateurs_attractivite_disponibles >= 5
ORDER BY score_attractivite_100 DESC, population_2022 DESC
LIMIT 50;


/* ============================================================
   3. Communes vieillissantes
   ============================================================ */

SELECT
    codgeo,
    population_2022,
    typologie_commune,
    part_60_ans_plus_2022,
    part_75_ans_plus_2022,
    indice_vieillissement_simplifie,
    evol_population_2016_2022_pct,
    part_menages_personnes_seules_2022,
    part_80_plus_seuls_2022
FROM insee_obs.v_commune_typology
WHERE typologie_commune = 'Commune vieillissante'
ORDER BY part_60_ans_plus_2022 DESC, population_2022 DESC
LIMIT 50;


/* ============================================================
   4. Communes à forte vacance de logements
   ============================================================ */

SELECT
    codgeo,
    population_2022,
    typologie_commune,
    logements_2022,
    logements_vacants_2022,
    part_logements_vacants_2022,
    evol_logements_vacants_2016_2022_pct,
    evol_population_2016_2022_pct,
    score_fragilite_100
FROM insee_obs.v_commune_typology
WHERE logements_2022 >= 100
ORDER BY part_logements_vacants_2022 DESC, logements_vacants_2022 DESC
LIMIT 50;


/* ============================================================
   5. Pôles urbains / pôles d'emploi
   ============================================================ */

SELECT
    codgeo,
    population_2022,
    typologie_commune,
    emplois_lieu_travail_2022,
    ROUND((emplois_lieu_travail_2022 / NULLIF(population_2022, 0))::numeric, 3) AS emplois_par_habitant,
    taux_chomage_2022,
    part_diplomes_superieur_2022,
    niveau_vie_median_euros,
    part_transport_commun_2022,
    part_transport_voiture_2022
FROM insee_obs.v_commune_typology
WHERE typologie_commune = 'Pôle urbain / pôle d''emploi'
ORDER BY population_2022 DESC
LIMIT 50;


/* ============================================================
   6. Communes résidentielles favorisées
   ============================================================ */

SELECT
    codgeo,
    population_2022,
    typologie_commune,
    score_attractivite_100,
    niveau_vie_median_euros,
    part_proprietaires_2022,
    part_maisons_2022,
    part_diplomes_superieur_2022,
    taux_chomage_2022,
    part_travail_hors_commune_residence_2022
FROM insee_obs.v_commune_typology
WHERE typologie_commune = 'Commune résidentielle favorisée'
ORDER BY niveau_vie_median_euros DESC NULLS LAST, population_2022 DESC
LIMIT 50;


/* ============================================================
   7. Synthèse par typologie
   ============================================================ */

SELECT
    typologie_commune,
    nb_communes,
    population_2022,
    population_moyenne,
    score_fragilite_moyen,
    score_attractivite_moyen,
    taux_chomage_moyen,
    revenu_median_moyen,
    part_diplomes_superieur_moyenne,
    part_logements_vacants_moyenne,
    part_60_ans_plus_moyenne
FROM insee_obs.v_typology_summary
ORDER BY nb_communes DESC;