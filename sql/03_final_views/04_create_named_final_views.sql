/*
Objectif :
Créer des vues finales enrichies avec les noms de communes.

Ces vues servent aux requêtes métier, aux exports et aux captures pour GitHub.
Elles évitent de modifier directement les vues déjà utilisées par le scoring.
*/


CREATE OR REPLACE VIEW insee_obs.v_commune_observatory_named AS
SELECT
    o.*,
    rc.nom_commune,
    rc.code_departement,
    rc.code_region,
    rc.type_commune
FROM insee_obs.v_commune_observatory o
LEFT JOIN insee_obs.ref_communes rc
    ON o.codgeo = rc.codgeo;


CREATE OR REPLACE VIEW insee_obs.v_commune_typology_named AS
SELECT
    t.*,
    rc.nom_commune,
    rc.code_departement,
    rc.code_region,
    rc.type_commune
FROM insee_obs.v_commune_typology t
LEFT JOIN insee_obs.ref_communes rc
    ON t.codgeo = rc.codgeo;