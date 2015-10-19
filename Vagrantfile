require 'yaml'

settings = YAML.load_file 'settings.yml'

Vagrant.configure(2) do |config|
  
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.ssh.forward_agent = true

  # config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder ".", "/vagrant"

  if settings['local']['trip_folder']
    config.vm.synced_folder settings['local']['trip_folder'], "/var/www/trip2", group: 'www-data', owner: 'www-data'
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision "shell" do |s|
    s.path = "provision.sh"
    s.args = [settings['global']['password']]
  end

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'ams3'
    provider.token = settings['digital_ocean']['token']
    provider.size = settings['digital_ocean']['plan']
  end

  config.vm.provider :linode do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'linode'
    override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"
    provider.distribution = 'Ubuntu 14.04 LTS'
    provider.datacenter = 'frankfurt'
    provider.api_key = settings['linode']['token']
    provider.plan = settings['linode']['plan']
  end
end