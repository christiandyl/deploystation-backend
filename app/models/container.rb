class Container < ActiveRecord::Base
  include ApiExtension
  include Redis::Objects

  STATUS_CREATED   = "created"
  STATUS_ONLINE    = "online"
  STATUS_OFFLINE   = "offline"
  STATUS_SUSPENDED = "suspended"
  
  ASYNC = false
  
  PERMIT_LIST_UPDATE = [:name, :is_private]
  
  TRIAL_DAYS = 7
  
  REWARD_HOURS = 48

  #############################################################
  #### Accessors
  #############################################################

  store_accessor :metadata, :is_paid, :notified_expiration, :started_at, :charged_at

  value :players, :type => String, :expiration => 1.hour

  #############################################################
  #### Scopes
  #############################################################

  # default_scope -> { where.not(status: STATUS_SUSPENDED) }
  scope :active, -> { where.not(status: STATUS_SUSPENDED) }
  scope :inactive, -> { where(status: STATUS_SUSPENDED) }
  scope :online, -> { where(status: STATUS_ONLINE) }
  scope(:will_stop, -> do
    where('metadata @> hstore(:key, :value)', key: 'notified_expiration', value: 'true').active
  end)
  scope :paid, -> { where('metadata @> hstore(:key, :value)', key: 'is_paid', value: 'true') }
  scope :unpaid, -> { where('metadata @> hstore(:key, :value)', key: 'is_paid', value: 'false') }
  
  #############################################################
  #### Relations
  #############################################################

  belongs_to :user
  belongs_to :plan
  belongs_to :host
  has_one    :game, :through => :plan
  has_many   :accesses
  has_many   :bookmarks
  
  #############################################################
  #### Validations
  #############################################################

  validates :user_id, :presence => true
  validates :host_id, :presence => true
  validates :is_private, inclusion: { in: [true, false] }
  validates :is_paid, inclusion: { in: [true, false] }
  validates :notified_expiration, inclusion: { in: [true, false] }

  #############################################################
  #### Callbacks setup
  #############################################################

  define_callbacks :start, :stop

  set_callback :stop, :before, :charge_credits

  after_create :define_config
  # after_create :send_details_email
  before_destroy :destroy_docker_container
  after_initialize :define_default_values
  after_update :change_container_size, if: Proc.new { |c| c.plan_id_changed? }

  #############################################################
  #### API attributes
  #############################################################

  def api_attributes(_layers)
    h = {
      id: id,
      status: status,
      ip: ip,
      name: name,
      players_on_server: players_on_server,
      is_private: is_private,
      user_id: user_id,
      is_active: is_active,
      is_paid: is_paid,
      host_id: host_id,
      host_info: host.to_api,
      plan_info: plan.to_api,
      game_info: game.to_api
    }

    h
  end

  #############################################################
  #### Methods to override
  #############################################################

  def define_config; raise "SubclassResponsibility"; end
  def command; raise "SubclassResponsibility"; end
  def players_online; raise "SubclassResponsibility"; end
  def logs; raise "SubclassResponsibility"; end
  def started?; raise "SubclassResponsibility"; end
  def starting_progress; raise "SubclassResponsibility"; end

  #############################################################
  #### Static methods
  #############################################################

  class << self
    def class_for game
      cname = "containers/#{game}".classify.constantize
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
        c.active_until = TRIAL_DAYS.days.from_now.to_time
        c.is_paid = false
        c.is_private = false
      end
      
      container.save!
      Rails.logger.debug "Container(#{container.id}) record has created, attributes: #{container.attributes.to_s}"

      unless now
        ContainerWorkers::CreateWorker.perform_async(container.id)
      else
        container.create_docker_container
      end
      
      return container
    end

    def worker(name)
      cname = "container_workers/#{name}_worker".classify.constantize
      raise "#{cname} is not supported" if defined?(cname) == nil
      cname      
    end

    def periodic_worker(name)
      cname = "container_workers/periodic/#{name}_worker".classify.constantize
      raise "#{cname} is not supported" if defined?(cname) == nil
      cname      
    end
  end

  #############################################################
  #### Callbacks
  #############################################################

  def define_default_values
    if self.new_record?
      self.status = STATUS_OFFLINE
      self.notified_expiration ||= false
      self.is_paid ||= false
      self.is_private ||= false
    end
  end

  def send_details_email
    ContainerMailer.delay.container_created_email(id)
  end

  def destroy_docker_container
    begin
      host.use
      docker_container.delete(:force => true)
    rescue
    end
  end

  def change_container_size(**opts)
    now = opts[:now] || false

    unless now
      method_name = 'change_container_size'
      method_args = { now: true }
      ContainerWorkers::MethodWorker.perform_async(id, method_name, method_args)
    else
      # TODO
    end
  end

  #############################################################
  #### Helpers
  #############################################################

  def to_game_class
    klass = class_for(plan.game.sname)
    klass.new(attributes)
  end

  def notified_expiration  
    return (super == 'true') if %w{true false}.include? super
    super
  end

  def is_paid  
    return (super == 'true') if %w{true false}.include? super
    super
  end

  def charged_at
    DateTime.parse(super) rescue nil
  end

  def started_at
    DateTime.parse(super) rescue nil
  end

  def invitation method_name, method_data
    Invitation.new(self, method_name, method_data)
  end
  
  def players_on_server
    unless players.nil?
      return players.value
    else
      return "0/#{plan.max_players.to_s}"
    end
  end

  def is_owner? user
    user_id == user.id || Access.exists?(container_id: container_id, user_id: user.id)
  end
  
  def is_super_owner? user
    user_id == user.id
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

  def plugins
    @plugins ||= GamePluginsCollection.plugins_for_container(self)
  end
  
  def has_plugins?
    cname = "game_plugins/#{game.sname}".classify.constantize
    
    return !cname.default_plugins.blank?
  end
  
  def backup
    @backup ||= DockerServices::Backup.new(container: self)
  end
  
  def conntrack
    @conntrack ||= DockerServices::Conntrack.new(container: self)
  end
  
  def docker_container_id
    "container_" + id.to_s
  end

  #############################################################
  #### Actions
  #############################################################

  def create_docker_container opts = {}
    reset = opts[:reset] || false
    
    opts = docker_container_create_opts
    Rails.logger.debug "Creating docker container with params: #{opts.to_s}"
    
    host.use

    # ram_in_bytes = (plan.ram * 1000000).to_i
    
    opts.merge!({
      "name"       => docker_container_id,
      # "HostConfig" => {
      #   "Memory"           => ram_in_bytes,
      #   "MemorySwap"       => 0,
      #   "MemorySwappiness" => -1
      # }
    })

    begin
      container_docker = Docker::Container.create(opts)
    rescue => e
      message = "Container(#{id}) docker creation error: #{e.message}"
      Rails.logger.debug(message)
      raise message
      
      return nil
    end
    
    self.docker_id = container_docker.id  
    port!
    save!

    unless ASYNC
      container_docker.wait
      Rails.logger.debug "Container(#{id}) docker has created"
    end
    
    unless reset
      send_details_email
      Backend::Helper::slack_ping("User #{user.full_name} has created a new server for #{game.name}, ip is #{ip}")
    end
    
    return container_docker
  end

  def start now=false
    begin
      memory_is_nil = docker_container.info["HostConfig"]["Memory"] == 0
    rescue
      memory_is_nil = false
    end
    
    opts = memory_is_nil == true ? docker_container_start_opts : nil

    unless now
      ContainerWorkers::StartWorker.perform_async(id)
      return true
    end

    run_callbacks :start do
      Rails.logger.debug "Starting container(#{id})"
      docker_container.start(opts)
      config.export_to_docker if status == STATUS_CREATED
      Rails.logger.debug "Container(#{id}) has started"
    
      self.status = STATUS_ONLINE
      self.started_at = Time.now.to_s
      save!
    end
  end

  def stop now=false
    unless now    
      ContainerWorkers::StopWorker.perform_async(id)
      return true
    end

    run_callbacks :stop do
      Rails.logger.debug "Stopping container(#{id})"
      config.export_to_docker
      docker_container.stop
    
      raise "Container #{id} stopping error" unless stopped?
    
      Rails.logger.debug "Container(#{id}) has stopped"
    
      self.status = STATUS_OFFLINE
      save! 
    end
  end

  def restart now=false
    unless now          
      ContainerWorkers::RestartWorker.perform_async(id)
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
  
  def reset now=false
    unless now    
      ContainerWorkers::ResetWorker.perform_async(id)
      return true
    end

    Rails.logger.debug "Resetting container(#{id})"

    destroy_docker_container
    create_docker_container(reset: true)
    start(true)
    
    sleep 2
    
    conntrack.clear_udp_cache
    
    sleep 2
    
    Rails.logger.debug "Container(#{id}) is resetted"
  end
  
  def destroy_container now=false
    unless now    
      ContainerWorkers::DestroyWorker.perform_async(id)
      return true
    end
    
    Rails.logger.debug "Destroying container(#{id})"
    destroy
    
    dc = docker_container rescue true
    
    raise "Container #{id} destroying error" unless dc == true
    
    Rails.logger.debug "Container(#{id}) has destroyed"
    
    return true
  end
  
  # def suspend
  #   self.status = STATUS_SUSPENDED
  #   save
  #
  #   ContainerMailer.delay.welcome_email(id)
  # end
  
  def command_data command_id, now=false
    unless now    
      ContainerWorkers::CommandDataWorker.perform_async(id, command_id)
      return true
    end
    
    command = {}
    
    command = (commands.find { |c| c[:name] == command_id }).clone
    raise "Command #{id} doesn't exists" if command.nil?

    # TODO shit code !!!!!!!!!!!!!!!!!!!!!!
    command = JSON.parse command.to_json
    
    command["players_online"] = players_online(true)[:players_online] rescue 0

    command["args"].each_with_index do |hs,i|
      if hs["type"] == "list" && hs["options"].is_a?(String)
        command["args"][i]["options"] = send(hs["options"])
      end
    end
    
    return command
  end

  def command name, args, now=false
    unless now    
      ContainerWorkers::CommandWorker.perform_async(id, name, args)
      return true
    end
        
    command_settings = self.class::COMMANDS.find { |c| c[:name] == name }
    raise ArgumentError.new("Command #{name} doesn't exists") if command_settings.nil?
    
    return send("command_#{name}", args)
  end

  def charge_credits
    if [STATUS_ONLINE].include?(status)
      price_per_hour = plan.price_per_hour

      if charged_at.nil? || started_at > charged_at
        time_to_charge = (((Time.now.to_f - started_at.to_f) / 60.0) / 60.0).ceil
      else
        time_to_charge = (((Time.now.to_f - charged_at.to_f) / 60.0) / 60.0).ceil
      end

      charge_amount = price_per_hour * time_to_charge

      user_credits = user.credits - charge_amount
      user_credits = 0 if user_credits < 0

      user.update credits: user_credits

      charged_minutes = time_to_charge / 60
      charged_minutes = charged_minutes == 0 ? 1 : charged_minutes

      Charge.create(
        user: user,
        container_id: id,
        amount: charge_amount,
        type: 'container_charge',
        comment: "#{charged_minutes} minutes"
      )

      self.charged_at = Time.now
      save
    end
  end

  #############################################################
  #### Additional
  #############################################################

  def push_new_stat_gaming_time attrs
    total_gaming_time   = attrs[:total_gaming_time] || 0
    segment_gaming_time = attrs[:segment_gaming_time] || 0
    
    begin
      ContainerStatGamingTime.new({
        :container_id        => id,
        :total_gaming_time   => total_gaming_time,
        :segment_gaming_time => segment_gaming_time
      }).save
    
      return true
    rescue
      return false
    end
  end
  
  def referral_token_extra_time
    user.referral_token({
      :reward => {
        :type => "time",
        :cid  => id.to_s
      }
    })
  end
end
