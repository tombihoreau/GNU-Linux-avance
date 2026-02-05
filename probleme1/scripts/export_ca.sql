SELECT periode, SUM(total) AS total
FROM (
  SELECT
    DATE_FORMAT(date_facture, '%m %Y') AS periode,
    SUM(montant_total) AS total
  FROM prod_db.factures
  GROUP BY periode

  UNION ALL

  SELECT
    DATE_FORMAT(date_facture, '%m %Y') AS periode,
    SUM(montant_total) AS total
  FROM archive_db.factures_archive
  GROUP BY periode
) t
GROUP BY periode;
