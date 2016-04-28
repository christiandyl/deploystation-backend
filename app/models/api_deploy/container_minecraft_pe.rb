require 'securerandom'
require 'rcon/rcon'

module ApiDeploy
  class ContainerMinecraftPe < Container

    REPOSITORY = 'deploystation/mcpeserver'
    
    COMMANDS = [
      {
        :name  => "kick",
        :title => "Kicks a player off a server.",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "reason", type: "text", required: false }
        ]
      }
    ]
  
    def docker_container_env_vars
      return [
        "CONFIG_SERVER_NAME=#{name}",
        "CONFIG_SERVER_PORT=#{port!}",
        "CONFIG_MEMORY_LIMIT=#{config.get_property_value('memory-limit')}",
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

      if stopped?
        Rails.logger.debug "Can't reset container, container is stopped"
        return
      end

      Rails.logger.debug "Resetting container(#{id})"
    
      # TODO reset logics
      
      Rails.logger.debug "Container(#{id}) is resetted"
    end
  
    def players_online now=false
      return false unless started?
      
      unless now    
        ApiDeploy::ContainerPlayersOnlineWorker.perform_async(id)
        return true
      end
      
      players_online = 0
      max_players    = config.get_property_value("max-players")
      
      return { players_online: players_online, max_players: max_players }
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

      download = logs_str.scan(/([0-9]+)%\[/)
      unless download.blank?
        progress = download.last[0].to_f
        progress_global = ((50 + (progress * 0.5)) / 100).round(2)

        return { progress: progress_global, message: "Starting server" }
      end
      
      return { progress: 0.4, message: "Setting up server" }
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
      config.set_property("memory-limit", "#{plan.ram}m")
      config.set_property("max-players", plan.max_players)
      config.export_to_database
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
