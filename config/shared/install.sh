#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./install.sh db_password"
else

    if [ ! -d "../trip2" ]; then
        echo "trip2 directory does not exist. Clone it from Github first"
    else

        cd ../trip2

        cp ../.env .env

        composer install --prefer-dist --no-interaction

        php artisan key:generate
        sudo sed -i "s/DB_PASSWORD1=.*/DB_PASSWORD1=$1/" .env
        sudo sed -i "s/DB_PASSWORD2=.*/DB_PASSWORD2=$1/" .env

        npm install
        gulp

        mkdir -p /var/www/trip2/storage/app/images/large
        mkdir -p /var/www/trip2/storage/app/images/medium
        mkdir -p /var/www/trip2/storage/app/images/original
        mkdir -p /var/www/trip2/storage/app/images/small
        mkdir -p /var/www/trip2/storage/app/images/small_square
        mkdir -p /var/www/trip2/storage/app/images/xsmall_square

        sudo ln -s /var/www/trip2/storage/app/images /var/www/trip2/public/images

        sudo chown -R www-data:www-data /var/www/trip2
        sudo chmod -R o+w /var/www/trip2/bootstrap/cache/
        sudo chmod -R o+w /var/www/trip2/storage/
        
        php artisan optimize --force
        php artisan cache:clear
        php artisan route:clear
        php artisan config:clear

        mysqladmin -uroot -p$1 create trip
        mysqladmin -uroot -p$1 create trip2

        php artisan migrate

        sudo supervisorctl start queue:*
    fi

fi
