require 'yaml'

settings = YAML.load_file 'settings.yml'

Vagrant.configure(2) do |config|
  
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.ssh.forward_agent = true

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "virtualbox" do |provider|
    provider.config.vm.synced_folder settings['local']['repo_path'], settings['local']['base_path'], group: 'www-data', owner: 'www-data'
    provider.customize ["modifyvm", :id, "--memory", "2048"]
    provider.vm.provision "shell" do |s|
      s.path = "provision.sh"
      s.args = [settings['local']['db_password'], settings['local']['base_path'],settings['local']['public_path']]
    end
  end

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'ams3'
    provider.token = settings['digital_ocean']['token']
    provider.size = settings['digital_ocean']['plan']
    provider.vm.provision "shell" do |s|
      s.path = "provision.sh"
      s.args = [settings['digital_ocean']['db_password'], settings['digital_ocean']['base_path'],settings['digital_ocean']['public_path']]
    end
  end

  config.vm.provider :linode do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'linode'
    override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"
    provider.distribution = 'Ubuntu 14.04 LTS'
    provider.datacenter = 'frankfurt'
    provider.api_key = settings['linode']['token']
    provider.plan = settings['linode']['plan']
    provider.vm.provision "shell" do |s|
      s.path = "provision.sh"
      s.args = [settings['linode']['db_password'], settings['linode']['base_path'],settings['linode']['public_path']]
    end
  end

end