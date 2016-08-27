module Containers
  class Minecraft < Container
    include MinecraftCommands  

    REPOSITORY = 'itzg/minecraft-server'
    
    def docker_container_create_opts
      # TODO dirty hack (kill me for that !!!)
      # ram = plan.ram
      # memory = (ram + 200) * 1000000
      ram = 2048
      memory = ram * 1000000

      opts = {
        "Image"        => REPOSITORY,
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "Memory"       => memory * 2,
        "MemorySwap"   => -1,
        "HostConfig"   => {
          "PortBindings" => {
            "25565/tcp" => [{ "HostIp" => "", "HostPort" => port! }],
            "25565/udp" => [{ "HostIp" => "", "HostPort" => port! }]
          }
        },
        "ExposedPorts" => { "25565/tcp": {}, "25565/udp": {} },
        "Env" => [
          "EULA=TRUE",
          "JVM_OPTS=-Xmx#{ram}M",
          "ENABLE_RCON=#{config.get_property_value('enable-rcon')}",
          "RCON_PASSWORD=#{config.get_property_value('rcon.password')}"
        ]
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
    
    # def reset now=false
    #   unless now
    #     ContainerWorkers::ResetWorker.perform_async(id)
    #     return true
    #   end
    #
    #   if stopped?
    #     Rails.logger.debug "Can't reset container, container is stopped"
    #     return
    #   end
    #
    #   Rails.logger.debug "Resetting container(#{id})"
    #
    #   level_name = config.get_property_value("level-name")
    #   docker_container.exec ["rm", "-rf", level_name]
    #
    #   sleep 2
    #
    #   Rails.logger.debug "Container(#{id}) is resetted"
    # end
  
    def players_online now=false
      unless now    
        ContainerWorkers::PlayersOnlineWorker.perform_async(id)
        return true
      end
      
      players_online = 0
      max_players    = config.get_property_value("max-players")
      
      unless stopped?
        begin
          query = ::Query::fullQuery(host.ip, port)
      
          players_online = query[:numplayers].to_i
          max_players    = query[:maxplayers].to_i
        rescue
          Rails.logger.debug "Can't get query from Minecraft server in container-#{id}"
        end
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
      
      return [
        "minecraft:stone",
        "minecraft:planks",
        "minecraft:stick",
        "minecraft:water",
        "minecraft:lava",
        "minecraft:diamond_block",
        "minecraft:diamond_sword",
        "minecraft:diamond_pickaxe",
        "minecraft:diamond_axe",
        "minecraft:diamond_shovel",
        "minecraft:bowl",
        "minecraft:bed",
        "minecraft:tnt",
        "minecraft:bow",
        "minecraft:arrow"
      ].map { |b| { title: b.split(":")[1].capitalize, value: b } }
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
    
    # Stats
    
    def calculate_stats
      stat_attrs = { total_gaming_time: 0, segment_gaming_time: 0 }
      
      logs_str = docker_container.logs(stdout: true)
      stats = logs_str.scan(/\[([0-9]{2}):([0-9]{2}):([0-9]{2})\] .+?\]: (.+?) (joined the game|left the game)/)
      
      users = ((stats.uniq { |m| m[3] }).map { |m| m[3] }) rescue []
      
      users.each do |username|
        stats_by_user = (stats.select { |m| m[3] == username }) rescue []

        unless stats_by_user.blank?
          total_gaming_time = 0
          last_join = 0
          stats_by_user.each do |m|
            is_join = m[4] == "joined the game"
            seconds = ((m[0].to_i * 60) * 60) + (m[1].to_i * 60) + m[2].to_i
            
            unless is_join
              total_gaming_time += seconds - last_join if seconds > last_join
            else
              last_join = seconds
            end
          end
          
          stat_attrs[:total_gaming_time] += total_gaming_time unless total_gaming_time == 0
        end
        
        stats_by_user = nil
      end

      users = nil
      
      begin
        prev_stat = (ContainerStat.where(container_id: id).all.sort_by { |st| st.created_at }).last
        prev_total_gaming_time = prev_stat.total_gaming_time
      rescue
        prev_total_gaming_time = stat_attrs[:total_gaming_time]
      end
      
      stat_attrs[:segment_gaming_time] = stat_attrs[:total_gaming_time] - prev_total_gaming_time
      stat_attrs[:segment_gaming_time] = 0 if stat_attrs[:segment_gaming_time] < 0
      
      prev_stats = pstat = prev_total_gaming_time = nil
      
      push_new_stat_gaming_time(stat_attrs)
      
      return stat_attrs
    end
    
    def started?
      !logs.blank?
    end
    
    def config
      @config ||= GameConfigs::Minecraft.new(id)
    end
    
    def define_config
      config.super_access = true
      config.set_property("rcon.password", SecureRandom.hex)
      config.set_property("max-players", plan.max_players)
      # config.set_property("level-name", name)
      config.export_to_database
    end
    
    def commands
      COMMANDS
    end
  
    def change_container_volume
      config.super_access = true
      config.set_property("max-players", plan.max_players)
      config.export_to_database
    end
  end
end
