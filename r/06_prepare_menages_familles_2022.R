library(readr)
library(dplyr)
library(janitor)

# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

# Fichier brut INSEE
input_file <- file.path(raw_dir, "base-cc-coupl-fam-men-2022.csv")

# Fonction de conversion numérique robuste
to_num <- function(x) {
  parse_number(
    as.character(x),
    locale = locale(decimal_mark = ",", grouping_mark = " ")
  )
}

# 1. Lecture du fichier en texte pour préserver les codes communes
menages_raw <- read_csv2(
  input_file,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE,
  guess_max = 100000
) |>
  clean_names()

# 2. Sélection et renommage des variables utiles
menages_prepared <- menages_raw |>
  transmute(
    codgeo = as.character(codgeo),
    
    # Ménages selon composition - 2022
    menages_2022 = to_num(c22_men),
    menages_personnes_seules_2022 = to_num(c22_menpseul),
    menages_hommes_seuls_2022 = to_num(c22_menhseul),
    menages_femmes_seules_2022 = to_num(c22_menfseul),
    menages_sans_famille_2022 = to_num(c22_mensfam),
    menages_avec_famille_2022 = to_num(c22_menfam),
    menages_couples_sans_enfant_2022 = to_num(c22_mencoupsenf),
    menages_couples_avec_enfant_2022 = to_num(c22_mencoupaenf),
    menages_familles_monoparentales_2022 = to_num(c22_menfammono),
    
    # Population des ménages selon composition - 2022
    population_menages_2022 = to_num(c22_pmen),
    population_menages_personnes_seules_2022 = to_num(c22_pmen_menpseul),
    population_menages_hommes_seuls_2022 = to_num(c22_pmen_menhseul),
    population_menages_femmes_seules_2022 = to_num(c22_pmen_menfseul),
    population_menages_sans_famille_2022 = to_num(c22_pmen_mensfam),
    population_menages_avec_famille_2022 = to_num(c22_pmen_menfam),
    population_menages_couples_sans_enfant_2022 = to_num(c22_pmen_mencoupsenf),
    population_menages_couples_avec_enfant_2022 = to_num(c22_pmen_mencoupaenf),
    population_menages_familles_monoparentales_2022 = to_num(c22_pmen_menfammono),
    
    # Population 15 ans ou plus par âge - 2022
    population_15_plus_2022 = to_num(p22_pop15p),
    population_15_19_2022 = to_num(p22_pop1519),
    population_20_24_2022 = to_num(p22_pop2024),
    population_25_39_2022 = to_num(p22_pop2539),
    population_40_54_2022 = to_num(p22_pop4054),
    population_55_64_2022 = to_num(p22_pop5564),
    population_65_79_2022 = to_num(p22_pop6579),
    population_80_plus_2022 = to_num(p22_pop80p),
    
    # Population vivant en ménage par âge - 2022
    population_menage_15_19_2022 = to_num(p22_popmen1519),
    population_menage_20_24_2022 = to_num(p22_popmen2024),
    population_menage_25_39_2022 = to_num(p22_popmen2539),
    population_menage_40_54_2022 = to_num(p22_popmen4054),
    population_menage_55_64_2022 = to_num(p22_popmen5564),
    population_menage_65_79_2022 = to_num(p22_popmen6579),
    population_menage_80_plus_2022 = to_num(p22_popmen80p),
    
    # Personnes seules par âge - 2022
    personnes_seules_15_19_2022 = to_num(p22_pop1519_pseul),
    personnes_seules_20_24_2022 = to_num(p22_pop2024_pseul),
    personnes_seules_25_39_2022 = to_num(p22_pop2539_pseul),
    personnes_seules_40_54_2022 = to_num(p22_pop4054_pseul),
    personnes_seules_55_64_2022 = to_num(p22_pop5564_pseul),
    personnes_seules_65_79_2022 = to_num(p22_pop6579_pseul),
    personnes_seules_80_plus_2022 = to_num(p22_pop80p_pseul),
    
    # Personnes en couple par âge - 2022
    personnes_en_couple_15_19_2022 = to_num(p22_pop1519_couple),
    personnes_en_couple_20_24_2022 = to_num(p22_pop2024_couple),
    personnes_en_couple_25_39_2022 = to_num(p22_pop2539_couple),
    personnes_en_couple_40_54_2022 = to_num(p22_pop4054_couple),
    personnes_en_couple_55_64_2022 = to_num(p22_pop5564_couple),
    personnes_en_couple_65_79_2022 = to_num(p22_pop6579_couple),
    personnes_en_couple_80_plus_2022 = to_num(p22_pop80p_couple),
    
    # Statut matrimonial - 2022
    personnes_15_plus_mariees_2022 = to_num(p22_pop15p_mariee),
    personnes_15_plus_pacsees_2022 = to_num(p22_pop15p_pacsee),
    personnes_15_plus_union_libre_2022 = to_num(p22_pop15p_concub_union_libre),
    personnes_15_plus_veuves_2022 = to_num(p22_pop15p_veufs),
    personnes_15_plus_divorcees_2022 = to_num(p22_pop15p_divorcee),
    personnes_15_plus_celibataires_2022 = to_num(p22_pop15p_celibataire),
    
    # Familles - 2022
    familles_2022 = to_num(c22_fam),
    familles_couples_avec_enfant_2022 = to_num(c22_coupaenf),
    familles_monoparentales_2022 = to_num(c22_fammono),
    familles_monoparentales_hommes_2022 = to_num(c22_hmono),
    familles_monoparentales_femmes_2022 = to_num(c22_fmono),
    familles_couples_sans_enfant_2022 = to_num(c22_coupsenf),
    
    # Familles selon nombre d'enfants de moins de 24 ans - 2022
    familles_sans_enfant_moins_24_ans_2022 = to_num(c22_ne24f0),
    familles_1_enfant_moins_24_ans_2022 = to_num(c22_ne24f1),
    familles_2_enfants_moins_24_ans_2022 = to_num(c22_ne24f2),
    familles_3_enfants_moins_24_ans_2022 = to_num(c22_ne24f3),
    familles_4_enfants_plus_moins_24_ans_2022 = to_num(c22_ne24f4p),
    
    # Familles traditionnelles / recomposées - 2022
    familles_traditionnelles_2022 = to_num(c22_famtrad),
    familles_recomposees_2022 = to_num(c22_famrecomp),
    
    # Données comparables 2016
    menages_2016 = to_num(c16_men),
    menages_personnes_seules_2016 = to_num(c16_menpseul),
    menages_sans_famille_2016 = to_num(c16_mensfam),
    menages_avec_famille_2016 = to_num(c16_menfam),
    menages_couples_sans_enfant_2016 = to_num(c16_mencoupsenf),
    menages_couples_avec_enfant_2016 = to_num(c16_mencoupaenf),
    menages_familles_monoparentales_2016 = to_num(c16_menfammono),
    population_menages_2016 = to_num(c16_pmen),
    
    familles_2016 = to_num(c16_fam),
    familles_couples_avec_enfant_2016 = to_num(c16_coupaenf),
    familles_monoparentales_2016 = to_num(c16_fammono),
    familles_couples_sans_enfant_2016 = to_num(c16_coupsenf),
    
    # Données comparables 2011, seulement les principaux indicateurs
    menages_2011 = to_num(c11_men),
    menages_personnes_seules_2011 = to_num(c11_menpseul),
    menages_sans_famille_2011 = to_num(c11_mensfam),
    menages_avec_famille_2011 = to_num(c11_menfam),
    menages_couples_sans_enfant_2011 = to_num(c11_mencoupsenf),
    menages_couples_avec_enfant_2011 = to_num(c11_mencoupaenf),
    menages_familles_monoparentales_2011 = to_num(c11_menfammono),
    population_menages_2011 = to_num(c11_pmen),
    
    familles_2011 = to_num(c11_fam),
    familles_couples_avec_enfant_2011 = to_num(c11_coupaenf),
    familles_monoparentales_2011 = to_num(c11_fammono),
    familles_couples_sans_enfant_2011 = to_num(c11_coupsenf)
  )

# 3. Contrôles rapides
cat("Nombre de communes :", nrow(menages_prepared), "\n")
cat("Nombre de codes communes distincts :", n_distinct(menages_prepared$codgeo), "\n")

cat("\nValeurs manquantes ménages 2022 :\n")
print(sum(is.na(menages_prepared$menages_2022)))

cat("\nValeurs manquantes familles 2022 :\n")
print(sum(is.na(menages_prepared$familles_2022)))

cat("\nAperçu du fichier préparé :\n")
print(head(menages_prepared, 10))

# 4. Export du fichier propre
output_file <- file.path(prepared_dir, "cc_menages_familles_2022.csv")

write_csv2(
  menages_prepared,
  output_file,
  na = ""
)

cat("\nFichier créé :", output_file, "\n")