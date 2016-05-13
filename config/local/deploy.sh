#!/bin/bash

cd trip2

git pull
composer install --no-interaction
npm install --no-bin-links
gulp

php artisan optimize --force
php artisan cache:clear
php artisan route:clear
php artisan config:clear

sudo chown -R www-data:www-data /var/www/trip2
sudo chmod -R o+w storage/
sudo chmod -R o+w bootstrap/cache/

    