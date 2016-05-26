module ApiDeploy
  class GamePluginsCollection < Array
    
    def self.plugins_for_container(container)
      cname = "api_deploy/plugin_#{container.game.sname}".classify.constantize
      
      list = PluginMinecraftPe.default_plugins.map do |hs|
        hs[:container] = container
        cname.new(hs)
      end
      
      return new(list)
    end
    
    def all
      select { |p| p.visible == true }
    end
    
    def find_by_id(id)
      find { |p| p.id == id } or raise ActiveRecord::RecordNotFound
    end
    
  end
end