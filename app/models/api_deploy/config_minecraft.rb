module ApiDeploy
  class ConfigMinecraft < GameConfig
    
    attr_accessor :properties, :container_id, :super_access
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
      {
        :key           => "generator-settings",
        :type          => :string,
        :title         => "",
        :default_value => nil,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "op-permission-level",
        :type          => :integer,
        :title         => "",
        :default_value => 4,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "allow-nether",
        :type          => :boolean,
        :title         => "Allow nether",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "resource-pack-hash",
        :type          => :string,
        :title         => "",
        :default_value => nil,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "level-name",
        :type          => :string,
        :title         => "Level name",
        :default_value => "world",
        :is_editable   => false,
        :validations   => { allow_blank: false, :length => { minimum: 2, maximum: 20 } }
      }, {
        :key           => "enable-query",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :validations   => {}
      }, {
        :key           => "allow-flight",
        :type          => :boolean,
        :title         => "Allow flight",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "announce-player-achievements",
        :type          => :boolean,
        :title         => "Annonce player achievements",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "server-port",
        :type          => :integer,
        :title         => "",
        :default_value => 25565,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "max-world-size",
        :type          => :integer,
        :title         => "",
        :default_value => 29999984,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "level-type",
        :type          => :string,
        :title         => "",
        :default_value => "DEFAULT",
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "enable-rcon",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
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
        :key           => "force-gamemode",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "server-ip",
        :type          => :string,
        :title         => "",
        :default_value => nil,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "network-compression-threshold",
        :type          => :integer,
        :title         => "",
        :default_value => 256,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "max-build-height",
        :type          => :integer,
        :title         => "",
        :default_value => 256,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "spawn-npcs",
        :type          => :boolean,
        :title         => "Spawn npcs",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "white-list",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "spawn-animals",
        :type          => :boolean,
        :title         => "Spawn animals",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "hardcore",
        :type          => :boolean,
        :title         => "Hardcore",
        :default_value => false,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "snooper-enabled",
        :type          => :boolean,
        :title         => "",
        :default_value => true,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "online-mode",
        :type          => :boolean,
        :title         => "Online mode",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "resource-pack",
        :type          => :string,
        :title         => "",
        :default_value => nil,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "pvp",
        :type          => :boolean,
        :title         => "PVP",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "difficulty",
        :type          => :integer,
        :title         => "",
        :default_value => 1,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "enable-command-block",
        :type          => :boolean,
        :title         => "",
        :default_value => false,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "gamemode",
        :type          => :integer,
        :title         => "",
        :default_value => 0,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "player-idle-timeout",
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
        :key           => "max-tick-time",
        :type          => :integer,
        :title         => "",
        :default_value => 60000,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "spawn-monsters",
        :type          => :boolean,
        :title         => "Spawn monsters",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "generate-structures",
        :type          => :boolean,
        :title         => "Generate structures",
        :default_value => true,
        :is_editable   => true,
        :validations   => {}
      }, {
        :key           => "view-distance",
        :type          => :integer,
        :title         => "",
        :default_value => 10,
        :is_editable   => false,
        :validations   => {}
      }, {
        :key           => "motd",
        :type          => :string,
        :title         => "Server name",
        :default_value => "A Minecraft Server",
        :is_editable   => true,
        :validations   => { allow_blank: false, :length => { minimum: 2, maximum: 20 } }
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
      @container ||= Container.find(self.container_id)
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
      str = "#Minecraft server properties\n#{Time.current.utc}\n"
      properties.each do |p|
        value = (p[:value].nil? ? p[:default_value] : p[:value]).to_s
        str << p[:key] + "=" + value + "\n"
      end
      
      container.docker_container.exec ["bash", "-c", "echo \"#{str}\" > server_temp.properties"]
      container.docker_container.exec ["chmod", "777", "server_temp.properties"]
      
      output = container.docker_container.exec ["cat", "server_temp.properties"]

      if output[0][0][0..-2] == str
        container.docker_container.exec ["rm", "server.properties"]
        container.docker_container.exec ["mv", "server_temp.properties", "server.properties"]
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
