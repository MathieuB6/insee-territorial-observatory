/*
Objectif :
Liste des tables importés
*/

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'insee_raw'
ORDER BY table_name;