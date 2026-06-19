# Données brutes

Les fichiers bruts INSEE ne sont pas inclus dans ce dépôt GitHub car ils sont trop volumineux.

Pour reproduire le projet, les fichiers sources doivent être téléchargés depuis les plateformes publiques de l'INSEE puis placés dans ce dossier `data/raw/`.

Fichiers attendus :

- base-cc-evol-struct-pop-2022.CSV
- base-cc-emploi-pop-active-2022.CSV
- base-cc-diplomes-formation-2022.CSV
- base-cc-logement-2022.CSV
- base-cc-coupl-fam-men-2022.CSV
- base-cc-caract_emp-2022.CSV
- DS_FILOSOFI_CC_data.csv
- DS_FILOSOFI_CC_metadata.csv
- v_commune_2025.csv

Les scripts R du dossier `r/` utilisent ces fichiers pour produire les fichiers préparés dans `data/prepared/`.
