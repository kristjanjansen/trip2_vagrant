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



