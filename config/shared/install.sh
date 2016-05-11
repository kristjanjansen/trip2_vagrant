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


        sudo chown -R www-data:www-data /var/www
        sudo chmod -R o+w bootstrap/cache/
        sudo chmod -R o+w storage/
        
        mkdir -p storage/app/images/large
        mkdir -p storage/app/images/medium
        mkdir -p storage/app/images/original
        mkdir -p storage/app/images/small
        mkdir -p storage/app/images/small_square
        mkdir -p storage/app/images/xsmall_square

        sudo ln -s storage/app/images public/images

        php artisan optimize --force
        php artisan cache:clear
        php artisan route:clear
        php artisan config:clear

        mysqladmin -uroot -p$1 create trip
        mysqladmin -uroot -p$1 create trip2

        php artisan migrate

    fi

fi
