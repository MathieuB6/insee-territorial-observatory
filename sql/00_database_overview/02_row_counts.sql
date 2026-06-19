/*
Objectif :
Compter le nombre de lignes dans chaque table importée.

Cela permet d'identifier les éventuelles différences de couverture entre fichiers.
*/

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
FROM insee_raw.cc_revenu_com_2021

ORDER BY table_name;