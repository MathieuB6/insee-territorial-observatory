/*
Objectif :
Créer la vue finale de l'observatoire territorial.

Cette vue rassemble les principaux indicateurs issus des différentes thématiques :
- population
- emploi
- diplôme
- logement
- ménages / familles
- caractéristiques de l'emploi
- revenus

Elle constitue la table analytique centrale du projet.
*/

CREATE OR REPLACE VIEW insee_obs.v_commune_observatory AS
SELECT
    p.codgeo,

    /* Population */
    p.population_2022,
    p.population_2016,
    p.population_2011,
    p.evol_population_2016_2022_pct,
    p.evol_population_2011_2022_pct,
    p.part_0_14_ans_2022,
    p.part_15_29_ans_2022,
    p.part_moins_30_ans_2022,
    p.part_60_ans_plus_2022,
    p.part_75_ans_plus_2022,
    p.indice_vieillissement_simplifie,
    p.part_femmes_2022,
    p.part_hommes_2022,

    /* Emploi / activité */
    e.population_15_64_2022,
    e.actifs_15_64_2022,
    e.actifs_occupes_15_64_2022,
    e.chomeurs_15_64_2022,
    e.taux_activite_2022,
    e.taux_emploi_2022,
    e.taux_chomage_2022,
    e.taux_chomage_jeunes_2022,
    e.taux_chomage_55_64_2022,
    e.part_inactifs_15_64_2022,
    e.part_etudiants_15_64_2022,
    e.part_retraites_15_64_2022,
    e.emplois_lieu_travail_2022,
    e.part_emplois_salaries_2022,
    e.part_emplois_non_salaries_2022,
    e.part_emplois_agriculture_2022,
    e.part_emplois_industrie_2022,
    e.part_emplois_construction_2022,
    e.part_emplois_commerce_transport_services_2022,
    e.part_emplois_admin_enseignement_sante_social_2022,
    e.part_emplois_cadres_2022,
    e.part_emplois_ouvriers_2022,
    e.part_emplois_employes_2022,
    e.evol_taux_chomage_2016_2022_points,
    e.evol_emplois_lieu_travail_2016_2022_pct,

    /* Diplômes / formation */
    d.population_non_scolarisee_15_plus_2022,
    d.part_sans_diplome_2022,
    d.part_cap_bep_2022,
    d.part_bac_2022,
    d.part_diplomes_superieur_2022,
    d.part_bac_5_plus_2022,
    d.taux_scolarisation_15_17_2022,
    d.taux_scolarisation_18_24_2022,
    d.taux_scolarisation_25_29_2022,
    d.evol_part_sans_diplome_2016_2022_points,
    d.evol_part_diplomes_superieur_2016_2022_points,

    /* Logement */
    l.logements_2022,
    l.residences_principales_2022,
    l.residences_secondaires_2022,
    l.logements_vacants_2022,
    l.maisons_2022,
    l.appartements_2022,
    l.part_residences_principales_2022,
    l.part_residences_secondaires_2022,
    l.part_logements_vacants_2022,
    l.part_maisons_2022,
    l.part_appartements_2022,
    l.part_proprietaires_2022,
    l.part_locataires_2022,
    l.part_locataires_hlm_2022,
    l.taille_moyenne_menage_logement_2022,
    l.nombre_moyen_pieces_residence_principale_2022,
    l.part_menages_avec_voiture_2022,
    l.part_menages_2_voitures_plus_2022,
    l.evol_logements_2016_2022_pct,
    l.evol_logements_vacants_2016_2022_pct,

    /* Ménages / familles */
    m.menages_2022,
    m.population_menages_2022,
    m.familles_2022,
    m.taille_moyenne_menage_2022,
    m.part_menages_personnes_seules_2022,
    m.part_menages_couples_sans_enfant_2022,
    m.part_menages_couples_avec_enfant_2022,
    m.part_menages_familles_monoparentales_2022,
    m.part_familles_monoparentales_2022,
    m.part_familles_recomposees_2022,
    m.part_80_plus_seuls_2022,
    m.evol_menages_personnes_seules_2016_2022_pct,
    m.evol_familles_monoparentales_2016_2022_pct,

    /* Caractéristiques de l'emploi */
    ce.part_salaries_2022,
    ce.part_non_salaries_2022,
    ce.part_temps_partiel_2022,
    ce.part_cdi_2022,
    ce.part_cdd_2022,
    ce.part_interim_2022,
    ce.part_apprentis_2022,
    ce.part_travail_commune_residence_2022,
    ce.part_travail_hors_commune_residence_2022,
    ce.part_transport_voiture_2022,
    ce.part_transport_commun_2022,
    ce.part_transport_velo_2022,
    ce.part_transport_marche_2022,
    ce.part_pas_de_deplacement_2022,

    /* Revenus */
    r.niveau_vie_median_euros,
    r.niveau_vie_1er_decile_euros,
    r.niveau_vie_9e_decile_euros,
    r.rapport_interdecile_d9_d1,
    r.taux_pauvrete_60_pct,
    r.part_menages_imposes_pct,
    r.part_revenus_activite_pct,
    r.part_salaires_pct,
    r.part_revenus_non_salaries_pct,
    r.part_indemnites_chomage_pct,
    r.part_pensions_retraites_rentes_pct,
    r.part_prestations_sociales_pct,
    r.part_revenus_patrimoine_autres_pct,
    r.part_impots_directs_pct

FROM insee_obs.ind_population p
LEFT JOIN insee_obs.ind_emploi e
    ON p.codgeo = e.codgeo
LEFT JOIN insee_obs.ind_diplome d
    ON p.codgeo = d.codgeo
LEFT JOIN insee_obs.ind_logement l
    ON p.codgeo = l.codgeo
LEFT JOIN insee_obs.ind_menages_familles m
    ON p.codgeo = m.codgeo
LEFT JOIN insee_obs.ind_caracteristiques_emploi ce
    ON p.codgeo = ce.codgeo
LEFT JOIN insee_obs.ind_revenu r
    ON p.codgeo = r.codgeo;