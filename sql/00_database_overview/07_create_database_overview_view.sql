/*
Objectif :
Créer une vue de synthèse des tables importées.

Cette vue permet de documenter rapidement les volumes de données disponibles dans le projet.
*/

CREATE OR REPLACE VIEW insee_obs.v_database_overview AS

SELECT 'cc_population_2022' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_population_2022

UNION ALL

SELECT 'cc_emploi_2022' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_emploi_2022

UNION ALL

SELECT 'cc_diplome_2022' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_diplome_2022

UNION ALL

SELECT 'cc_logement_2022' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_logement_2022

UNION ALL

SELECT 'cc_menages_familles_2022' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_menages_familles_2022

UNION ALL

SELECT 'cc_caracteristiques_emploi_2022' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_caracteristiques_emploi_2022

UNION ALL

SELECT 'cc_revenu_com_2021' AS table_name, COUNT(*) AS nb_lignes
FROM insee_raw.cc_revenu_com_2021;