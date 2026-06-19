library(readr)
library(dplyr)
library(janitor)

# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

# Fichier brut INSEE
input_file <- file.path(raw_dir, "base-cc-logement-2022.csv")

# Fonction de conversion numérique robuste
to_num <- function(x) {
  parse_number(
    as.character(x),
    locale = locale(decimal_mark = ",", grouping_mark = " ")
  )
}

# 1. Lecture du fichier en texte pour préserver les codes communes
logement_raw <- read_csv2(
  input_file,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE,
  guess_max = 100000
) |>
  clean_names()

# 2. Sélection et renommage des variables utiles
logement_prepared <- logement_raw |>
  transmute(
    codgeo = as.character(codgeo),
    
    # Parc de logements 2022
    logements_2022 = to_num(p22_log),
    residences_principales_2022 = to_num(p22_rp),
    residences_secondaires_2022 = to_num(p22_rsecocc),
    logements_vacants_2022 = to_num(p22_logvac),
    
    # Type de logement 2022
    maisons_2022 = to_num(p22_maison),
    appartements_2022 = to_num(p22_appart),
    
    # Taille des résidences principales 2022
    residences_principales_1_piece_2022 = to_num(p22_rp_1p),
    residences_principales_2_pieces_2022 = to_num(p22_rp_2p),
    residences_principales_3_pieces_2022 = to_num(p22_rp_3p),
    residences_principales_4_pieces_2022 = to_num(p22_rp_4p),
    residences_principales_5_pieces_plus_2022 = to_num(p22_rp_5pp),
    nombre_pieces_residences_principales_2022 = to_num(p22_nbpi_rp),
    
    # Ménages et population des ménages 2022
    menages_2022 = to_num(p22_men),
    population_menages_2022 = to_num(p22_pmen),
    
    # Ancienneté d'emménagement des ménages 2022
    menages_emmenagement_0_2_ans_2022 = to_num(p22_men_anem0002),
    menages_emmenagement_2_4_ans_2022 = to_num(p22_men_anem0204),
    menages_emmenagement_5_9_ans_2022 = to_num(p22_men_anem0509),
    menages_emmenagement_10_ans_plus_2022 = to_num(p22_men_anem10p),
    menages_emmenagement_30_ans_plus_2022 = to_num(p22_men_anem30p),
    
    # Statut d'occupation 2022
    proprietaires_2022 = to_num(p22_rp_prop),
    locataires_2022 = to_num(p22_rp_loc),
    locataires_hlm_2022 = to_num(p22_rp_lochlmv),
    loges_gratuitement_2022 = to_num(p22_rp_grat),
    
    # Population selon statut d'occupation 2022
    personnes_residences_principales_2022 = to_num(p22_nper_rp),
    personnes_proprietaires_2022 = to_num(p22_nper_rp_prop),
    personnes_locataires_2022 = to_num(p22_nper_rp_loc),
    personnes_locataires_hlm_2022 = to_num(p22_nper_rp_lochlmv),
    personnes_logees_gratuitement_2022 = to_num(p22_nper_rp_grat),
    
    # Équipement automobile 2022
    menages_avec_voiture_2022 = to_num(p22_rp_voit1p),
    menages_1_voiture_2022 = to_num(p22_rp_voit1),
    menages_2_voitures_plus_2022 = to_num(p22_rp_voit2p),
    menages_avec_garage_parking_2022 = to_num(p22_rp_garl),
    
    # Comparaison 2016
    logements_2016 = to_num(p16_log),
    residences_principales_2016 = to_num(p16_rp),
    residences_secondaires_2016 = to_num(p16_rsecocc),
    logements_vacants_2016 = to_num(p16_logvac),
    maisons_2016 = to_num(p16_maison),
    appartements_2016 = to_num(p16_appart),
    menages_2016 = to_num(p16_men),
    population_menages_2016 = to_num(p16_pmen),
    proprietaires_2016 = to_num(p16_rp_prop),
    locataires_2016 = to_num(p16_rp_loc),
    locataires_hlm_2016 = to_num(p16_rp_lochlmv),
    loges_gratuitement_2016 = to_num(p16_rp_grat),
    
    # Comparaison 2011, seulement les indicateurs principaux
    logements_2011 = to_num(p11_log),
    residences_principales_2011 = to_num(p11_rp),
    residences_secondaires_2011 = to_num(p11_rsecocc),
    logements_vacants_2011 = to_num(p11_logvac),
    maisons_2011 = to_num(p11_maison),
    appartements_2011 = to_num(p11_appart),
    menages_2011 = to_num(p11_men),
    population_menages_2011 = to_num(p11_pmen),
    proprietaires_2011 = to_num(p11_rp_prop),
    locataires_2011 = to_num(p11_rp_loc),
    locataires_hlm_2011 = to_num(p11_rp_lochlmv),
    loges_gratuitement_2011 = to_num(p11_rp_grat)
  )

# 3. Contrôles rapides
cat("Nombre de communes :", nrow(logement_prepared), "\n")
cat("Nombre de codes communes distincts :", n_distinct(logement_prepared$codgeo), "\n")

cat("\nValeurs manquantes logements 2022 :\n")
print(sum(is.na(logement_prepared$logements_2022)))

cat("\nValeurs manquantes résidences principales 2022 :\n")
print(sum(is.na(logement_prepared$residences_principales_2022)))

cat("\nAperçu du fichier préparé :\n")
print(head(logement_prepared, 10))

# 4. Export du fichier propre
output_file <- file.path(prepared_dir, "cc_logement_2022.csv")

write_csv2(
  logement_prepared,
  output_file,
  na = ""
)

cat("\nFichier créé :", output_file, "\n")