# ============================================================
# 13_export_final_outputs.R
# Export des résultats finaux du projet SQL INSEE
# ============================================================
#
# Objectif :
# - Exporter les vues finales PostgreSQL vers le dossier exports/
# - Produire des fichiers CSV lisibles et réutilisables
# - Alimenter le README GitHub et les analyses métier
#
# Base PostgreSQL utilisée :
# ProjetPlateforme
#
# Connexion :
# Le script lit les paramètres locaux dans :
# config/connexion_postgres_locale.R
#
# Ce fichier local ne doit pas être envoyé sur GitHub.
# ============================================================


# ============================================================
# 1. Packages
# ============================================================

library(DBI)
library(RPostgres)
library(readr)


# ============================================================
# 2. Chemins du projet
# ============================================================

dossier_projet <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

dossier_exports <- file.path(dossier_projet, "exports")
fichier_connexion <- file.path(dossier_projet, "config", "connexion_postgres_locale.R")

dir.create(dossier_exports, recursive = TRUE, showWarnings = FALSE)


# ============================================================
# 3. Chargement de la connexion PostgreSQL locale
# ============================================================

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


# ============================================================
# 4. Connexion à PostgreSQL
# ============================================================

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


# ============================================================
# 5. Fonction d'export
# ============================================================

exporter_requete <- function(requete_sql, nom_fichier) {
  donnees <- dbGetQuery(con, requete_sql)

  chemin_sortie <- file.path(dossier_exports, nom_fichier)

  write_csv2(
    donnees,
    chemin_sortie,
    na = ""
  )

  cat("Export créé :", chemin_sortie, "-", nrow(donnees), "lignes\n")
}


# ============================================================
# 6. Exports finaux
# ============================================================

# 6.1 Vue finale complète avec noms de communes
exporter_requete(
  "
  SELECT *
  FROM insee_obs.v_commune_observatory_named
  ORDER BY code_departement, nom_commune;
  ",
  "commune_observatory_named.csv"
)

# 6.2 Vue finale avec scoring et typologie
exporter_requete(
  "
  SELECT *
  FROM insee_obs.v_commune_typology_named
  ORDER BY code_departement, nom_commune;
  ",
  "commune_typology_named.csv"
)

# 6.3 Synthèse par typologie
exporter_requete(
  "
  SELECT *
  FROM insee_obs.v_typology_summary
  ORDER BY nb_communes DESC;
  ",
  "typology_summary.csv"
)

# 6.4 Top communes fragiles
exporter_requete(
  "
  SELECT
      codgeo,
      nom_commune,
      code_departement,
      population_2022,
      typologie_commune,
      score_fragilite_100,
      score_attractivite_100,
      taux_chomage_2022,
      niveau_vie_median_euros,
      part_sans_diplome_2022,
      part_logements_vacants_2022,
      part_familles_monoparentales_2022,
      evol_population_2016_2022_pct,
      part_60_ans_plus_2022,
      nb_indicateurs_fragilite_disponibles
  FROM insee_obs.v_commune_typology_named
  WHERE population_2022 >= 2000
    AND nb_indicateurs_fragilite_disponibles >= 5
  ORDER BY score_fragilite_100 DESC, population_2022 DESC
  LIMIT 100;
  ",
  "top_communes_fragiles.csv"
)

# 6.5 Top communes attractives
exporter_requete(
  "
  SELECT
      codgeo,
      nom_commune,
      code_departement,
      population_2022,
      typologie_commune,
      score_fragilite_100,
      score_attractivite_100,
      evol_population_2016_2022_pct,
      niveau_vie_median_euros,
      part_diplomes_superieur_2022,
      taux_chomage_2022,
      part_logements_vacants_2022,
      emplois_lieu_travail_2022,
      nb_indicateurs_attractivite_disponibles
  FROM insee_obs.v_commune_typology_named
  WHERE population_2022 >= 2000
    AND nb_indicateurs_attractivite_disponibles >= 5
  ORDER BY score_attractivite_100 DESC, population_2022 DESC
  LIMIT 100;
  ",
  "top_communes_attractives.csv"
)

# 6.6 Communes vieillissantes
exporter_requete(
  "
  SELECT
      codgeo,
      nom_commune,
      code_departement,
      population_2022,
      typologie_commune,
      part_60_ans_plus_2022,
      part_75_ans_plus_2022,
      indice_vieillissement_simplifie,
      evol_population_2016_2022_pct,
      part_menages_personnes_seules_2022,
      part_80_plus_seuls_2022
  FROM insee_obs.v_commune_typology_named
  WHERE typologie_commune = 'Commune vieillissante'
  ORDER BY part_60_ans_plus_2022 DESC, population_2022 DESC
  LIMIT 100;
  ",
  "communes_vieillissantes.csv"
)

# 6.7 Communes à forte vacance de logements
exporter_requete(
  "
  SELECT
      codgeo,
      nom_commune,
      code_departement,
      population_2022,
      typologie_commune,
      logements_2022,
      logements_vacants_2022,
      part_logements_vacants_2022,
      evol_logements_vacants_2016_2022_pct,
      evol_population_2016_2022_pct,
      score_fragilite_100
  FROM insee_obs.v_commune_typology_named
  WHERE logements_2022 >= 500
  ORDER BY part_logements_vacants_2022 DESC, logements_vacants_2022 DESC
  LIMIT 100;
  ",
  "communes_forte_vacance_logements.csv"
)


# ============================================================
# 7. Fin du script
# ============================================================

cat("\nExports terminés avec succès.\n")
cat("Dossier des exports :", dossier_exports, "\n")
