#!/bin/bash

cd trip2
git pull
composer update --prefer-dist --no-interaction
npm install --no-bin-links
gulp
php artisan optimize --force
php artisan cache:clear
php artisan route:cache
php artisan config:cache
env $(cat trip2/.env | xargs) slackcli -h servers -m "Code updated from Github master" -u server
