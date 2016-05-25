module ApiDeploy
  class GamePluginsCollection < Array
    
    def self.plugins_for_container(container)
      list = PluginMinecraftPe.default_plugins.select { |p| p[:visible] == true }
      
      return new(list)
    end
    
    def find(id)
      data = super { |p| p.id == id } or raise ActiveRecord::RecordNotFound
      
      return new(data)
    end
    
  end
end