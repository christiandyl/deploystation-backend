module ApiDeploy
  class GamePlugin
    include ActiveModel::Model
    
    class_attribute :default_plugins
    
    attr_accessor :id, :name, :description, :configuration, :dependencies, :visible, :status

    def initialize args = nil
      super(args)
      
      self.dependencies ||= {}
      self.configuration ||= {}
      
      self.visible ||= false
      self.status ||= false
    end

    def to_api data_type = :public
      hs = {
        :id            => id,
        :name          => name,
        :description   => description,
        :configuration => configuration,
        :status        => status
      }
      
      return hs
    end

    def activate
      self.status = true
      save
    end
    
    def disactivate
      self.status = false
      save
    end

    def save
    end
    
    def fetch
    end
    
  end
end