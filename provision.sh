#!/usr/bin/env bash

# Update system
sudo apt update -y --nogpgcheck

# Install some useful programs
sudo apt install nano wget -y

# Install apache2
sudo apt install apache2 -y

# Install mariadb/mysql
sudo apt install mariadb-server -y

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Enable and start MariaDB
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Setting up php. Current php version support by IonCube that WHMCS needs to run is 7.0 so we setup that one

# Install php
sudo apt install php php-fpm php-cli php-common php-gd php-zip php-soap php-xmlrpc php-mbstring php-mcrypt php-mysql php-pdo php-pear php-xml php-curl php-imap libapache2-mod-php composer -y

# Config for this php install is at /etc/php.ini

# Restart apache to take this new php setup up
sudo systemctl restart apache2.service

# Enable php-fpm and start it
sudo systemctl enable php7.0-fpm
sudo systemctl start php7.0-fpm

# Done with php and its extentions for NOW...

# Installation of IonCube shitware
# Lets move to ~ for this download
cd ~

# Download latest ioncube loader package
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

# Extract it
tar xfz ioncube_loaders_lin_x86-64.tar.gz

# Move it to extention folder
cp ~/ioncube/ioncube_loader_lin_7.0.so /usr/lib/php/20151012/

# Configure php.ini to enable and pick up ioncube
cat <<EOT >> /etc/php/7.0/apache2/php.ini

# This enables ioncube extentions
zend_extension = /usr/lib/php/20151012/ioncube_loader_lin_7.0.so

EOT

# Restart apache and php-fpm so they pickup ioncube extention
sudo systemctl restart apache2.service
sudo systemctl restart php7.0-fpm.service


# Download WHMCS installation
cd /var/www/html/

wget https://dl.dropboxusercontent.com/s/gwsn5f4n34kiqg0/whmcs.tar.gz

# Extract it
tar -xzf whmcs.tar.gz

# Copy configuration.php.new to configuration.php || In packaged installed configuration.php is already copied. In other package is used 
# Uncommend following line to create configuration.php copy.
# cp whmcs/configuration.php.new whmcs/configuration.php

# Set each file chmod
# adjust permissions
sudo chmod 775 /var/www/html/whmcs/configuration.php
sudo chmod 777 /var/www/html/whmcs/attachments -R
sudo chmod 777 /var/www/html/whmcs/downloads -R
sudo chmod 777 /var/www/html/whmcs/templates_c -R

#Adjust ownership of files
sudo chown ubuntu:www-data -R /var/www/html/


# Create database and database user with restricted privileges 
mysql -uroot -e "CREATE DATABASE WHMCS"
echo "Created database with name WHMCS."
mysql -uroot -e "CREATE USER 'whmcs_admin'@'localhost' IDENTIFIED BY 'password'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON WHMCS.* TO 'whmcs_admin'@'localhost'"

echo "Created user with name whmcs_admin for WHMCS database. Password is 'password'. Run mysql_secure_installation if you want."

sudo systemctl restart apache2.service
sudo systemctl restart php7.0-fpm.service

echo "All is done, use this box to develop WHMCS modules. Add WHMCS files and remap apache from /var/www/html to /var/www/html/whmcs for easier access. Server IP is maped to 192.168.88.225 ."

echo "Read more about installing WHMCS here: http://docs.whmcs.com/Installing_WHMCS"

echo "Author Darko Demic. Have a good day."
