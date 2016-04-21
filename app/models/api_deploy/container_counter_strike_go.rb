module ApiDeploy
  class ContainerCounterStrikeGo < Container

    REPOSITORY = 'johnjelinek/csgoserver'
    
    COMMANDS = []
  
    after_create :define_config
  
    def self.create user, plan
      memory = plan.ram * 1000000
      port   = plan.host.free_port

      cmd = self.docker_cmd({
        port: port
      })
      
      docker_opts = {
        "Image"        => REPOSITORY,
        "Cmd"          => cmd,
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        "ExposedPorts" => { "#{port}/tcp": {}, "#{port}/udp": {} },
        "PortBindings" => {
          "#{port}/tcp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port }],
          "#{port}/udp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port }]
        },
        "Volumes" => [
          "/home/csgoserver" => {}
        ],
        "WorkingDir" => "/home/csgoserver",
        "Entrypoint" => ["/home/csgoserver/serverfiles/srcds_run"],
      }
      
      container = super(user, plan, docker_opts)
    end
  
    def start opts={}, now=false
      cmd = docker_cmd({
        port: port
      })
      
      opts = {
        "Binds" => ["/var/docker/csgoserver:/home/csgoserver:ro"],
        "Cmd"   => cmd
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
      max_players    = 5
      
      # begin
      #   query = ::Query::fullQuery(host.ip, port)
      #
      #   players_online = query[:numplayers].to_i
      #   max_players    = query[:maxplayers].to_i
      # rescue
      #   Rails.logger.debug "Can't get query from Minecraft server in container-#{id}"
      # end
      
      return { players_online: players_online, max_players: max_players }
    end
  
    def players_list
      return [] unless started?
      
      list = []
            
      return list
    end
  
    def command_data command_id, now=false
      unless now    
        ApiDeploy::ContainerCommandDataWorker.perform_async(id, command_id)
        return true
      end
      
      command = {}
      
      # command = (COMMANDS.find { |c| c[:name] == command_id }).clone
      # raise "Command #{id} doesn't exists" if command.nil?
      #
      # # TODO shit code !!!!!!!!!!!!!!!!!!!!!!
      # command = JSON.parse command.to_json
      #
      # command["args"].each_with_index do |hs,i|
      #   if hs["type"] == "list" && hs["options"].is_a?(String)
      #     command["args"][i]["options"] = send(hs["options"])
      #   end
      # end
      
      return command
    end
    
    def logs
      # logs = docker_container.logs(stdout: true).split("GameServer.Init successful").last

      # list = logs.scan(/([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2}:[0-9]{2}:[0-9]{2}) (.+?) INF (.+?)\r\n/)
      
      output = []
      # list.each do |s|
      #   spl = s[0].split("-")
      #   output << {
      #     :date      => s[0],
      #     :time      => s[1],
      #     :timestamp => s[2],
      #     :type      => "INF",
      #     :message   => s[3]
      #   }
      # end
      
      # TODO write some logics to get know last day
      
      return output
    end
    
    def starting_progress
      logs_str = docker_container.logs(stdout: true).split("Console initialized.").last
      logs_str = docker_container.logs(stdout: true)

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
      s = docker_container.info["State"]
      
      s["Running"] == true && s["Paused"] == false && s["Restarting"] == false && s["Dead"] == false
    end
    
    def config
      @config ||= ConfigCounterStrikeGo.new(id)
    end
    
    def define_config
      config.super_access = true
      # config.set_property("max-players", plan.max_players)
      # config.set_property("level-name", name)
      config.export_to_database
    end
    
    def docker_cmd hs
      self.class.docker_cmd(hs)
    end
    
    def self.docker_cmd hs
      port = hs[:port] or raise "Port is absent"
      
      cmd = [
        "-game",
        "csgo",
        "-usercon",
        "-strictportbind",
        "-ip",
        "0.0.0.0",
        "-port",
        port,
        # "+clientport",
        # "34082",
        # "+tv_port",
        # "47395",
        "-tickrate",
        "64",
        "+map",
        "cs_italy",
        # "+servercfgfile",
        # "csgo-server.cfg",
        # "+sv_setsteamaccount",
        # "2A4587B393F40ED045746E2F1AB0FC85",
        "-maxplayers_override",
        "8",
        "+mapgroup",
        "random_classic",
        "+game_mode",
        "0",
        "+game_type",
        "0",
        # "+host_workshop_collection",
        # "+workshop_start_map",
      ]
    end
  
  end
end
