require 'yaml'

settings = YAML.load_file 'settings.yml'

Vagrant.configure(2) do |config|
  
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.ssh.forward_agent = true

  config.vm.synced_folder ".", "/vagrant"

  if settings['environment'] == 'local'
    config.vm.synced_folder settings['trip_folder'], "/var/www/trip2", group: 'www-data', owner: 'www-data'
    config.vm.synced_folder settings['trip_folder'] + "/storage/app/images", "/var/www/trip2/public/images", group: 'www-data', owner: 'www-data'
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "3072"]
  end

  config.vm.provision "shell" do |s|
    s.path = "provision.sh"
    s.env = {
      "ENVIRONMENT" => settings['environment'],
      "DB_PASSWORD" => settings['db_password'],
      "REMOTE_DB_PASSWORD" => settings['remote_db_password'],
      "SLACK" => settings['slack'],
      "PAPERTRAIL_DOMAIN" => settings['papertrail_domain'],
      "PAPERTRAIL_PORT" => settings['papertrail_port'],
      "MAIL_USERNAME" => settings['mail_username'],
      "MAIL_PASSWORD" => settings['mail_password']
    }
  end

  config.vm.provider :digital_ocean do |provider, override|
    # override.ssh.username = "tripikas"
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.hostname = settings['name']
    override.vm.box = 'digital_ocean'
    override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'fra1'
    provider.token = settings['token']
    provider.size = settings['plan']
  end

  config.vm.provider :linode do |provider, override|
    override.ssh.username = "tripikas"
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'linode'
    override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"
    provider.distribution = 'Ubuntu 14.04 LTS'
    provider.datacenter = 'frankfurt'
    provider.api_key = settings['token']
    provider.plan = settings['plan']
    provider.label = settings['name']
  end

end