/*
Objectif :
Créer les vues d'indicateurs du projet.

Ces vues transforment les données staging en indicateurs territoriaux exploitables :
- parts en %
- taux
- évolutions
- ratios simples

Toutes les vues s'appuient sur les vues staging du schéma insee_obs.
*/


/* ============================================================
   1. Indicateurs population
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_population AS
SELECT
    codgeo,

    population_2022,
    population_2016,
    population_2011,

    ROUND(
        (100.0 * (population_2022 - population_2016) / NULLIF(population_2016, 0))::numeric,
        2
    ) AS evol_population_2016_2022_pct,

    ROUND(
        (100.0 * (population_2022 - population_2011) / NULLIF(population_2011, 0))::numeric,
        2
    ) AS evol_population_2011_2022_pct,

    pop_0_14_2022,
    pop_15_29_2022,
    pop_30_44_2022,
    pop_45_59_2022,
    pop_60_74_2022,
    pop_75_89_2022,
    pop_90_plus_2022,

    ROUND(
        (100.0 * pop_0_14_2022 / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_0_14_ans_2022,

    ROUND(
        (100.0 * pop_15_29_2022 / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_15_29_ans_2022,

    ROUND(
        (100.0 * (pop_0_14_2022 + pop_15_29_2022) / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_moins_30_ans_2022,

    ROUND(
        (100.0 * (pop_60_74_2022 + pop_75_89_2022 + pop_90_plus_2022) / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_60_ans_plus_2022,

    ROUND(
        (100.0 * (pop_75_89_2022 + pop_90_plus_2022) / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_75_ans_plus_2022,

    ROUND(
        (100.0 * (pop_60_74_2022 + pop_75_89_2022 + pop_90_plus_2022)
        / NULLIF(pop_0_14_2022 + pop_15_29_2022, 0))::numeric,
        2
    ) AS indice_vieillissement_simplifie,

    hommes_2022,
    femmes_2022,

    ROUND(
        (100.0 * femmes_2022 / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_femmes_2022,

    ROUND(
        (100.0 * hommes_2022 / NULLIF(population_2022, 0))::numeric,
        2
    ) AS part_hommes_2022

FROM insee_obs.stg_population;


/* ============================================================
   2. Indicateurs emploi / population active
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_emploi AS
SELECT
    codgeo,

    population_15_64_2022,
    actifs_15_64_2022,
    actifs_occupes_15_64_2022,
    chomeurs_15_64_2022,
    inactifs_15_64_2022,

    ROUND(
        (100.0 * actifs_15_64_2022 / NULLIF(population_15_64_2022, 0))::numeric,
        2
    ) AS taux_activite_2022,

    ROUND(
        (100.0 * actifs_occupes_15_64_2022 / NULLIF(population_15_64_2022, 0))::numeric,
        2
    ) AS taux_emploi_2022,

    ROUND(
        (100.0 * chomeurs_15_64_2022 / NULLIF(actifs_15_64_2022, 0))::numeric,
        2
    ) AS taux_chomage_2022,

    ROUND(
        (100.0 * inactifs_15_64_2022 / NULLIF(population_15_64_2022, 0))::numeric,
        2
    ) AS part_inactifs_15_64_2022,

    ROUND(
        (100.0 * etudiants_15_64_2022 / NULLIF(population_15_64_2022, 0))::numeric,
        2
    ) AS part_etudiants_15_64_2022,

    ROUND(
        (100.0 * retraites_15_64_2022 / NULLIF(population_15_64_2022, 0))::numeric,
        2
    ) AS part_retraites_15_64_2022,

    ROUND(
        (100.0 * chomeurs_15_24_2022 / NULLIF(actifs_15_24_2022, 0))::numeric,
        2
    ) AS taux_chomage_jeunes_2022,

    ROUND(
        (100.0 * chomeurs_55_64_2022 / NULLIF(actifs_55_64_2022, 0))::numeric,
        2
    ) AS taux_chomage_55_64_2022,

    emplois_lieu_travail_2022,

    ROUND(
        (100.0 * emplois_salaries_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_salaries_2022,

    ROUND(
        (100.0 * emplois_non_salaries_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_non_salaries_2022,

    ROUND(
        (100.0 * emplois_agriculture_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_agriculture_2022,

    ROUND(
        (100.0 * emplois_industrie_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_industrie_2022,

    ROUND(
        (100.0 * emplois_construction_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_construction_2022,

    ROUND(
        (100.0 * emplois_commerce_transport_services_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_commerce_transport_services_2022,

    ROUND(
        (100.0 * emplois_admin_enseignement_sante_social_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_admin_enseignement_sante_social_2022,

    ROUND(
        (100.0 * emplois_cadres_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_cadres_2022,

    ROUND(
        (100.0 * emplois_ouvriers_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_ouvriers_2022,

    ROUND(
        (100.0 * emplois_employes_2022 / NULLIF(emplois_lieu_travail_2022, 0))::numeric,
        2
    ) AS part_emplois_employes_2022,

    ROUND(
        (100.0 * (chomeurs_15_64_2022 / NULLIF(actifs_15_64_2022, 0)
        - chomeurs_15_64_2016 / NULLIF(actifs_15_64_2016, 0)))::numeric,
        2
    ) AS evol_taux_chomage_2016_2022_points,

    ROUND(
        (100.0 * (emplois_lieu_travail_2022 - emplois_lieu_travail_2016)
        / NULLIF(emplois_lieu_travail_2016, 0))::numeric,
        2
    ) AS evol_emplois_lieu_travail_2016_2022_pct

FROM insee_obs.stg_emploi;


/* ============================================================
   3. Indicateurs diplôme / formation
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_diplome AS
SELECT
    codgeo,

    population_non_scolarisee_15_plus_2022,

    sans_diplome_2022,
    brevet_2022,
    cap_bep_2022,
    bac_2022,
    diplome_superieur_bac_2_2022,
    diplome_superieur_bac_3_4_2022,
    diplome_superieur_bac_5_plus_2022,
    diplomes_superieur_2022,

    ROUND(
        (100.0 * sans_diplome_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0))::numeric,
        2
    ) AS part_sans_diplome_2022,

    ROUND(
        (100.0 * cap_bep_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0))::numeric,
        2
    ) AS part_cap_bep_2022,

    ROUND(
        (100.0 * bac_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0))::numeric,
        2
    ) AS part_bac_2022,

    ROUND(
        (100.0 * diplomes_superieur_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0))::numeric,
        2
    ) AS part_diplomes_superieur_2022,

    ROUND(
        (100.0 * diplome_superieur_bac_5_plus_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0))::numeric,
        2
    ) AS part_bac_5_plus_2022,

    ROUND(
        (100.0 * scolarises_15_17_2022 / NULLIF(population_15_17_2022, 0))::numeric,
        2
    ) AS taux_scolarisation_15_17_2022,

    ROUND(
        (100.0 * scolarises_18_24_2022 / NULLIF(population_18_24_2022, 0))::numeric,
        2
    ) AS taux_scolarisation_18_24_2022,

    ROUND(
        (100.0 * scolarises_25_29_2022 / NULLIF(population_25_29_2022, 0))::numeric,
        2
    ) AS taux_scolarisation_25_29_2022,

    ROUND(
        (
            100.0 * sans_diplome_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0)
            -
            100.0 * sans_diplome_2016 / NULLIF(population_non_scolarisee_15_plus_2016, 0)
        )::numeric,
        2
    ) AS evol_part_sans_diplome_2016_2022_points,

    ROUND(
        (
            100.0 * diplomes_superieur_2022 / NULLIF(population_non_scolarisee_15_plus_2022, 0)
            -
            100.0 * diplomes_superieur_2016 / NULLIF(population_non_scolarisee_15_plus_2016, 0)
        )::numeric,
        2
    ) AS evol_part_diplomes_superieur_2016_2022_points

FROM insee_obs.stg_diplome;


/* ============================================================
   4. Indicateurs logement
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_logement AS
SELECT
    codgeo,

    logements_2022,
    residences_principales_2022,
    residences_secondaires_2022,
    logements_vacants_2022,
    maisons_2022,
    appartements_2022,
    menages_2022,
    population_menages_2022,

    ROUND(
        (100.0 * residences_principales_2022 / NULLIF(logements_2022, 0))::numeric,
        2
    ) AS part_residences_principales_2022,

    ROUND(
        (100.0 * residences_secondaires_2022 / NULLIF(logements_2022, 0))::numeric,
        2
    ) AS part_residences_secondaires_2022,

    ROUND(
        (100.0 * logements_vacants_2022 / NULLIF(logements_2022, 0))::numeric,
        2
    ) AS part_logements_vacants_2022,

    ROUND(
        (100.0 * maisons_2022 / NULLIF(logements_2022, 0))::numeric,
        2
    ) AS part_maisons_2022,

    ROUND(
        (100.0 * appartements_2022 / NULLIF(logements_2022, 0))::numeric,
        2
    ) AS part_appartements_2022,

    ROUND(
        (100.0 * proprietaires_2022 / NULLIF(residences_principales_2022, 0))::numeric,
        2
    ) AS part_proprietaires_2022,

    ROUND(
        (100.0 * locataires_2022 / NULLIF(residences_principales_2022, 0))::numeric,
        2
    ) AS part_locataires_2022,

    ROUND(
        (100.0 * locataires_hlm_2022 / NULLIF(residences_principales_2022, 0))::numeric,
        2
    ) AS part_locataires_hlm_2022,

    ROUND(
        (population_menages_2022 / NULLIF(menages_2022, 0))::numeric,
        2
    ) AS taille_moyenne_menage_logement_2022,

    ROUND(
        (nombre_pieces_residences_principales_2022 / NULLIF(residences_principales_2022, 0))::numeric,
        2
    ) AS nombre_moyen_pieces_residence_principale_2022,

    ROUND(
        (100.0 * menages_avec_voiture_2022 / NULLIF(residences_principales_2022, 0))::numeric,
        2
    ) AS part_menages_avec_voiture_2022,

    ROUND(
        (100.0 * menages_2_voitures_plus_2022 / NULLIF(residences_principales_2022, 0))::numeric,
        2
    ) AS part_menages_2_voitures_plus_2022,

    ROUND(
        (100.0 * (logements_2022 - logements_2016) / NULLIF(logements_2016, 0))::numeric,
        2
    ) AS evol_logements_2016_2022_pct,

    ROUND(
        (100.0 * (logements_vacants_2022 - logements_vacants_2016) / NULLIF(logements_vacants_2016, 0))::numeric,
        2
    ) AS evol_logements_vacants_2016_2022_pct

FROM insee_obs.stg_logement;


/* ============================================================
   5. Indicateurs ménages / familles
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_menages_familles AS
SELECT
    codgeo,

    menages_2022,
    population_menages_2022,
    familles_2022,

    menages_personnes_seules_2022,
    menages_couples_sans_enfant_2022,
    menages_couples_avec_enfant_2022,
    menages_familles_monoparentales_2022,

    familles_monoparentales_2022,
    familles_couples_avec_enfant_2022,
    familles_couples_sans_enfant_2022,

    ROUND(
        (population_menages_2022 / NULLIF(menages_2022, 0))::numeric,
        2
    ) AS taille_moyenne_menage_2022,

    ROUND(
        (100.0 * menages_personnes_seules_2022 / NULLIF(menages_2022, 0))::numeric,
        2
    ) AS part_menages_personnes_seules_2022,

    ROUND(
        (100.0 * menages_couples_sans_enfant_2022 / NULLIF(menages_2022, 0))::numeric,
        2
    ) AS part_menages_couples_sans_enfant_2022,

    ROUND(
        (100.0 * menages_couples_avec_enfant_2022 / NULLIF(menages_2022, 0))::numeric,
        2
    ) AS part_menages_couples_avec_enfant_2022,

    ROUND(
        (100.0 * menages_familles_monoparentales_2022 / NULLIF(menages_2022, 0))::numeric,
        2
    ) AS part_menages_familles_monoparentales_2022,

    ROUND(
        (100.0 * familles_monoparentales_2022 / NULLIF(familles_2022, 0))::numeric,
        2
    ) AS part_familles_monoparentales_2022,

    ROUND(
        (100.0 * familles_recomposees_2022 / NULLIF(familles_2022, 0))::numeric,
        2
    ) AS part_familles_recomposees_2022,

    ROUND(
        (100.0 * personnes_seules_80_plus_2022 / NULLIF(population_80_plus_2022, 0))::numeric,
        2
    ) AS part_80_plus_seuls_2022,

    ROUND(
        (100.0 * (menages_personnes_seules_2022 - menages_personnes_seules_2016)
        / NULLIF(menages_personnes_seules_2016, 0))::numeric,
        2
    ) AS evol_menages_personnes_seules_2016_2022_pct,

    ROUND(
        (100.0 * (familles_monoparentales_2022 - familles_monoparentales_2016)
        / NULLIF(familles_monoparentales_2016, 0))::numeric,
        2
    ) AS evol_familles_monoparentales_2016_2022_pct

FROM insee_obs.stg_menages_familles;


/* ============================================================
   6. Indicateurs caractéristiques de l'emploi
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_caracteristiques_emploi AS
SELECT
    codgeo,

    actifs_occupes_15_plus_2022,
    salaries_15_plus_2022,
    non_salaries_15_plus_2022,

    ROUND(
        (100.0 * salaries_15_plus_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_salaries_2022,

    ROUND(
        (100.0 * non_salaries_15_plus_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_non_salaries_2022,

    ROUND(
        (100.0 * actifs_occupes_temps_partiel_15_plus_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_temps_partiel_2022,

    ROUND(
        (100.0 * salaries_cdi_2022 / NULLIF(salaries_15_plus_2022, 0))::numeric,
        2
    ) AS part_cdi_2022,

    ROUND(
        (100.0 * salaries_cdd_2022 / NULLIF(salaries_15_plus_2022, 0))::numeric,
        2
    ) AS part_cdd_2022,

    ROUND(
        (100.0 * salaries_interim_2022 / NULLIF(salaries_15_plus_2022, 0))::numeric,
        2
    ) AS part_interim_2022,

    ROUND(
        (100.0 * salaries_apprentis_2022 / NULLIF(salaries_15_plus_2022, 0))::numeric,
        2
    ) AS part_apprentis_2022,

    ROUND(
        (100.0 * actifs_occupes_travaillant_commune_residence_2022
        / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_travail_commune_residence_2022,

    ROUND(
        (100.0 * actifs_occupes_travaillant_hors_commune_residence_2022
        / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_travail_hors_commune_residence_2022,

    ROUND(
        (100.0 * transport_voiture_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_transport_voiture_2022,

    ROUND(
        (100.0 * transport_commun_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_transport_commun_2022,

    ROUND(
        (100.0 * transport_velo_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_transport_velo_2022,

    ROUND(
        (100.0 * transport_marche_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_transport_marche_2022,

    ROUND(
        (100.0 * transport_pas_de_deplacement_2022 / NULLIF(actifs_occupes_15_plus_2022, 0))::numeric,
        2
    ) AS part_pas_de_deplacement_2022

FROM insee_obs.stg_caracteristiques_emploi;


/* ============================================================
   7. Indicateurs revenus
   ============================================================ */

CREATE OR REPLACE VIEW insee_obs.ind_revenu AS
SELECT
    codgeo,

    niveau_vie_median_euros,
    niveau_vie_1er_decile_euros,
    niveau_vie_9e_decile_euros,
    rapport_interdecile_d9_d1,
    taux_pauvrete_60_pct,

    nombre_menages,
    nombre_personnes,
    nombre_unites_consommation,

    part_menages_imposes_pct,
    part_revenus_activite_pct,
    part_salaires_pct,

    -- Nom harmonisé dans la vue SQL
    s_ei_di_n_sal AS part_revenus_non_salaries_pct,

    part_indemnites_chomage_pct,
    part_pensions_retraites_rentes_pct,
    part_prestations_sociales_pct,
    part_revenus_patrimoine_autres_pct,
    part_impots_directs_pct

FROM insee_obs.stg_revenu;