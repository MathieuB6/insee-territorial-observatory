# 01_prepare_filosofi_2021.R
# Préparation du fichier Filosofi 2021 au format commune

# Objectif :
# - Lire le fichier brut Filosofi placé dans data/raw/
# - Transformer les indicateurs utiles au format large
# - Renommer les variables avec des noms compréhensibles
# - Exporter un CSV propre dans data/prepared/

# Fichier attendu en entrée :
# data/raw/DS_FILOSOFI_CC_data.csv

# Fichier produit :
# data/prepared/cc_revenu_com_2021.csv
# Remarque :
# Les valeurs non diffusées pour secret statistique restent à NA.
# On ne remplace pas les NA par "s" dans le fichier principal,
# afin de garder un fichier exploitable en SQL.


# 1. Packages

library(readr)
library(dplyr)
library(tidyr)
library(janitor)
library(stringr)


# 2. Chemins du projet

dossier_projet <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

dossier_raw <- file.path(dossier_projet, "data", "raw")
dossier_prepared <- file.path(dossier_projet, "data", "prepared")

dir.create(dossier_prepared, recursive = TRUE, showWarnings = FALSE)

fichier_entree <- file.path(dossier_raw, "DS_FILOSOFI_CC_data.csv")
fichier_sortie <- file.path(dossier_prepared, "cc_revenu_com_2021.csv")


# 3. Vérification du fichier d'entrée

if (!file.exists(fichier_entree)) {
  stop(
    paste(
      "Fichier introuvable :",
      fichier_entree,
      "\nVérifie que DS_FILOSOFI_CC_data.csv est bien dans data/raw/."
    )
  )
}


# 4. Lecture du fichier brut

filosofi_brut <- read_delim(
  fichier_entree,
  delim = ";",
  locale = locale(decimal_mark = ".", grouping_mark = " "),
  show_col_types = FALSE,
  guess_max = 100000
) %>%
  clean_names()


# 5. Détection des colonnes utiles
# Selon la version du fichier INSEE, les colonnes peuvent avoir
# des noms légèrement différents. Cette partie rend le script
# plus robuste.

noms_colonnes <- names(filosofi_brut)

colonne_commune <- intersect(
  c("geo", "geographie", "codgeo", "code_geo", "code_commune"),
  noms_colonnes
)[1]

colonne_indicateur <- intersect(
  c("indic", "indicateur", "measure", "mesure"),
  noms_colonnes
)[1]

colonne_valeur <- intersect(
  c("value", "valeur", "obs_value", "observation"),
  noms_colonnes
)[1]

if (is.na(colonne_commune) || is.na(colonne_indicateur) || is.na(colonne_valeur)) {
  stop(
    paste(
      "Impossible d'identifier les colonnes commune / indicateur / valeur.",
      "\nColonnes trouvées dans le fichier :",
      paste(noms_colonnes, collapse = ", ")
    )
  )
}


# 6. Indicateurs conservés

indicateurs_a_conserver <- c(
  "D1_SL",
  "D9_SL",
  "MED_SL",
  "IR_D9_D1_SL",
  "PR_M60",
  "PR_MD60",
  "S_HH_TAX",
  "NUM_HH",
  "NUM_PER",
  "NUM_CU",
  "S_EI_DI",
  "S_EI_DI_SAL",
  "S_EI_DI_N_SAL",
  "S_EI_DI_UNE",
  "S_SOC_BEN_DI",
  "S_RET_PEN_DI",
  "S_INC_ASS_DI",
  "S_DIR_TAX_DI"
)

indicateurs_a_conserver_clean <- tolower(indicateurs_a_conserver)


# 7. Passage du format long au format large

filosofi_prepare <- filosofi_brut %>%
  transmute(
    codgeo = as.character(.data[[colonne_commune]]),
    indicateur = str_to_lower(as.character(.data[[colonne_indicateur]])),
    valeur = suppressWarnings(as.numeric(.data[[colonne_valeur]]))
  ) %>%
  filter(indicateur %in% indicateurs_a_conserver_clean) %>%
  distinct(codgeo, indicateur, .keep_all = TRUE) %>%
  pivot_wider(
    names_from = indicateur,
    values_from = valeur
  ) %>%
  rename(
    niveau_vie_1er_decile_euros = d1_sl,
    niveau_vie_9e_decile_euros = d9_sl,
    niveau_vie_median_euros = med_sl,
    rapport_interdecile_d9_d1 = ir_d9_d1_sl,
    taux_pauvrete_60_pct = pr_m60,
    taux_pauvrete_60_pct_bis = pr_md60,
    part_menages_imposes_pct = s_hh_tax,
    nombre_menages = num_hh,
    nombre_personnes = num_per,
    nombre_unites_consommation = num_cu,
    part_revenus_activite_pct = s_ei_di,
    part_salaires_pct = s_ei_di_sal,
    part_revenus_non_salaries_pct = s_ei_di_n_sal,
    part_indemnites_chomage_pct = s_ei_di_une,
    part_prestations_sociales_pct = s_soc_ben_di,
    part_pensions_retraites_rentes_pct = s_ret_pen_di,
    part_revenus_patrimoine_autres_pct = s_inc_ass_di,
    part_impots_directs_pct = s_dir_tax_di
  ) %>%
  mutate(
    codgeo = str_pad(codgeo, width = 5, side = "left", pad = "0")
  ) %>%
  arrange(codgeo)


# 8. Contrôles

nb_lignes <- nrow(filosofi_prepare)
nb_communes_distinctes <- n_distinct(filosofi_prepare$codgeo)
nb_doublons <- nb_lignes - nb_communes_distinctes

cat("\nContrôle du fichier Filosofi préparé\n")
cat("-----------------------------------\n")
cat("Nombre de lignes :", nb_lignes, "\n")
cat("Nombre de communes distinctes :", nb_communes_distinctes, "\n")
cat("Nombre de doublons codgeo :", nb_doublons, "\n")
cat("Valeurs manquantes revenu médian :", sum(is.na(filosofi_prepare$niveau_vie_median_euros)), "\n")

if (nb_doublons > 0) {
  stop("Des doublons de codgeo sont présents dans le fichier préparé.")
}


# 9. Export

write_csv2(
  filosofi_prepare,
  fichier_sortie,
  na = ""
)

cat("\nFichier créé avec succès :\n")
cat(fichier_sortie, "\n")
