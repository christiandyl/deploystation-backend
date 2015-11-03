module ApiDeploy
  class ContainerMinecraft < Container
  
    REPOSITORY = 'itzg/minecraft-server'
  
    def self.create user, plan
      memory = plan.ram * 1000000
      
      docker_opts = {
        "Image"        => REPOSITORY,
        "Cmd"          => "/start",
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "HostConfig"   => {
          "Memory"     => memory
          # "MemorySwap" => -1,
          # "CpuShares"  => 1
        },
        "ExposedPorts" => { "25565/tcp": {} },
        "PortBindings" => { "25565/tcp" => [{ "HostIp" => "127.0.0.1", "HostPort" => available_port }] },
        "Env"          => ["EULA=TRUE"]
      }
      
      super(user, plan, docker_opts)
    end
  
    def start opts={}
      opts = {
        "PortBindings" => { "25565/tcp" => [{ "HostIp" => "", "HostPort" => port }] } 
      }
      super(opts)
    end
  
    def command name, args
      if name == "kill_player"
        send("command_#{name}", args)
      end
    end
  
    def command_kill_player args
      player_name = args[:player_name] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "kill #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container - Minecraft - #{id} : Player #{player_name} has kicked from the game"
      
      return true
    end
  
  end
end