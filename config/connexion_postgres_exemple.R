# ============================================================
# Exemple de fichier de connexion PostgreSQL
# Projet : Observatoire territorial SQL - Données INSEE
# ============================================================
#
# Pour utiliser le projet en local :
# 1. Copier ce fichier.
# 2. Renommer la copie en connexion_postgres_locale.R.
# 3. Remplacer le mot de passe par le mot de passe PostgreSQL local.
#
# Le fichier connexion_postgres_locale.R est ignoré par Git
# afin de ne pas publier d'identifiants sur GitHub.

nom_base <- "insee_observatory"
hote <- "localhost"
port_postgres <- 5432L
utilisateur_postgres <- "postgres"
mot_de_passe_postgres <- "ton_mot_de_passe_postgresql"
