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
sudo apt-add-repository ppa:ondrej/php-7.0 -y

sudo apt-get update -y


# PHP

sudo apt-get install -y --force-yes php7.0-cli php7.0-dev \
php-pgsql php-sqlite3 php-gd \
php-curl php7.0-dev \
php-imap php-mysql

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

sudo apt-get install -y --force-yes nginx php7.0-fpm
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

# Set Nginx settings

sudo sed -i "s/http {/http {\n\nclient_max_body_size 100M;/" /etc/nginx/nginx.conf

# Set PHP-FPM settings

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini

# Copy fastcgi_params to Nginx because they broke it on the PPA

cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param   QUERY_STRING        \$query_string;
fastcgi_param   REQUEST_METHOD      \$request_method;
fastcgi_param   CONTENT_TYPE        \$content_type;
fastcgi_param   CONTENT_LENGTH      \$content_length;
fastcgi_param   SCRIPT_FILENAME     \$request_filename;
fastcgi_param   SCRIPT_NAME     \$fastcgi_script_name;
fastcgi_param   REQUEST_URI     \$request_uri;
fastcgi_param   DOCUMENT_URI        \$document_uri;
fastcgi_param   DOCUMENT_ROOT       \$document_root;
fastcgi_param   SERVER_PROTOCOL     \$server_protocol;
fastcgi_param   GATEWAY_INTERFACE   CGI/1.1;
fastcgi_param   SERVER_SOFTWARE     nginx/\$nginx_version;
fastcgi_param   REMOTE_ADDR     \$remote_addr;
fastcgi_param   REMOTE_PORT     \$remote_port;
fastcgi_param   SERVER_ADDR     \$server_addr;
fastcgi_param   SERVER_PORT     \$server_port;
fastcgi_param   SERVER_NAME     \$server_name;
fastcgi_param   HTTPS           \$https if_not_empty;
fastcgi_param   REDIRECT_STATUS     200;
EOF

# Restart

sudo service nginx restart
sudo service php7.0-fpm restart


# Install MySQL

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"
sudo apt-get install -y mysql-server-5.6


# MySQL remote access

sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
sudo mysql --user="root" --password="$1" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY '$1' WITH GRANT OPTION;"
sudo mysql --user="root" --password="$1" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"

# sudo mysql --user="root" --password="$1" -e "CREATE USER 'server'@'0.0.0.0' IDENTIFIED BY '$1';"
# sudo mysql --user="root" --password="$1" -e "GRANT ALL ON *.* TO 'server'@'0.0.0.0' IDENTIFIED BY '$1' WITH GRANT OPTION;"
# sudo mysql --user="root" --password="$1" -e "GRANT ALL ON *.* TO 'server'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;"
# sudo mysql --user="root" --password="$1" -e "FLUSH PRIVILEGES;"

sudo service mysql restart

# Add Timezone Support To MySQL

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=secret mysql

# Node

sudo apt-add-repository ppa:chris-lea/node.js -y
sudo apt-get update -y
sudo apt-get install -y nodejs
sudo /usr/bin/npm install -g gulp slack-cli

# Redis

sudo apt-get install -y redis-server

# Other

# sudo apt-get install -y memcached beanstalkd

# Enable Swap Memory

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile

sudo swapon /swapfile


# Final steps

sudo cp /vagrant/trip2.nginx /etc/nginx/sites-available/trip2
sudo ln -fs /etc/nginx/sites-available/trip2 /etc/nginx/sites-enabled/trip2
sudo rm -R /var/www/html

sudo cp /vagrant/.htpasswd /etc/nginx/

sudo cp /vagrant/scripts/* /var/www/.

sudo ssh-keygen -t rsa -b 4096 -C "trip@trip.ee" -N "" -f ~/.ssh/id_rsa
