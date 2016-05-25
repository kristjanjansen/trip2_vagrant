## Installation

### Local Vagrant

Run

    git clone https://github.com/tripikad/trip2_vagrant
    git clone https://github.com/tripikad/trip2
    cd trip2_vagrant
    cp example.settings.yml settings.yml

Then

    vagrant up
    vagrant ssh

When logged inside virtual machine, set up you root password

    sudo passwd

Then enter your root password
    
    su

Then

```sh
cd /var/www/scripts
./install.sh your-db-password # secret
```

### Remote Digital Ocean or Linode server

First install respective Vagrant plugin:

    vagrant plugin install vagrant-digitalocean

or

    vagrant plugin install vagrant-linode

Then update ```settings.yaml``` with Digital Ocean or Linode API token. Also set the environment to ```staging``` or ```production```.

Then run

    vagrant up --provider=digital_ocean
    vagrant ssh

When logged inside virtual machine

    cd /var/www
    git clone https://github.com/tripikad/trip2.git
    ./var/www/scripts/install.sh your-db-password