VAGRANTFILE_API_VERSION = '2'

$script = <<SCRIPT
echo Adding docker permissions to vagrant user
sudo groupadd docker
sudo usermod -aG docker vagrant
echo Pulling docker images
docker pull itzg/minecraft-server
docker pull deploystation/mcpeserver
docker pull deploystation/csgoserver
echo Finishing provision
echo 'yes' | sudo apt-get autoremove
date > /etc/vagrant_provisioned_at
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'

  # config.vm.network :private_network, ip: "192.168.50.50"
  config.vm.network :public_network
  # config.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  # config.vm.customize ["modifyvm", :id, "--natdnsproxy1", "on"]


  config.ssh.forward_agent = true

  config.vm.provider 'virtualbox' do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = '3072'
  end

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    # chef.version = "12.10.40"
    chef.cookbooks_path = ['cookbooks']

    chef.add_recipe 'apt'
    chef.add_recipe 'dpkg_packages'
    chef.add_recipe 'rvm::system'
    chef.add_recipe 'rvm::vagrant'
    chef.add_recipe 'postgresql::server'
    chef.add_recipe 'postgresql::contrib'
    chef.add_recipe 'postgresql::libpq'
    chef.add_recipe 'redis::server'
    chef.add_recipe 'timezone-ii'

    # Install Redis, PostgreSQL and Ruby with RVM
    chef.json = {
      dpkg_packages: {
        pkgs: {
          'phantomjs'   => { "action": "install" },
          'imagemagick' => { "action": "install" },
          'vim'         => { "action": "install" },
          'git'         => { "action": "install" },
          'nodejs'      => { "action": "install" },
          'docker.io'   => { "action": "install" }
        }
      },
      postgresql: {
        :shared_buffers           => '512MB',
        :shared_preload_libraries => 'pg_stat_statements',
        :users                    => [{
          :username   => 'vagrant',
          :superuser  => true,
          :createdb   => true,
          :createrole => true,
          :login      => true
        }],
        :databases => [{
          :name       => 'deploystation_development',
          :owner      => 'vagrant',
          :template   => 'template0',
          :encoding   => 'UTF-8',
          :locale     => 'en_US.UTF-8',
          :extensions => ['hstore', 'dblink'],
          :postgis    => true
        },{
          :name       => 'deploystation_test',
          :owner      => 'vagrant',
          :template   => 'template0',
          :encoding   => 'UTF-8',
          :locale     => 'en_US.UTF-8',
          :extensions => ['hstore', 'dblink'],
          :postgis    => true          
        }]
      },
      rvm: {
        default_ruby: '2.2.3',
        global_gems: [
          { name: 'bundler' }
        ],
        vagrant: {
          system_chef_solo: '/opt/chef/bin/chef-solo'
        }
      },
      tz: "UTC"
    }
  end

  config.vm.provision 'shell', inline: $script
end