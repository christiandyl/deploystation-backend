require 'securerandom'

module ApiDeploy
  class ContainerMinecraftPe < Container

    REPOSITORY = 'deploystation/mcpeserver'
    
    COMMANDS = []
  
    def docker_container_env_vars
      return [
        "CONFIG_SERVER_NAME=#{name}",
        "CONFIG_SERVER_PORT=19132",
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
        "CONFIG_AUTO_SAVE=#{config.get_property_value('auto-save')}"
      ]
    end
  
    def docker_container_create_opts
      opts = {
        "Image"        => REPOSITORY,
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "ExposedPorts" => { "19132/tcp": {}, "19132/udp": {} },
        "Env"          => docker_container_env_vars
      }

      return opts
    end
  
    def docker_container_start_opts
      opts = {
        "PortBindings" => { 
          "19132/tcp" => [{ "HostIp" => "", "HostPort" => port }],
          "19132/udp" => [{ "HostIp" => "", "HostPort" => port }]
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
  
    def players_list
      return [] unless started?
      
      list = []
      
      # rcon_auth do |server|
      #   break if server.nil?
      #   out = server.rcon_exec('users')
      #   out.gsub!("<slot:userid:\"name\">", "")
      #   list = out.scan(/"(.+?)\"/).map { |v| v[0] }
      # end
            
      return list
    end
    
    def logs
      output = []
      
      return output
    end
    
    def starting_progress
      logs_str = docker_container.logs(stdout: true)

      # 5.times { puts "======================================" }
      # ap logs_str.split("\n")

      return { progress: 0.2, message: "Initializing server" } if logs_str.blank?

      unless (/Done \(/).match(logs_str).nil?

        return { progress: 1.0, message: "Done" }
      end

      unless (/Installing the latest stable release/).match(logs_str).nil?
        return { progress: 0.7, message: "Installing server" }
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
    
    # def rcon_auth
    #   server = SourceServer.new(host.ip, port)
    #   begin
    #     server.rcon_auth(config.get_property_value(:rcon_password))
    #     yield(server)
    #   rescue RCONNoAuthException
    #     Rails.logger.debug 'Could not authenticate with the game server.'
    #
    #     yield(nil)
    #   end
    # end
    
    def commands
      COMMANDS
    end
  
  end
end
