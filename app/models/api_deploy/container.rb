module ApiDeploy
  class Container < ActiveRecord::Base
    include ApiConverter

    attr_api [:id, :info]
    
    before_destroy :on_before_destroy
    
    ASYNC = false
    
    # Relations
    belongs_to :user
    belongs_to :plan
    belongs_to :host
    has_one    :game, :through => :plan
    
    # Validations
    validates :user_id, :presence => true
    validates :docker_id, :presence => true
    validates :host_id, :presence => true
    validates :port, :presence => true
  
    class << self
      def class_for game
        cname = "api_deploy/container_#{game}".classify.constantize
        raise "#{cname} is not supported" if defined?(cname) == nil
    
        return cname
      end
      
      def create user, plan, opts
        Rails.logger.debug "Creating container with params: #{opts.to_s}"

        port = opts["PortBindings"].first[1].first["HostPort"] or raise ArgumentError.new("HostPort is absent")
        host = plan.host

        Docker.url = "tcp://#{host.ip}:5422" unless host.ip == '127.0.0.1'

        container_docker = Docker::Container.create(opts)

        container = Container.new.tap do |c|
          c.user_id   = user.id
          c.docker_id = container_docker.id
          c.plan_id   = plan.id
          c.host_id   = host.id
          c.port      = port
        end

        container.save
        
        ap container.attributes
        
        Rails.logger.debug "Container(#{container.id}) record has created, attributes: #{container.to_s}"
      
        unless ASYNC
          container_docker.wait
          Rails.logger.debug "Container(#{container.id}) has created"
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
  
    def start opts={}
      Rails.logger.debug "Starting container(#{id})"
      docker_container.start(opts)
      Rails.logger.debug "Container(#{id}) has started"
    end
  
    def restart
      Rails.logger.debug "Restarting container(#{id})"
      docker_container.restart
      Rails.logger.debug "Container(#{id}) has restarted"
    end
  
    def stop
      Rails.logger.debug "Stopping container(#{id})"
      docker_container.stop
      Rails.logger.debug "Container(#{id}) has stopped"
    end
    
    def is_owner? user
      user_id == user.id
    end
    
    def info
      docker_container.info
    end
    
    private
    
    def docker_container
      docker_container = Docker::Container.get(docker_id)
      raise "Container(#{docker_id}) does not exists" if docker_container.nil?
      
      return docker_container
    end
    
    def on_before_destroy
      # TODO delete docker container in sidekiq
      docker_container.delete(:force => true)
    end
  
  end
end