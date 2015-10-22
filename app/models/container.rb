class Container < Docker::Container
  include ApiConverter

  ASYNC = false

  attr_api [:id, :info]
  
  def self.get_free_port
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    
    return port.to_s
  end
  
  def self.create opts
    Rails.logger.debug "Creating container with params: #{opts.to_s}"

    container = super(opts)
    unless ASYNC
      container.wait
      Rails.logger.debug "Container(#{container.id}) has created"
    end
    
    return container
  end
  
  def self.class_for game
    cname = "container_#{game}".classify.constantize
    raise "#{cname} is not supported" if defined?(cname) == nil
    
    return cname
  end
  
  def start
    Rails.logger.debug "Starting container(#{id})"
    super
    unless ASYNC
      wait
      Rails.logger.debug "Container(#{id}) has started"
    end
  end
  
  def restart
    Rails.logger.debug "Restarting container(#{id})"
    super
    unless ASYNC
      wait
      Rails.logger.debug "Container(#{id}) has restarted"
    end
  end
  
  def stop
    Rails.logger.debug "Stopping container(#{id})"
    super
    unless ASYNC
      wait
      Rails.logger.debug "Container(#{id}) has stopped"
    end
  end
  
  def image
    Image.get(info["Image"])
  end
  
end