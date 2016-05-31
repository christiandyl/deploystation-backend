module ApiDeploy
  class GamePlugin
    include ActiveModel::Model
    
    class_attribute :default_plugins
    
    attr_accessor(
      :id,
      :name,
      :author,
      :description,
      :configuration,
      :dependencies,
      :visible,
      :status,
      :repo_url,
      :download_url,
      :container
    )

    def initialize args = nil
      super(args)
      
      self.dependencies ||= {}
      self.configuration ||= {}
      
      self.visible ||= false
      self.status ||= false
      
      if container
        server_plugins = container.server_plugins || {}
        self.status = server_plugins.key?(id.to_s)
      end
    end

    def to_api data_type = :public
      hs = {
        :id            => id,
        :name          => name,
        :author        => author,
        :description   => description,
        :configuration => configuration,
        :status        => status,
        :repo_url      => repo_url
      }
      
      if data_type == :private
        hs[:dependencies] = dependencies
        hs[:download_url] = download_url
      end
      
      return hs
    end

    def enable
      self.status = true
      save
    end
    
    def disable
      self.status = false
      save
    end

    def save
      server_plugins = container.server_plugins || {}
      
      if status == true
        server_plugins[id.to_s] = {
          :configuration => configuration
        }
      else
        server_plugins.delete(id.to_s)
      end
      
      container.server_plugins = server_plugins
      
      return container.save
    end
    
    def enabled?
      self.status == true
    end
    
    def fetch
    end
    
  end
end