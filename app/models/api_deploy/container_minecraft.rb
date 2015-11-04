module ApiDeploy
  class ContainerMinecraft < Container
  
    REPOSITORY = 'itzg/minecraft-server'
    
    COMMANDS = [
      {
        :name => "kill_player",
        :args => [
          { name: "player_name", type: "string", required: true }
        ]
      },
      {
        :name => "ban_player",
        :args => [
          { name: "player_name", type: "string", required: true },
          { name: "reason", type: "text", required: false }
        ]
      },
      {
        :name => "tp",
        :args => [
          { name: "player", type: "string", required: true },
          { name: "target", type: "string", required: true }
        ]
      },
      {
        :name => "give",
        :args => [
          { name: "player", type: "string", required: true },
          { name: "block_id", type: "string", required: true },
          { name: "amount", type: "string", required: true }
        ]
      },
      {
        :name => "list",
        :args => []
      }
    ]
  
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
  
    def command_kill_player args
      player_name = args[:player_name] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "kill #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} has killed by the adminstrator request"
      
      return { success: true }
    end
    
    def command_tp args
      player = args[:player] or raise ArgumentError.new("Player doesn't exists")
      target = args[:target] or raise ArgumentError.new("Target doesn't exists")
      
      input  = "tp #{player} #{target}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player} has been teleported to #{target}"
      
      return { success: true }
    end
    
    def command_give args
      player = args[:player] or raise ArgumentError.new("Player doesn't exists")
      target = args[:block_id] or raise ArgumentError.new("Block_id doesn't exists")
      amount = args[:amount] or raise ArgumentError.new("Amount doesn't exists")
      
      input  = "give #{player} #{block_id} #{amount}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player} has received #{amount}x#{block_id}"
      
      return { success: true }
    end
    
    def command_list args
      input  = "list\n"
      docker_container.attach stdin: StringIO.new(input)
      
      return { success: true }
    end
    
    def logs
      logs = docker_container.logs(stdout: true)
      lines = logs.split("\n")
      
      list = lines.map do |line|
        splitted = line.split(":")
        prefix = splitted.first.split(" ")
        
        { time: prefix[0], type: prefix[1], message: splitted[1] }
      end
      
      return list
    end
  
  end
end