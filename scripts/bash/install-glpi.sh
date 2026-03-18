# placement a la racine avant debut du script
cd /

# mise a jour du systeme
apt-get update && apt-get upgrade

# installation de apache2
apt-get install apache2 -y

# installation de php
apt-get install php

# installation de mariadb
apt install mariadb-server

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

# suppression du fichier install.php
rm /var/www/html/glpi/install/install.php

# activation de l'option session.cookie_httponly
sed -i -e 's/session.cookie_httponly =/session.cookie_httponly = on/g' /etc/php/8.2/apache2/php.ini

# Creation du fichier de configuration du site apache2
echo "
<VirtualHost :80> 

    ServerName ITFormation 

    DocumentRoot /var/www/glpi/public 

    # If you want to place GLPI in a subfolder of your site (e.g. your virtual host is serving multiple applications), 

    # you can use an Alias directive. If you do this, the DocumentRoot directive MUST NOT target the GLPI directory itself. 

    Alias "/glpi" "/var/www/html/glpi/public" 

    <Directory /var/www/html/glpi/public> 

        Require all granted 

        RewriteEngine On 

        # Redirect all requests to GLPI router, unless file exists. 

        RewriteCond %{REQUEST_FILENAME} !-f 

        RewriteRule ^(.)$ index.php [QSA,L] 

    </Directory> 

</VirtualHost>

" >> /etc/apache2/sites-available/glpi.conf

# activation du site web de glpi
a2ensite /etc/apache2/sites-available/glpi.conf

# desactivation du site par defaut
a2dissite /etc/apache2/sites-available/000-default.conf

# activation du mode rewrite
a2enmod rewrite

# redemarrage du service apache2
systemctl restart apache2

# affichage pour vérification
systemctl status apache2
systemctl status mariadb
php -v

# donne les indentifiants pour la connection a la base de donnée
clear
echo "identifiant de glpi pour ce connecter a la base de donnée"
echo "identifiant: glpibdd"
echo "mot de passe: Azerty1"

# identifiants pour ce connecter sur l'interface de glpi
echo "identifiant et mdp pour ce connecter a l'interface de glpi"
echo "identifiant: glpi"
echo "mot de passe: glpi"