library(readr)
library(dplyr)
library(purrr)
library(janitor)
library(tibble)

# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

prepared_dir <- file.path(project_dir, "data/prepared")
documentation_dir <- file.path(project_dir, "documentation")

dir.create(documentation_dir, recursive = TRUE, showWarnings = FALSE)

# Fichiers préparés attendus
expected_files <- c(
  "cc_population_2022.csv",
  "cc_emploi_2022.csv",
  "cc_diplome_2022.csv",
  "cc_logement_2022.csv",
  "cc_menages_familles_2022.csv",
  "cc_caracteristiques_emploi_2022.csv",
  "cc_revenu_com_2021.csv"
)

expected_paths <- file.path(prepared_dir, expected_files)

# 1. Vérification existence des fichiers
files_check <- tibble(
  file_name = expected_files,
  file_path = expected_paths,
  exists = file.exists(expected_paths)
)

cat("\n=== Vérification existence des fichiers ===\n")
print(files_check)

missing_files <- files_check |>
  filter(!exists)

if (nrow(missing_files) > 0) {
  stop(
    paste(
      "Fichiers manquants dans data/prepared :",
      paste(missing_files$file_name, collapse = ", ")
    )
  )
}

# 2. Fonction de lecture
read_prepared_file <- function(file_path) {
  read_csv2(
    file_path,
    col_types = cols(.default = col_character()),
    locale = locale(encoding = "UTF-8"),
    show_col_types = FALSE,
    guess_max = 100000
  ) |>
    clean_names()
}

# 3. Fonction d'audit d'un fichier
audit_file <- function(file_name) {
  file_path <- file.path(prepared_dir, file_name)
  
  df <- read_prepared_file(file_path)
  
  has_codgeo <- "codgeo" %in% names(df)
  
  if (!has_codgeo) {
    return(tibble(
      file_name = file_name,
      nb_rows = nrow(df),
      nb_columns = ncol(df),
      has_codgeo = FALSE,
      nb_codgeo_distinct = NA_integer_,
      nb_codgeo_missing = NA_integer_,
      nb_duplicate_codgeo = NA_integer_
    ))
  }
  
  df <- df |>
    mutate(codgeo = as.character(codgeo))
  
  tibble(
    file_name = file_name,
    nb_rows = nrow(df),
    nb_columns = ncol(df),
    has_codgeo = TRUE,
    nb_codgeo_distinct = n_distinct(df$codgeo),
    nb_codgeo_missing = sum(is.na(df$codgeo) | df$codgeo == ""),
    nb_duplicate_codgeo = nrow(df) - n_distinct(df$codgeo)
  )
}

# 4. Audit global
audit_results <- map_dfr(expected_files, audit_file)

cat("\n=== Audit global des fichiers préparés ===\n")
print(audit_results)

write_csv2(
  audit_results,
  file.path(documentation_dir, "prepared_files_audit.csv"),
  na = ""
)

# 5. Vérification des doublons détaillés
cat("\n=== Doublons éventuels par fichier ===\n")

for (file_name in expected_files) {
  df <- read_prepared_file(file.path(prepared_dir, file_name))
  
  if ("codgeo" %in% names(df)) {
    duplicates <- df |>
      count(codgeo, name = "nb_lignes") |>
      filter(nb_lignes > 1)
    
    cat("\n", file_name, "\n", sep = "")
    
    if (nrow(duplicates) == 0) {
      cat("Aucun doublon sur codgeo.\n")
    } else {
      print(duplicates)
    }
  }
}

# 6. Vérification de couverture par rapport au fichier population
population_ref <- read_prepared_file(
  file.path(prepared_dir, "cc_population_2022.csv")
) |>
  select(codgeo) |>
  distinct()

check_coverage <- function(file_name) {
  df <- read_prepared_file(file.path(prepared_dir, file_name)) |>
    select(codgeo) |>
    distinct()
  
  missing_in_file <- population_ref |>
    anti_join(df, by = "codgeo")
  
  extra_in_file <- df |>
    anti_join(population_ref, by = "codgeo")
  
  tibble(
    file_name = file_name,
    communes_reference_population = nrow(population_ref),
    communes_in_file = nrow(df),
    communes_missing_vs_population = nrow(missing_in_file),
    communes_extra_vs_population = nrow(extra_in_file)
  )
}

coverage_results <- map_dfr(
  expected_files[expected_files != "cc_population_2022.csv"],
  check_coverage
)

cat("\n=== Couverture par rapport au fichier population ===\n")
print(coverage_results)

write_csv2(
  coverage_results,
  file.path(documentation_dir, "prepared_files_coverage_check.csv"),
  na = ""
)

# 7. Inventaire des colonnes
columns_inventory <- map_dfr(expected_files, function(file_name) {
  df <- read_prepared_file(file.path(prepared_dir, file_name))
  
  tibble(
    file_name = file_name,
    column_position = seq_along(names(df)),
    column_name = names(df)
  )
})

write_csv2(
  columns_inventory,
  file.path(documentation_dir, "prepared_files_columns_inventory.csv"),
  na = ""
)

cat("\n=== Fichiers de contrôle créés ===\n")
cat(file.path(documentation_dir, "prepared_files_audit.csv"), "\n")
cat(file.path(documentation_dir, "prepared_files_coverage_check.csv"), "\n")
cat(file.path(documentation_dir, "prepared_files_columns_inventory.csv"), "\n")

cat("\nCheck terminé.\n")