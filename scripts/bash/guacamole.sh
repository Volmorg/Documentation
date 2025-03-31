clear;
apt-get update && apt-get upgrade
apt-get install -y build-essential 
apt-get install -y libcairo2-dev 
apt-get install -y libjpeg-turbo8-dev 
apt-get install -y libpng-dev 
apt-get install -y libtool-bin 
apt-get install -y libossp-uuid-dev 
apt-get install -y libvncserver-dev 
apt-get install -y freerdp2-dev 
apt-get install -y libssh2-1-dev 
apt-get install -y libtelnet-dev 
apt-get install -y libwebsockets-dev 
apt-get install -y libpulse-dev 
apt-get install -y libvorbis-dev
apt-get install -y libwebp-dev 
apt-get install -y libssl-dev 
apt-get install -y libpango1.0-dev 
apt-get install -y libswscale-dev 
apt-get install -y libavcodec-dev 
apt-get install -y libavutil-dev 
apt-get install -y libavformat-dev 
wget https://downloads.apache.org/guacamole/1.5.3/source/guacamole-server-1.5.3.tar.gz -O /tmp/guacamole-server.tar.gz 2>/dev/null;
tar -xzf /tmp/guacamole-server.tar.gz -C /tmp/;
cd /tmp/guacamole-server-*
./configure --with-init-dir=/etc/init.d --disable-guacenc;
make # -$(nproc) 1>/dev/null;
make install;
ldconfig;
systemctl daemon-reload; # Rafraichir liste des services
systemctl start guacd; # Demarrage du service Guacamole
systemctl enable guacd; # Démarrage automatique du service au boot
systemctl status guacd; # Verifier le statut du service Guacamole
mkdir -p /etc/guacamole/{extensions,lib};

echo " deb http://deb.debian.org/debian/ bullseye main " > /etc/apt/sources.list.d/bullseye.list

##Installez Tomcat 9
apt-get update

apt-get install -y tomcat9 
apt-get install -y tomcat9-admin 
apt-get install -y tomcat9-common
apt-get install -y tomcat9-user 
wget https://downloads.apache.org/guacamole/1.5.3/binary/guacamole-1.5.3.war -O /tmp/guacamole.war;
mv /tmp/guacamole.war /var/lib/tomcat9/webapps/guacamole.war;
systemctl restart tomcat9 guacd;
apt-get install -y mariadb-server

mysql -u root -e " DROP DATABASE IF EXISTS guacadb; "
mysql -u root -e " CREATE DATABASE IF NOT EXISTS guacadb; "
mysql -u root -e " DROP USER IF EXISTS 'Guacamole'@'localhost'; "
mysql -u root -e " CREATE USER 'Guacamole'@'localhost' IDENTIFIED BY 'mypassword'; "
mysql -u root -e " SELECT user FROM mysql.user; "
mysql -u root -e " GRANT ALL PRIVILEGES ON guacadb.* TO 'Guacamole'@'localhost'; "

sed -i 's/^/#/' /etc/apt/sources.list.d/bullseye.list
sed -i -e " s/127.0.0.1/0.0.0.0/g " /etc/mysql/mariadb.conf.d/50-server.cnf; systemctl restart mariadb;

wget https://downloads.apache.org/guacamole/1.5.3/binary/guacamole-auth-jdbc-1.5.3.tar.gz -O /tmp/guacamole-auth-jdbc.tar.gz;
tar -xzf /tmp/guacamole-auth-jdbc.tar.gz -C /tmp/;
mv /tmp/guacamole-auth-jdbc-1.5.3/mysql/guacamole-auth-jdbc-mysql-1.5.3.jar /etc/guacamole/extensions/;

wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.2.0.tar.gz -O /tmp/mysql-connector-j-8.2.0.tar.gz;
tar -xvf /tmp/mysql-connector-j-8.2.0.tar.gz -C /tmp;
mv /tmp/mysql-connector-j-8.2.0/mysql-connector-j-8.2.0.jar /etc/guacamole/lib;


mysql -u root guacadb < /tmp/guacamole-auth-jdbc-1.5.3/mysql/schema/001-create-schema.sql;
mysql -u root guacadb < /tmp/guacamole-auth-jdbc-1.5.3/mysql/schema/002-create-admin-user.sql

echo " [server]" >>  /etc/guacamole/guacd.conf
echo "bind_host = 0.0.0.0 " >>  /etc/guacamole/guacd.conf
echo "bind_port = 4822" >> /etc/guacamole/guacd.conf


echo "mysql-hostname: 127.0.0.1" >>  /etc/guacamole/guacamole.properties
echo "mysql-port: 3306" >>  /etc/guacamole/guacamole.properties
echo "mysql-database: guacadb" >>  /etc/guacamole/guacamole.properties
echo "mysql-username: Guacamole" >>  /etc/guacamole/guacamole.properties
echo "mysql-password: mypassword" >>  /etc/guacamole/guacamole.properties


systemctl restart tomcat9 guacd mariadb;

