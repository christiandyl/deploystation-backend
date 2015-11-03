require 'ipaddr'

class Host < ActiveRecord::Base

  belongs_to :plan
  has_many   :containers
  
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
      Docker.url = 'tcp://195.69.187.71:2376'
    else
      Docker.url = 'unix:///var/run/docker.sock'
    end
  end

end
