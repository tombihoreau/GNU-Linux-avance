-- Archivage des clients inactifs (plus de 3 ans)
INSERT IGNORE archive_db.clients_archive
SELECT *
FROM prod_db.clients
WHERE last_activity < DATE_SUB(CURDATE(), INTERVAL 3 YEAR);

-- Archivage des factures associées
INSERT IGNORE archive_db.factures_archive
SELECT f.*
FROM prod_db.factures f
JOIN prod_db.clients c ON f.client_id = c.id
WHERE c.last_activity < DATE_SUB(CURDATE(), INTERVAL 3 YEAR);

-- Anonymisation des clients inactifs en base de production
UPDATE prod_db.clients
SET
  nom = 'ANON',
  prenom = 'ANON',
  email = CONCAT(id, '@anon.local'),
  adresse = 'ANON',
  password = 'ANON'
WHERE last_activity < DATE_SUB(CURDATE(), INTERVAL 3 YEAR);
