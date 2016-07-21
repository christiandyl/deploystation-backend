class User < ActiveRecord::Base
  include ApiExtension
  include UserStorage
  include UserReferral
  include UserBraintree

  attr_accessor :current_password, :new_password

  store_accessor :metadata, :credits

  EMAIL_CONFIRMATION_PERIOD = 1.day
  DEFAULT_CREDITS = 5.freeze

  #############################################################
  #### Relations
  #############################################################

  has_many :connects
  has_many :containers
  has_many :shared_containers, through: :accesses, :source => :container
  # has_many :bookmarked_containers, through: :bookmarks, :source => :container
  has_many :bookmarked_containers, through: :bookmarks, :source => :container
  has_many :accesses
  has_many :bookmarks
  has_many :devices
  has_many :roles
  has_many :payments

  #############################################################
  #### Callbacks setup
  #############################################################

  after_initialize :define_default_values
  after_create     :send_welcome_mail
  after_create     :send_confirmation_mail
  after_create     :subscribe_email
  after_update     :update_user_data

  #############################################################
  #### Validations
  #############################################################

  validates :email, uniqueness: true, format: { with: /\A[^@\s]+@([^@.\s]+\.)*[^@.\s]+\z/ }
  validates :confirmation, allow_nil: true, inclusion: { in: [true, false] }
  validates :credits, presence: true, length: { in: 0..1000 }

  #############################################################
  #### Scopes
  #############################################################

  scope(:admins, lambda do
    joins('INNER JOIN roles ON roles.user_id = users.id')
      .where('roles.name = ?', Role::ROLE_ADMIN)
  end)

  #############################################################
  #### API attributes
  #############################################################

  def api_attributes(layers)
    h = {
      id: id,
      email: email,
      full_name: full_name,
      avatar_url: avatar_url,
      locale: locale,
      confirmation: confirmation,
      confirmation_required: confirmation_required,
    }
    if layers.include? :private
      h[:credits] = credits
    end

    h
  end

  #############################################################
  #### Callbacks
  #############################################################

  def define_default_values
    if self.new_record?
      self.confirmation ||= false
      self.credits = DEFAULT_CREDITS if credits == 0.0
    end
  end

  def send_welcome_mail
    UserMailer.delay.welcome_email(self)
  end
  
  def send_confirmation_mail
    UserMailer.delay.confirmation_email(id)
  end
  
  def subscribe_email
    UserWorkers::SubscribeEmail.perform_async(id) unless Rails.env.test?
  end
  
  def confirmation_required
    !confirmation && Time.now > (created_at + EMAIL_CONFIRMATION_PERIOD)
  end
  
  def update_user_data
    return if connect_login.nil?
    if email_changed? && email != connect_login.partner_id
      connect_login.update!(partner_id: email)
    end
    if !current_password.nil? || !new_password.nil?
      raise "Current password doesn't exists" if current_password.nil?
      raise "New password doesn't exists" if new_password.nil?
      
      connect_login.change_password(current_password, new_password)
      self.current_password = nil
      self.new_password = nil
    end
  end
  
  #############################################################
  #### Helpers
  #############################################################

  def credits
    super.to_f rescue 0
  end

  def connect_login
    @connect_login ||= Connects::Login.find_by_user_id(id)
  end

  def is_owner? user
    id == user.id
  end

  def role?(role)
    roles.exists?(name: role)
  end
  
  #############################################################
  #### Email confirmation
  #############################################################
  
  def self.find_by_confirmation_token(token, opts={})
    opts[:confirm_email] ||= false
    
    begin
      hs = JWT.decode token, Settings.token_encoding.confirmation_key
      user = self.find(hs[0]["id"])
      
      return false if user.confirmation == true
      
      user.update!(confirmation: true) if opts[:confirm_email]
      return user
    rescue
      return false
    end
  end
  
  def confirmation_token
    expires = (90.days.from_now).to_i
    payload = { id: id, exp: expires }
    
    token = JWT.encode payload, Settings.token_encoding.confirmation_key, Settings.token_encoding.algorithm
    
    return token
  end
  
  #############################################################
  #### Administration
  #############################################################

  def self.create_admin(**args)
    args[:locale] ||= :en

    connect = Connects::Login.new(args.stringify_keys)
    connect.user = User.create(email: connect.email, full_name: connect.full_name, locale: connect.locale, confirmation: true)
    connect.save!

    Role.create user: connect.user, name: Role::ROLE_ADMIN

    connect.user
  end
end
