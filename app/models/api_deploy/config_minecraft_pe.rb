module ApiDeploy
  class ConfigMinecraftPe < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
      {     
        :key           => "gamemode",
        :type          => :integer,
        :title         => "",
        :default_value => 0,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "max-players",
        :type          => :integer,
        :title         => "",
        :default_value => 5,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "spawn-protection",
        :type          => :integer,
        :title         => "",
        :default_value => 16,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "white-list",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "enable-query",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "enable-rcon",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "motd",
        :type          => :string,
        :title         => "Server name",
        :default_value => "Minecraft: PE Server",
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "announce-player-achievements",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "allow-flight",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "spawn-animals",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "spawn-mobs",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "force-gamemode",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "hardcore",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "pvp",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "difficulty",
        :type          => :integer,
        :title         => "",
        :default_value => 1,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "generator-settings",
        :type          => :string,
        :title         => "",
        :default_value => nil,
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "level-name",
        :type          => :string,
        :title         => "",
        :default_value => "world",
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "level-seed",
        :type          => :string,
        :title         => "Level seed",
        :default_value => nil,
        :is_editable   => true,
        :validations   => {}
      }, {      
        :key           => "level-type",
        :type          => :string,
        :title         => "",
        :default_value => "DEFAULT",
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "rcon.password",
        :type          => :string,
        :title         => "",
        :default_value => "uKsq1C8Cqu",
        :is_editable   => false,
        :validations   => {}
      }, {      
        :key           => "auto-save",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
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

    def export_to_docker
      str = ""
      container.docker_container_env_vars.each { |v| str << "export #{v}\n" }

      container.docker_container.exec ["bash", "-c", "echo \"#{str}\" > /nukkit/envs"]
      
      return true
    end

    def schema
      SCHEMA
    end
    
    def last_time_updated
      LAST_TIME_UPDATED
    end
    
    def container
      @container ||= ContainerMinecraftPe.find(self.container_id)
    end
    
    def save
      export_to_database

      return true
    end
    
  end
end
