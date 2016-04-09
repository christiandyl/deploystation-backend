VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = 'ubuntu/trusty64'

  config.vm.network :forwarded_port, guest: 3000, host: 3000

  config.ssh.forward_agent = true

  config.vm.provider 'virtualbox' do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = '2048'
  end

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks']

    chef.add_recipe 'apt'
    chef.add_recipe 'dpkg_packages'
    chef.add_recipe 'rvm::system'
    chef.add_recipe 'rvm::vagrant'
    chef.add_recipe 'postgresql::server'
    chef.add_recipe 'postgresql::contrib'
    chef.add_recipe 'postgresql::libpq'
    chef.add_recipe 'redis::server'

    # Install Redis, PostgreSQL and Ruby with RVM
    chef.json = {
      dpkg_packages: {
        pkgs: {
          'phantomjs'   => { "action": "install" },
          'imagemagick' => { "action": "install" },
          'vim'         => { "action": "install" },
          'git'         => { "action": "install" },
          'nodejs'      => { "action": "install" }
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
      }
    }
  end

  config.vm.provision 'shell', inline: "echo 'yes' | sudo apt-get autoremove"
end