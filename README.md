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

You'll need to pass your public key to the old trip server first. In virtual machine run

    cat /root/.ssh/id_rsa.pub

and pass it to admin. Then:

    ./update_db.sh secret trip-remote-db-password

## Advaced setup

### Run Digital Ocean machine

#### Setup

Update ```settings.php``` with Digital Ocean API token (API > Your Tokens).
Also, set ```trip_folder: false```.

#### Install

    vagrant plugin install vagrant-digitalocean
    vagrant up --provider=digital_ocean
    vagrant ssh

#### When inside virtual machine

    cd /var/www
    git clone https://github.com/tripikad/trip2.git
    ./install.sh secret

### Run Linode machine

#### Setup

Update ```settings.php``` with Linode API token (My Profile > API Keys).
Also, set ```trip_folder: false```.

#### Install

    vagrant plugin install vagrant-linode
    vagrant up --provider=linode
    vagrant ssh

### When inside virtual machine

    cd /var/www
    git clone https://github.com/tripikad/trip2.git
    ./install.sh secret
    