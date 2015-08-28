## Installation

    cp example.settings.yml settings.yml

## Run local machine

    vagrant up

## Run Digital Ocean machine

Update ```settings.php``` with Digital Ocean API token. Then

    vagrant plugin install vagrant-digitalocean
    vagrant up --provider=digital_ocean

## Run Linode machine

Update ```settings.php``` with Linode API token. Then

    vagrant plugin install vagrant-linode
    vagrant up --provider=linode
