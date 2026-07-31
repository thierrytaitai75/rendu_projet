-- ============================================================
-- MISE À JOUR DU CHAMP obs_progression
-- Nombre de mois où le volume de ventes 2024 est supérieur à 2023
-- ============================================================

UPDATE
    `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
SET
    obs_progression = (
        SELECT
            COUNT(*) || ' mois en progression'
        FROM (
            SELECT
                T1.mois,
                T1.volume_vente2023,
                T2.volume_vente2024,
                CASE
                    WHEN T2.volume_vente2024 > T1.volume_vente2023
                        THEN 'CA 2024 en progression'
                    WHEN T2.volume_vente2024 = T1.volume_vente2023
                        THEN 'CA constant'
                    WHEN T2.volume_vente2024 < T1.volume_vente2023
                        THEN 'CA 2024 en régression'
                END AS observation
            FROM (
                SELECT
                    mois,
                    mois_nombre,
                    COUNT(DISTINCT order_id) AS volume_vente2023
                FROM
                    `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
                WHERE
                    order_status = 'Complete'
                    AND annee = 2023
                GROUP BY
                    mois,
                    mois_nombre
            ) AS T1
            INNER JOIN (
                SELECT
                    mois,
                    COUNT(DISTINCT order_id) AS volume_vente2024
                FROM
                    `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
                WHERE
                    order_status = 'Complete'
                    AND annee = 2024
                GROUP BY
                    mois
            ) AS T2
                ON T1.mois = T2.mois
        )
        WHERE
            observation = 'CA 2024 en progression'
    )
WHERE
    annee = 2024;

-- ============================================================
-- MISE À JOUR DU CA, DE LA MARGE BRUTE ET DU PANIER MOYEN
-- PAR ANNÉE
-- ============================================================

MERGE INTO
    `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024` AS T1
USING (
    SELECT
        annee,
        ROUND(SUM(sale_price), 2) AS ca,
        ROUND(SUM(sale_price - cost), 2) AS marge_brute,
        COUNT(DISTINCT order_id) AS nb_commande,
        ROUND(
            SUM(sale_price) / COUNT(DISTINCT order_id),
            2
        ) AS panier_moyen
    FROM
        `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
    WHERE
        order_status = 'Complete'
    GROUP BY
        annee
) AS T2
    ON T1.annee = T2.annee

WHEN MATCHED THEN
    UPDATE SET
        T1.ca = T2.ca,
        T1.marge_brut = T2.marge_brute,
        T1.panier_moyen = T2.panier_moyen;

-- ============================================================
-- MISE À JOUR DU NOMBRE DE RETOURS ET DU TAUX DE RETOUR ANNUEL
-- ============================================================

MERGE INTO
    `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024` AS T1
USING (
    SELECT
        V.annee,
        V.nb_venteretour,
        R.nb_retour,
        ROUND(
            R.nb_retour / V.nb_venteretour * 100,
            2
        ) AS taux_retour
    FROM (
        SELECT
            annee,
            COUNT(DISTINCT order_id) AS nb_venteretour
        FROM
            `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
        WHERE
            order_status IN ('Complete', 'Returned')
        GROUP BY
            annee
    ) AS V
    INNER JOIN (
        SELECT
            annee,
            COUNT(DISTINCT order_id) AS nb_retour
        FROM
            `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
        WHERE
            order_status = 'Returned'
        GROUP BY
            annee
    ) AS R
        ON V.annee = R.annee
) AS T2
    ON T1.annee = T2.annee

WHEN MATCHED THEN
    UPDATE SET
        T1.nb_retour = T2.nb_retour,
        T1.taux_retour = T2.taux_retour;


-- ============================================================
-- MISE À JOUR DU TAUX DE RÉACHAT ANNUEL
-- ============================================================

MERGE INTO
    `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024` AS T1
USING (
    WITH commandes AS (
        SELECT
            annee,
            user_id,
            COUNT(DISTINCT order_id) AS nb_commandes
        FROM
            `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
        WHERE
            order_status = 'Complete'
        GROUP BY
            annee,
            user_id
    )

    SELECT
        annee,
        COUNTIF(nb_commandes >= 2) AS clients_reachat,
        COUNT(*) AS clients_ayant_commande,
        ROUND(
            COUNTIF(nb_commandes >= 2) * 100.0 / COUNT(*),
            2
        ) AS taux_reachat_pct
    FROM
        commandes
    GROUP BY
        annee
) AS T2
    ON T1.annee = T2.annee

WHEN MATCHED THEN
    UPDATE SET
        T1.clients_reachat = T2.clients_reachat,
        T1.clients_ayant_commande = T2.clients_ayant_commande,
        T1.taux_reachat_pct = T2.taux_reachat_pct;


-- ============================================================
-- MISE À JOUR DU NOMBRE D'ANNULATIONS
-- ET DU TAUX D'ANNULATION ANNUEL
-- ============================================================

MERGE INTO
    `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024` AS T
USING (
    SELECT
        V.annee,
        V.nb_venteannulation,
        A.nb_annulation,
        ROUND(
            A.nb_annulation / V.nb_venteannulation * 100,
            2
        ) AS taux_annulation
    FROM (
        SELECT
            annee,
            COUNT(DISTINCT order_id) AS nb_venteannulation
        FROM
            `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
        WHERE
            order_status IN ('Complete', 'Cancelled')
        GROUP BY
            annee
    ) AS V
    INNER JOIN (
        SELECT
            annee,
            COUNT(DISTINCT order_id) AS nb_annulation
        FROM
            `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
        WHERE
            order_status = 'Cancelled'
        GROUP BY
            annee
    ) AS A
        ON V.annee = A.annee
) AS T2
    ON T.annee = T2.annee

WHEN MATCHED THEN
    UPDATE SET
        T.nb_annulation = T2.nb_annulation,
        T.taux_annulation = T2.taux_annulation;


-- ============================================================
-- AFFICHAGE DE LA TABLE RÉCAPITULATIVE DES KPI
-- ============================================================

SELECT
    *
FROM
    `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ORDER BY
    annee;
