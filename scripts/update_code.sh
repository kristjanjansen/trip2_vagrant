#!/bin/bash

cd trip2
git pull
composer update
npm install
gulp
php artisan cache:clear