/*
Objectif :
Vérifier les valeurs manquantes sur les indicateurs clés de la vue finale.
*/

SELECT
    COUNT(*) AS nb_communes,

    COUNT(*) FILTER (WHERE niveau_vie_median_euros IS NULL) AS missing_revenu_median,
    COUNT(*) FILTER (WHERE taux_pauvrete_60_pct IS NULL) AS missing_taux_pauvrete,
    COUNT(*) FILTER (WHERE rapport_interdecile_d9_d1 IS NULL) AS missing_rapport_interdecile,

    COUNT(*) FILTER (WHERE taux_chomage_2022 IS NULL) AS missing_taux_chomage,
    COUNT(*) FILTER (WHERE part_sans_diplome_2022 IS NULL) AS missing_sans_diplome,
    COUNT(*) FILTER (WHERE part_diplomes_superieur_2022 IS NULL) AS missing_diplome_superieur,
    COUNT(*) FILTER (WHERE part_logements_vacants_2022 IS NULL) AS missing_logements_vacants,
    COUNT(*) FILTER (WHERE part_familles_monoparentales_2022 IS NULL) AS missing_familles_monoparentales
FROM insee_obs.v_commune_observatory;