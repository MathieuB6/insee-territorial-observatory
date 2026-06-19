/*
Objectif :
Vérifier qu'il n'existe pas de doublons sur le code commune dans chaque table.

Chaque table doit contenir au maximum une ligne par commune.
*/

SELECT 'cc_population_2022' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_population_2022
GROUP BY codgeo
HAVING COUNT(*) > 1

UNION ALL

SELECT 'cc_emploi_2022' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_emploi_2022
GROUP BY codgeo
HAVING COUNT(*) > 1

UNION ALL

SELECT 'cc_diplome_2022' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_diplome_2022
GROUP BY codgeo
HAVING COUNT(*) > 1

UNION ALL

SELECT 'cc_logement_2022' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_logement_2022
GROUP BY codgeo
HAVING COUNT(*) > 1

UNION ALL

SELECT 'cc_menages_familles_2022' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_menages_familles_2022
GROUP BY codgeo
HAVING COUNT(*) > 1

UNION ALL

SELECT 'cc_caracteristiques_emploi_2022' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_caracteristiques_emploi_2022
GROUP BY codgeo
HAVING COUNT(*) > 1

UNION ALL

SELECT 'cc_revenu_com_2021' AS table_name, codgeo, COUNT(*) AS nb_lignes
FROM insee_raw.cc_revenu_com_2021
GROUP BY codgeo
HAVING COUNT(*) > 1

ORDER BY table_name, codgeo;