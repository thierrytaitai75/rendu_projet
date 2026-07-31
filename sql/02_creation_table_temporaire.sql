--création d'une table qui servira de rapport pour la présentation des KPI
--cette table sera alimenté par la vue précédemment créée
CREATE OR REPLACE TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024` as 
SELECT annee, 
FORMAT_TIMESTAMP('%d/%m/%Y',min(order_created_at)) as date_debut,
FORMAT_TIMESTAMP('%d/%m/%Y',max(order_created_at)) as date_fin,
COUNT(DISTINCT order_id) AS vente
FROM `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
WHERE order_status = 'Complete'
GROUP BY annee;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN obs_progression STRING;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN ca FLOAT64;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN marge_brut FLOAT64;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN panier_moyen FLOAT64;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN nb_retour NUMERIC;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN taux_retour FLOAT64;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN clients_reachat NUMERIC;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN clients_ayant_commande NUMERIC;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN taux_reachat_pct FLOAT64;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN nb_annulation NUMERIC;

ALTER TABLE `project-14a21b71-120d-42de-bd0.datagong.OBSERVATION2023_2024`
ADD COLUMN taux_annulation FLOAT64;
