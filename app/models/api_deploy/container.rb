module ApiDeploy
  class Container < ActiveRecord::Base
    include ApiConverter

    attr_api [:id, :status, :host_info, :plan_info, :ip, :name]
    
    before_destroy :on_before_destroy
    
    STATUS_ONLINE  = "online"
    STATUS_OFFLINE = "offline"
    
    ASYNC = false
    
    PERMIT_LIST_UPDATE = [:name, :is_private]
    
    # Relations
    belongs_to :user
    belongs_to :plan
    belongs_to :host
    has_one    :game, :through => :plan
    has_many   :accesses
    
    # Validations
    validates :user_id, :presence => true
    validates :host_id, :presence => true
    validates :is_private, inclusion: { in: [true, false] }
  
    def command; raise "SubclassResponsibility"; end
    def players_online; raise "SubclassResponsibility"; end
    def logs; raise "SubclassResponsibility"; end
    def started?; raise "SubclassResponsibility"; end
    def starting_progress; raise "SubclassResponsibility"; end
  
    class << self
      def class_for game
        cname = "api_deploy/container_#{game}".classify.constantize
        raise "#{cname} is not supported" if defined?(cname) == nil
    
        return cname
      end
      
      def create user, plan, opts, now=false
        host = plan.host
        
        container = Container.new.tap do |c|
          c.user_id    = user.id
          c.plan_id    = plan.id
          c.host_id    = host.id
          c.status     = STATUS_OFFLINE
          c.is_private = false
        end
        
        container.save!
        Rails.logger.debug "Container(#{container.id}) record has created, attributes: #{container.attributes.to_s}"
        
        unless now          
          ApiDeploy::ContainerCreateWorker.perform_async(container.id, opts)
        else          
          container.create_docker_container
        end
        
        return container
      end
      
      def available_port
        exists = true
        while exists
          port = Helper::available_port
          exists = self.exists? port: port
        end
      
        return port
      end
    end
  
    def create_docker_container opts
      Rails.logger.debug "Creating docker container with params: #{opts.to_s}"

      port = opts["PortBindings"].first[1].first["HostPort"] or raise ArgumentError.new("HostPort is absent")
      
      host.use

      opts["name"] = "container_" + id.to_s

      begin
        container_docker = Docker::Container.create(opts)
      rescue => e
        message = "Container(#{id}) docker creation error: #{e.message}"
        Rails.logger.debug(message)
        raise message
        
        return nil
      end
      
      self.docker_id = container_docker.id
      self.port      = port
      
      save!
  
      unless ASYNC
        container_docker.wait
        Rails.logger.debug "Container(#{id}) docker has created"
      end
      
      return container_docker
    end
  
    def start opts={}, now=false
      unless now          
        ApiDeploy::ContainerStartWorker.perform_async(id, opts)
        return true
      end
      
      Rails.logger.debug "Starting container(#{id})"
      docker_container.start(opts)
      Rails.logger.debug "Container(#{id}) has started"
      
      self.status = STATUS_ONLINE
      save!
    end
  
    def restart now=false
      unless now          
        ApiDeploy::ContainerRestartWorker.perform_async(id)
        return true
      end
      
      self.status = STATUS_OFFLINE
      save!
      
      Rails.logger.debug "Restarting container(#{id})"
      docker_container.restart
      Rails.logger.debug "Container(#{id}) has restarted"
      
      self.status = STATUS_ONLINE
      save!
    end
  
    def stop now=false
      unless now    
        ApiDeploy::ContainerStopWorker.perform_async(id)
        return true
      end

      Rails.logger.debug "Stopping container(#{id})"
      docker_container.stop
      
      raise "Container #{id} stopping error" unless stopped?
      
      Rails.logger.debug "Container(#{id}) has stopped"
      
      self.status = STATUS_OFFLINE
      save!
    end
    
    def destroy_container now=false
      unless now    
        ApiDeploy::ContainerDestroyWorker.perform_async(id)
        return true
      end
      
      Rails.logger.debug "Destroying container(#{id})"
      destroy
      
      dc = docker_container rescue true
      
      raise "Container #{id} destroying error" unless dc == true
      
      Rails.logger.debug "Container(#{id}) has destroyed"
      
      return true
    end
    
    def is_owner? user
      user_id == user.id || Access.exists?(container_id: container_id, user_id: user.id)
    end
    
    def is_super_owner? user
      user_id == user.id
    end
    
    def host_info
      host.to_api(:public)
    end
    
    def plan_info
      plan.to_api(:public)
    end
    
    def ip
      (host.ip + ":" + port) rescue nil
    end
    
    def command name, args, now=false
      unless now    
        ApiDeploy::ContainerCommandWorker.perform_async(id, name, args)
        return true
      end
          
      command_settings = self.class::COMMANDS.find { |c| c[:name] == name }
      raise ArgumentError.new("Command #{name} doesn't exists") if command_settings.nil?
      
      return send("command_#{name}", args)
    end
    
    def docker_container
      if docker_id.nil?
        raise "Container(#{docker_id}) can't get docker container, docker_id is empty"
      end
      
      host.use
      
      docker_container = Docker::Container.get(docker_id)
      raise "Container(#{docker_id}) does not exists" if docker_container.nil?
      
      return docker_container
    end
    
    def stopped?
      s = docker_container.info["State"]
      
      s["Running"] == false && s["Paused"] == false && s["Restarting"] == false && s["Dead"] == false
    end
    
    def game
      plan.game
    end
    
    def config
      @config ||= ("ApiDeploy::Config#{game.name.capitalize}".constantize).new(id)
    end
    
    private
    
    def on_before_destroy
      host.use
      docker_container.delete(:force => true)
    end
  
  end
end