#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./install.sh local-db-password"
else
    cd trip2
    composer install --prefer-source
    cp .env.example .env
    php artisan key:generate
    npm install --no-bin-links
    gulp

    sudo chown -R www-data:www-data /var/www
    sudo chmod -R o+w bootstrap/cache/
    sudo chmod -R o+w storage/
    sudo chmod -R o+w public/images/

    mysqladmin -uroot -p$1 create trip
    mysqladmin -uroot -p$1 create trip2

    echo "

DB_HOST1=127.0.0.1
DB_DATABASE1=trip
DB_USERNAME1=root
DB_PASSWORD1=$1

DB_HOST2=127.0.0.1
DB_DATABASE2=trip2
DB_USERNAME2=root
DB_PASSWORD2=$1

DB_CONNECTION=trip2

CONVERT_TAKE=20
CONVERT_FILES=false
CONVERT_SCRAMBLE=true" >> .env
    
    php artisan migrate

fi