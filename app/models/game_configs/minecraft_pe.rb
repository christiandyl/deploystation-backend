module GameConfigs
  class MinecraftPe < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    def self.schema
      return [
        {     
          :key           => "gamemode",
          :type          => :list,
          :title         => "",
          :default_value => 0,
          :is_editable   => true,
          :validations   => {},
          :options       => [
            { title: "Survival", value: 0 },
            { title: "Creative", value: 1 },
            { title: "Adventure", value: 2 },
            { title: "Spectator", value: 3 }
          ],
          :requires_reset   => true,
          :requires_restart => true
        }, {      
          :key           => "max-players",
          :type          => :integer,
          :title         => "",
          :default_value => 5,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "spawn-protection",
          :type          => :integer,
          :title         => "",
          :default_value => 16,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "white-list",
          :type          => :boolean,
          :title         => "",
          :default_value => false,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "enable-query",
          :type          => :boolean,
          :title         => "",
          :default_value => true,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "enable-rcon",
          :type          => :boolean,
          :title         => "",
          :default_value => true,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "motd",
          :type          => :string,
          :title         => "Server name",
          :default_value => "Minecraft: PE Server",
          :is_editable   => true,
          :validations   => {
            :length => {
              :allow_blank => true,
              :minimum     => 1,
              :maximum     => 20
            }
          },
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "announce-player-achievements",
          :type          => :boolean,
          :title         => "Player achievements",
          :default_value => true,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "allow-flight",
          :type          => :boolean,
          :title         => "Allow flight",
          :default_value => false,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "spawn-animals",
          :type          => :boolean,
          :title         => "Spawn animals",
          :default_value => true,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "spawn-mobs",
          :type          => :boolean,
          :title         => "Spawn mobs",
          :default_value => true,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "force-gamemode",
          :type          => :boolean,
          :title         => "Force gamemode",
          :default_value => false,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "hardcore",
          :type          => :boolean,
          :title         => "Hardcore",
          :default_value => false,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "pvp",
          :type          => :boolean,
          :title         => "PVP",
          :default_value => true,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "difficulty",
          :type          => :list,
          :title         => "Difficulty",
          :default_value => 1,
          :is_editable   => true,
          :validations   => {},
          :options       => [
            { title: "Peaceful", value: 0 },
            { title: "Easy", value: 1 },
            { title: "Normal", value: 2 },
            { title: "Hard", value: 3 }
          ],
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "generator-settings",
          :type          => :string,
          :title         => "",
          :default_value => nil,
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => true,
          :requires_restart => true
        }, {      
          :key           => "level-name",
          :type          => :string,
          :title         => "",
          :default_value => "world",
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => true,
          :requires_restart => true
        }, {      
          :key           => "level-seed",
          :type          => :string,
          :title         => "Level seed",
          :default_value => nil,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "level-type",
          :type          => :string,
          :title         => "",
          :default_value => "DEFAULT",
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "rcon.password",
          :type          => :string,
          :title         => "",
          :default_value => "uKsq1C8Cqu",
          :is_editable   => false,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
        }, {      
          :key           => "auto-save",
          :type          => :boolean,
          :title         => "Auto save",
          :default_value => true,
          :is_editable   => true,
          :validations   => {},
          :requires_reset   => false,
          :requires_restart => true
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

    def export_to_docker
      container.export_env_vars
      
      return true
    end
    
    def last_time_updated
      LAST_TIME_UPDATED
    end
    
    def container
      @container ||= Containers::MinecraftPe.find(self.container_id)
    end
    
    def save
      export_to_database

      return true
    end

    def props_to_file(props)
      file_content = ''

      props.each do |p|
        file_content << "#{p[:key]}=#{p[:value]}\n"
      end

      file_content
    end
    
  end
end
