module GameConfigs
  class SevenDaysToDie < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
      {
        :key           => "ServerPort",
        :type          => :integer,
        :title         => "",
        :default_value => 26900,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "ServerIsPublic",
        :type          => :boolean,
        :title         => "Public",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "ServerName",
        :type          => :string,
        :title         => "Server name",
        :default_value => "My Game Host",
        :is_editable   => true,
        :validations   => { allow_blank: false, :length => { minimum: 2, maximum: 20 } }
      },{
        :key           => "ServerPassword",
        :type          => :string,
        :title         => "Server password",
        :default_value => nil,
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "ServerMaxPlayerCount",
        :type          => :integer,
        :title         => "",
        :default_value => 8,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "ServerDescription",
        :type          => :string,
        :title         => "Server description",
        :default_value => "A 7 Days to Die server",
        :is_editable   => true,
        :validations   => { allow_blank: false, :length => { minimum: 2, maximum: 20 } }
      },{
        :key           => "ServerWebsiteURL",
        :type          => :string,
        :title         => "Server website url",
        :default_value => nil,
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "GameWorld",
        :type          => :string,
        :title         => "Game world",
        :default_value => "Navezgane",
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "GameName",
        :type          => :string,
        :title         => "Game name",
        :default_value => "My game",
        :is_editable   => true,
        :validations   => { allow_blank: false, :length => { minimum: 2, maximum: 20 } }
      },{
        :key           => "GameDifficulty",
        :type          => :string,
        :title         => "Game difficulty",
        :default_value => 2,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "GameMode",
        :type          => :string,
        :title         => "Game mode",
        :default_value => "GameModeSurvivalMP",
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "ZombiesRun",
        :type          => :integer,
        :title         => "Zombies run",
        :default_value => 0,
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "BuildCreate",
        :type          => :string,
        :title         => "Cheat mode",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "DayNightLength",
        :type          => :integer,
        :title         => "Day/night length",
        :default_value => 40,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "FriendlyFire",
        :type          => :boolean,
        :title         => "Friendly fire",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      },{
        :key           => "PersistentPlayerProfiles",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "ControlPanelEnabled",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "ControlPanelPort",
        :type          => :integer,
        :title         => "",
        :default_value => 8080,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "ControlPanelPassword",
        :type          => :string,
        :title         => "",
        :default_value => "CHANGEME",
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "TelnetEnabled",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "TelnetPort",
        :type          => :integer,
        :title         => "",
        :default_value => 8081,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "TelnetPassword",
        :type          => :string,
        :title         => "",
        :default_value => "ds2016",
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "DisableNAT",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "AdminFileName",
        :type          => :string,
        :title         => "",
        :default_value => "serveradmin.xml",
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "DropOnDeath",
        :type          => :integer,
        :title         => "",
        :default_value => 0,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "DropOnQuit",
        :type          => :integer,
        :title         => "",
        :default_value => 1,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "CraftTimer",
        :type          => :integer,
        :title         => "",
        :default_value => 1,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LootTimer",
        :type          => :integer,
        :title         => "",
        :default_value => 1,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "EnemySenseMemory",
        :type          => :integer,
        :title         => "",
        :default_value => 60,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "EnemySpawnMode",
        :type          => :integer,
        :title         => "",
        :default_value => 3,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "EnemyDifficulty",
        :type          => :integer,
        :title         => "",
        :default_value => 0,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "NightPercentage",
        :type          => :integer,
        :title         => "",
        :default_value => 35,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "BlockDurabilityModifier",
        :type          => :integer,
        :title         => "",
        :default_value => 100,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LootAbundance",
        :type          => :integer,
        :title         => "",
        :default_value => 100,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LootRespawnDays",
        :type          => :integer,
        :title         => "",
        :default_value => 7,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LandClaimSize",
        :type          => :integer,
        :title         => "",
        :default_value => 7,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LandClaimDeadZone",
        :type          => :integer,
        :title         => "",
        :default_value => 30,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LandClaimExpiryTime",
        :type          => :integer,
        :title         => "",
        :default_value => 3,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LandClaimDecayMode",
        :type          => :integer,
        :title         => "",
        :default_value => 0,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LandClaimOnlineDurabilityModifier",
        :type          => :integer,
        :title         => "",
        :default_value => 4,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "LandClaimOfflineDurabilityModifier",
        :type          => :integer,
        :title         => "",
        :default_value => 4,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "AirDropFrequency",
        :type          => :integer,
        :title         => "",
        :default_value => 72,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "MaxSpawnedZombies",
        :type          => :integer,
        :title         => "",
        :default_value => 60,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "EACEnabled",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      },{
        :key           => "SaveGameFolder",
        :type          => :integer,
        :title         => "",
        :default_value => nil,
        :is_editable   => false,
        :validations   => {}
      }
    ]

    def self.permit
      SCHEMA.map { |p| p[:key] }
    end
    
    def initialize container_id, props=nil
      self.properties = SCHEMA
      self.container_id = container_id
      self.super_access = false
      
      read_from_database
      
      props.each { |p| set_property(p["key"], p["value"]) } unless props.nil?
    end
    
    def set_property key, value
      key = key.to_s
      
      is_found = false
      self.properties.each_with_index do |prop, index|
        if prop[:key] == key
          raise "Property #{key} is not editable" if !prop[:is_editable] && !self.super_access
          
          type = prop[:type]
          validations = prop[:validations]
          if type == :boolean
            raise ArgumentError.new("Property #{key} doesn't have type #{type}") unless [true,false].include?(value)
          elsif type == :string
            value = value.to_s.split.join(" ").tr('^A-Za-z0-9 ', '')[0..20]            
          elsif type == :integer
            raise ArgumentError.new("Property #{key} doesn't have type #{type}") unless value.is_a?(Integer)
          end
          
          raise "Property #{key} can't be blank" if validations[:allow_blank] == true && value.blank?
          
          self.properties[index][:value] = value
          is_found = true
          break
        end
      end
      
      raise ArgumentError.new("Property #{key} doesn't exists") unless is_found
      
      return true
    end
    
    def set_properties props
      props.each { |prop| set_property(prop[0], prop[1]) }
      
      return true
    end
    
    def get_property key
      key = key.to_s
      prop = (self.properties.find { |p| p[:key] == key }) or raise ArgumentError.new("Property #{key} doesn't exists")
      
      return prop
    end
    
    def get_property_value key
      prop = get_property(key)
      
      return prop[:value].nil? ? prop[:default_value] : prop[:value]
    end
    
    def container
      @container ||= Containers::SevenDaysToDie.find(self.container_id)
    end
    
    def all flavor = :private
      return flavor == :public ? properties.find_all { |p| p[:is_editable] == true } : properties
    end
    
    def export_to_database
      hs = {
        :ltu   => LAST_TIME_UPDATED,
        :props => {}
      }

      props = properties.map do |p|
        hs[:props][p[:key]] = p[:value].nil? ? p[:default_value] : p[:value]
      end
      
      hs[:props] = hs[:props].to_json
      
      container.server_config = hs
      container.save
      
      return true
    end
    
    def export_to_docker      
      str = '<?xml version="1.0"?>\n'
      properties.each do |p|
        value = (p[:value].nil? ? p[:default_value] : p[:value]).to_s
        str << '<property name="' + p[:key] +'" value="' + value + '"/>'
      end
      str << "</ServerSettings>"
      
      conf_path = "/home/steam/app/serverconfig.xml"
      tmp_conf_path = "/home/steam/app/serverconfig_copy.xml"
      container.docker_container.exec ["bash", "-c", "echo '#{str}' > #{tmp_conf_path}"]
      container.docker_container.exec ["chmod", "777", tmp_conf_path]

      output = container.docker_container.exec ["cat", tmp_conf_path]

      if output[0][0][0..-2] == str
        container.docker_container.exec ["rm", conf_path]
        container.docker_container.exec ["mv", tmp_conf_path, conf_path]
      else
        raise "Error syncing server config in docker: #{str}"
      end
      
      # TODO write extra check for server.properties
      # output = container.docker_container.exec ["cat", "server.properties"]
      # unless output[0][0][0..-2] == str
      #   raise "Error syncing server config in docker: #{str}"
      # end
      
      return true
    end
    
    def read_from_database
      if container.server_config.is_a?(Hash) && container.server_config["props"]
        props = JSON.parse(container.server_config["props"])
        unless props.is_a?(Hash)
          raise "Container #{container.id} config read error: #{container.server_config.to_s}"
        end
        
        Rails.logger.debug "Container #{container.id} server config: #{props.to_s}"
        
        self.super_access = true
        props.each { |v| set_property(v[0], v[1]) }
        self.super_access = false
        
        return true
      end
      
      return false
    end
    
    def save
      export_to_database

      return true
    end
    
  end
end
