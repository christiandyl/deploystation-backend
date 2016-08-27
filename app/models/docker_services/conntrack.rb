module DockerServices
  class Conntrack
  
    REPOSITORY = "claesjonsson/conntrack"
  
    attr_accessor :container_id, :container
  
    def initialize attrs
      self.container_id = attrs[:container_id]
      if attrs[:container]
        self.container = attrs[:container]
        self.container_id = container.id
      end
    
      Rails.logger.debug "Conntrack initialized for container #{container_id}"
    end
  
    def clear_udp_cache
      Rails.logger.debug "Clearing cache for udp port for container-#{container_id}"

      opts = docker_opts
      # opts["Cmd"] = ["/opt/backup.sh"]

      delete_container_from_host

      dcontainer = Docker::Container.create(opts)
      dcontainer.start
      dcontainer.wait
      
      Rails.logger.debug "Creating backup for container-#{container_id} is done"
      
      delete_container_from_host
      
      return true
    end
  
    def delete_container_from_host
      container.host.use
      Docker::Container.get(container_name).delete(:force => true) rescue nil
    end
  
    private

    def docker_opts
      {
        "name"  => container_name,
        "Image" => REPOSITORY,
        "Cmd"   => ["-D", "-p", "udp", "--orig-port-dst", container.port.to_s],
        "HostConfig" => {
          "Privileged"  => true,
          "NetworkMode" => "host"
        }
      }
    end
    
    def container_name
      "conntrack-#{container.docker_container_id}"
    end
    
    def container
      @container ||= Container.find(container_id)
    end
  
  end
end