library(readr)
library(dplyr)
library(janitor)
library(stringr)

project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

input_file <- file.path(raw_dir, "v_commune_2025.csv")

if (!file.exists(input_file)) {
  stop("Fichier v_commune_2025.csv introuvable dans data/raw/")
}

communes_raw <- read_delim(
  input_file,
  delim = ",",
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE
) |>
  clean_names()

ref_communes <- communes_raw |>
  filter(typecom == "COM") |>
  transmute(
    codgeo = as.character(com),
    nom_commune = libelle,
    code_departement = as.character(dep),
    code_region = as.character(reg),
    type_commune = typecom
  ) |>
  distinct(codgeo, .keep_all = TRUE) |>
  arrange(codgeo)

output_file <- file.path(prepared_dir, "ref_communes.csv")

write_csv2(
  ref_communes,
  output_file,
  na = ""
)

cat("Fichier créé :", output_file, "\n")
cat("Nombre de communes :", nrow(ref_communes), "\n")
print(head(ref_communes, 20))