module Containers
  module MinecraftCommands
    extend ActiveSupport::Concern

    included do
    end

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
          { name: "amount", type: "int", required: true, default_value: 1 }
        ],
        :requires_players => true
      },{
        :name  => "time",
        :title => "Change day time",
        :args  => [
          { title: "time of day", name: "value", type: "list", required: true, options: ["day","night"] }
        ],
        :requires_players => false
      },{
        :name  => "tell",
        :title => "Tell something to the player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" },
          { name: "message", type: "string", required: true }
        ],
        :requires_players => true
      },{
        :name  => "weather",
        :title => "Change weather in game",
        :args  => [
          { title: "Weather", name: "value", type: "list", required: true, options: ["clear","rain","thunder"] }
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

    def command_data command_id, now=false
      unless now    
        ContainerWorkers::CommandDataWorker.perform_async(id, command_id)
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
  end
end
