require 'securerandom'

module Containers
  class CounterStrikeGo < Container
    include CounterStrikeGoCommands

    REPOSITORY   = 'deploystation/csgoserver'
    STEAM_APP_ID = 730
  
    before_destroy :return_gslt
    
    set_callback :start, :after, :clean_port_cache
    set_callback :start, :after, :apply_config
  
    def return_gslt
      token = config.get_property_value(:gslt)
      SteamServerLoginToken.return_token(STEAM_APP_ID, token)
    end
  
    def apply_config
      config.apply_config_via_rcon
    end
    
    def clean_port_cache
      conntrack.clear_udp_cache
    end
    
    def restart now=false
      unless now          
        ContainerWorkers::RestartWorker.perform_async(id)
        return true
      end
      
      Rails.logger.debug "Restarting container(#{id})"
      rcon_auth do |server|
        out = server.rcon_exec("restart")
        raise "Restart server CS GO" unless out.blank?
      end
      Rails.logger.debug "Container(#{id}) has restarted"
      
      self.status = STATUS_ONLINE
      save!
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
        "StdinOnce"    => true,
        "Memory"       => memory,
        "MemorySwap"   => memory * 2,
        "ExposedPorts" => { "#{port!}/tcp": {}, "#{port!}/udp": {} },
        "Env" => docker_container_env_vars,
        "HostConfig"   => {
          "PortBindings" => {
            "#{port}/tcp" => [{ "HostIp" => "0.0.0.0", "HostPort" => port }],
            "#{port}/udp" => [{ "HostIp" => "0.0.0.0", "HostPort" => port }]
          },
          "Binds" => ["/var/docker/csgoserver:/home/csgoserver:rw"]
        },
      }

      return opts
    end
  
    def docker_container_env_vars
      cfg_file_name = "server_#{id.to_s}.cfg"
      return [
        "PORT=#{port!}",
        "CFG_FILE_NAME=#{cfg_file_name}",
        "SERVER_NAME=#{name}",
        "SERVER_PASS=#{config.get_property_value(:sv_password)}",
        "RCON_PASS=#{config.get_property_value(:rcon_password)}",
        "MAX_PLAYERS=#{config.get_property_value(:maxplayers)}",
        "DEFAULT_MAP=#{config.get_property_value(:map)}",
        "GSLT=#{config.get_property_value(:gslt)}"
      ]
    end
  
    def docker_container_start_opts      
      opts = {
        "PortBindings" => {
          "#{port}/tcp" => [{ "HostIp" => "0.0.0.0", "HostPort" => port }],
          "#{port}/udp" => [{ "HostIp" => "0.0.0.0", "HostPort" => port }]
        },
        "Binds" => ["/var/docker/csgoserver:/home/csgoserver:rw"]
      }
      
      return opts
    end
  
    def players_online now=false      
      unless now    
        ContainerWorkers::PlayersOnlineWorker.perform_async(id)
        return true
      end
      
      players_online = 0
      max_players    = config.get_property_value(:maxplayers)
      
      if started?
        rcon_auth do |server|
          unless server.nil?
            players_online = server.server_info[:number_of_players]
            max_players    = server.server_info[:max_players]
          end
        end
      end
      
      return { players_online: players_online, max_players: max_players }
    end
  
    def players_list
      return [] unless started?
      
      list = []
      
      rcon_auth do |server|
        break if server.nil?
        out = server.rcon_exec('users')
        out.gsub!("<slot:userid:\"name\">", "")
        list = out.scan(/"(.+?)\"/).map { |v| v[0] }
      end
            
      return list
    end
    
    def levels_list
      return [] unless started?
      
      list = []
      
      rcon_auth do |server|
        break if server.nil?
        out = server.rcon_exec("maps *")
        list = out.scan(/\) (.+?).bsp\n/).map { |v| v[0] }
      end
            
      return list
    end
    
    def logs
      output = []
      
      return output
    end
    
    def starting_progress
      # byebug
      logs_str = docker_container.logs(stdout: true).split("Console initialized.").last

      return { progress: 0.2, message: "Initializing server" } if logs_str.blank?

      unless (/Connection to Steam servers successful/).match(logs_str).nil?
        return { progress: 1.0, message: "Done" }
      end

      unless (/Executing dedicated server config file/).match(logs_str).nil?
        return { progress: 0.7, message: "Creating configuration" }
      end

      return { progress: 0.4, message: "Setting up server" }
    end
    
    def started?
      begin
      s = docker_container.info["State"]
      return s["Running"] == true && s["Paused"] == false && s["Restarting"] == false && s["Dead"] == false
      rescue
        return false
      end
    end
    
    def config
      @config ||= GameConfigs::CounterStrikeGo.new(id)
    end
    
    def define_config
      config.super_access = true
      config.set_property("rcon_password", SecureRandom.hex)
      config.set_property("gslt", SteamServerLoginToken.take_token(STEAM_APP_ID))
      config.export_to_database
    end
    
    def calculate_stats
      stat_attrs = { total_gaming_time: 0, segment_gaming_time: 0 }
      
      return stat_attrs
    end
    
    def rcon_auth
      server = SourceServer.new(host.ip, port)
      begin
        server.rcon_auth(config.get_property_value(:rcon_password))
        yield(server)
      # rescue RCONNoAuthException
      rescue
        Rails.logger.debug 'Could not authenticate with the game server.'
        
        yield(nil)
      end
    end
    
    def commands
      COMMANDS
    end

    def change_container_volume
      config.super_access = true
      config.set_property("maxplayers", plan.max_players)
      config.save 
    end
  end
end
