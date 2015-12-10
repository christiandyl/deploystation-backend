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
      port   = plan.host.free_port
      
      docker_opts = {
        "Image"        => REPOSITORY,
        "Cmd"          => "/start",
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "HostConfig"   => {
          "Memory"     => memory,
          "MemorySwap" => -1,
          # "CpuShares"  => 1
        },
        "ExposedPorts" => { "25565/tcp": {} },
        "PortBindings" => { "25565/tcp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port }] },
        "Env"          => ["EULA=TRUE", "JVM_OPTS=-Xmx#{plan.ram}M"]
      }
      
      super(user, plan, docker_opts)
    end
  
    def start opts={}, now=false
      opts = {
        "PortBindings" => { "25565/tcp" => [{ "HostIp" => "", "HostPort" => port }] } 
      }
      super(opts, now)
    end
  
    def players_online now=false
      return false unless started?
      
      unless now    
        ApiDeploy::ContainerPlayersOnlineWorker.perform_async(id)
        return true
      end
      
      logs_before = logs
      stamp = logs_before.last[:time]
      docker_container.attach stdin: StringIO.new("list\n")
      sleep(1)
      logs_after = logs
      
      players_list = []
      number_of_players = 0
      max_players = 0
      header_found = false
      logs_after.each do |l|
        unless header_found
          match = /There are ([0-9]*)\/([0-9]*) players online:/.match(l[:message])
          if (l[:time] >= stamp && !match.nil?)
            number_of_players = match[1].to_i
            max_players = match[2].to_i
            header_found = true
            next
          end
        else
          if header_found == true && players_list.count != number_of_players
            players_list << l[:message]
          end
        end
      end
      
      return { number_of_players: number_of_players, players_list: players_list, max_players: max_players }
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

      list = logs.scan(/\[([0-9]{2}:[0-9]{2}:[0-9]{2})\] \[[a-zA-Z ]*\/([A-Z]*)\]: (.+?)\r\n/)
      
      output = []
      list.each do |s|
        output << {
          :date    => nil,
          :time    => s[0],
          :type    => s[1],
          :message => s[2]
        }
      end
      
      # TODO write some logics to get know last day
      
      return output
    end
    
    def starting_progress
      logs_str = docker_container.logs(stdout: true)
      logs_str = logs_str.split("usermod: no changes").last || ""
      
      return { progress: 0.2, message: "Initializing server" } if logs_str.blank?
      
      unless (/ Done \(/).match(logs_str).nil?
        return { progress: 1.0, message: "Done" }
      end
      
      spawn = logs_str.scan(/Preparing spawn area: ([0-9]+)%/)
      unless spawn.blank?
        progress = spawn.last[0].to_f
        progress_global = ((50 + (progress * 0.5)) / 100).round(2)
        
        return { progress: progress_global, message: "Creating your world" }
      end
      
      starting = (/ Starting minecraft server version (.+?)\r\n/).match(logs_str)
      unless starting.nil?
        return { progress: 0.5, message: "Starting server" }
      end
      
      downloading = (/Downloading minecraft_server.(.+?).jar/).match(logs_str)
      unless downloading.nil?
        return { progress: 0.4, message: "Downloading server" }
      end
      
      return { progress: 0.2, message: "Initializing server" }
    end
    
    def started?
      !logs.blank?
    end
  
  end
end