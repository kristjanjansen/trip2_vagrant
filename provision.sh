#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Upgrade

sudo apt-get update -y 
sudo apt-get upgrade -y


# Locale

sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
sudo locale-gen en_US.UTF-8

# Packages

sudo apt-get install -y software-properties-common build-essential curl unzip imagemagick apache2-utils dos2unix gcc git libmcrypt4 libpcre3-dev supervisor

sudo apt-add-repository ppa:nginx/stable -y
sudo apt-add-repository ppa:rwky/redis -y
sudo apt-add-repository ppa:ondrej/php -y
sudo curl --silent --location https://deb.nodesource.com/setup_5.x | bash -

sudo apt-get update -y

# Set timezone

sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# PHP

sudo apt-get install -y --force-yes php7.0-cli php7.0-dev php-mysql php-curl php-gd php-imagick php7.0-mcrypt php-mbstring php7.0-readline php-xml

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

sudo apt-get install -y --force-yes nginx php7.0-fpm 

# Set Nginx settings

# sudo sed -i "s/http {/http {\n\nclient_max_body_size 128M;/" /etc/nginx/nginx.conf

# Setup Some PHP-FPM Options

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini

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

sudo mysql_tzinfo_to_sql /usr/share/zoneinfo | sudo mysql --user=root --password=secret mysql

# Node

sudo apt-get install -y nodejs
sudo /usr/bin/npm install -g gulp@3.9.0

# Redis

sudo apt-get install -y redis-server

# Enable Swap Memory

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=4096
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

# Configuring Nginx

sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/default

if [ "$ENVIRONMENT" = "local" ]; then
    sudo cp /vagrant/nginx/local /etc/nginx/sites-available/trip2
    sudo cp /vagrant/scripts/install.sh /var/www/.
    sudo cp /vagrant/scripts/update_code.sh /var/www/.
    sudo cp /vagrant/scripts/update_db.sh /var/www/.
    sudo cp /vagrant/env/.env.local /var/www/.
fi

if [ "$ENVIRONMENT" = "staging" ]; then
    sudo cp /vagrant/nginx/staging /etc/nginx/sites-available/trip2
    sudo cp /vagrant/scripts/update_db.sh /var/www/.
    sudo usermod -G sudo tripikas
    sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config 
    sudo service ssh restart
fi

if [ "$ENVIRONMENT" = "production" ]; then
    sudo cp /vagrant/nginx/production /etc/nginx/sites-available/trip2
    sudo cp /vagrant/scripts/update_db.sh /var/www/.
    sudo usermod -G sudo tripikas
    sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config 
    sudo service ssh restart
    mkdir /etc/nginx/cache
    ## Add this to /etc/fstab
    # tmpfs /etc/nginx/cache tmpfs defaults,size=256M 0 0
fi

sudo ln -fs /etc/nginx/sites-available/trip2 /etc/nginx/sites-enabled/trip2
sudo rm -Rf /var/www/html

sudo sed -i "s/# gzip_vary/gzip_vary/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_proxied/gzip_proxied/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_comp_level/gzip_comp_level/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_buffers/gzip_buffers/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_http_version/gzip_http_version/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_types.*/gzip_types text\/plain text\/css application\/json application\/javascript text\/xml application\/xml application\/xml+rss application\/atom+xml text\/javascript image\/svg+xml image\/x-icon;/" /etc/nginx/nginx.conf

sudo service nginx restart

# Generating a SSH key

sudo ssh-keygen -t rsa -b 4096 -C "trip@trip.ee" -N "" -f ~/.ssh/id_rsa
