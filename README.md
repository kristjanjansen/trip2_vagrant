## Installation

    git clone https://github.com/tripikad/trip2_vagrant
    git clone https://github.com/tripikad/trip2
    cd trip2_vagrant
    cp example.settings.yml settings.yml

## Run local machine

### In local machine

    vagrant up
    vagrant ssh

### When inside virtual machine

Set your root password:

    sudo passwd

Enter your root password:
    
    su

Then

    cd /var/www
    ./install.sh secret

## Get the data

You'll need to pass your public key to the old trip server first.

Then, in virtual machine:

    ./update_db secret trip-remote-db-password

## Advaced setup

### Run Digital Ocean machine

Update ```settings.php``` with Digital Ocean API token. Then

    vagrant plugin install vagrant-digitalocean
    vagrant up --provider=digital_ocean

### Run Linode machine

Update ```settings.php``` with Linode API token. Then

    vagrant plugin install vagrant-linode
    vagrant up --provider=linode
    vagrant provision
