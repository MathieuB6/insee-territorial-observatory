# ============================================================
# Script : 12_import_ref_communes_to_postgres.R
# Objectif : importer la nomenclature des communes dans PostgreSQL
# Projet : Observatoire territorial SQL - Données INSEE
# ============================================================

library(readr)
library(dplyr)
library(janitor)
library(DBI)
library(RPostgres)

# ------------------------------------------------------------
# 1. Paramètres du projet
# ------------------------------------------------------------

dossier_projet <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"
dossier_prepare <- file.path(dossier_projet, "data/prepared")

fichier_entree <- file.path(dossier_prepare, "ref_communes.csv")

if (!file.exists(fichier_entree)) {
  stop("Le fichier ref_communes.csv est introuvable dans data/prepared/")
}

# ------------------------------------------------------------
# 2. Connexion PostgreSQL
# ------------------------------------------------------------

# Les identifiants sont stockés dans un fichier local ignoré par Git :
# config/connexion_postgres_locale.R
# Ce fichier reste sur ton PC et ne doit pas être envoyé sur GitHub.

fichier_connexion <- file.path(dossier_projet, "config", "connexion_postgres_locale.R")

if (!file.exists(fichier_connexion)) {
  stop(
    paste0(
      "Le fichier de connexion est introuvable : ", fichier_connexion, "
",
"Crée le fichier config/connexion_postgres_locale.R en copiant le modèle config/connexion_postgres_exemple.R."
    )
  )
}

source(fichier_connexion, encoding = "UTF-8")

# Vérification simple des paramètres de connexion
parametres_connexion <- c(
  "nom_base",
  "hote",
  "port_postgres",
  "utilisateur_postgres",
  "mot_de_passe_postgres"
)

parametres_manquants <- parametres_connexion[
  !vapply(parametres_connexion, exists, logical(1))
]

if (length(parametres_manquants) > 0) {
  stop(
    paste(
      "Paramètres manquants dans config/connexion_postgres_locale.R :",
      paste(parametres_manquants, collapse = ", ")
    )
  )
}

connexion <- dbConnect(
  RPostgres::Postgres(),
  dbname = nom_base,
  host = hote,
  port = as.integer(port_postgres),
  user = utilisateur_postgres,
  password = mot_de_passe_postgres
)

# ------------------------------------------------------------
# 3. Lecture du fichier de référence des communes
# ------------------------------------------------------------

ref_communes <- read_csv2(
  fichier_entree,
  col_types = cols(
    codgeo = col_character(),
    nom_commune = col_character(),
    code_departement = col_character(),
    code_region = col_character(),
    type_commune = col_character()
  ),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE
) |>
  clean_names() |>
  mutate(
    codgeo = as.character(codgeo),
    code_departement = as.character(code_departement),
    code_region = as.character(code_region)
  ) |>
  distinct(codgeo, .keep_all = TRUE)

# ------------------------------------------------------------
# 4. Import dans PostgreSQL
# ------------------------------------------------------------

dbWriteTable(
  conn = connexion,
  name = Id(schema = "insee_raw", table = "ref_communes"),
  value = ref_communes,
  overwrite = TRUE,
  row.names = FALSE
)

# Index sur le code commune pour accélérer les jointures
dbExecute(connexion, "
CREATE INDEX IF NOT EXISTS idx_ref_communes_codgeo
ON insee_raw.ref_communes (codgeo);
")

cat("Nomenclature importée dans insee_raw.ref_communes :", nrow(ref_communes), "lignes\n")

# ------------------------------------------------------------
# 5. Fermeture de la connexion
# ------------------------------------------------------------

dbDisconnect(connexion)
