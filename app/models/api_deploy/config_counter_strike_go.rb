module ApiDeploy
  class ConfigCounterStrikeGo < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
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
    
    def self.permit
      SCHEMA.map { |p| p[:key] }
    end
    
    def initialize container_id, props=nil
      super(container_id, props)
    end
    
    def save
      export_to_database

      return true
    end
    
    def export_to_docker
      str = ""
      container.docker_container_env_vars.each { |v| str << "export #{v}\n" }

      container.docker_container.exec ["bash", "-c", "echo \"#{str}\" > /data/envs"]
      
      return true
    end
    
    def schema
      SCHEMA
    end
    
    def last_time_updated
      LAST_TIME_UPDATED
    end
    
    def container
      @container ||= ContainerCounterStrikeGo.find(self.container_id)
    end
    
  end
end
