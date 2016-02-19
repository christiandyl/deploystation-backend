module ApiDeploy
  class ContainerMinecraft < Container
  
    REPOSITORY = 'itzg/minecraft-server'
    
    COMMANDS = [
      {
        :name  => "kill_player",
        :title => "Kill player",
        :args  => [
          { name: "player_name", type: "list", required: true, options: "players_list" }
        ]
      },
      {
        :name  => "ban_player",
        :title => "Ban player",
        :args  => [
          { name: "player_name", type: "string", required: true },
          { name: "reason", type: "text", required: false }
        ]
      },
      {
        :name  => "tp",
        :title => "Teleport player",
        :args  => [
          { name: "player", type: "string", required: true },
          { name: "target", type: "string", required: true }
        ]
      },
      {
        :name  => "give",
        :title => "Give item to player",
        :args  => [
          { name: "player", type: "string", required: true },
          { name: "block_id", type: "int", required: true },
          { name: "amount", type: "int", required: true }
        ]
      },
      {
        :name  => "time",
        :title => "Change day time",
        :args  => [
          { name: "value", type: "string", required: true }
        ]
      },
    ]
  
    after_create :define_config
  
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
      
      container = super(user, plan, docker_opts)
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
      
      players_online = 0
      max_players    = config.get_property_value("max-players")
      
      
      if status == STATUS_ONLINE
        init_stamp = logs.last[:time].split(":")
        init_stamp = (init_stamp[0].to_i * 3600) + (init_stamp[1].to_i * 60) + init_stamp[2].to_i
        
        docker_container.attach stdin: StringIO.new("list\n")
        # (docker_container.wait(5) rescue nil) unless Rails.env.test?

        x = 5
        seconds_delay = 2
        done = false
        
        x.times do
          str = docker_container.logs(stdout: true).split("usermod: no changes").last 
 
          regex = /\[([0-9]{2}:[0-9]{2}:[0-9]{2})\] \[[a-zA-Z ]*\/([A-Z]*)\]: There are ([0-9]*)\/([0-9]*) players online:/
          match = str.scan(regex).last
          unless match.nil?
            stamp = match[0].split(":")
            stamp = (stamp[0].to_i * 3600) + (stamp[1].to_i * 60) + stamp[2].to_i
            if stamp >= init_stamp
              players_online = match[2].to_i
              done = true
              break
            end
          end
          
          sleep(seconds_delay)
        end

        raise "Can't get players online" unless done
      end
      
      return { players_online: players_online, max_players: max_players }
    end
  
    def players_list
      return [] unless started?
      
      timestamp = logs.last[:timestamp]
      
      docker_container.attach stdin: StringIO.new("list\n")

      list = nil
      x = 5
      seconds_delay = 1
      
      x.times do
        current_logs = logs.find_all { |s| s[:timestamp] > timestamp }
        points = nil
        regex = /There are ([0-9]*)\/([0-9]*) players online:/
        
        current_logs.each_with_index do |s,i|
          result = regex.match s[:message]
          unless result.nil?
            points = (i + 1)..(i + result[1].to_i)
            if result[1].to_i > 0
              list = current_logs[points].map { |s| s[:message] }
            else
              list = []
            end
            break
          end
        end

        break unless points.nil?
        
        sleep(seconds_delay)
      end
            
      return list
    end
  
    # def players_online now=false
    #   return false unless started?
    #
    #   unless now
    #     ApiDeploy::ContainerPlayersOnlineWorker.perform_async(id)
    #     return true
    #   end
    #
    #   logs_before = logs
    #   stamp = logs_before.last[:time]
    #   docker_container.attach stdin: StringIO.new("list\n")
    #   sleep(1)
    #   logs_after = logs
    #
    #   players_list = []
    #   number_of_players = 0
    #   max_players = 0
    #   header_found = false
    #   logs_after.each do |l|
    #     unless header_found
    #       match = /There are ([0-9]*)\/([0-9]*) players online:/.match(l[:message])
    #       if (l[:time] >= stamp && !match.nil?)
    #         number_of_players = match[1].to_i
    #         max_players = match[2].to_i
    #         header_found = true
    #         next
    #       end
    #     else
    #       if header_found == true && players_list.count != number_of_players
    #         players_list << l[:message]
    #       end
    #     end
    #   end
    #
    #   return { number_of_players: number_of_players, players_list: players_list, max_players: max_players }
    # end
  
    def command_data id
      command = (COMMANDS.find { |c| c[:name] == id }).clone
      raise "Command #{id} doesn't exists" if command.nil?
      
      command = JSON.parse command.to_json
      
      command["args"].each_with_index do |hs,i|
        if hs["type"] == "list" && hs["options"].is_a?(String)
          command["args"][i]["options"] = send(hs["options"])
        end
      end
      
      return command
    end
  
    def command_kill_player args
      player_name = args["player_name"] or raise ArgumentError.new("Player_name doesn't exists")
      input       = "kill #{player_name}\n"
      
      docker_container.attach stdin: StringIO.new(input)
      
      Rails.logger.info "Container(#{id}) - Minecraft : Player #{player_name} has killed by the adminstrator request"
      
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
  
  end
end
