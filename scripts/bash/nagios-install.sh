#!/bin/bash

echo "*****************************************************"
echo "* Scrit : Installation automatique de Nagios Server *"
echo "*    Pour Linux Distribution : Debian ou Ubuntu     *"
echo "*     By MoNiR TSRIT - M2I Groupe / 01/08/2021      *"
echo "*****************************************************"
echo "#####################################################"
echo "#####################################################"
echo "#####################################################"
echo "## Avant d'executer ce script assurer vous d'avoir ##"
echo "## une connexion internet avec résolution de nom ! ##"
echo "## le scrip doit être executer avec les droits root##"
echo "#####################################################"
echo "#####################################################"

echo " Mise à jour du Système" 
apt-get update -y && apt-get upgrade -y 
echo " Instalaltion des prérequis pour Nagios "
apt-get install wget build-essential unzip openssl libssl-dev apache2 php libapache2-mod-php php-gd libgd-dev -y 

echo -e " l'instalaltion des prérequis s'est terminée en succès ?? (O/n) \c"
read reponse 
case $reponse in 
		O|o|0)  echo "nous allons continuer l'instalaltion ;-) "
				 
				;;
		  N|n)	echo "Veuillez faire les vérifications nécessaires avant de relancer ce script"
				exit 1
				read default
				;;
				
		    *)  echo " Choix non autorisé ... Aurevoir "
				exit 1
				reboot -t 0 
				;;
				
esac 

echo " Ajout de l'utilisateur 'nagios' et liaison avec les groupes Apache et nagios "
adduser nagios
 groupadd nagcmd
 usermod -a -G nagcmd nagios
 usermod -a -G nagcmd www-data

echo "Téléchargement et Instalaltion de Nagios Core Service "
cd /opt/
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.9.tar.gz
tar xzf nagios-4.5.9.tar.gz

echo " Extraction, Compilation et configuration de Nagios source "
cd nagios-4.5.9
 ./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode

cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers

echo "Mise en place et paramètrage de Authentication avec Apache "


echo "ScriptAlias /nagios/cgi-bin "/usr/local/nagios/sbin" " >  /etc/apache2/conf-available/nagios.conf
echo " " >>  /etc/apache2/conf-available/nagios.conf
echo "<Directory "/usr/local/nagios/sbin"> " >>  /etc/apache2/conf-available/nagios.conf
echo "   Options ExecCGI " >>  /etc/apache2/conf-available/nagios.conf
echo "   AllowOverride None " >>  /etc/apache2/conf-available/nagios.conf
echo "   Order allow,deny " >>  /etc/apache2/conf-available/nagios.conf
echo "   Allow from all " >>  /etc/apache2/conf-available/nagios.conf
echo '   AuthName "Restricted Area" ' >>  /etc/apache2/conf-available/nagios.conf
echo "   AuthType Basic " >>  /etc/apache2/conf-available/nagios.conf
echo "   AuthUserFile /usr/local/nagios/etc/htpasswd.users " >>  /etc/apache2/conf-available/nagios.conf
echo "   Require valid-user " >>  /etc/apache2/conf-available/nagios.conf
echo "</Directory> " >>  /etc/apache2/conf-available/nagios.conf
echo " " >>  /etc/apache2/conf-available/nagios.conf
echo "Alias /nagios "/usr/local/nagios/share" " >>  /etc/apache2/conf-available/nagios.conf
echo " " >>  /etc/apache2/conf-available/nagios.conf
echo "<Directory "/usr/local/nagios/share"> " >>  /etc/apache2/conf-available/nagios.conf
echo "   Options None " >>  /etc/apache2/conf-available/nagios.conf
echo "   AllowOverride None " >>  /etc/apache2/conf-available/nagios.conf
echo "   Order allow,deny " >>  /etc/apache2/conf-available/nagios.conf
echo "   Allow from all " >>  /etc/apache2/conf-available/nagios.conf
echo "   AuthName 'Restricted Area' " >>  /etc/apache2/conf-available/nagios.conf
echo "   AuthType Basic " >>  /etc/apache2/conf-available/nagios.conf
echo "   AuthUserFile /usr/local/nagios/etc/htpasswd.users " >>  /etc/apache2/conf-available/nagios.conf
echo "   Require valid-user " >>  /etc/apache2/conf-available/nagios.conf
echo "</Directory> " >>  /etc/apache2/conf-available/nagios.conf
echo ""
echo " Attribution du mot de passe pour : nagios"
read mot2passe
echo "votre mot de passe est :$mot2passe" 
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
echo " Configuration du site nagios sur le serveur Apache2"
a2enconf nagios
a2enmod cgi rewrite
service apache2 restart
echo "Appuyez sur une touche pour continuer "
read  choix
echo "##################################"
echo "# Instalaltion des Plugin Nagios #"
echo "##################################"
echo "Appuyez sur une touche pour continuer "
read  choix
cd /opt
wget https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.12/nagios-plugins-2.4.12.tar.gz
tar xzf nagios-plugins-2.4.12.tar.gz
cd nagios-plugins-2.4.12

echo "Appuyez sur une touche pour continuer "
read  choix

echo "##################################"
echo "#  Compilation des Plugin Nagios #"
echo "##################################"
echo "Appuyez sur une touche pour continuer "
read  choix
 ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
make install

echo "##################################"
echo "#  Vérifications des paramtres   #"
echo "##################################"

echo "Appuyez sur une touche pour continuer "
read  choix
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
echo " Si vous n avez aucune erreur alors l instalaltion est achevée en succes"
echo " Démarrage du service Nagios "
service nagios start

systemctl enable nagios
echo "Appuyez sur une touche pour continuer "
read  choix

echo "*****************************************************"
echo "* Scrit : Installation automatiuqe de Nagios Server *"
echo "*    Pour Linux Distribution : Debian ou Ubuntu     *"
echo "*     By MoNiR TSRIT - M2I Groupe / 01/08/2021      *"
echo "*****************************************************"
echo "######################################################"
echo "######################################################"
echo "######################################################"
echo "##  Tester maintenent si votre Serveur Nagios est   ##"
echo "##    installé connrectement ! via la commande      ##"
echo "##service nagios status OU /etc/init.d/nagios status##"
echo "##   Si ça marche pas ! Appelez le formateur        ##"
echo "######################################################"
