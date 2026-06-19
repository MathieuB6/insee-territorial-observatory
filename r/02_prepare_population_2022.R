library(readr)
library(dplyr)
library(janitor)

# Dossier projet
project_dir <- "C:/Users/matma/OneDrive/Documents/Portefolio/SQL/insee-territorial-observatory-sql"

raw_dir <- file.path(project_dir, "data/raw")
prepared_dir <- file.path(project_dir, "data/prepared")

dir.create(prepared_dir, recursive = TRUE, showWarnings = FALSE)

# Fichier brut INSEE
input_file <- file.path(raw_dir, "base-cc-evol-struct-pop-2022.csv")

# Fonction de conversion numérique
to_num <- function(x) {
  parse_number(
    as.character(x),
    locale = locale(decimal_mark = ",", grouping_mark = " ")
  )
}

# 1. Lecture du fichier en texte pour préserver les codes communes
population_raw <- read_csv2(
  input_file,
  col_types = cols(.default = col_character()),
  locale = locale(encoding = "UTF-8"),
  show_col_types = FALSE,
  guess_max = 100000
) |>
  clean_names()

# 2. Sélection et renommage des variables utiles
population_prepared <- population_raw |>
  transmute(
    codgeo = as.character(codgeo),
    
    # Population totale
    population_2022 = to_num(p22_pop),
    population_2016 = to_num(p16_pop),
    population_2011 = to_num(p11_pop),
    
    # Structure par âge 2022
    pop_0_14_2022 = to_num(p22_pop0014),
    pop_15_29_2022 = to_num(p22_pop1529),
    pop_30_44_2022 = to_num(p22_pop3044),
    pop_45_59_2022 = to_num(p22_pop4559),
    pop_60_74_2022 = to_num(p22_pop6074),
    pop_75_89_2022 = to_num(p22_pop7589),
    pop_90_plus_2022 = to_num(p22_pop90p),
    
    # Hommes / femmes 2022
    hommes_2022 = to_num(p22_poph),
    femmes_2022 = to_num(p22_popf),
    
    # Structure par âge 2016
    pop_0_14_2016 = to_num(p16_pop0014),
    pop_15_29_2016 = to_num(p16_pop1529),
    pop_30_44_2016 = to_num(p16_pop3044),
    pop_45_59_2016 = to_num(p16_pop4559),
    pop_60_74_2016 = to_num(p16_pop6074),
    pop_75_89_2016 = to_num(p16_pop7589),
    pop_90_plus_2016 = to_num(p16_pop90p),
    
    # Structure par âge 2011
    pop_0_14_2011 = to_num(p11_pop0014),
    pop_15_29_2011 = to_num(p11_pop1529),
    pop_30_44_2011 = to_num(p11_pop3044),
    pop_45_59_2011 = to_num(p11_pop4559),
    pop_60_74_2011 = to_num(p11_pop6074),
    pop_75_89_2011 = to_num(p11_pop7589),
    pop_90_plus_2011 = to_num(p11_pop90p)
  )

# 3. Contrôles rapides
cat("Nombre de communes :", nrow(population_prepared), "\n")
cat("Nombre de codes communes distincts :", n_distinct(population_prepared$codgeo), "\n")

cat("\nValeurs manquantes population 2022 :\n")
print(sum(is.na(population_prepared$population_2022)))

cat("\nAperçu du fichier préparé :\n")
print(head(population_prepared, 10))

# 4. Export du fichier propre
output_file <- file.path(prepared_dir, "cc_population_2022.csv")

write_csv2(
  population_prepared,
  output_file,
  na = ""
)

cat("\nFichier créé :", output_file, "\n")