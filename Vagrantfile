Vagrant.configure(2) do |config|
  
  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, ip: '192.168.50.50'
  config.ssh.forward_agent = true
  
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

end