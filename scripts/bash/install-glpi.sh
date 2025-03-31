# mise a jour du systeme
apt-get update && apt-get upgrade

# installation de apache2
apt-get install apache2 -y

# verification de apache2
systemctl status apache2.service

# installation de php
apt-get install php

# installation de mariadb
apt install mariadb-server

# verification de l'installation
systemctl status mariadb.service

# creation de la base de donne de glpi ainsi que son utilisateur
mysql -u root -e "CREATE DATABASE glpi;"
mysql -u root -e "CREATE USER 'glpibdd'@'localhost' IDENTIFIED BY 'Azerty1';"
mysql -u root -e "GRANT ALL PRIVILEGES ON glpi.* TO 'glpibdd'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# redemarrage de mariadb pour prendre en compte les changements
systemctl restart mariadb

# installation des dependances
apt-get install php-ldap php-imap php-apcu php-cas php-mbstring php-curl php-gd perl php-zip php-intl php-bz2 php-mysql php-xml -y
systemctl reload apache2

# telechargement de glpi
cd /usr/src
wget https://github.com/glpi-project/glpi/releases/download/10.0.18/glpi-10.0.18.tgz
tar -zxvf glpi-10.0.18.tgz
mkdir /var/www/html/glpi
mv /usr/src/glpi/* /var/www/html/glpi/

#donner les droits a apache sur le dossier
chown -R www-data:www-data /var/www/html/

# affichage pour vérification
systemctl status apache2
systemctl status mariadb
php -v

# donne les indentifiants pour la connection a la base de donnée
echo "identifiant de glpi pour ce connecter a la base de donnée"
echo "identifiant: glpibdd"
echo "mot de passe: Azerty1"

# identifiants pour ce connecter sur l'interface de glpi
echo "identifiant et mdp pour ce connecter a l'interface de glpi"
echo "identifiant: glpi"
echo "mot de passe: glpi"