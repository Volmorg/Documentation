#!/bin/bash

DEST="/var/backups/glpi"
DATE=$(date +%Y-%m-%d_%H%M)


# Créer le dossier s'il n'existe pas
mkdir -p $DEST

# Export de la base | le mot de passe doit bien être collé au "p"
mysqldump -u glpi -p'TON_MOT_DE_PASSE' glpi > $DEST/glpi_$DATE.sql

# Optionnel : compresser le fichier pour gagner de la place
gzip $DEST/glpi_$DATE.sql

# Supprimer les backups de plus de 30 jours
find $DEST -type f -mtime +30 -delete

# Affichage des informations de fin
echo "L'export de la base de donnée à bien était effectué."
echo "Vous le trouverai dans /var/backups/glpi avec la date du jour."