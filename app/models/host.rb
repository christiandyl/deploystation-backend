require 'ipaddr'

class Host < ActiveRecord::Base
  include ApiConverter

  attr_api [:id, :name, :location, :country_code, :plans_list], :private => [:ip, :domain, :created_at, :updated_at]

  has_many :plans
  has_many :containers
  
  def ip
    return IPAddr.new(super, Socket::AF_INET).to_s
  end
  
  def ip= val
    super IPAddr.new(val).to_i
  end
  
  def use    
    unless ip == '127.0.0.1'
      ssl_path = Pathname.new(Settings.general.ssl_path).join(name)

      Docker.options = {
        :client_cert => ssl_path.join('cert.pem').to_s,
        :client_key  => ssl_path.join('key.pem').to_s,
        :ssl_ca_file => ssl_path.join('ca.pem').to_s,
        :scheme      => 'https'
      }
      Docker.url = "tcp://#{ip}:2376"
    else
      Docker.url = 'unix:///var/run/docker.sock'
    end
  end
  
  def plans_list
    plans.map { |p| p.to_api(:public) }
  end
  
  def free_port
    port = nil
    
    unless ip == "127.0.0.1"
      ssl_path = Pathname.new(Settings.general.ssl_path).join(name)
      keys = [ssl_path.join('id_rsa').to_s]
      Net::SSH.start(ip, host_user, keys: keys) do |ssh|
        out  = ssh.exec!("sh /opt/scripts/get_free_port/run.sh")
        port = out.split("\n").first
      end
    else
      server = TCPServer.new('127.0.0.1', 0)
      port   = server.addr[1].to_s
      server.close if server
    end
    
    raise "Can't get free port" if port.nil?
    
    return port
  end

end
