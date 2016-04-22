module ApiDeploy
  class ConfigCounterStrikeGo < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
      {
        :key           => "server_password",
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
        :key           => "max_players",
        :type          => :integer,
        :title         => "Max players",
        :default_value => 16,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "default_map",
        :type          => :string,
        :title         => "Default map",
        :default_value => "cs_italy",
        :is_editable   => false,
        :validations   => {}
      }
    ]
    
    def initialize container_id, props=nil
      super(container_id, props)
    end
    
    def save
      export_to_database

      return true
    end
    
    def export_to_docker
      return true
    end
    
    def schema
      SCHEMA
    end
    
    def last_time_updated
      LAST_TIME_UPDATED
    end
    
  end
end
