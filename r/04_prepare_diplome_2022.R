library(readr)
library(dplyr)
library(janitor)

# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

# Fichier brut INSEE
input_file <- file.path(raw_dir, "base-cc-diplomes-formation-2022.csv")

# Fonction de conversion numérique robuste
to_num <- function(x) {
  parse_number(
    as.character(x),
    locale = locale(decimal_mark = ",", grouping_mark = " ")
  )
}

# 1. Lecture du fichier en texte pour préserver les codes communes
diplome_raw <- read_csv2(
  input_file,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE,
  guess_max = 100000
) |>
  clean_names()

# 2. Sélection et renommage des variables utiles
diplome_prepared <- diplome_raw |>
  transmute(
    codgeo = as.character(codgeo),
    
    # Population par âge scolaire - 2022
    population_2_5_2022 = to_num(p22_pop0205),
    population_6_10_2022 = to_num(p22_pop0610),
    population_11_14_2022 = to_num(p22_pop1114),
    population_15_17_2022 = to_num(p22_pop1517),
    population_18_24_2022 = to_num(p22_pop1824),
    population_25_29_2022 = to_num(p22_pop2529),
    population_30_plus_2022 = to_num(p22_pop30p),
    
    # Population scolarisée - 2022
    scolarises_2_5_2022 = to_num(p22_scol0205),
    scolarises_6_10_2022 = to_num(p22_scol0610),
    scolarises_11_14_2022 = to_num(p22_scol1114),
    scolarises_15_17_2022 = to_num(p22_scol1517),
    scolarises_18_24_2022 = to_num(p22_scol1824),
    scolarises_25_29_2022 = to_num(p22_scol2529),
    scolarises_30_plus_2022 = to_num(p22_scol30p),
    
    # Diplômes des 15 ans ou plus non scolarisés - 2022
    population_non_scolarisee_15_plus_2022 = to_num(p22_nscol15p),
    sans_diplome_2022 = to_num(p22_nscol15p_diplmin),
    brevet_2022 = to_num(p22_nscol15p_bepc),
    cap_bep_2022 = to_num(p22_nscol15p_capbep),
    bac_2022 = to_num(p22_nscol15p_bac),
    diplome_superieur_bac_2_2022 = to_num(p22_nscol15p_sup2),
    diplome_superieur_bac_3_4_2022 = to_num(p22_nscol15p_sup34),
    diplome_superieur_bac_5_plus_2022 = to_num(p22_nscol15p_sup5),
    
    # Version agrégée utile pour SQL
    diplomes_superieur_2022 =
      to_num(p22_nscol15p_sup2) +
      to_num(p22_nscol15p_sup34) +
      to_num(p22_nscol15p_sup5),
    
    # Données comparables 2016
    population_non_scolarisee_15_plus_2016 = to_num(p16_nscol15p),
    sans_diplome_2016 = to_num(p16_nscol15p_diplmin),
    cap_bep_2016 = to_num(p16_nscol15p_capbep),
    bac_2016 = to_num(p16_nscol15p_bac),
    diplomes_superieur_2016 = to_num(p16_nscol15p_sup),
    
    # Scolarisation 2016, pour comparaison simple
    population_15_17_2016 = to_num(p16_pop1517),
    population_18_24_2016 = to_num(p16_pop1824),
    population_25_29_2016 = to_num(p16_pop2529),
    
    scolarises_15_17_2016 = to_num(p16_scol1517),
    scolarises_18_24_2016 = to_num(p16_scol1824),
    scolarises_25_29_2016 = to_num(p16_scol2529)
  )

# 3. Contrôles rapides
cat("Nombre de communes :", nrow(diplome_prepared), "\n")
cat("Nombre de codes communes distincts :", n_distinct(diplome_prepared$codgeo), "\n")

cat("\nValeurs manquantes population non scolarisée 15+ 2022 :\n")
print(sum(is.na(diplome_prepared$population_non_scolarisee_15_plus_2022)))

cat("\nValeurs manquantes diplômés supérieur 2022 :\n")
print(sum(is.na(diplome_prepared$diplomes_superieur_2022)))

cat("\nAperçu du fichier préparé :\n")
print(head(diplome_prepared, 10))

# 4. Export du fichier propre
output_file <- file.path(prepared_dir, "cc_diplome_2022.csv")

write_csv2(
  diplome_prepared,
  output_file,
  na = ""
)

cat("\nFichier créé :", output_file, "\n")