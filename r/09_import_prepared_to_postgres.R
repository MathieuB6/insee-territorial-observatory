# 09_import_prepared_to_postgres.R
# Import des fichiers préparés dans PostgreSQL

# Objectif :
# - Lire les fichiers CSV présents dans data/prepared/
# - Créer les schémas PostgreSQL nécessaires
# - Importer les tables dans le schéma insee_raw

# Base PostgreSQL utilisée :
# ProjetPlateforme

# Connexion :
# Le script lit les paramètres locaux dans :
# config/connexion_postgres_locale.R

# Ce fichier local ne doit pas être envoyé sur GitHub.



# 1. Packages


library(DBI)
library(RPostgres)
library(readr)
library(dplyr)



# 2. Chemins du projet


dossier_projet <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

dossier_prepared <- file.path(dossier_projet, "data", "prepared")
fichier_connexion <- file.path(dossier_projet, "config", "connexion_postgres_locale.R")



# 3. Chargement de la connexion PostgreSQL locale


if (!file.exists(fichier_connexion)) {
  stop(
    paste(
      "Fichier de connexion introuvable :",
      fichier_connexion,
      "\nCrée le fichier config/connexion_postgres_locale.R avant de lancer ce script."
    )
  )
}

source(fichier_connexion, encoding = "UTF-8")

parametres_requis <- c(
  "nom_base",
  "hote",
  "port_postgres",
  "utilisateur_postgres",
  "mot_de_passe_postgres"
)

parametres_manquants <- parametres_requis[
  !vapply(parametres_requis, exists, logical(1))
]

if (length(parametres_manquants) > 0) {
  stop(
    paste(
      "Paramètres manquants dans config/connexion_postgres_locale.R :",
      paste(parametres_manquants, collapse = ", ")
    )
  )
}

if (nom_base != "ProjetPlateforme") {
  warning(
    paste(
      "Attention : le nom de base lu est",
      nom_base,
      "alors que le projet utilise normalement ProjetPlateforme."
    )
  )
}



# 4. Connexion à PostgreSQL


con <- dbConnect(
  RPostgres::Postgres(),
  dbname = nom_base,
  host = hote,
  port = as.integer(port_postgres),
  user = utilisateur_postgres,
  password = mot_de_passe_postgres
)

on.exit(dbDisconnect(con), add = TRUE)

cat("\nConnexion PostgreSQL réussie.\n")
cat("Base utilisée :", nom_base, "\n")



# 5. Création des schémas


dbExecute(con, "CREATE SCHEMA IF NOT EXISTS insee_raw;")
dbExecute(con, "CREATE SCHEMA IF NOT EXISTS insee_obs;")

cat("\nSchémas vérifiés / créés : insee_raw, insee_obs\n")


# 6. Liste des fichiers à importer

tables_a_importer <- tibble::tribble(
  ~fichier_csv,                              ~nom_table,
  "cc_population_2022.csv",                  "cc_population_2022",
  "cc_emploi_2022.csv",                      "cc_emploi_2022",
  "cc_diplome_2022.csv",                     "cc_diplome_2022",
  "cc_logement_2022.csv",                    "cc_logement_2022",
  "cc_menages_familles_2022.csv",            "cc_menages_familles_2022",
  "cc_caracteristiques_emploi_2022.csv",     "cc_caracteristiques_emploi_2022",
  "cc_revenu_com_2021.csv",                  "cc_revenu_com_2021"
)


# 7. Fonction d'import

importer_table <- function(fichier_csv, nom_table) {
  chemin_fichier <- file.path(dossier_prepared, fichier_csv)
  
  if (!file.exists(chemin_fichier)) {
    stop(paste("Fichier préparé introuvable :", chemin_fichier))
  }
  
  cat("\nImport de", fichier_csv, "vers insee_raw.", nom_table, "\n")
  
  donnees <- read_csv2(
    chemin_fichier,
    show_col_types = FALSE,
    guess_max = 100000
  )
  
  # Sécurité : les codes communes doivent rester en texte.
  if ("codgeo" %in% names(donnees)) {
    donnees <- donnees %>%
      mutate(codgeo = as.character(codgeo))
  }
  
  dbWriteTable(
    con,
    Id(schema = "insee_raw", table = nom_table),
    donnees,
    overwrite = TRUE,
    row.names = FALSE
  )
  
  dbExecute(
    con,
    paste0(
      "CREATE INDEX IF NOT EXISTS idx_",
      nom_table,
      "_codgeo ON insee_raw.",
      nom_table,
      " (codgeo);"
    )
  )
  
  cat("Table importée :", nom_table, "-", nrow(donnees), "lignes\n")
}


# 8. Import de toutes les tables

for (i in seq_len(nrow(tables_a_importer))) {
  importer_table(
    fichier_csv = tables_a_importer$fichier_csv[i],
    nom_table = tables_a_importer$nom_table[i]
  )
}


# 9. Contrôle rapide des volumes importés

controle_import <- dbGetQuery(
  con,
  "
  SELECT
      schemaname AS schema,
      relname AS table,
      n_live_tup AS estimation_lignes
  FROM pg_stat_user_tables
  WHERE schemaname = 'insee_raw'
  ORDER BY relname;
  "
)

cat("\nContrôle des tables importées :\n")
print(controle_import)

cat("\nImport terminé avec succès.\n")
