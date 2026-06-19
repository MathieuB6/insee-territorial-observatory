/*
Objectif :
Créer une vue propre de référence des communes.

Source :
Code officiel géographique INSEE, millésime 2025.
*/

CREATE OR REPLACE VIEW insee_obs.ref_communes AS
SELECT
    codgeo,
    nom_commune,
    code_departement,
    code_region,
    type_commune
FROM insee_raw.ref_communes;