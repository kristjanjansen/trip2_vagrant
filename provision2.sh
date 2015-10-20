#!/bin/bash

sudo sed -i "s/root \/var\/www\/trip2\/public;/root $1;/" /etc/nginx/sites-available/trip2
sudo service nginx restart