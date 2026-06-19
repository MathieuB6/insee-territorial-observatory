library(readr)
library(dplyr)
library(janitor)

project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"
raw_dir <- file.path(project_dir, "data/raw")

list.files(raw_dir)


# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

# Fichier brut INSEE
input_file <- file.path(raw_dir, "base-cc-caract_emp-2022.CSV")

# Fonction de conversion numérique robuste
to_num <- function(x) {
  parse_number(
    as.character(x),
    locale = locale(decimal_mark = ",", grouping_mark = " ")
  )
}

# 1. Lecture du fichier en texte pour préserver les codes communes
caract_emp_raw <- read_csv2(
  input_file,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE,
  guess_max = 100000
) |>
  clean_names()

# 2. Sélection et renommage des variables utiles
caract_emp_prepared <- caract_emp_raw |>
  transmute(
    codgeo = as.character(codgeo),
    
    # Statut d'emploi - 2022
    actifs_occupes_15_plus_2022 = to_num(p22_actocc15p),
    salaries_15_plus_2022 = to_num(p22_sal15p),
    non_salaries_15_plus_2022 = to_num(p22_nsal15p),
    
    actifs_occupes_temps_partiel_15_plus_2022 = to_num(p22_actocc15p_tp),
    salaries_temps_partiel_15_plus_2022 = to_num(p22_sal15p_tp),
    non_salaries_temps_partiel_15_plus_2022 = to_num(p22_nsal15p_tp),
    
    # Contrats salariés - 2022
    # Total reconstruit hommes + femmes
    salaries_cdi_2022 =
      to_num(p22_hsal15p_cdi) + to_num(p22_fsal15p_cdi),
    
    salaries_cdd_2022 =
      to_num(p22_hsal15p_cdd) + to_num(p22_fsal15p_cdd),
    
    salaries_interim_2022 =
      to_num(p22_hsal15p_interim) + to_num(p22_fsal15p_interim),
    
    salaries_emplois_aides_2022 =
      to_num(p22_hsal15p_empaid) + to_num(p22_fsal15p_empaid),
    
    salaries_apprentis_2022 =
      to_num(p22_hsal15p_appr) + to_num(p22_fsal15p_appr),
    
    # Non salariés - 2022
    non_salaries_independants_2022 =
      to_num(p22_hnsal15p_indep) + to_num(p22_fnsal15p_indep),
    
    non_salaries_employeurs_2022 =
      to_num(p22_hnsal15p_employ) + to_num(p22_fnsal15p_employ),
    
    non_salaries_aides_familiaux_2022 =
      to_num(p22_hnsal15p_aidfam) + to_num(p22_fnsal15p_aidfam),
    
    # Temps partiel par sexe - 2022
    salaries_hommes_temps_partiel_2022 = to_num(p22_hsal15p_tp),
    salaries_femmes_temps_partiel_2022 = to_num(p22_fsal15p_tp),
    
    # Lieu de travail - 2022
    actifs_occupes_travaillant_commune_residence_2022 = to_num(p22_actocc15p_ilt1),
    actifs_occupes_travaillant_hors_commune_residence_2022 = to_num(p22_actocc15p_ilt2p),
    actifs_occupes_travaillant_autre_commune_meme_departement_2022 = to_num(p22_actocc15p_ilt2),
    actifs_occupes_travaillant_autre_departement_meme_region_2022 = to_num(p22_actocc15p_ilt3),
    actifs_occupes_travaillant_autre_region_2022 = to_num(p22_actocc15p_ilt4),
    actifs_occupes_travaillant_hors_france_metropolitaine_2022 = to_num(p22_actocc15p_ilt5),
    
    # Mode de transport domicile-travail - 2022
    transport_pas_de_deplacement_2022 = to_num(p22_actocc15p_pastrans),
    transport_marche_2022 = to_num(p22_actocc15p_marche),
    transport_velo_2022 = to_num(p22_actocc15p_velo),
    transport_deux_roues_motorise_2022 = to_num(p22_actocc15p_2rouesmot),
    transport_voiture_2022 = to_num(p22_actocc15p_voiture),
    transport_commun_2022 = to_num(p22_actocc15p_commun),
    
    # Comparaison 2016
    actifs_occupes_15_plus_2016 = to_num(p16_actocc15p),
    salaries_15_plus_2016 = to_num(p16_sal15p),
    non_salaries_15_plus_2016 = to_num(p16_nsal15p),
    
    actifs_occupes_temps_partiel_15_plus_2016 = to_num(p16_actocc15p_tp),
    salaries_temps_partiel_15_plus_2016 = to_num(p16_sal15p_tp),
    non_salaries_temps_partiel_15_plus_2016 = to_num(p16_nsal15p_tp),
    
    salaries_cdi_2016 =
      to_num(p16_hsal15p_cdi) + to_num(p16_fsal15p_cdi),
    
    salaries_cdd_2016 =
      to_num(p16_hsal15p_cdd) + to_num(p16_fsal15p_cdd),
    
    salaries_interim_2016 =
      to_num(p16_hsal15p_interim) + to_num(p16_fsal15p_interim),
    
    salaries_emplois_aides_2016 =
      to_num(p16_hsal15p_empaid) + to_num(p16_fsal15p_empaid),
    
    salaries_apprentis_2016 =
      to_num(p16_hsal15p_appr) + to_num(p16_fsal15p_appr),
    
    non_salaries_independants_2016 =
      to_num(p16_hnsal15p_indep) + to_num(p16_fnsal15p_indep),
    
    non_salaries_employeurs_2016 =
      to_num(p16_hnsal15p_employ) + to_num(p16_fnsal15p_employ),
    
    non_salaries_aides_familiaux_2016 =
      to_num(p16_hnsal15p_aidfam) + to_num(p16_fnsal15p_aidfam),
    
    actifs_occupes_travaillant_commune_residence_2016 = to_num(p16_actocc15p_ilt1),
    actifs_occupes_travaillant_hors_commune_residence_2016 = to_num(p16_actocc15p_ilt2p),
    
    transport_pas_de_deplacement_2016 = to_num(p16_actocc15p_pastrans),
    transport_marche_2016 = to_num(p16_actocc15p_marche),
    transport_deux_roues_2016 = to_num(p16_actocc15p_2roues),
    transport_voiture_2016 = to_num(p16_actocc15p_voiture),
    transport_commun_2016 = to_num(p16_actocc15p_commun)
  )

# 3. Contrôles rapides
cat("Nombre de communes :", nrow(caract_emp_prepared), "\n")
cat("Nombre de codes communes distincts :", n_distinct(caract_emp_prepared$codgeo), "\n")

cat("\nValeurs manquantes actifs occupés 15+ 2022 :\n")
print(sum(is.na(caract_emp_prepared$actifs_occupes_15_plus_2022)))

cat("\nValeurs manquantes salariés 15+ 2022 :\n")
print(sum(is.na(caract_emp_prepared$salaries_15_plus_2022)))

cat("\nAperçu du fichier préparé :\n")
print(head(caract_emp_prepared, 10))

# 4. Export du fichier propre
output_file <- file.path(prepared_dir, "cc_caracteristiques_emploi_2022.csv")

write_csv2(
  caract_emp_prepared,
  output_file,
  na = ""
)

cat("\nFichier créé :", output_file, "\n")