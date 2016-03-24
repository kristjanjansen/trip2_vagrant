#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./install.sh local-db-password"
else

    if [ ! -d "trip2" ]; then
        echo "trip2 directory does not exist. Clone it from Github first"
    else

        mv .env.local trip2/.

        cd trip2
        composer install --no-interaction

        mv .env.local .env
        php artisan key:generate
        sudo sed -i "s/DB_PASSWORD1=.*/DB_PASSWORD1=$1/" .env
        sudo sed -i "s/DB_PASSWORD2=.*/DB_PASSWORD2=$1/" .env

        npm install --no-bin-links
        npm install gulp-sass@2
        gulp

        sudo chown -R www-data:www-data /var/www
        sudo chmod -R o+w bootstrap/cache/
        sudo chmod -R o+w storage/
        sudo chmod -R o+w public/images/

        mysqladmin -uroot -p$1 create trip
        mysqladmin -uroot -p$1 create trip2

        php artisan migrate

    fi

fi
