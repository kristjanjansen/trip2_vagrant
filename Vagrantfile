Vagrant.configure(2) do |config|
  
  config.vm.box = "ubuntu/trusty64"

  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.ssh.forward_agent = true

  # config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder ".", "/vagrant"

  # config.vm.synced_folder "../trip2", "/var/www/trip2", group: 'www-data', owner: 'www-data'

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.provision "shell" do |s|
    s.path = "provision.sh"
  end

  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    provider.token = '0c2b79a731cd4f39565838a2cf22b461ba5fe4f3d3f20f9fa19aefa3fc4cc4c3'
    provider.image = 'ubuntu-14-04-x64'
    provider.region = 'ams3'
    provider.size = '512mb'
  end

end