/*
Objectif :
Créer un inventaire des colonnes importées dans PostgreSQL.

Ce script sert à documenter la structure des données disponibles.
*/

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'insee_raw'
ORDER BY table_name, ordinal_position;