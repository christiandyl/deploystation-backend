module ApiDeploy
  class ContainerSevenDaysToDie < Container
  
    REPOSITORY = 'zobees/7daystodie'
    
    COMMANDS = []
  
    # after_create :define_config
  
    def self.create user, plan
      memory = plan.ram * 1000000
      port   = plan.host.free_port
      
      docker_opts = {
        "Image"        => REPOSITORY,
        # "Cmd"          => "/start",
        "Tty"          => true,
        "OpenStdin"    => true,
        'StdinOnce'    => true,
        # "HostConfig"   => {
        #   "Memory"     => memory,
        #   "MemorySwap" => -1,
        #   # "CpuShares"  => 1
        # },
        "ExposedPorts" => { "26900/tcp": {}, "26900/udp": {} },
        "PortBindings" => {
          "25565/tcp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port }],
          "25565/udp" => [{ "HostIp" => "127.0.0.1", "HostPort" => port }]
        },
        "Env"          => ["STEAM_USERNAME=ooloo", "STEAM_PASSWORD=abcsolutions2010"]
      }
      
      container = super(user, plan, docker_opts)
    end
  
    def start opts={}, now=false
      opts = {
        "PortBindings" => { 
          "26900/tcp" => [{ "HostIp" => "", "HostPort" => port }],
          "26900/udp" => [{ "HostIp" => "", "HostPort" => port }]
        }
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
      logs = docker_container.logs(stdout: true).split("GameServer.Init successful").last

      list = logs.scan(/([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2}:[0-9]{2}:[0-9]{2}) (.+?) INF (.+?)\r\n/)
      
      output = []
      list.each do |s|
        spl = s[0].split("-")
        output << {
          :date      => s[0],
          :time      => s[1],
          :timestamp => s[2],
          :type      => "INF",
          :message   => s[3]
        }
      end
      
      # TODO write some logics to get know last day
      
      return output
    end
    
    def starting_progress
      logs_str = docker_container.logs(stdout: true)
      logs_str = logs_str.split("Checking for available update...").last || ""
      
      return { progress: 0.2, message: "Initializing server" } if logs_str.blank?
      
      unless (/ GameServer.Init successful/).match(logs_str).nil?
        return { progress: 1.0, message: "Done" }
      end
      
      downloading = logs_str.scan(/downloading, progress: ([0-9.]+)/)
      unless downloading.blank?
        progress = downloading.last[0].to_f
        progress_global = ((50 + (progress * 0.5)) / 100).round(2)
        
        return { progress: progress_global, message: "Downloading server" }
      end
      
      return { progress: 0.4, message: "Setting up server" }
    end
    
    def started?
      !logs.blank?
    end
    
    def config
      @config ||= ConfigSevenDaysToDie.new(id)
    end
    
    def define_config
      config.super_access = true
      # config.set_property("max-players", plan.max_players)
      # config.set_property("level-name", name)
      config.export_to_database
    end
  
  end
end
