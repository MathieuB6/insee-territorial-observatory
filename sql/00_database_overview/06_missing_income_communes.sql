/*
Identification des communes présentes dans la population 2022 mais absentes du fichier revenus Filosofi 2021.
*/

SELECT
    p.codgeo,
    p.population_2022
FROM insee_raw.cc_population_2022 p
LEFT JOIN insee_raw.cc_revenu_com_2021 r
    ON p.codgeo = r.codgeo
WHERE r.codgeo IS NULL
ORDER BY p.population_2022 DESC;