#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Upgrade

sudo apt-get update -y 
sudo apt-get upgrade -y


# Locale

sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
sudo locale-gen en_US.UTF-8

# Repositories

sudo apt-get install -y software-properties-common build-essential curl unzip imagemagick apache2-utils dos2unix gcc git libmcrypt4 libpcre3-dev 

sudo apt-add-repository ppa:nginx/stable -y
sudo apt-add-repository ppa:rwky/redis -y
sudo apt-add-repository ppa:ondrej/php -y
sudo curl --silent --location https://deb.nodesource.com/setup_5.x | bash -

sudo apt-get update -y

# Set timezone

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP

sudo apt-get install -y --force-yes php7.0-cli php7.0-dev php-mysql php-curl php-gd php-imagick php7.0-mcrypt php-mbstring php7.0-readline php-xml

# Make MCrypt Available

#sudo ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
#sudo php5enmod mcrypt


# Composer

sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo printf "\nPATH=\"/home/vagrant/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile


# Set PHP CLI Settings

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini


# Nginx and PHP-FPM

sudo apt-get install -y --force-yes nginx nginx-extras php7.0-fpm 
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default

# Set Nginx settings

# sudo sed -i "s/http {/http {\n\nclient_max_body_size 128M;/" /etc/nginx/nginx.conf

# Setup Some PHP-FPM Options

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/7.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini

# Copy fastcgi_params to Nginx

sudo cat > /etc/nginx/fastcgi_params << EOF
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

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=secret mysql

# Node

sudo apt-get install -y nodejs
sudo /usr/bin/npm install -g gulp slack-cli

# Redis

sudo apt-get install -y redis-server

# Other

# sudo apt-get install -y memcached beanstalkd

# Enable Swap Memory

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=4096
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

# Configuring Nginx

if [ "$CACHE" = "true" ]; then
    sudo cp /vagrant/trip2_cache.nginx /etc/nginx/sites-available/trip2
    mkdir /etc/nginx/cache
    ## Add this to /etc/fstab
    # tmpfs /etc/nginx/cache tmpfs defaults,size=128M 0 0

else
    sudo cp /vagrant/trip2.nginx /etc/nginx/sites-available/trip2
fi

if [ "$ENVOYER" = "true" ]; then
    sed -i "s/trip2\/public/trip2\/current\/public/" /etc/nginx/sites-available/trip2
fi

sudo ln -fs /etc/nginx/sites-available/trip2 /etc/nginx/sites-enabled/trip2
sudo rm -R /var/www/html

sudo service nginx restart

# Copying scripts

sudo cp /vagrant/scripts/* /var/www/.

# Generating a SSH key

sudo ssh-keygen -t rsa -b 4096 -C "trip@trip.ee" -N "" -f ~/.ssh/id_rsa
