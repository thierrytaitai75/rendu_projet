# Analyse E-commerce 2023 vs 2024 – TheLook E-commerce

## Contexte

Ce projet a été réalisé dans le cadre de la spécialisation **Data Analyst**.

L'objectif est d'analyser les performances e-commerce de **TheLook Europe** sur les années **2023** et **2024** afin de comparer l'évolution de l'activité, mesurer les principaux indicateurs de performance (KPI) et proposer des recommandations à destination de la direction e-commerce.

Le projet couvre l'ensemble de la chaîne d'analyse :

- Extraction des données depuis Google BigQuery
- Analyse exploratoire en Python
- Validation des KPI en SQL
- Restitution des résultats dans Power BI

---

# Objectifs

Les objectifs du projet sont les suivants :

- Contrôler la qualité des données
- Réaliser une analyse exploratoire (EDA)
- Comparer les performances entre 2023 et 2024
- Calculer les principaux KPI métier
- Vérifier les résultats obtenus en Python avec SQL (BigQuery)
- Construire un tableau de bord Power BI destiné à l'aide à la décision

---

# Sous-périmètre étudié

## Période

01/01/2023 → 31/12/2024

## Pays

France

## Département

Women

---

# Source des données

Dataset public Google BigQuery

```
bigquery-public-data.thelook_ecommerce
```

Tables utilisées :

- users
- orders
- order_items
- products

---

# Modèle de données

Jointures utilisées :

```
users.id
      │
      ▼
orders.user_id

orders.order_id
      │
      ▼
order_items.order_id

products.id
      │
      ▼
order_items.product_id
```

---

# KPI calculés

Les indicateurs calculés sont :

- Chiffre d'affaires
- Marge brute
- Panier moyen
- Taux de retour
- Taux de réachat

Conventions utilisées :

| KPI | Statut utilisé |
|------|----------------|
| Vente | Complete |
| Retour | Returned |

---

# Organisation du dépôt

```
.
├── README.md
│
├── data/
│   └── thelook_fr_women_2023_2024.csv
│
├── notebooks/
│   ├── 01_EDA_python.ipynb
│   └── 02_checks_coherence.ipynb
│
├── sql/
│   ├── kpi_ca_marge_par_annee.sql
│   ├── kpi_aov_par_annee.sql
│   ├── kpi_taux_retour_par_annee.sql
│   ├── kpi_taux_reachat_par_annee.sql
│   └── extract_sous_perimetre.sql
│
├── powerbi/
│   └── dashboard_thelook.pbix
│
├── slides/
│   └── soutenance_20min.pptx
│
├── src/
│   └── utils.py
│
└── .gitignore
```

---

# Technologies utilisées

| Outil | Utilisation |
|--------|-------------|
| Python | Analyse exploratoire |
| Pandas | Manipulation des données |
| Matplotlib | Visualisations |
| SQL | Calcul des KPI |
| Google BigQuery | Source de données |
| Power BI | Tableau de bord |
| Git & GitHub | Gestion de version |

---

# Installation

Créer un environnement virtuel

```bash
python -m venv .venv
```

Activation sous Windows

```bash
.venv\Scripts\activate
```

Installation des dépendances

```bash
pip install pandas numpy matplotlib jupyter
```

Lancer Jupyter Notebook

```bash
jupyter notebook
```

---

# Reproduction du projet

Les différentes étapes doivent être exécutées dans l'ordre suivant.

## 1. Analyse exploratoire

Exécuter

```
notebooks/01_EDA_python.ipynb
```

Ce notebook réalise :

- chargement des données
- contrôle qualité
- traitement des valeurs manquantes
- détection des doublons
- contrôle des dates
- statistiques descriptives
- visualisations
- calcul des KPI

---

## 2. Contrôles complémentaires

Exécuter

```
notebooks/02_checks_coherence.ipynb
```

Ce notebook permet :

- de vérifier les résultats obtenus ;
- de réaliser des recoupements ;
- de contrôler la cohérence des calculs.

---

## 3. Extraction du sous-périmètre

Exécuter la requête

```
sql/extract_sous_perimetre.sql
```

Cette requête extrait le périmètre :

- France
- Women
- 2023–2024

Le résultat est exporté dans

```
data/thelook_fr_women_2023_2024.csv
```

---
## 4. Validation SQL

Les KPI sont recalculés directement depuis BigQuery grâce aux requêtes du dossier

```
sql/
```

Les résultats SQL sont comparés avec ceux calculés en Python.

---

## 5. Dashboard Power BI

Le tableau de bord est disponible dans

```
powerbi/dashboard_thelook.pbix
```

Il présente notamment :

- l'évolution du chiffre d'affaires ;
- l'évolution de la marge ;
- le panier moyen ;
- le taux de retour ;
- le taux de réachat ;
- les performances par marque ;
- les performances par catégorie ;
- la répartition géographique ;
- les comparaisons mensuelles 2023 / 2024.

---

# Contrôles qualité réalisés

Les principaux contrôles réalisés sont :

- valeurs manquantes ;
- doublons ;
- types de données ;
- formats de dates ;
- cohérence des identifiants ;
- cohérence temporelle ;
- contrôle des valeurs aberrantes.

---

# Principaux enseignements

L'analyse permet notamment :

- d'identifier les évolutions entre 2023 et 2024 ;
- de mesurer la contribution des marques et catégories ;
- d'évaluer l'impact des retours sur la marge ;
- d'identifier les périodes de forte activité ;
- de mettre en évidence les tendances saisonnières ;
- d'aider à la prise de décision grâce au tableau de bord Power BI.

---

# Auteur

TT

Projet réalisé dans le cadre de la spécialisation **Data Analyst**.

Dataset :

Google BigQuery Public Dataset

```
bigquery-public-data.thelook_ecommerce
```
