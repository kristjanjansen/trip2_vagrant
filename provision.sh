#!/bin/bash


# Upgrade

sudo apt-get update -y 
sudo apt-get upgrade -y


# Locale

sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
sudo locale-gen en_US.UTF-8
sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime


# Requisites

sudo apt-get install software-properties-common -y
sudo apt-get install build-essential -y
sudo apt-get install curl -y
sudo apt-get install unzip -y
sudo apt-get install imagemagick -y
sudo apt-get install apache2-utils -y

sudo apt-get install -y dos2unix gcc git libmcrypt4 libpcre3-dev 

sudo apt-add-repository ppa:nginx/stable -y
sudo apt-add-repository ppa:rwky/redis -y
sudo apt-add-repository ppa:chris-lea/node.js -y
sudo apt-add-repository ppa:ondrej/php5-5.6 -y

sudo apt-get update -y


# PHP

sudo apt-get install -y php5-cli php5-mysqlnd php5-json php5-curl php5-gd php5-mcrypt php5-memcached php5-imagick


# Make MCrypt Available

sudo ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt


# Composer

sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo printf "\nPATH=\"/home/vagrant/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile


# Set PHP CLI Settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/cli/php.ini


# Nginx and PHP-FPM

sudo apt-get install -y nginx php5-fpm
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

# Set Nginx settings

sudo sed -i "s/http {/http {\n\nclient_max_body_size 100M;/" /etc/nginx/nginx.conf


# Set PHP-FPM settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/fpm/php.ini

sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php5/fpm/php.ini


# Restart

sudo service nginx restart
sudo service php5-fpm restart


# Install MySQL

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
sudo apt-get install -y mysql-server-5.6


# MySQL remote access

sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"

# sudo mysql --user="root" --password="secret" -e "CREATE USER 'server'@'0.0.0.0' IDENTIFIED BY 'secret';"
# sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'server'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
# sudo mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'server'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
# sudo mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"

sudo service mysql restart

# Node

sudo apt-add-repository ppa:chris-lea/node.js -y
sudo apt-get update -y
sudo apt-get install -y nodejs
sudo /usr/bin/npm install -g gulp

# Redis

sudo apt-get install -y redis-server

# Other

# sudo apt-get install -y memcached beanstalkd

# Enable Swap Memory

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

# You might need to to reenter this later 

sudo swapon /swapfile


# Final steps

sudo cp /vagrant/trip2.nginx /etc/nginx/sites-available/trip2
sudo ln -fs /etc/nginx/sites-available/trip2 /etc/nginx/sites-enabled/trip2
sudo rm -R /var/www/html

sudo cp /vagrant/.htpasswd /etc/nginx/

sudo cp /vagrant/scripts/* /var/www/.

sudo ssh-keygen -t rsa -b 4096 -C "trip@trip.ee" -N "" -f ~/.ssh/id_rsa