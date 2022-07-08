#!/bin/bash
clear
echo
#This creates apache configuration file named wordpress.conf
echo "What is you WordPress site Domain?  "
read wpdomain1
echo "<VirtualHost *:80>" | tee -a /tmp/wordpress.conf
echo ServerName $wpdomain1 | tee -a /tmp/wordpress.conf
echo "RewriteEngine On" | tee -a /tmp/wordpress.conf
echo "    RewriteCond %{REQUEST_URI} !^/\.well\-known/acme\-challenge/" | tee -a /tmp/wordpress.conf
echo "    RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]" | tee -a /tmp/wordpress.conf
echo "</VirtualHost>" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "<VirtualHost *:443>" | tee -a /tmp/wordpress.conf
echo "        SSLStrictSNIVHostCheck on" | tee -a /tmp/wordpress.conf
echo "        Protocols h2 h2c http/1.1" | tee -a /tmp/wordpress.conf
echo         ServerName $wpdomain1 | tee -a /tmp/wordpress.conf
echo "        DocumentRoot /var/www/wordpress" | tee -a /tmp/wordpress.conf
echo "        LogLevel warn" | tee -a /tmp/wordpress.conf
echo "        <Directory /var/www/wordpress>" | tee -a /tmp/wordpress.conf
echo "               AllowOverride All" | tee -a /tmp/wordpress.conf
echo "#          Require all granted" | tee -a /tmp/wordpress.conf
echo "        </Directory>" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "SSLEngine on" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "		SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem" | tee -a /tmp/wordpress.conf
echo "                SSLCertificateKeyFile	/etc/ssl/private/ssl-cert-snakeoil.key" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "    # intermediate configuration" | tee -a /tmp/wordpress.conf
echo "SSLProtocol            all -SSLv3 -TLSv1 -TLSv1.1" | tee -a /tmp/wordpress.conf
echo "SSLCipherSuite         ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384" | tee -a /tmp/wordpress.conf
echo "SSLHonorCipherOrder     on" | tee -a /tmp/wordpress.conf
echo "SSLSessionTickets       off" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "    # HSTS (mod_headers is required) (15768000 seconds = 6 months)" | tee -a /tmp/wordpress.conf
echo "    Header always add Strict-Transport-Security "max-age=15768000"" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "SSLUseStapling on" | tee -a /tmp/wordpress.conf
echo "SSLStaplingResponderTimeout 5" | tee -a /tmp/wordpress.conf
echo "SSLStaplingReturnResponderErrors off" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "CustomLog /var/log/apache2/wp.log combined" | tee -a /tmp/wordpress.conf
echo ServerAlias $wpdomain1 | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "</VirtualHost>" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "" | tee -a /tmp/wordpress.conf
echo "SSLStaplingCache shmcb:/var/run/ocsp(128000)" | tee -a /tmp/wordpress.conf

clear
# end of the creation of wordpress.conf


#This will install the packages
sudo apt clean
sudo apt update
sudo apt full-upgrade -y
sudo apt install wget apache2 libapache2-mod-security2 socat php libapache2-mod-php php-common php-mbstring php-xmlrpc php-soap php-gd php-xml php-intl php-mysql php-cli php-ldap php-zip php-curl mariadb-server -y

#This will download and configure wordpress
wget -c https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
sudo mkdir /var/www/wordpress
sudo mv wordpress/ /var/www/
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod 755 -R /var/www/wordpress/
sudo cp /tmp/wordpress.conf /etc/apache2/sites-available/
sudo chown root /etc/apache2/sites-available//tmp/wordpress.conf
sudo chmod 644 /etc/apache2/sites-available//tmp/wordpress.conf
sudo a2ensite wordpress.conf
sudo a2enmod ssl http2 headers rewrite socache_shmcb security2 alias

#This generates a random signature to prevent users knowing the OS for security reasons
sudo echo SecServerSignature $RANDOM | sudo tee -a /etc/apache2/apache2.conf > /dev/null

sudo systemctl restart apache2
sudo rm latest.tar.gz



sudo mysql -u root -e "CREATE DATABASE wordpress;"

read -p  "Username for the databate: " user
read -p "Password for that user: " password

sudo mysql -u root -e "GRANT ALL PRIVILEGES on wordpress.* TO '$user'@'localhost' IDENTIFIED BY '$password';"

sudo mysql -u root -e "FLUSH PRIVILEGES;"

clear
echo
echo When asked for the root password just press enter for none and then set a new password.
echo
echo Just press enter for everything else
echo
sudo mysql_secure_installation

clear
echo **DELETE IS FILE AFTER READING IT** | tee -a wpuserdata.txt
echo The Domain is $wpdomain1 |tee wpuserdata.txt
echo Database name is wordpress | tee -a wpuserdata.txt
echo Username is $user | tee -a wpuserdata.txt
echo Chosen password is $password | tee -a wpuserdata.txt
echo **DELETE IS FILE AFTER READING IT** | tee -a wpuserdata.txt

echo edit the file /etc/apache2/sites-available//tmp/wordpress.conf
rm /tmp/wordpress.conf
