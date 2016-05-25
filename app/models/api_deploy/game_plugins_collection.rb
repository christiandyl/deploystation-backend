module ApiDeploy
  class GamePluginsCollection < Array
    
    def self.plugins_for_container(container)
      list = PluginMinecraftPe.default_plugins.select { |p| p[:visible] == true }
      list = list.map { || }
      
      return new(list)
    end
    
    def all
    end
    
    def find(id)
      data = super { |p| p.id == id } or raise ActiveRecord::RecordNotFound
      
      return new(data)
    end
    
  end
end