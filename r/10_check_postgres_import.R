# 10_check_postgres_import.R
# Contrôle des tables importées dans PostgreSQL

# Objectif :
# - Vérifier que les tables préparées ont bien été importées
# - Contrôler le nombre de lignes
# - Vérifier les doublons de codgeo
# - Vérifier la présence des tables dans le schéma insee_raw
#
# Base PostgreSQL utilisée :


# 1. Packages

library(DBI)
library(RPostgres)


# 2. Chemins du projet

dossier_projet <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

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


# 5. Vérification des tables attendues

tables_attendues <- c(
  "cc_population_2022",
  "cc_emploi_2022",
  "cc_diplome_2022",
  "cc_logement_2022",
  "cc_menages_familles_2022",
  "cc_caracteristiques_emploi_2022",
  "cc_revenu_com_2021"
)

tables_presentes <- dbGetQuery(
  con,
  "
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'insee_raw'
  ORDER BY table_name;
  "
)

cat("\nTables présentes dans insee_raw :\n")
print(tables_presentes)

tables_manquantes <- setdiff(tables_attendues, tables_presentes$table_name)

if (length(tables_manquantes) > 0) {
  cat("\nTables manquantes :\n")
  print(tables_manquantes)
} else {
  cat("\nToutes les tables attendues sont présentes.\n")
}


# 6. Contrôle du nombre de lignes

cat("\nContrôle du nombre de lignes :\n")

for (table in tables_attendues) {
  requete <- paste0("SELECT COUNT(*) AS nb_lignes FROM insee_raw.", table, ";")
  resultat <- dbGetQuery(con, requete)
  
  cat(table, ":", resultat$nb_lignes, "lignes\n")
}

# 7. Contrôle des doublons de codgeo

cat("\nContrôle des doublons de codgeo :\n")

for (table in tables_attendues) {
  requete <- paste0(
    "
    SELECT
        COUNT(*) AS nb_lignes,
        COUNT(DISTINCT codgeo) AS nb_codgeo_distincts,
        COUNT(*) - COUNT(DISTINCT codgeo) AS nb_doublons
    FROM insee_raw.",
    table,
    ";
    "
  )
  
  resultat <- dbGetQuery(con, requete)
  
  cat(
    table,
    ":",
    resultat$nb_lignes,
    "lignes,",
    resultat$nb_codgeo_distincts,
    "codgeo distincts,",
    resultat$nb_doublons,
    "doublons\n"
  )
}


# 8. Fin du contrôle

cat("\nContrôle terminé.\n")