module ApiDeploy
  class ContainerMinecraft < Container
  
    REPOSITORY = 'overshard/minecraft'
  
    def self.create user
      uuid = SecureRandom.uuid
      port = Helper.get_free_port
      
      docker_opts = {
        'Image'        => REPOSITORY,
        'Cmd'          => '/start',
        "HostConfig"   => { "Binds" => ["/mnt/#{uuid}:/data"] },
        "PortBindings" => { "25565/tcp": [{ "HostPort": port }] }
      }
      
      super(user, docker_opts)
    end
  
    def ban_user user_id
    end
  
    def unban_user user_id
    end
  
  end
end