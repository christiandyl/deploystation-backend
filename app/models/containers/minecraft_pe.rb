require 'securerandom'
require 'rcon/rcon'

module Containers
  class MinecraftPe < Container
    include MinecraftPeCommands

    REPOSITORY = 'deploystation/mcpeserver'
  
    def docker_container_env_vars
      # TODO dirty hack (kill me for that !!!)
      # ram = plan.ram
      # memory = (ram + 200) * 1000000
      ram = 2048
      
      api_prefix = case Rails.env
        when :development
          "http://api_local.deploystation.com/v1/"
        when :staging
          "http://api-stage.deploystation.com/v1/"
        when :production
          "http://api.deploystation.com/v1/"
      end
      
      return [
        "DS_CONTAINER_ID=#{id.to_s}",
        "DS_API_PATH=#{api_base_url}",
        # "JVM_OPTS=-Xmx#{ram}M -Xms#{ram}M",
        "JVM_OPTS=",
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
        "Memory"       => memory,
        "MemorySwap"   => -1,
        "ExposedPorts" => { "#{port!}/tcp": {}, "#{port!}/udp": {} },
        "Env"          => docker_container_env_vars,
        "HostConfig"   => {
          "PortBindings" => { 
            "#{port}/tcp" => [{ "HostIp" => "", "HostPort" => port }],
            "#{port}/udp" => [{ "HostIp" => "", "HostPort" => port }]
          }
        },
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
      @config ||= GameConfigs::MinecraftPe.new(id)
    end
    
    def define_config
      config.super_access = true
      config.set_property("rcon.password", SecureRandom.hex)
      config.set_property("max-players", plan.max_players)
      config.export_to_database
    end
    
    def export_env_vars
      # Generating file content
      str = ""
      docker_container_env_vars.each { |v| str << "export #{v}\n" }

      # Plugins
      plugins_urls = (plugins.enabled.map { |p| p.download_url }).join(";") rescue ""
      str << "export NUKKIT_PLUGINS='#{plugins_urls}'"

      # Exporting file
      docker_container.exec ["bash", "-c", "echo \"#{str}\" > /nukkit/envs"]

      return true
    end
    
    def commands
      COMMANDS
    end

    def change_container_volume
      config.super_access = true
      config.set_property("max-players", plan.max_players)
      config.save
    end
  end
end
