#!/bin/bash

php artisan down

git pull
composer update
npm install
gulp v1

composer dump-autoload --optimize --profile
php artisan optimize --force
php artisan cache:clear
php artisan route:clear
php artisan config:clear

sudo chown -R www-data:www-data /var/www
sudo chmod -R o+w storage/
sudo chmod -R o+w bootstrap/cache/

php artisan migrate --force

sudo rm -R /etc/nginx/cache/*
sudo service nginx restart
sudo service php7.0-fpm restart

php artisan up
