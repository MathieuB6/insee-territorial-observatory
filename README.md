# Observatoire territorial SQL à partir de données INSEE

## Présentation du projet

Ce projet consiste à construire un observatoire territorial à partir de données communales issues de l’INSEE.

L’objectif est de préparer, intégrer, contrôler et analyser plusieurs jeux de données publiques afin d’identifier différents profils de communes selon leurs caractéristiques démographiques, sociales, économiques et résidentielles.

La problématique retenue est la suivante :

**Comment identifier les profils socio-économiques des communes françaises à partir de données INSEE afin d’aider à la priorisation territoriale ?**

Ce projet a été réalisé dans une logique de portfolio Data Analyst, avec une attention portée à la reproductibilité, à la structuration SQL, aux contrôles qualité et à l’interprétation métier des résultats.

---

## Objectifs

Les objectifs principaux du projet sont :

- préparer plusieurs fichiers INSEE bruts au format CSV ;
- harmoniser les codes communes ;
- importer les données préparées dans PostgreSQL ;
- organiser la base en plusieurs couches SQL ;
- créer des indicateurs territoriaux ;
- construire des scores de fragilité et d’attractivité ;
- produire une typologie communale ;
- exporter des résultats finaux exploitables ;
- documenter la méthode, les limites et les principaux résultats.

---

## Données utilisées

Le projet s’appuie principalement sur des données publiques INSEE à l’échelle communale :

- recensement de la population 2022 ;
- emploi et population active 2022;
- diplômes et formation 2022;
- logement 2022;
- ménages, couples et familles 2022;
- caractéristiques de l’emploi 2022;
- revenus communaux Filosofi 2021 ;
- référentiel communal INSEE 2025.

Les fichiers bruts ne sont pas inclus dans le dépôt GitHub afin de limiter le poids du projet et de conserver un dépôt lisible.

Les fichiers préparés nécessaires à la compréhension du projet sont disponibles dans le dossier `data/prepared/`.

---

## Architecture du projet

```text
insee-territorial-observatory-sql/
├── config/
│   └── connexion_postgres_exemple.R
├── data/
│   └── prepared/
├── documentation/
├── exports/
├── r/
├── screenshots/
├── sql/
│   ├── 00_database_overview/
│   ├── 01_staging/
│   ├── 02_indicators/
│   ├── 03_final_views/
│   ├── 04_scoring_typology/
│   ├── 05_analysis_queries/
│   └── 06_screenshots/
├── .gitignore
└── README.md
```

---

## Environnement technique

Le projet utilise :

- **PostgreSQL** pour le stockage, la structuration et l’analyse SQL ;
- **pgAdmin** pour l’exécution des scripts SQL et les contrôles ;
- **R** pour la préparation des fichiers CSV, l’import en base et l’export des résultats ;
- **SQL** pour les vues intermédiaires, les indicateurs, les scores et les requêtes métier.

Packages R utilisés :

- `readr`
- `dplyr`
- `tidyr`
- `janitor`
- `stringr`
- `DBI`
- `RPostgres`

---

## Méthodologie

Le projet suit une logique en plusieurs couches.

### 1. Préparation des données avec R

Les fichiers bruts INSEE sont nettoyés et harmonisés avec des scripts R.

Chaque script prépare un thème de données :

- population ;
- emploi ;
- diplômes ;
- logement ;
- ménages et familles ;
- caractéristiques de l’emploi ;
- revenus ;
- référentiel communes.


Les fichiers préparés sont exportés dans le dossier `data/prepared/`.

---

### 2. Import dans PostgreSQL

Les fichiers préparés sont importés dans PostgreSQL dans le schéma :

```sql
insee_raw
```

Ce schéma contient les tables sources propres, prêtes à être exploitées en SQL.

---

### 3. Création des vues de contrôle

Un premier ensemble de scripts permet de contrôler :

- les tables importées ;
- les volumes de lignes ;
- la présence des colonnes ;
- les doublons de codes communes ;
- la couverture des différentes sources ;
- les communes exclues du périmètre d’analyse.

Le périmètre final d’analyse comprend **34 804 communes**.

---

### 4. Création des vues staging

Les vues staging servent à sélectionner, renommer et structurer les variables utiles avant la création des indicateurs.

Schéma utilisé :

```sql
insee_obs
```

Exemples de vues staging :

- `stg_population`
- `stg_emploi`
- `stg_diplome`
- `stg_logement`
- `stg_menages_familles`
- `stg_caracteristiques_emploi`
- `stg_revenu`

---

### 5. Création des indicateurs

Les vues d’indicateurs transforment les variables sources en indicateurs interprétables :

- évolution de la population ;
- part des personnes âgées ;
- taux de chômage ;
- part des diplômés du supérieur ;
- part des personnes sans diplôme ;
- part des logements vacants ;
- part des propriétaires ;
- part des familles monoparentales ;
- niveau de vie médian ;
- densité d’emploi ;
- indicateurs de mobilité domicile-travail.

Ces indicateurs servent ensuite à construire la vue finale d’observation communale.

---

### 6. Vue finale d’observatoire

La vue centrale du projet est :

```sql
insee_obs.v_commune_observatory_named
```

Elle rassemble les indicateurs principaux par commune, avec :

- le code commune ;
- le nom de la commune ;
- le département ;
- la population ;
- les indicateurs démographiques ;
- les indicateurs d’emploi ;
- les indicateurs de diplôme ;
- les indicateurs de logement ;
- les indicateurs de revenus ;
- les indicateurs de structure familiale.

---

## Scoring territorial

Deux scores de repérage ont été créés :

- un **score de fragilité** ;
- un **score d’attractivité**.

Ces scores ne sont pas des mesures absolues.  
Ils permettent d’identifier des profils territoriaux à partir de plusieurs critères.

### Score de fragilité

Le score de fragilité prend en compte plusieurs dimensions :

- chômage élevé ;
- niveau de vie médian faible ;
- part élevée de personnes sans diplôme ;
- vacance de logements élevée ;
- part élevée de familles monoparentales ;
- baisse démographique ;
- vieillissement marqué.

### Score d’attractivité

Le score d’attractivité prend en compte :

- croissance démographique ;
- niveau de vie médian élevé ;
- part élevée de diplômés du supérieur ;
- chômage faible ;
- vacance de logements faible ;
- forte densité d’emploi.

### Interprétation des scores

Les scores sont construits à partir de critères binaires basés sur des seuils statistiques, notamment des quartiles.

Une commune valide ou non chaque critère, puis le score est ramené sur 100 selon le nombre d’indicateurs disponibles.

```text
score = nombre de critères validés / nombre de critères disponibles × 100
```

Les valeurs manquantes ne pénalisent pas une commune.  
Le nombre d’indicateurs disponibles est donc conservé dans les vues finales afin de mieux interpréter les scores.

---

## Typologie communale

À partir des scores et de plusieurs indicateurs structurants, une typologie communale a été construite.

Les communes sont réparties en six profils :

- Commune intermédiaire ;
- Commune vieillissante ;
- Commune fragile ;
- Commune résidentielle favorisée ;
- Pôle urbain / pôle d’emploi ;
- Commune dynamique / attractive.

Vue utilisée :

```sql
insee_obs.v_commune_typology_named
```

---

## Résultats principaux

Le projet aboutit à l’analyse de **34 804 communes**.

Répartition par typologie :

| Typologie | Nombre de communes |
|---|---:|
| Commune intermédiaire | 23 181 |
| Commune vieillissante | 3 223 |
| Commune fragile | 3 220 |
| Commune résidentielle favorisée | 2 538 |
| Pôle urbain / pôle d’emploi | 2 363 |
| Commune dynamique / attractive | 279 |

Quelques constats généraux :

- Les communes fragiles présentent en moyenne un taux de chômage plus élevé, un niveau de vie plus faible, une vacance de logements plus importante et une part plus forte de personnes âgées.
- Les communes résidentielles favorisées se distinguent par un revenu médian plus élevé, une part importante de diplômés du supérieur, un chômage plus faible et une vacance réduite.
- Les pôles urbains / pôles d’emploi concentrent une population plus importante et un volume élevé d’emplois au lieu de travail.
- Les communes vieillissantes sont souvent marquées par une part importante de population âgée et une dynamique démographique plus faible.

---

## Exemples de résultats

### Vue finale avec typologie

<img width="1356" height="668" alt="03_commune_typology_preview" src="https://github.com/user-attachments/assets/5f15d6fd-b182-47db-a36d-2808c4572914" />

### Synthèse par typologie

<img width="1316" height="570" alt="04_typology_summary" src="https://github.com/user-attachments/assets/3b4d7f8c-eee1-458a-b326-837c88a63310" />

### Top communes fragiles

<img width="1305" height="736" alt="05_top_fragile_communes" src="https://github.com/user-attachments/assets/995f750a-9670-4892-9eaf-a70b24935153" />

### Top communes attractives

<img width="1353" height="743" alt="06_top_attractive_communes" src="https://github.com/user-attachments/assets/071dabf8-fb1f-4850-bd13-d87152c5f6ce" />

### Communes à forte vacance de logements

<img width="1354" height="736" alt="07_top_housing_vacancy" src="https://github.com/user-attachments/assets/d4a1f492-13dc-4a51-aa93-f611b885ac1e" />

---

## Exports produits

Les principaux résultats sont exportés dans le dossier `exports/` :

```text
exports/
├── commune_observatory_named.csv
├── commune_typology_named.csv
├── typology_summary.csv
├── top_communes_fragiles.csv
├── top_communes_attractives.csv
├── communes_vieillissantes.csv
└── communes_forte_vacance_logements.csv
```

Ces fichiers peuvent être utilisés pour une analyse complémentaire dans Excel, Power BI ou Python.

---

## Reproductibilité

### 1. Préparer les données

Les scripts R du dossier `r/` permettent de préparer les fichiers sources et de produire les fichiers du dossier `data/prepared/`.

### 2. Configurer la connexion PostgreSQL

Le fichier local suivant doit être créé :

```text
config/connexion_postgres_locale.R
```

Il doit reprendre le modèle fourni dans :

```text
config/connexion_postgres_exemple.R
```

Exemple :

```r
nom_base <- "ProjetPlateforme"
hote <- "localhost"
port_postgres <- 5432L
utilisateur_postgres <- "postgres"
mot_de_passe_postgres <- "A_COMPLETER"
```

Le fichier `connexion_postgres_locale.R` contient un mot de passe local et ne doit pas être publié sur GitHub.

### 3. Importer les données préparées

```r
source("r/09_import_prepared_to_postgres.R")
```

### 4. Exécuter les scripts SQL

Les scripts SQL sont organisés dans l’ordre suivant :

```text
sql/00_database_overview/
sql/01_staging/
sql/02_indicators/
sql/03_final_views/
sql/04_scoring_typology/
sql/05_analysis_queries/
sql/06_screenshots/
```

### 5. Exporter les résultats finaux

```r
source("r/13_export_final_outputs.R")
```

---

## Limites méthodologiques

Ce projet repose sur des données communales agrégées.  
Il ne permet donc pas d’analyser les disparités infra-communales.

Certaines variables sont concernées par le secret statistique ou par des valeurs non diffusées, notamment dans les données de revenus.  
Les indicateurs fortement incomplets n’ont pas été utilisés dans le scoring final.

Les scores de fragilité et d’attractivité sont des scores de repérage.  
Ils permettent de comparer les profils de communes, mais ne doivent pas être interprétés comme une mesure absolue ou définitive.

La typologie proposée dépend des seuils retenus et peut être ajustée selon les objectifs d’analyse.

---

## Compétences démontrées

Ce projet met en pratique plusieurs compétences de Data Analyst :

- préparation et nettoyage de données avec R ;
- structuration d’un projet data ;
- import de fichiers CSV dans PostgreSQL ;
- modélisation en couches SQL ;
- création de vues SQL ;
- jointures multi-sources ;
- construction d’indicateurs métier ;
- contrôles qualité ;
- scoring territorial ;
- typologie communale ;
- rédaction d’une documentation technique ;
- production d’exports exploitables ;
- valorisation d’un projet dans un portfolio GitHub.

---

## Auteur

Projet réalisé par Mathieu Buvat -- mathieubuvatpro@gmail.com
