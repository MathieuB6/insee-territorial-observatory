/*
Objectif :
Créer les vues staging du projet.

Les vues staging appliquent le périmètre d'analyse défini dans :
insee_obs.ref_communes_analysis

Elles constituent la couche propre utilisée ensuite pour calculer les indicateurs.
*/


CREATE OR REPLACE VIEW insee_obs.stg_population AS
SELECT
    p.*
FROM insee_raw.cc_population_2022 p
INNER JOIN insee_obs.ref_communes_analysis r
    ON p.codgeo = r.codgeo;


CREATE OR REPLACE VIEW insee_obs.stg_emploi AS
SELECT
    e.*
FROM insee_raw.cc_emploi_2022 e
INNER JOIN insee_obs.ref_communes_analysis r
    ON e.codgeo = r.codgeo;


CREATE OR REPLACE VIEW insee_obs.stg_diplome AS
SELECT
    d.*
FROM insee_raw.cc_diplome_2022 d
INNER JOIN insee_obs.ref_communes_analysis r
    ON d.codgeo = r.codgeo;


CREATE OR REPLACE VIEW insee_obs.stg_logement AS
SELECT
    l.*
FROM insee_raw.cc_logement_2022 l
INNER JOIN insee_obs.ref_communes_analysis r
    ON l.codgeo = r.codgeo;


CREATE OR REPLACE VIEW insee_obs.stg_menages_familles AS
SELECT
    m.*
FROM insee_raw.cc_menages_familles_2022 m
INNER JOIN insee_obs.ref_communes_analysis r
    ON m.codgeo = r.codgeo;


CREATE OR REPLACE VIEW insee_obs.stg_caracteristiques_emploi AS
SELECT
    c.*
FROM insee_raw.cc_caracteristiques_emploi_2022 c
INNER JOIN insee_obs.ref_communes_analysis r
    ON c.codgeo = r.codgeo;


CREATE OR REPLACE VIEW insee_obs.stg_revenu AS
SELECT
    r.*
FROM insee_raw.cc_revenu_com_2021 r
INNER JOIN insee_obs.ref_communes_analysis ref
    ON r.codgeo = ref.codgeo;