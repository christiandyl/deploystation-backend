module Containers
  module CounterStrikeGoCommands
    extend ActiveSupport::Concern

    included do
    end

    COMMANDS = [
      {
        :name  => "kick",
        :title => "Kick player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ],
        :requires_players => true
      },{
        :name  => "changelevel",
        :title => "Change level",
        :args  => [
          { name: "level", type: "list", required: true, options: "levels_list" }
        ],
        :requires_players => false
      },{
        :name  => "kill",
        :title => "Kill player",
        :args  => [
          { name: "player", type: "list", required: true, options: "players_list" }
        ],
        :requires_players => true
      },{
        :name  => "sv_gravity",
        :title => "Change gravity",
        :args  => [
          { name: "gravity", type: "int", required: true, default_value: 800 }
        ],
        :requires_players => false
      },{
        :name  => "mp_restartgame",
        :title => "Restart round",
        :args  => nil,
        :requires_players => false
      }
    ]

    def command_kick args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      
      rcon_auth do |server|
        out = server.rcon_exec("kick #{player_name}")
      end 
      
      Rails.logger.info "Container(#{id}) - CSGO : Player #{player_name} has been kicked"
      
      return { success: true }
    end
    
    def command_kill args
      player_name = args["player"] or raise ArgumentError.new("Player_name doesn't exists")
      
      rcon_auth do |server|
        out = server.rcon_exec("kill #{player_name}")
      end 
      
      Rails.logger.info "Container(#{id}) - CSGO : Player #{player_name} has been killed"
      
      return { success: true }
    end
    
    def command_changelevel args
      level = args["level"] or raise ArgumentError.new("level doesn't exists")

      rcon_auth do |server|
        out = server.rcon_exec("changelevel #{level}")
        raise "Change level exception" unless out.blank?
      end 
      
      Rails.logger.info "Container(#{id}) - CSGO : Level changed to #{level}"
      
      return { success: true }
    end
    
    def command_sv_gravity args
      gravity = args["gravity"] or raise ArgumentError.new("gravity doesn't exists")

      rcon_auth do |server|
        out = server.rcon_exec("sv_gravity #{gravity}")
        raise "Change gravity exception" unless out.blank?
      end 
      
      Rails.logger.info "Container(#{id}) - CSGO : Gravity changed to #{gravity.to_s}"
      
      return { success: true }
    end
    
    def command_mp_restartgame args=nil
      rcon_auth do |server|
        out = server.rcon_exec("mp_restartgame 1")
        raise "Restart round exception" unless out.blank?
      end 
      
      Rails.logger.info "Container(#{id}) - CSGO : Round restarted"
      
      return { success: true }
    end
  end
end
