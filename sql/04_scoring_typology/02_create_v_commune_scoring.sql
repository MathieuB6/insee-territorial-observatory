/*
Objectif :
Créer les scores de fragilité et d'attractivité des communes.

Méthode :
- Chaque indicateur disponible peut ajouter 1 point.
- Les valeurs NULL ne pénalisent pas et ne favorisent pas.
- Un score normalisé sur 100 est calculé pour tenir compte des données disponibles.
*/

CREATE OR REPLACE VIEW insee_obs.v_commune_scoring AS
WITH base AS (
    SELECT
        o.*,
        t.*
    FROM insee_obs.v_commune_observatory o
    CROSS JOIN insee_obs.v_scoring_thresholds t
),

scoring AS (
    SELECT
        codgeo,
        population_2022,

        /* Indicateurs utiles repris pour lecture */
        evol_population_2016_2022_pct,
        taux_chomage_2022,
        niveau_vie_median_euros,
        part_sans_diplome_2022,
        part_diplomes_superieur_2022,
        part_logements_vacants_2022,
        part_familles_monoparentales_2022,
        part_60_ans_plus_2022,
        emplois_lieu_travail_2022,
        part_proprietaires_2022,

        /* -------------------------
           Score de fragilité
           ------------------------- */

        CASE
            WHEN taux_chomage_2022 IS NOT NULL AND taux_chomage_2022 >= taux_chomage_p75 THEN 1
            ELSE 0
        END AS frag_chomage_eleve,

        CASE
            WHEN niveau_vie_median_euros IS NOT NULL AND niveau_vie_median_euros <= revenu_median_p25 THEN 1
            ELSE 0
        END AS frag_revenu_faible,

        CASE
            WHEN part_sans_diplome_2022 IS NOT NULL AND part_sans_diplome_2022 >= sans_diplome_p75 THEN 1
            ELSE 0
        END AS frag_sans_diplome_eleve,

        CASE
            WHEN part_logements_vacants_2022 IS NOT NULL AND part_logements_vacants_2022 >= logements_vacants_p75 THEN 1
            ELSE 0
        END AS frag_vacance_elevee,

        CASE
            WHEN part_familles_monoparentales_2022 IS NOT NULL
                 AND part_familles_monoparentales_2022 >= familles_monoparentales_p75 THEN 1
            ELSE 0
        END AS frag_familles_monoparentales_elevees,

        CASE
            WHEN evol_population_2016_2022_pct IS NOT NULL AND evol_population_2016_2022_pct < 0 THEN 1
            ELSE 0
        END AS frag_baisse_demographique,

        CASE
            WHEN part_60_ans_plus_2022 IS NOT NULL AND part_60_ans_plus_2022 >= part_60_ans_plus_p75 THEN 1
            ELSE 0
        END AS frag_vieillissement_eleve,

        /* Nombre d'indicateurs disponibles pour le score de fragilité */
        (
            CASE WHEN taux_chomage_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN niveau_vie_median_euros IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN part_sans_diplome_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN part_logements_vacants_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN part_familles_monoparentales_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN evol_population_2016_2022_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN part_60_ans_plus_2022 IS NOT NULL THEN 1 ELSE 0 END
        ) AS nb_indicateurs_fragilite_disponibles,

        /* -------------------------
           Score d'attractivité
           ------------------------- */

        CASE
            WHEN evol_population_2016_2022_pct IS NOT NULL
                 AND evol_population_2016_2022_pct >= evol_population_p75 THEN 1
            ELSE 0
        END AS attr_croissance_demographique,

        CASE
            WHEN niveau_vie_median_euros IS NOT NULL
                 AND niveau_vie_median_euros >= revenu_median_p75 THEN 1
            ELSE 0
        END AS attr_revenu_eleve,

        CASE
            WHEN part_diplomes_superieur_2022 IS NOT NULL
                 AND part_diplomes_superieur_2022 >= diplomes_superieur_p75 THEN 1
            ELSE 0
        END AS attr_diplomes_superieur_eleves,

        CASE
            WHEN taux_chomage_2022 IS NOT NULL
                 AND taux_chomage_2022 <= taux_chomage_p25 THEN 1
            ELSE 0
        END AS attr_chomage_faible,

        CASE
            WHEN part_logements_vacants_2022 IS NOT NULL
                 AND part_logements_vacants_2022 <= logements_vacants_p25 THEN 1
            ELSE 0
        END AS attr_vacance_faible,

        CASE
            WHEN emplois_lieu_travail_2022 IS NOT NULL
                 AND population_2022 IS NOT NULL
                 AND emplois_lieu_travail_2022 / NULLIF(population_2022, 0) >= densite_emploi_p75 THEN 1
            ELSE 0
        END AS attr_densite_emploi_elevee,

        /* Nombre d'indicateurs disponibles pour le score d'attractivité */
        (
            CASE WHEN evol_population_2016_2022_pct IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN niveau_vie_median_euros IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN part_diplomes_superieur_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN taux_chomage_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN part_logements_vacants_2022 IS NOT NULL THEN 1 ELSE 0 END +
            CASE WHEN emplois_lieu_travail_2022 IS NOT NULL AND population_2022 IS NOT NULL THEN 1 ELSE 0 END
        ) AS nb_indicateurs_attractivite_disponibles

    FROM base
)

SELECT
    *,

    (
        frag_chomage_eleve +
        frag_revenu_faible +
        frag_sans_diplome_eleve +
        frag_vacance_elevee +
        frag_familles_monoparentales_elevees +
        frag_baisse_demographique +
        frag_vieillissement_eleve
    ) AS score_fragilite_brut,

    ROUND(
        (
            100.0 *
            (
                frag_chomage_eleve +
                frag_revenu_faible +
                frag_sans_diplome_eleve +
                frag_vacance_elevee +
                frag_familles_monoparentales_elevees +
                frag_baisse_demographique +
                frag_vieillissement_eleve
            )
            / NULLIF(nb_indicateurs_fragilite_disponibles, 0)
        )::numeric,
        2
    ) AS score_fragilite_100,

    (
        attr_croissance_demographique +
        attr_revenu_eleve +
        attr_diplomes_superieur_eleves +
        attr_chomage_faible +
        attr_vacance_faible +
        attr_densite_emploi_elevee
    ) AS score_attractivite_brut,

    ROUND(
        (
            100.0 *
            (
                attr_croissance_demographique +
                attr_revenu_eleve +
                attr_diplomes_superieur_eleves +
                attr_chomage_faible +
                attr_vacance_faible +
                attr_densite_emploi_elevee
            )
            / NULLIF(nb_indicateurs_attractivite_disponibles, 0)
        )::numeric,
        2
    ) AS score_attractivite_100

FROM scoring;