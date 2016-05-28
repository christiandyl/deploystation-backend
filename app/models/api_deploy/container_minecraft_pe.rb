require 'securerandom'
require 'rcon/rcon'

module ApiDeploy
  class ContainerMinecraftPe < Container

    REPOSITORY = 'deploystation/mcpeserver'
    
    COMMANDS = [
      {
        :name  => "kill_player",
        :title => "Kill player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ],
        :requires_players => true
      },{
        :name  => "ban",
        :title => "Ban player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "reason", type: "text", required: false }
        ],
        :requires_players => true
      },{
        :name  => "unban",
        :title => "Unban player",
        :args  => [
          { name: "player", type: "string", required: true }
        ],
        :requires_players => false
      },{
        :name  => "give",
        :title => "Give item to player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "block_id", type: "list", required: true, options: "blocks_list" },
          { name: "amount", type: "int", required: true, default_value: 1 }
        ],
        :requires_players => true
      },{
        :name  => "time",
        :title => "Change day time",
        :args  => [
          { name: "value", type: "list", required: true, options: ["day","night"] }
        ],
        :requires_players => false
      },{
        :name  => "tell",
        :title => "Tell something to the player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "message", type: "text", required: true }
        ],
        :requires_players => true
      },{
        :name  => "weather",
        :title => "Change weather in game",
        :args  => [
          { name: "value", type: "list", required: true, options: ["clear","rain","thunder"] }
        ],
        :requires_players => false
      },{
        :name  => "xp",
        :title => "Give level to player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "level", type: "list", required: true, options: [1,2,3,4,5,6,7,8,9,10,11,12] }
        ],
        :requires_players => true
      },{
        :name  => "op",
        :title => "Grants operator status to a player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ],
        :requires_players => true
      },{
        :name  => "deop",
        :title => "Revoke operator status from a player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ],
        :requires_players => true
      },{
        :name  => "say",
        :title => "Displays a message to multiple players.",
        :args  => [
          { name: "message", type: "string", required: true }
        ],
        :requires_players => true
      },{
        :name  => "kick",
        :title => "Kicks a player off a server.",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "reason", type: "text", required: false }
        ],
        :requires_players => true
      }
    ]
  
    def docker_container_env_vars
      ram = plan.ram.to_s
      
      return [
        "JVM_OPTS=-Xmx#{ram}M -Xms#{ram}M",
        "CONFIG_SERVER_NAME=#{name}",
        "CONFIG_SERVER_PORT=#{port!}",
        "CONFIG_GAMEMODE=#{config.get_property_value('gamemode')}",
        "CONFIG_MAX_PLAYERS=#{config.get_property_value('max-players')}",
        "CONFIG_SPAWN_PROTECTION=#{config.get_property_value('spawn-protection')}",
        "CONFIG_WHITE_LIST=#{config.get_property_value('white-list')}",
        "CONFIG_ENABLE_QUERY=#{config.get_property_value('enable-query')}",
        "CONFIG_ENABLE_RCON=#{config.get_property_value('enable-rcon')}",
        "CONFIG_MOTD=#{config.get_property_value('motd')}",
        "CONFIG_ANNOUNCE_PLAYER_ACHIEVEMENTS=#{config.get_property_value('announce-player-achievements')}",
        "CONFIG_ALLOW_FLIGHT=#{config.get_property_value('allow-flight')}",
        "CONFIG_SPAWN_ANIMALS=#{config.get_property_value('spawn-animals')}",
        "CONFIG_SPAWN_MOBS=#{config.get_property_value('spawn-mobs')}",
        "CONFIG_FORCE_GAMEMODE=#{config.get_property_value('force-gamemode')}",
        "CONFIG_HARDCORE=#{config.get_property_value('hardcore')}",
        "CONFIG_PVP=#{config.get_property_value('pvp')}",
        "CONFIG_DIFFICULTY=#{config.get_property_value('difficulty')}",
        "CONFIG_GENERATOR_SETTINGS=#{config.get_property_value('generator-settings')}",
        "CONFIG_LEVEL_NAME=#{config.get_property_value('level-name')}",
        "CONFIG_LEVEL_SEED=#{config.get_property_value('level-seed')}",
        "CONFIG_LEVEL_TYPE=#{config.get_property_value('level-type')}",
        "CONFIG_RCON_PASSWORD=#{config.get_property_value('rcon.password')}",
        "CONFIG_AUTO_SAVE=#{config.get_property_value('auto-save')}",
        "UPDATE_LATEST_DEV=YES"
      ]
    end
  
    def docker_container_create_opts
      opts = {
        "Image"        => REPOSITORY,
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "ExposedPorts" => { "#{port!}/tcp": {}, "#{port!}/udp": {} },
        "Env"          => docker_container_env_vars
      }

      return opts
    end
  
    def docker_container_start_opts
      opts = {
        "PortBindings" => { 
          "#{port}/tcp" => [{ "HostIp" => "", "HostPort" => port }],
          "#{port}/udp" => [{ "HostIp" => "", "HostPort" => port }]
        }
      }
      
      return opts
    end
  
    def reset now=false
      unless now    
        ApiDeploy::ContainerResetWorker.perform_async(id)
        return true
      end

      Rails.logger.debug "Resetting container(#{id})"

      destroy_docker_container
      create_docker_container
      start
      
      sleep 2
      
      conntrack.clear_udp_cache
      
      sleep 2
      
      Rails.logger.debug "Container(#{id}) is resetted"
    end
  
    def players_online now=false      
      unless now    
        ApiDeploy::ContainerPlayersOnlineWorker.perform_async(id)
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
      output = []
      
      return output
    end
    
    def starting_progress
      logs_str = docker_container.logs(stdout: true)
      logs_str = logs_str.split("nukkit/envs").last || ""

      return { progress: 0.2, message: "Initializing server" } if logs_str.blank?

      unless (/Done \(/).match(logs_str).nil?
        return { progress: 1.0, message: "Done" }
      end

      unless (/Saving to/).match(logs_str).nil?
        return { progress: 0.6, message: "Updating server" }
      end

      # download = logs_str.scan(/([0-9]+)%\[/)
      # unless download.blank?
      #   progress = download.last[0].to_f
      #   progress_global = ((60 + (progress * 0.5)) / 100).round(2)
      #
      #   return { progress: progress_global, message: "Starting server" }
      # end
      
      return { progress: 0.4, message: "Setting up server" }
    end
    
    # Stats
    
    def calculate_stats
      stat_attrs = { total_gaming_time: 0, segment_gaming_time: 0 }
      
      logs_str = docker_container.logs(stdout: true)
      stats = logs_str.scan(/([0-9]{2}):([0-9]{2}):([0-9]{2})\e\[0m \e\[37;1m\[INFO\] \e\[33;1m(.+?) (joined the game|left the game)/)
      
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
      s = docker_container.info["State"]
      
      s["Running"] == true && s["Paused"] == false && s["Restarting"] == false && s["Dead"] == false
    end
    
    def config
      @config ||= ConfigMinecraftPe.new(id)
    end
    
    def define_config
      config.super_access = true
      config.set_property("rcon.password", SecureRandom.hex)
      config.set_property("max-players", plan.max_players)
      config.export_to_database
    end
    
    ############################################################
    ### Commands
    ############################################################
    
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
    
    def commands
      COMMANDS
    end
  
  end
end
