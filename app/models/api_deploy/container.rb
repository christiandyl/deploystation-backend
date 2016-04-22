module ApiDeploy
  class Container < ActiveRecord::Base
    include ApiConverter

    attr_api [:id, :status, :host_info, :plan_info, :game_info, :ip, :name, :is_private, :user_id, :is_active, :is_paid]
    
    # default_scope -> { where.not(status: STATUS_SUSPENDED) }
    
    STATUS_CREATED   = "created"
    STATUS_ONLINE    = "online"
    STATUS_OFFLINE   = "offline"
    STATUS_SUSPENDED = "suspended"
    
    ASYNC = false
    
    PERMIT_LIST_UPDATE = [:name, :is_private]
    
    TRIAL_DAYS = 7
    
    REWARD_HOURS = 24
    
    # Relations
    belongs_to :user
    belongs_to :plan
    belongs_to :host
    has_one    :game, :through => :plan
    has_many   :accesses
    has_many   :bookmarks
    
    # Validations
    validates :user_id, :presence => true
    validates :host_id, :presence => true
    validates :is_private, inclusion: { in: [true, false] }
  
    # Callbacks
    after_create :define_config
    after_create :send_details_email
    before_destroy :destroy_docker_container
  
    def command; raise "SubclassResponsibility"; end
    def players_online; raise "SubclassResponsibility"; end
    def logs; raise "SubclassResponsibility"; end
    def started?; raise "SubclassResponsibility"; end
    def starting_progress; raise "SubclassResponsibility"; end
    def reset; raise "SubclassResponsibility"; end
  
    class << self
      def class_for game
        cname = "api_deploy/container_#{game}".classify.constantize
        raise "#{cname} is not supported" if defined?(cname) == nil
    
        return cname
      end
      
      def create user, plan, name, now=false
        host = plan.host
        
        container = self.new.tap do |c|
          c.user_id    = user.id
          c.plan_id    = plan.id
          c.host_id    = host.id
          c.status     = STATUS_CREATED
          c.name       = name
          # c.active_until = (Date.today + 7).to_datetime
          c.active_until = TRIAL_DAYS.days.from_now.to_time
          c.is_paid = false
          c.is_private = false
        end
        
        container.save!
        Rails.logger.debug "Container(#{container.id}) record has created, attributes: #{container.attributes.to_s}"

        unless now          
          ApiDeploy::ContainerCreateWorker.perform_async(container.id)
        else          
          container.create_docker_container
        end
        
        return container
      end
    end
  
    # Actions
  
    def create_docker_container
      opts = docker_container_create_opts
      Rails.logger.debug "Creating docker container with params: #{opts.to_s}"
      
      host.use

      opts["name"] = docker_container_id

      begin
        container_docker = Docker::Container.create(opts)
      rescue => e
        message = "Container(#{id}) docker creation error: #{e.message}"
        Rails.logger.debug(message)
        raise message
        
        return nil
      end
      
      self.docker_id = container_docker.id
      
      save!
  
      unless ASYNC
        container_docker.wait
        Rails.logger.debug "Container(#{id}) docker has created"
      end
      
      Helper::slack_ping("User #{user.full_name} has created a new server for #{game.name}, ip is #{ip}")
      
      return container_docker
    end
  
    def start now=false
      opts = docker_container_start_opts
      unless now          
        ApiDeploy::ContainerStartWorker.perform_async(id)
        return true
      end
      
      Rails.logger.debug "Starting container(#{id})"
      docker_container.start(opts)
      config.export_to_docker if status == STATUS_CREATED
      Rails.logger.debug "Container(#{id}) has started"
      
      self.status = STATUS_ONLINE
      save!
    end
  
    def stop now=false
      unless now    
        ApiDeploy::ContainerStopWorker.perform_async(id)
        return true
      end

      Rails.logger.debug "Stopping container(#{id})"
      config.export_to_docker
      docker_container.stop
      
      raise "Container #{id} stopping error" unless stopped?
      
      Rails.logger.debug "Container(#{id}) has stopped"
      
      self.status = STATUS_OFFLINE
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
    
    def command name, args, now=false
      unless now    
        ApiDeploy::ContainerCommandWorker.perform_async(id, name, args)
        return true
      end
          
      command_settings = self.class::COMMANDS.find { |c| c[:name] == name }
      raise ArgumentError.new("Command #{name} doesn't exists") if command_settings.nil?
      
      return send("command_#{name}", args)
    end
    
    def invitation method_name, method_data
      Invitation.new(self, method_name, method_data)
    end
    
    # def suspend
    #   self.status = STATUS_SUSPENDED
    #   save
    #
    #   ContainerMailer.delay.welcome_email(id)
    # end
    
    # Getters
    
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
    
    def game_info
      game.to_api(:public)
    end
    
    def is_active
      begin
        status = active_until > Date.today
      rescue
        status = false
      end
      
      return status
    end
    
    def ip
      (host.domain + ":" + port) rescue nil
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
    
    def port!
      self.port ||= plan.host.free_port
    end
    
    def config
      @config ||= GameConfig.class_for(game.sname).new(id)
    end
    
    def referral_token_extra_time
      user.referral_token({
        :reward => {
          :type => "time",
          :cid  => id.to_s
        }
      })
    end
    
    def command_data command_id, now=false
      unless now    
        ApiDeploy::ContainerCommandDataWorker.perform_async(id, command_id)
        return true
      end
      
      command = {}
      
      command = (commands.find { |c| c[:name] == command_id }).clone
      raise "Command #{id} doesn't exists" if command.nil?

      # TODO shit code !!!!!!!!!!!!!!!!!!!!!!
      command = JSON.parse command.to_json

      command["args"].each_with_index do |hs,i|
        if hs["type"] == "list" && hs["options"].is_a?(String)
          command["args"][i]["options"] = send(hs["options"])
        end
      end
      
      return command
    end
    
    # Callbacks endpoints
    
    def send_details_email
      ContainerMailer.delay.container_created_email(id)
    end
    
    def backup
      @backup ||= Backup.new(container: self)
    end
    
    def docker_container_id
      "container_" + id.to_s
    end
    
    private
    
    def destroy_docker_container
      host.use
      docker_container.delete(:force => true)
    end
  
  end
end