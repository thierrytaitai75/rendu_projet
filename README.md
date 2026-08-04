# Projet de fin de formation – Data Analyst
## Analyse décisionnelle des ventes — TheLook E-commerce (France / Femme / 2023–2024)

---

## 1. Contexte et objectifs

### Contexte
Ce projet a été réalisé dans le cadre de la spécialisation **Data Analyst**. Il s'appuie sur le jeu de données public **TheLook Ecommerce** (BigQuery public dataset) pour répondre à une question métier :

> **Comment a évolué l'activité commerciale entre 2023 et 2024, et quels leviers d'amélioration peut-on en tirer ?**

Le projet couvre l'intégralité d'une chaîne de travail Data Analyst : cadrage du périmètre, extraction et contrôle qualité des données, analyse exploratoire, calcul d'indicateurs (KPI), restitution via un tableau de bord Power BI, et synthèse orale.

### Objectifs
- Reconstruire un sous-périmètre exploitable à partir des données brutes BigQuery.
- Nettoyer et contrôler la qualité des données (doublons, formats, cohérence des dates et statuts).
- Réaliser une analyse exploratoire (EDA) en Python.
- Calculer les KPI clés : chiffre d'affaires, marge brute, panier moyen, taux de retour, taux d'annulation, taux de réachat.
- Consolider ces KPI dans BigQuery (SQL).
- Concevoir un tableau de bord Power BI orienté décision.
- Présenter les résultats et recommandations lors d'une soutenance.

### Livrables
| Livrable | Fichier |
|---|---|
| Vue SQL du sous-périmètre | `01_creation_vue_sous_perimetre.sql` |
| Notebook d'analyse exploratoire | `01_EDA_python.ipynb` |
| Table de reporting SQL | `02_creation_table_temporaire.sql` |
| Calcul des KPI SQL | `03_calcul_kpi.sql` |
| Tableau de bord Power BI | `renduprojet.pbix` |
| Support de soutenance | `Soutenance_TheLook_DataAnalyst_sobre.pptx` |

---

## 2. Description du sous-périmètre

### Tables sources (dataset public BigQuery `bigquery-public-data.thelook_ecommerce`)
| Table | Rôle |
|---|---|
| `users` | Informations client (pays, genre, ville, état) |
| `orders` | Commandes (statut, dates de création/expédition/livraison) |
| `order_items` | Lignes de commande (statut produit, prix de vente) |
| `products` | Catalogue produit (catégorie, département, marque, coût) |

### Clés de jointure
- `users.id = orders.user_id`
- `orders.order_id = order_items.order_id`
- `order_items.product_id = products.id`

### Filtres du sous-périmètre
- `users.country = 'France'`
- `users.gender = 'F'`
- `products.department = 'Women'`
- `EXTRACT(YEAR FROM orders.created_at) BETWEEN 2023 AND 2024`

Ces filtres sont appliqués dans la vue `THELOOKECOMMERCE` (voir `01_creation_vue_sous_perimetre.sql`), qui sert de **table maître** à l'ensemble du projet (SQL, Python, Power BI).

### ⚠️ Point de vigilance
Les données BigQuery sont **vivantes** (mises à jour en continu par Google). Le volume observé au moment de l'export CSV (1 679 lignes) peut différer du volume observé lors d'une nouvelle exécution de la requête SQL (1 240 lignes lors de la rédaction de ce projet). Ceci est normal et attendu — aucune garantie de reproductibilité stricte du volume, uniquement de la logique de calcul.

---

## 3. Installation et exécution

### Prérequis
- Python ≥ 3.10
- Un compte Google Cloud avec accès au projet BigQuery contenant le dataset `bigquery-public-data.thelook_ecommerce` (accès en lecture) et un projet cible pour créer la vue/table (`project-14a21b71-120d-42de-bd0.datagong` dans ce projet — à adapter à votre propre projet GCP)
- Power BI Desktop (pour ouvrir/modifier `renduprojet.pbix`)

### Installation de l'environnement Python
```bash
# création d'un environnement virtuel
python -m venv venv
source venv/bin/activate      # Windows : venv\Scripts\activate

# installation des dépendances
pip install pandas numpy matplotlib jupyter
```

### Accès BigQuery
Les requêtes SQL sont exécutées directement dans la console **BigQuery** (ou via le client `bq`/`google-cloud-bigquery`). Adapter les identifiants de projet/dataset (`project-14a21b71-120d-42de-bd0.datagong`) à votre propre environnement GCP avant exécution.

---

## 4. Cheminement pour reproduire les résultats

L'ordre d'exécution est important : le notebook Python dépend d'un export CSV généré depuis BigQuery.

Les volets **Python** et **SQL** s'appuient sur deux sources indépendantes du même périmètre métier (voir point de vigilance en section 2) et peuvent être déroulés dans n'importe quel ordre l'un par rapport à l'autre.

### Volet Python (analyse exploratoire)

1. **Récupérer le fichier CSV source**
   Le fichier `thelook_fr_women_2023_2024.csv` est **fourni par l'organisme de formation** (photo du périmètre à un instant T). Il n'est pas généré ni exporté depuis la vue SQL. Le placer dans un dossier `data/` à la racine du projet :
   `data/thelook_fr_women_2023_2024.csv`
   *(chemin attendu par le notebook : `../data/thelook_fr_women_2023_2024.csv`)*

2. **Lancer l'analyse exploratoire**
   Ouvrir et exécuter `01_EDA_python.ipynb` dans l'ordre des cellules, en s'appuyant sur ce CSV fourni :
   - chargement et audit du dataset (dictionnaire de colonnes, valeurs manquantes, doublons)
   - contrôle qualité (cohérence des dates, cohérence statut commande/produit)
   - retraitement (suppression des résidus 2022, typage des dates, ajout mois/année)
   - analyse descriptive et calcul des KPI en Python (fonctions `contribution()` et `kpi()`)
   - visualisations (saisonnalité, comparaison 2023 vs 2024)

### Volet SQL (BigQuery)

Exécuter les 3 fichiers SQL **dans l'ordre**, chacun s'appuyant sur le précédent :

1. `01_creation_vue_sous_perimetre.sql` → crée la vue `THELOOKECOMMERCE`, qui reconstruit le sous-périmètre (filtres, jointures — voir section 2) et sert de table maître aux deux fichiers suivants.
2. `02_creation_table_temporaire.sql` → crée la table `OBSERVATION2023_2024` (une ligne par année, colonnes KPI initialisées), alimentée à partir de la vue précédente.
3. `03_calcul_kpi.sql` → met à jour successivement les colonnes de `OBSERVATION2023_2024` : progression mensuelle, CA/marge/panier moyen, taux de retour, taux de réachat, taux d'annulation.

### Volet Power BI

Ouvrir `renduprojet.pbix` dans Power BI Desktop, la source de données est le même fichier utilisé pour l'analyse python.

---

## 5. Décisions de design Power BI et principaux enseignements

### Décisions de design
- **KPI fixes en haut de page** : les indicateurs clés (CA, marge, panier moyen, taux de retour, taux d'annulation) restent visibles en permanence pour garder le contexte quel que soit le filtre appliqué.
- **Page dédiée "statut des commandes"** : mise en évidence de la part de ventes en cours, annulées et retournées — le dashboard ne se limite pas au CA réalisé, il montre aussi le potentiel non transformé (CA perdu / CA en cours vs CA réel), sur une visualisation mensuelle comparative.
- **Vues Top / Flop** par catégorie, marque et ville pour prioriser les segments commerciaux (assortiment, animation commerciale, ciblage géographique).
- **Mesures DAX** construites pour distinguer explicitement CA réel (statut `Complete`), CA perdu (`Cancelled`/`Returned`) et CA en cours (`Processing`/`Shipped`), plutôt qu'un simple total, afin de rendre visible le delta entre activité potentielle et activité réalisée.
- **Tri chronologique des mois** géré via la colonne numérique `numero_mois`/`mois_nombre` (créée en Python et en SQL) pour éviter un tri alphabétique erroné des axes temporels dans les visuels.

### Principaux enseignements (résultats clés 2023 → 2024)
| KPI | 2023 | 2024 | Évolution |
|---|---|---|---|
| Chiffre d'affaires | 7 806,32 € | 15 716,28 € | +101,33 % |
| Marge brute | 4 075,34 € | 8 134,61 € | +99,61 % |
| Panier moyen | 80,48 € | 85,41 € | +6,13 % |
| Taux de retour | 37,87 % | 30,42 % | −7,45 pts |
| Taux d'annulation | 39,92 % | 33,89 % | −6,03 pts |

- La croissance 2024 est **homogène sur l'année** (supérieure à 2023 chaque mois), avec un pic en octobre les deux années, la plus forte hausse relative en mars (+318,63 %) et la progression la plus faible en avril (+15 %).
- La **saisonnalité 2024** concentre les meilleurs niveaux de CA sur juin, août, septembre, octobre (2 388,50 €, meilleur mois) et décembre ; juillet est le point bas — un levier d'anticipation pour la préparation des stocks et campagnes.
- Les segments les plus contributeurs sont les catégories *Outerwear & Coats*, *Jeans* et *Intimates*, les marques *Arc'teryx*, *PAIGE* et *Jones New York*, et la ville de Paris.
- Le **taux de réachat reste faible**, identifié comme le principal axe d'amélioration (relance post-achat, offres personnalisées, segmentation client).

### Limites identifiées
- Écart entre volume CSV (1 679 lignes) et volume BigQuery lors d'une nouvelle exécution (1 240 lignes), lié au caractère non figé des données publiques BigQuery.
- 904 lignes présentent une date de création d'item antérieure à investiguer (point d'attention documenté mais non résolu à ce stade).

---

## 6. Structure du dépôt

```text
├── data/
│   └── thelook_fr_women_2023_2024.csv      # généré à l'étape 2 (non versionné si volumineux/sensible)
├── notebooks/
│   └── 01_EDA_python.ipynb
├── sql/
│   ├── 01_creation_vue_sous_perimetre.sql
│   ├── 02_creation_table_temporaire.sql
│   └── 03_calcul_kpi.sql
├── powerbi/
│   └── renduprojet.pbix
├── slides/
│   └── Soutenance_TheLook_DataAnalyst_sobre.pptx
└── README.md
```

---

## Technologies utilisées
- Python (Pandas, NumPy, Matplotlib)
- SQL (Google BigQuery)
- Power BI (Power Query, DAX)
- Git / GitHub
