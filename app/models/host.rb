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

end
