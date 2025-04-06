#!/bin/bash

# this script have been made by Charles Top-Pottez in order to quickly create the basics functions of a LAMP server

# paquets update
apt-get update && apt-get upgrade

# installation of apache2
apt install apache2 -y

# start apache service and allow it to run on server startup
systemctl start apache2
systemctl enable apache2

# installation of php and the dependencies
apt install php libapache2-mod-php php-mysql -y

# installation of mariadb
apt install mariadb-server -y

# restart of all services
systemctl restart apache2
systemctl restart mariadb.service

# clear the screen for better view
clear

# print of services status and recommendations
systemctl status apache2
systemctl status mariadb.service

echo "we higly recommend you to run the mysql_secure_installation script"
echo "this script will allow you to setup the default security for the database"
echo "enjoy your brand new LAMP server :)"
