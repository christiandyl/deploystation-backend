module ApiDeploy
  class ConfigCounterStrikeGo < GameConfig
    attr_accessor :properties, :container_id, :super_access
    
    set_callback :export_to_database, :after, :apply_config_via_rcon
    
    LAST_TIME_UPDATED = 1450115967
    
    def self.schema
      return [
        {
          :key           => "gslt",
          :type          => :string,
          :title         => "Steam server login token",
          :default_value => nil,
          :is_editable   => false,
          :validations   => {}
        },{
          :key           => "sv_password",
          :type          => :string,
          :title         => "Server password",
          :default_value => nil,
          :is_editable   => true,
          :validations   => {}
        },{
          :key           => "rcon_password",
          :type          => :string,
          :title         => "Rcon password",
          :default_value => nil,
          :is_editable   => false,
          :validations   => {}
        },{
          :key           => "maxplayers",
          :type          => :integer,
          :title         => "Max players",
          :default_value => 16,
          :is_editable   => false,
          :validations   => {}
        },{
          :key           => "map",
          :type          => :list,
          :title         => "Default map",
          :default_value => "cs_italy",
          :is_editable   => false,
          :validations   => {},
          :options       => ["cs_italy", "de_dust2", "cs_assault"]
        },{
          :key           => "sv_cheats",
          :type          => :boolean,
          :title         => "Enable cheats",
          :default_value => false,
          :is_editable   => true,
          :validations   => {}
        }
      ]
    end
    
    def schema
      self.class.schema
    end
    
    def self.permit
      schema.map { |p| p[:key] }
    end
    
    def initialize container_id, props=nil
      super(container_id, props)
    end
    
    def save
      export_to_database

      apply_config_via_rcon if container.started?
        
      return true
    end
    
    def export_to_docker
      str = ""
      container.docker_container_env_vars.each { |v| str << "export #{v}\n" }

      container.docker_container.exec ["bash", "-c", "echo \"#{str}\" > /data/envs"]
      
      return true
    end
    
    def apply_config_via_rcon
      return false unless container.started?
      
      # container.rcon_auth do |server|
        # sv_cheats
      #   val = get_property_value(:sv_cheats) == true ? "1" : "0"
      #   out = server.rcon_exec("sv_cheats #{val}")
      # end
      
      return true
    end
    
    def last_time_updated
      LAST_TIME_UPDATED
    end
    
    def container
      @container ||= ContainerCounterStrikeGo.find(self.container_id)
    end
    
  end
end
