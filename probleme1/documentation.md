# Problème 1 — Se conformer au RGPD  
## Guide de mise en œuvre pas à pas (Debian / MySQL)

---

## 0. Situation initiale

On suppose :

- Une machine **Debian neuve**
- Un utilisateur membre du groupe `sudo`
- Un service **MySQL / MariaDB actif**
- Un accès à l’utilisateur `root` de la base de données

---

## 1. Identifier les données personnelles et les durées de conservation

### Identifier les données personnelles

Dans la base relationnelle, les données suivantes sont considérées comme des **données personnelles** :

| Table   | Champs   |
|--------|----------|
| clients | nom      |
| clients | prenom   |
| clients | email    |
| clients | adresse  |
| clients | password |

Ces données permettent d’identifier directement une personne physique.

Les données suivantes **ne sont pas personnelles** lorsqu’elles sont dissociées de l’identité :

| Table    | Champs         |
|----------|----------------|
| factures | montant_total  |
| factures | date_facture   |

---

### Définir les durées de conservation

Les durées retenues sont :

- **3 ans** après la dernière activité pour les données clients
- **10 ans** pour les données de facturation (obligation comptable)
- Conservation illimitée des données **anonymisées**

> Ces durées sont cohérentes avec les recommandations de la CNIL.

---

## 2. Définir un processus RGPD

### Définir un processus automatisé

Le processus retenu est le suivant :

1. Identifier les clients inactifs depuis plus de 3 ans
2. Copier leurs données dans une base d’archive
3. Copier les factures associées dans la base d’archive
4. Anonymiser les données personnelles en production
5. Conserver uniquement les données anonymisées pour l’exploitation statistique

> L’archivage est effectué avant l’anonymisation afin de conserver un historique exploitable.

### Schéma du processus

```
+--------------------+
|  prod_db.clients   |
+--------------------+
           |
           | clients inactifs (> 3 ans)
           v
+-----------------------------+
| archive_db.clients_archive  |
+-----------------------------+
           |
           |
           v
+----------------------------------+
| Anonymisation en base de prod_db |
+----------------------------------+
```

---

## 3. Créer l’environnement technique

### Installer les outils nécessaires

```bash
sudo apt update
sudo apt install mariadb-server gawk cron
```

## 4. Créer les bases de données
### Créer deux bases

- Une base de production
- Une base d’archive intermédiaire

```
CREATE DATABASE prod_db;
CREATE DATABASE archive_db;
```

## 5. Créer les tables
### Créer les tables de production

```
CREATE TABLE clients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(50),
  prenom VARCHAR(50),
  email VARCHAR(100),
  adresse VARCHAR(150),
  password VARCHAR(255),
  last_activity DATE
);

CREATE TABLE factures (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT,
  montant_total DECIMAL(10,2),
  date_facture DATE
);
```

### Créer les tables d'archives

```
CREATE TABLE clients_archive LIKE prod_db.clients;
CREATE TABLE factures_archive LIKE prod_db.factures;
```

## 6. Insérer un jeu de données de test

### Insérer des données représentatives

```
INSERT INTO clients (...)
VALUES (...);

INSERT INTO factures (...)
VALUES (...);
```
> Le jeu de données permet de tester à la fois un client actif et un client inactif

## Mettre en place le script SQL RGPD

### Créer un script SQL dédié

- l’archivage des clients inactifs
- l’archivage des factures associées
- l’anonymisation des données personnelles

```
INSERT IGNORE INTO archive_db.clients_archive
SELECT * FROM prod_db.clients
WHERE last_activity < DATE_SUB(CURDATE(), INTERVAL 3 YEAR);

INSERT IGNORE INTO archive_db.factures_archive
SELECT ...
```

## 8. Mettre en place un script shell

### Créer un script d'éxécution

```
#!/bin/bash
mariadb < archive_and_anonymize.sql
```

## 9. Automatiser avec cron

### Planifier l'éxécution quotidienne

```
0 3 * * * /home/user/probleme1/scripts/run_rgpd.sh
```

> Le traitement RGPD est éxécuté automatiquement chaque nuit

## 11. Générer automatiquement les rapports

### Créer un script shell dédié

Ce script : 

- exécute l’export SQL
- applique le traitement AWK
- génère un fichier texte horodaté

### Planifier le rapport annuel

```
0 4 22 12 * /home/user/probleme1/scripts/generate_report.sh
```
> Le rapport est généré automatiquement le 22 décembre à 04:00, comme demandé.

## 12. Résultat final 

- Archivage automatisé
- Anonymisation conforme au RGPD
- Scripts relançables
- Rapports annuels générés automatiquement
- Solution documentée et reproductible

## Conclusion 

Cette solution répond strictement aux exigences du sujet :

- Conformité RGPD
- Automatisation complète
- Utilisation de cron, scripts shell, SQL et AWK
- Guide clair permettant la reproduction de la solution
