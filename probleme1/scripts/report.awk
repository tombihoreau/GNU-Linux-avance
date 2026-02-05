BEGIN {
  print "Mois Annee CA_TTC"
}

NR == 1 { next }  # saute l'en-tête "periode total"

{
  mois = $1
  annee = $2
  total = $3
  printf "%s %s %.2f\n", mois, annee, total
}
