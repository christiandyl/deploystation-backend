module ApiDeploy
  class ContainerMinecraft < Container
  
    REPOSITORY = 'itzg/minecraft-server'
    
    COMMANDS = [
      {
        :name  => "kill_player",
        :title => "Kill player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ]
      },{
        :name  => "ban",
        :title => "Ban player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "reason", type: "text", required: false }
        ]
      },{
        :name  => "unban",
        :title => "Unban player",
        :args  => [
          { name: "player", type: "string", required: true }
        ]
      # },{
      #   :name  => "tp",
      #   :title => "Teleport player",
      #   :args  => [
      #     { name: "player", type: "list", required: true, options: "players_list" },
      #     { name: "target", type: "string", required: true }
      #   ]
      },{
        :name  => "give",
        :title => "Give item to player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "block_id", type: "list", required: true, options: "blocks_list" },
          { name: "amount", type: "int", required: true }
        ]
      },{
        :name  => "time",
        :title => "Change day time",
        :args  => [
          { name: "value", type: "list", required: true, options: ["day","night"] }
        ]
      },{
        :name  => "tell",
        :title => "Tell something to the player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "message", type: "string", required: true }
        ]
      },{
        :name  => "weather",
        :title => "Change weather in game",
        :args  => [
          { name: "value", type: "list", required: true, options: ["clear","rain","thunder"] }
        ]  
      },{
        :name  => "xp",
        :title => "Give level to player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "level", type: "list", required: true, options: [1,2,3,4,5,6,7,8,9,10,11,12] }
        ]
      },{
        :name  => "op",
        :title => "Grants operator status to a player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ]
      },{
        :name  => "deop",
        :title => "Revoke operator status from a player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ]
      },{
        :name  => "say",
        :title => "Displays a message to multiple players.",
        :args  => [
          { name: "message", type: "string", required: true }
        ]
      },{
        :name  => "kick",
        :title => "Kicks a player off a server.",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "reason", type: "text", required: false }
        ]
      }
    ]
    
    def docker_container_create_opts
      memory = plan.ram * 1000000
      
      opts = {
        "Image"        => REPOSITORY,
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "HostConfig"   => {
          "Memory"     => memory,
          "MemorySwap" => -1
        },
        "ExposedPorts" => { "25565/tcp": {}, "25565/udp": {} },
        "PortBindings" => {
          "25565/tcp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port! }],
          "25565/udp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port! }]
        },
        "Env" => ["EULA=TRUE", "JVM_OPTS=-Xmx#{plan.ram}M"]
      }
      
      return opts
    end
    
    def docker_container_start_opts
      opts = {
        "PortBindings" => { 
          "25565/tcp" => [{ "HostIp" => "", "HostPort" => port }],
          "25565/udp" => [{ "HostIp" => "", "HostPort" => port }]
        }
      }
      
      return opts
    end
    
    def reset now=false
      unless now    
        ApiDeploy::ContainerResetWorker.perform_async(id)
        return true
      end

      if stopped?
        Rails.logger.debug "Can't reset container, container is stopped"
        return
      end

      Rails.logger.debug "Resetting container(#{id})"
      
      level_name = config.get_property_value("level-name")
      docker_container.exec ["rm", "-rf", level_name]
      
      sleep 2
      
      Rails.logger.debug "Container(#{id}) is resetted"
    end
  
    def players_online now=false
      return false if stopped?
      
      unless now    
        ApiDeploy::ContainerPlayersOnlineWorker.perform_async(id)
        return true
      end
      
      players_online = 0
      max_players    = config.get_property_value("max-players")
      
      begin
        query = ::Query::fullQuery(host.ip, port)
      
        players_online = query[:numplayers].to_i
        max_players    = query[:maxplayers].to_i
      rescue
        Rails.logger.debug "Can't get query from Minecraft server in container-#{id}"
      end
      
      return { players_online: players_online, max_players: max_players }
    end
  
    def players_list
      return [] unless started?
      
      list = []
      
      begin
        query = ::Query::fullQuery(host.ip, port)
      
        list = query[:players]
      rescue
        Rails.logger.debug "Can't get query from Minecraft server in container-#{id}"
      end
            
      return list
    end
    
    def blocks_list
      # file = File.read('lib/api_deploy/minecraft/items.json')
      # data_hash = JSON.parse(file)
      
      # list = data_hash.map { |hs| hs["text_id"] }
      
      return ["minecraft:stone","minecraft:lava","minecraft:diamond_block","minecraft:diamond_sword","minecraft:diamond_pickaxe","minecraft:bowl"]
    end
  
    def command_data command_id, now=false
      unless now    
        ApiDeploy::ContainerCommandDataWorker.perform_async(id, command_id)
        return true
      end
      
      command = (COMMANDS.find { |c| c[:name] == command_id }).clone
      raise "Command #{id} doesn't exists" if command.nil?
      
      # TODO shit code !!!!!!!!!!!!!!!!!!!!!!
      command = JSON.parse command.to_json
      
      command["args"].each_with_index do |hs,i|
        if hs["type"] == "list" && hs["options"].is_a?(String)
          command["args"][i]["options"] = send(hs["options"])
        end
      end
      
      return command
    end
  
    def command_xp args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      level       = args["level"] or raise ArgumentError.new("Level doesn't exists")
      input       = "xp #{level}L #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} just received #{level} levels"
      
      return { success: true }
    end
    
    def command_weather args
      value = args["value"] or raise ArgumentError.new("Value doesn't exists")
      input       = "weather #{value}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Weather has changed to #{value}"
      
      return { success: true }
    end
  
    def command_kill_player args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "kill #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} has killed by the adminstrator request"
      
      return { success: true }
    end
    
    def command_ban args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      reason      = args["reason"] or raise ArgumentError.new("Reason doesn't exists")
      input       = "ban #{player_name} #{reason}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} has banned by the adminstrator request"
      
      return { success: true }
    end
    
    def command_unban args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "pardon #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} has unbunned by the adminstrator request"
      
      return { success: true }
    end
    
    def command_tp args
      player = args["player"] or raise ArgumentError.new("Player doesn't exists")
      target = args["target"] or raise ArgumentError.new("Target doesn't exists")
      
      input  = "tp #{player} #{target}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player} has been teleported to #{target}"
      
      return { success: true }
    end
    
    def command_give args
      player   = args["player"] or raise ArgumentError.new("Player doesn't exists")
      block_id = args["block_id"] or raise ArgumentError.new("Block_id doesn't exists")
      amount   = args["amount"] or raise ArgumentError.new("Amount doesn't exists")
      
      input  = "give #{player} #{block_id} #{amount}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player} has received #{amount}x#{block_id}"
      
      return { success: true }
    end
    
    def command_time args
      value = args["value"] or raise ArgumentError.new("Value doesn't exists")
      
      input = "time set #{value}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      Rails.logger.info "Container(#{id}) - Minecraft : Day time has changed to #{value}"
      
      return { success: true }
    end
    
    def command_tell args
      player  = args["player"] or raise ArgumentError.new("Player doesn't exists")
      message = args["message"] or raise ArgumentError.new("Message doesn't exists")
      raise "Message is blank" if message.blank?
      
      input = "tell #{player} #{message}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player} received message \"#{message}\""
      
      return { success: true }
    end
    
    def command_op args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "op #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} is now an admin"
      
      return { success: true }
    end
    
    def command_deop args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "deop #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} is now not admin"
      
      return { success: true }
    end
    
    def command_say args
      message = args["message"] or raise ArgumentError.new("Message doesn't exists")
      input   = "say #{message}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Sayed to all #{message}"
      
      return { success: true }
    end
    
    def command_kick args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      reason      = args["reason"] or raise ArgumentError.new("Reason doesn't exists")
      input       = "kick #{player_name} #{reason}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} has been kicked"
      
      return { success: true }
    end
    
    def logs
      logs = docker_container.logs(stdout: true).split("usermod: no changes").last

      list = logs.scan(/\[([0-9]{2}:[0-9]{2}:[0-9]{2})\] \[[a-zA-Z ]*\/([A-Z]*)\]: (.+?)\r\n/)
      
      output = []
      list.each do |s|
        spl = s[0].split(":")
        timestamp = (spl[0].to_i * 3600) + (spl[1].to_i * 60) + spl[2].to_i
        output << {
          :date      => nil,
          :time      => s[0],
          :timestamp => timestamp,
          :type      => s[1],
          :message   => s[2]
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
    
    def config
      @config ||= ConfigMinecraft.new(id)
    end
    
    def define_config
      config.super_access = true
      config.set_property("max-players", plan.max_players)
      # config.set_property("level-name", name)
      config.export_to_database
    end
    
    def commands
      COMMANDS
    end
  
  end
end
