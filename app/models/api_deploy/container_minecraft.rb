module ApiDeploy
  class ContainerMinecraft < Container
  
    REPOSITORY = 'overshard/minecraft'
  
    def self.create user, plan
      uuid = SecureRandom.uuid
      name = "minecraft_server_#{uuid}"
      
      docker_opts = {
        "Name"         => name,
        "Image"        => REPOSITORY,
        "Cmd"          => "/start",
        # "HostConfig"   => { "Binds" => ["/mnt/#{name}:/data"] },
        "ExposedPorts" => { "25565/tcp": {} },
        "PortBindings" => { "25565/tcp" => [{ "HostIp" => "127.0.0.1", "HostPort" => available_port }] }
      }
      
      super(user, plan, docker_opts)
    end
  
    def start opts={}
      opts = { "PortBindings" => { "25565/tcp" => [{ "HostIp" => "", "HostPort" => port }] } }
      super(opts)
    end
  
    def ban_user user_id
    end
  
    def unban_user user_id
    end
  
  end
end