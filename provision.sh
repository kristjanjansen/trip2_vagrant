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

# Set timezone and time syncronization

sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime
sudo apt-get install ntp

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

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DB_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DB_PASSWORD"
sudo apt-get install -y mysql-server-5.6


# MySQL remote access

sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
sudo mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"
sudo mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"

# sudo mysql --user="root" --password="$DB_PASSWORD" -e "CREATE USER 'server'@'0.0.0.0' IDENTIFIED BY '$DB_PASSWORD';"
# sudo mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO 'server'@'0.0.0.0' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"
# sudo mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO 'server'@'%' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"
# sudo mysql --user="root" --password="$DB_PASSWORD" -e "FLUSH PRIVILEGES;"

sudo service mysql restart

sudo mysql_tzinfo_to_sql /usr/share/zoneinfo | sudo mysql --user=root --password=$DB_PASSWORD mysql

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

sudo rm -Rf /var/www/html

sudo sed -i "s/# gzip_vary/gzip_vary/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_proxied/gzip_proxied/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_comp_level/gzip_comp_level/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_buffers/gzip_buffers/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_http_version/gzip_http_version/" /etc/nginx/nginx.conf
sudo sed -i "s/# gzip_types.*/gzip_types text\/plain text\/css application\/json application\/javascript text\/xml application\/xml application\/xml+rss application\/atom+xml text\/javascript image\/svg+xml image\/x-icon;/" /etc/nginx/nginx.conf


if [ "$ENVIRONMENT" = "local" ]; then

    # Nginx

    sudo cp /vagrant/config/local/nginx /etc/nginx/sites-available/trip2

    # Scripts

    sudo mkdir /var/www/scripts
    sudo cp /vagrant/config/shared/install.sh /var/www/scripts/.
    sudo cp /vagrant/config/shared/update_db.sh /var/www/scripts/.
    sudo cp /vagrant/config/local/deploy.sh /var/www/scripts/.

    # Environment

    sudo cp /vagrant/config/local/.env /var/www/.

    # SSH key

    sudo ssh-keygen -t rsa -b 4096 -C "local@trip.ee" -N "" -f ~/.ssh/id_rsa

fi

if [ "$ENVIRONMENT" = "staging" ] || [ "$ENVIRONMENT" = "production" ]; then

    # Scripts

    sudo mkdir /var/www/scripts
    sudo cp /vagrant/config/shared/update_db.sh /var/www/scripts/.

    # Access

    # sudo usermod -G sudo tripikas
    # sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config 
    sudo service ssh restart

    # Permissions

    #sudo mkdir -p /var/www/trip2/storage/app/images
    #sudo chown -R www-data:www-data /var/www
    #sudo chmod -R g+rwx /var/www

    # Cron

    cron="* * * * * php /var/www/trip2/current/artisan schedule:run >> /dev/null 2>&1"
    (sudo crontab -l 2>/dev/null; echo "$cron") | sudo crontab -

    # Netdata

    sudo apt-get -y install zlib1g-dev gcc make git autoconf autogen automake pkg-config
    sudo git clone https://github.com/firehol/netdata.git --depth=1
    cd netdata
    sudo ./netdata-installer.sh --dont-wait > /dev/null 2>&1
    sudo sed -i "s/compile:/php-fpm: php-fpm7.0\ncompile:/" /etc/netdata/apps_groups.conf
    echo "mysql_opts[trip2]=\"-u root -p$DB_PASSWORD\"" | sudo tee /etc/netdata/mysql.conf
    sudo sed -i "s/# debug log = .*/debug log = syslog/" /etc/netdata/netdata.conf
    sudo sed -i "s/# error log = .*/error log = syslog/" /etc/netdata/netdata.conf
    sudo sed -i "s/# access log = .*/access log = none/" /etc/netdata/netdata.conf
    sudo sed -i "s/nothing./nothing.\n\n\/usr\/sbin\/netdata\n/" /etc/rc.local
    
    # Firewall

    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 3333/tcp # github
    sudo ufw allow 19999/tcp # netdata
    # sudo ufw --force enable

fi

if [ "$ENVIRONMENT" = "staging" ]; then

    # Scripts

    # sudo cp /vagrant/config/shared/install.sh /var/www/scripts/.
    # sudo cp /vagrant/config/shared/package.json /var/www/scripts/.
    # sudo cp /vagrant/config/shared/deploy.js /var/www/scripts/.
    # sudo cp /vagrant/config/staging/deploy.sh /var/www/scripts/.
    # sudo cp /vagrant/config/shared/example.deploy.yaml /var/www/scripts/deploy.yaml

    # sudo sed -i "s/environment: .*/environment: production/" /var/www/scripts/deploy.yaml
    # sudo sed -i "s/branch: .*/branch: master/" /var/www/scripts/deploy.yaml
    # sudo sed -i "s/slack: .*/slack: $SLACK/" /var/www/scripts/deploy.yaml

    # cd /var/www/scripts
    # npm install
    
    # Queue

    # sudo cp /vagrant/config/staging/queue.conf /etc/supervisor/conf.d/queue.conf
    # sudo supervisorctl reread
    # sudo supervisorctl update
    # sudo supervisorctl start queue:*

    # Nginx 

    sudo cp /vagrant/config/staging/nginx /etc/nginx/sites-available/trip2
    
    # SSH key

    ssh-keygen -t rsa -b 4096 -C "staging@trip.ee" -N "" -f ~/.ssh/id_rsa

    # Databases

    mysqladmin -uroot -p$DB_PASSWORD create trip
    mysqladmin -uroot -p$DB_PASSWORD create trip2

fi

if [ "$ENVIRONMENT" = "production" ]; then

    # Scripts

    sudo cp /vagrant/config/shared/install.sh /var/www/scripts/.
    sudo cp /vagrant/config/shared/package.json /var/www/scripts/.
    sudo cp /vagrant/config/shared/deploy.js /var/www/scripts/.
    sudo cp /vagrant/config/production/deploy.sh /var/www/scripts/.
    sudo cp /vagrant/config/shared/example.deploy.yaml /var/www/scripts/deploy.yaml

    sudo sed -i "s/environment: .*/environment: production/" /var/www/scripts/deploy.yaml
    sudo sed -i "s/branch: .*/branch: v1/" /var/www/scripts/deploy.yaml
    sudo sed -i "s/slack: .*/slack: $SLACK/" /var/www/scripts/deploy.yaml

    cd /var/www/scripts
    npm install

    # Environment

    sudo cp /vagrant/config/production/.env /var/www/.

    # Queue

    sudo cp /vagrant/config/production/queue.conf /etc/supervisor/conf.d/queue.conf
    sudo supervisorctl reread
    sudo supervisorctl update
    sudo supervisorctl start queue:*

    # Nginx

    sudo cp /vagrant/config/production/nginx /etc/nginx/sites-available/trip2
    sudo mkdir /etc/nginx/cache
    ## Add this to /etc/fstab
    # tmpfs /etc/nginx/cache tmpfs defaults,size=256M 0 0
    
    # SSH key

    ssh-keygen -t rsa -b 4096 -C "production@trip.ee" -N "" -f ~/.ssh/id_rsa

fi

# Final Nginx setup

sudo ln -fs /etc/nginx/sites-available/trip2 /etc/nginx/sites-enabled/trip2
sudo service nginx restart
sudo service php7.0-fpm restart