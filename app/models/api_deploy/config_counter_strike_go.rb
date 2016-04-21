module ApiDeploy
  class ConfigCounterStrikeGo < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
      {
        :key           => "map",
        :type          => :string,
        :title         => "Default map",
        :default_value => "cs_assault",
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "mapgroup",
        :type          => :string,
        :title         => "Map group",
        :default_value => "random_classic",
        :is_editable   => true,
        :validations   => {}
      },
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
