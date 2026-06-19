library(readr)
library(dplyr)
library(janitor)

# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

# Fichier brut INSEE
input_file <- file.path(raw_dir, "base-cc-emploi-pop-active-2022.csv")

# Fonction de conversion numérique robuste
to_num <- function(x) {
  parse_number(
    as.character(x),
    locale = locale(decimal_mark = ",", grouping_mark = " ")
  )
}

# 1. Lecture du fichier en texte pour préserver les codes communes
emploi_raw <- read_csv2(
  input_file,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE,
  guess_max = 100000
) |>
  clean_names()

# 2. Sélection et renommage des variables utiles
emploi_prepared <- emploi_raw |>
  transmute(
    codgeo = as.character(codgeo),
    
    # Population active 2022
    population_15_64_2022 = to_num(p22_pop1564),
    population_15_24_2022 = to_num(p22_pop1524),
    population_25_54_2022 = to_num(p22_pop2554),
    population_55_64_2022 = to_num(p22_pop5564),
    
    actifs_15_64_2022 = to_num(p22_act1564),
    actifs_15_24_2022 = to_num(p22_act1524),
    actifs_25_54_2022 = to_num(p22_act2554),
    actifs_55_64_2022 = to_num(p22_act5564),
    
    actifs_occupes_15_64_2022 = to_num(p22_actocc1564),
    actifs_occupes_15_24_2022 = to_num(p22_actocc1524),
    actifs_occupes_25_54_2022 = to_num(p22_actocc2554),
    actifs_occupes_55_64_2022 = to_num(p22_actocc5564),
    
    chomeurs_15_64_2022 = to_num(p22_chom1564),
    chomeurs_15_24_2022 = to_num(p22_chom1524),
    chomeurs_25_54_2022 = to_num(p22_chom2554),
    chomeurs_55_64_2022 = to_num(p22_chom5564),
    
    inactifs_15_64_2022 = to_num(p22_inact1564),
    etudiants_15_64_2022 = to_num(p22_etud1564),
    retraites_15_64_2022 = to_num(p22_retr1564),
    autres_inactifs_15_64_2022 = to_num(p22_ainact1564),
    
    # Hommes / femmes 2022
    hommes_15_64_2022 = to_num(p22_h1564),
    femmes_15_64_2022 = to_num(p22_f1564),
    
    hommes_actifs_15_64_2022 = to_num(p22_hact1564),
    femmes_actives_15_64_2022 = to_num(p22_fact1564),
    
    hommes_chomeurs_15_64_2022 = to_num(p22_hchom1564),
    femmes_chomeuses_15_64_2022 = to_num(p22_fchom1564),
    
    hommes_actifs_occupes_15_64_2022 = to_num(p22_hactocc1564),
    femmes_actives_occupees_15_64_2022 = to_num(p22_factocc1564),
    
    # Emploi au lieu de travail 2022
    emplois_lieu_travail_2022 = to_num(p22_emplt),
    actifs_occupes_15p_2022 = to_num(p22_actocc),
    population_15p_2022 = to_num(p22_pop15p),
    actifs_15p_2022 = to_num(p22_act15p),
    
    emplois_salaries_2022 = to_num(p22_emplt_sal),
    emplois_salaries_femmes_2022 = to_num(p22_emplt_fsal),
    emplois_salaries_temps_partiel_2022 = to_num(p22_emplt_saltp),
    
    emplois_non_salaries_2022 = to_num(p22_emplt_nsal),
    emplois_non_salaries_femmes_2022 = to_num(p22_emplt_fnsal),
    emplois_non_salaries_temps_partiel_2022 = to_num(p22_emplt_nsaltp),
    
    # Emploi par grands secteurs 2022
    emplois_agriculture_2022 = to_num(c22_emplt_agri),
    emplois_industrie_2022 = to_num(c22_emplt_indus),
    emplois_construction_2022 = to_num(c22_emplt_const),
    emplois_commerce_transport_services_2022 = to_num(c22_emplt_cts),
    emplois_admin_enseignement_sante_social_2022 = to_num(c22_emplt_apesas),
    
    # Catégories socio-professionnelles au lieu de travail 2022
    # On garde ces colonnes, mais on les interprétera plus tard avec prudence.
    emplois_agriculteurs_2022 = to_num(c22_emplt_gs1),
    emplois_artisans_commercants_chefs_entreprise_2022 = to_num(c22_emplt_gs2),
    emplois_cadres_2022 = to_num(c22_emplt_gs3),
    emplois_professions_intermediaires_2022 = to_num(c22_emplt_gs4),
    emplois_employes_2022 = to_num(c22_emplt_gs5),
    emplois_ouvriers_2022 = to_num(c22_emplt_gs6),
    
    # Données comparables 2016
    population_15_64_2016 = to_num(p16_pop1564),
    actifs_15_64_2016 = to_num(p16_act1564),
    actifs_occupes_15_64_2016 = to_num(p16_actocc1564),
    chomeurs_15_64_2016 = to_num(p16_chom1564),
    inactifs_15_64_2016 = to_num(p16_inact1564),
    etudiants_15_64_2016 = to_num(p16_etud1564),
    retraites_15_64_2016 = to_num(p16_retr1564),
    autres_inactifs_15_64_2016 = to_num(p16_ainact1564),
    
    emplois_lieu_travail_2016 = to_num(p16_emplt),
    emplois_salaries_2016 = to_num(p16_emplt_sal),
    emplois_non_salaries_2016 = to_num(p16_emplt_nsal)
  )

# 3. Contrôles rapides
cat("Nombre de communes :", nrow(emploi_prepared), "\n")
cat("Nombre de codes communes distincts :", n_distinct(emploi_prepared$codgeo), "\n")

cat("\nValeurs manquantes population 15-64 ans 2022 :\n")
print(sum(is.na(emploi_prepared$population_15_64_2022)))

cat("\nValeurs manquantes actifs 15-64 ans 2022 :\n")
print(sum(is.na(emploi_prepared$actifs_15_64_2022)))

cat("\nAperçu du fichier préparé :\n")
print(head(emploi_prepared, 10))

# 4. Export du fichier propre
output_file <- file.path(prepared_dir, "cc_emploi_2022.csv")

write_csv2(
  emploi_prepared,
  output_file,
  na = ""
)

cat("\nFichier créé :", output_file, "\n")