class GameConfig
  include ActiveSupport::Callbacks
  
  define_callbacks :export_to_database
  
  def schema; raise "SubclassResponsibility"; end
  def last_time_updated; raise "SubclassResponsibility"; end
  
  def self.class_for game
    cname = "game_configs/#{game}".classify.constantize
    raise "#{cname} is not supported" if defined?(cname) == nil

    return cname
  end
  
  def initialize container_id, props=nil
    self.properties = schema
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
          value = value.to_s.split.join(" ").tr('^A-Za-z0-9_\- ', '')[0..50]            
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
    run_callbacks :export_to_database do
      hs = {
        :ltu   => last_time_updated,
        :props => {}
      }

      props = properties.map do |p|
        hs[:props][p[:key]] = p[:value].nil? ? p[:default_value] : p[:value]
      end
    
      hs[:props] = hs[:props].to_json
    
      container.server_config = hs
      container.save
    end
    
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
end
