#!/bin/bash

# env $(cat trip2/.env | xargs) slackcli -h servers -m "Starting updating code from Github master" -u server

cd trip2
git pull
composer install --prefer-dist --no-interaction
npm install --no-bin-links
gulp
php artisan optimize --force
php artisan cache:clear
php artisan route:cache
php artisan config:cache

#cd ..
#env $(cat trip2/.env | xargs) slackcli -h servers -m "Code updated from Github master" -u server
