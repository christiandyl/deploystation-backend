module ApiDeploy
  class ConfigMinecraft < GameConfig
    
    attr_accessor :properties, :container_id
    
    LAST_TIME_UPDATED = 1450115967
    
    SCHEMA = [
      {
        :key           => "generator-settings",
        :type          => :string,
        :default_value => nil,
        :is_editable   => false
      }, {
        :key           => "op-permission-level",
        :type          => :integer,
        :default_value => 4,
        :is_editable   => false
      }, {
        :key           => "allow-nether",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "resource-pack-hash",
        :type          => :string,
        :default_value => nil
      }, {
        :key           => "level-name",
        :type          => :string,
        :default_value => "world",
        :is_editable   => true
      }, {
        :key           => "enable-query",
        :type          => :boolean,
        :default_value => false
      }, {
        :key           => "allow-flight",
        :type          => :boolean,
        :default_value => false,
        :is_editable   => true
      }, {
        :key           => "announce-player-achievements",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "server-port",
        :type          => :integer,
        :default_value => 25565,
        :is_editable   => false
      }, {
        :key           => "max-world-size",
        :type          => :integer,
        :default_value => 29999984,
        :is_editable   => false
      }, {
        :key           => "level-type",
        :type          => :string,
        :default_value => "DEFAULT",
        :is_editable   => false
      }, {
        :key           => "enable-rcon",
        :type          => :boolean,
        :default_value => false,
        :is_editable   => false
      }, {
        :key           => "level-seed",
        :type          => :string,
        :default_value => nil,
        :is_editable   => false
      }, {
        :key           => "force-gamemode",
        :type          => :boolean,
        :default_value => false,
        :is_editable   => false
      }, {
        :key           => "server-ip",
        :type          => :string,
        :default_value => nil,
        :is_editable   => false
      }, {
        :key           => "network-compression-threshold",
        :type          => :integer,
        :default_value => 256,
        :is_editable   => false
      }, {
        :key           => "max-build-height",
        :type          => :integer,
        :default_value => 256,
        :is_editable   => false
      }, {
        :key           => "spawn-npcs",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "white-list",
        :type          => :boolean,
        :default_value => false,
        :is_editable   => false
      }, {
        :key           => "spawn-animals",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "hardcore",
        :type          => :boolean,
        :default_value => false,
        :is_editable   => true
      }, {
        :key           => "snooper-enabled",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => false
      }, {
        :key           => "online-mode",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "resource-pack",
        :type          => :string,
        :default_value => nil,
        :is_editable   => false
      }, {
        :key           => "pvp",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "difficulty",
        :type          => :integer,
        :default_value => 1,
        :is_editable   => false
      }, {
        :key           => "enable-command-block",
        :type          => :boolean,
        :default_value => false,
        :is_editable   => false
      }, {
        :key           => "gamemode",
        :type          => :integer,
        :default_value => 0,
        :is_editable   => false
      }, {
        :key           => "player-idle-timeout",
        :type          => :integer,
        :default_value => 0,
        :is_editable   => false
      }, {
        :key           => "max-players",
        :type          => :integer,
        :default_value => 5,
        :is_editable   => false
      }, {  
        :key           => "max-tick-time",
        :type          => :integer,
        :default_value => 60000,
        :is_editable   => false
      }, {
        :key           => "spawn-monsters",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => true
      }, {
        :key           => "generate-structures",
        :type          => :boolean,
        :default_value => true,
        :is_editable   => false
      }, {
        :key           => "view-distance",
        :type          => :integer,
        :default_value => 10,
        :is_editable   => false
      }, {
        :key           => "motd",
        :type          => :string,
        :default_value => "A Minecraft Server",
        :is_editable   => true
      }
    ]
    
    def initialize container_id, props=nil
      self.properties = SCHEMA
      self.container_id = container_id
      
      read_from_database
      
      props.each { |p| set_property(p["key"], p["value"]) } unless props.nil?
    end
    
    def set_property key, value
      key = key.to_s
      
      is_found = false
      self.properties.each_with_index do |prop, index|
        if prop[:key] == key
          raise "Property #{key} is not editable" if !prop[:is_editable]
          
          type = prop[:type]
          if type == :boolean
            raise ArgumentError.new("Property #{key} doesn't have type #{type}") unless [true,false].include?(value)
          elsif type == :string
            value = value.to_s.split.join(" ").tr('^A-Za-z0-9 ', '')[0..20]
          elsif type == :integer
            raise ArgumentError.new("Property #{key} doesn't have type #{type}") unless value.is_a?(Integer)
          end
          
          self.properties[index][:value] = value
          is_found = true
          break
        end
      end
      
      raise ArgumentError.new("Property #{key} doesn't exists") unless is_found
      
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
    
    def all flavor = :public
      return flavor == :private ? properties.find_all { |p| p[:is_editable] == true } : properties
    end
    
    def export_to_database
      hs = {
        :ltu   => LAST_TIME_UPDATED,
        :props => {}
      }
      
      props = properties.map do |p|
         hs[:props][p[:key]] = p[:value].nil? ? p[:default_value] : p[:value]
      end
      
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
      
      output = container.docker_container.exec ["cat", "server.properties"]
      unless output[0][0][0..-2] == str
        raise "Error syncing server config in docker: #{str}"
      end
      
      return true
    end
    
    def read_from_database
      if container.server_config.is_a?(Hash) && container.server_config[:props]
        container.server_config[:props].each { |v| set_property(v[0], v[1]) }
        return true
      end
      
      return false
    end
    
    def save
      export_to_database
      export_to_docker

      return true
    end
    
  end
end
