#!/bin/bash

cd trip2
git pull
composer update
npm install
gulp
php artisan optimize --force
php artisan cache:clear
php artisan route:cache
php artisan config:cache
