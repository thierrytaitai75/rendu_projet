--création d'une vue qui servira de table maitre pour l'ensemble des requêtes de KPI.
--cette vue répond à l'énoncé : 2.2 Reconstruction du sous‑périmètre (requête d’extraction)
-- il est plus simple de commencer par cette étape pour fluidifier les calculs KPI

CREATE OR REPLACE VIEW `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE` AS
SELECT
    T2.order_id,
    T3.id AS order_item_id,
    T4.id AS product_id,
    T3.created_at AS item_created_at,
    T3.status AS item_status,
    T3.sale_price,
    T4.cost,
    T4.category,
    T4.department,
    T4.brand,
    T4.name AS product_name,
    T2.status AS order_status,
    T2.created_at AS order_created_at,
    T2.shipped_at,
    T2.delivered_at,
    T2.user_id,
    T1.gender,
    T1.country,
    T1.state,
    T1.city,
    extract(YEAR from T2.created_at) as annee,
    extract(MONTH from T2.created_at) as mois_nombre,
    case EXTRACT(MONTH FROM T2.created_at)
    when 1 then 'janvier'
    when 2 then 'fevrier'
    when 3 then 'mars'
    when 4 then 'avril'
    when 5 then 'mai'
    when 6 then 'juin'
    when 7 then 'juillet'
    when 8 then 'aout'
    when 9 then 'septembre'
    when 10 then 'octobre'
    when 11 then 'novembre'
    when 12 then 'décembre'
    end as mois
FROM `bigquery-public-data.thelook_ecommerce.users` AS T1
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS T2
    ON T1.id = T2.user_id
JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS T3
    ON T2.order_id = T3.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` AS T4
    ON T4.id = T3.product_id
WHERE T1.country = 'France' 
  AND T1.gender = 'F'
  AND EXTRACT(YEAR FROM T2.created_at) BETWEEN 2023 AND 2024
  AND T4.department = 'Women';
  
  
--nombre de ligne totale
SELECT COUNT(*) 
FROM `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`;
--### Les données du csv fourni sont une image à un instant T des données de de bigquery.
--### Les données de bigquery sont "vivantes" (c-à-d que ces données sont mise à jour, supprimées, ajoutées)
--### Donc aucune garantie que les données csv et sql soient à ce jour présentes/identiques dans les deux sources de données
--### Ainsi volume python = 1679 et volume bigquery = 1240


--comparaison mensuelle 2023 - 2024
SELECT T1.mois,volume_vente2023,volume_vente2024,
CASE 
when volume_vente2024 > volume_vente2023 then 'CA 2024 en progression'
when volume_vente2024 = volume_vente2023 then 'CA constant'
when volume_vente2024 < volume_vente2023 then 'CA 2024 en régression'
END as observation
FROM 
(SELECT 
  mois, 
  COUNT(DISTINCT order_id) AS volume_vente2023,
  mois_nombre
 FROM `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
 WHERE order_status = 'Complete' and annee = 2023
 GROUP BY mois,mois_nombre
 order by mois_nombre
) T1 

inner join 

(
 SELECT 
  mois, 
  COUNT(DISTINCT order_id) AS volume_vente2024
 FROM `project-14a21b71-120d-42de-bd0.datagong.THELOOKECOMMERCE`
 WHERE order_status = 'Complete' and annee = 2024
 GROUP BY annee,mois
 order by annee) T2 
on T1.mois = T2.mois 
order by T1.mois_nombre;
