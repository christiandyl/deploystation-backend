class User < ActiveRecord::Base
  include ApiConverter

  attr_accessor :current_password, :new_password

  attr_api [:id, :email, :full_name, :avatar_url, :locale, :confirmation, :confirmation_required]

  AWS_FOLDER = "users/:user_id"
  AVATAR_UPLOAD_TYPES = [:direct_upload, :url]

  EMAIL_CONFIRMATION_PERIOD = 1.day

  has_many :connects
  has_many :containers, :class_name => "ApiDeploy::Container"
  has_many :shared_containers, through: :accesses, :source => :container
  # has_many :bookmarked_containers, through: :bookmarks, :source => :container
  has_many :bookmarked_containers, through: :bookmarks, :source => :container
  has_many :accesses
  has_many :bookmarks
  has_many :devices

  after_create   :send_welcome_mail
  after_create   :define_s3_bucket
  after_create   :subscribe_email
  after_update   :on_after_update
  before_destroy :on_before_destroy
  
  validates :email, uniqueness: true, format: { with: /\A[^@\s]+@([^@.\s]+\.)*[^@.\s]+\z/ }
  validates :confirmation, inclusion: { in: [true, false] }

  def after_initialize 
   self.confirmation ||= false
  end

  def send_welcome_mail
    UserMailer.delay.welcome_email(self)
  end
  
  def send_confirmation_mail
    UserMailer.delay.confirmation_email(id)
  end
  
  def define_s3_bucket
    self.s3_region = get_s3_region
    self.s3_bucket = get_s3_bucket
    self.save!
  end
  
  def subscribe_email
    ApiBack::UserSubscribeEmail.perform_async(id) unless Rails.env.test?
  end
  
  def avatar_url
    return nil unless has_avatar?
    return s3_root_url + "avatar.jpg"
  end
  
  def confirmation_required
    !confirmation && Time.now > (created_at + EMAIL_CONFIRMATION_PERIOD)
  end
  
  def upload_avatar source, type, now = false    
    unless now
      ApiBack::UserUploadAvatarWorker.perform_async(id, source, type)
      return true
    end
    type = type.to_sym
    
    if type == AVATAR_UPLOAD_TYPES[0] # direct_upload
      file_path = source["tmp_file_path"] or raise ArgumentError.new("Tmp file path is absent")
    elsif type == AVATAR_UPLOAD_TYPES[1] # url
      url = source["url"] or raise ArgumentError.new("Url is absent")
      file_path = Settings.general.tmp_path.join("uploaded_files", "avatar_#{SecureRandom.uuid}")
      open(file_path, 'wb') { |f| f << open(url).read }
    else
      raise ArgumentError.new("Type #{type} doesn't exists")
    end

    raise ArgumentError.new("Tmp file doesn't exists") unless File.exists?(file_path)

    image = MiniMagick::Image.open(file_path)
    image.resize "200x200"
    image.format "jpg"
    image.write file_path
    
    obj = s3_obj("avatar.jpg")
    obj.upload_file(file_path, :acl => 'public-read')

    self.has_avatar = true
    save!
    
    File.delete(file_path)
    
    return true
  end
  
  def destroy_avatar now = false
    unless now          
      ApiBack::UserDestroyAvatarWorker.perform_async(id)
      return true
    end
    
    obj = s3_obj("avatar.jpg")
    # obj.delete
    
    self.has_avatar = false
    save!
    
    return true
  end
  
  def is_owner? user
    id == user.id
  end
  
  def on_before_destroy
    s3 = Aws::S3::Resource.new region: get_s3_region
    bucket = s3.bucket(get_s3_bucket)
    path = AWS_FOLDER.gsub(":user_id", id.to_s)

    bucket.objects.delete("#{id.to_s}/")
  end
  
  def on_after_update
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
  
  def connect_login
    @connect_login ||= ConnectLogin.find_by_user_id(id)
  end
  
  # Email confirmation
  
  def self.find_by_confirmation_token token, opts={}
    opts[:confirm_email] ||= false
    
    begin
      hs = JWT.decode token, Settings.token_encoding.confirmation_key
      user = self.find(hs[0]["id"])
      
      if user.confirmation == true
        return false
      end
      
      if opts[:confirm_email]
        user.update! confirmation: true
      end
      
      return user
    rescue
      return false
    end
  end
  
  def confirmation_token
    expires = (90.days.from_now).to_i
    
    payload = {
      :id => id,
      :exp => expires
    }
    
    token = JWT.encode payload, Settings.token_encoding.confirmation_key, Settings.token_encoding.algorithm
    
    return token
  end
  
  # Referral
  
  def find_by_referral_token token, opts={}
    opts[:give_reward] ||= false
    
    begin
      hs = JWT.decode token, Settings.token_encoding.referral_key
      user = User.find(hs[0]["id"])
      if opts[:give_reward]
        reward = hs[0]["reward"] || {}
        status = user.give_reward(reward)

        if status == true
          Helper::slack_ping("#{full_name} was invited by #{User.find(user.id).full_name}") rescue nil
          Reward.create!(inviter_id: user.id, invited_id: self.id, referral_data: reward )
        end
      end
      return user
    rescue
      return false
    end
  end
  
  def referral_token payload_extra = {}
    expires = (Time.now + 5.years).to_i
    
    payload = {
      :id => id,
      :reward => {},
      :exp => expires
    }
    payload_extra.each { |k,v| payload[k] = v }
    
    token = JWT.encode payload, Settings.token_encoding.referral_key, Settings.token_encoding.algorithm
    
    return token
  end
  
  def give_reward data = {}
    type = data["type"] or raise ArgumentError.new("Reward type doesn't exists")
    
    status = case type
      when "time"
        cid = data["cid"] or raise ArgumentError.new("Container id doesn't exists for this reward")
        container = ApiDeploy::Container.find(cid) rescue ArgumentError.new("Container id #{cid.to_s} doesn't exists for this reward")
        
        time_now = Time.now.to_time
        active_until = container.active_until.to_time
        time = active_until > time_now ? active_until : time_now
        
        active_until = time + container.class::REWARD_HOURS.hours
        container.update(active_until: active_until)
        
        true
      else
        raise ArgumentError.new("Reward type #{type} is incorrect")
    end
    
    return status
  end
  
  # Additional
  
  private
  
  def s3_root_url
    path = AWS_FOLDER.gsub(":user_id", id.to_s) + "/"
    return "https://s3-#{get_s3_region}.amazonaws.com/#{get_s3_bucket}/" + path
  end
  
  def get_s3_region
    s3_region || Settings.aws.s3.region
  end
  
  def get_s3_bucket
    s3_bucket || Settings.aws.s3.bucket
  end
  
  def s3_obj file_path
    region = get_s3_region
    bucket = get_s3_bucket
    
    s3 = Aws::S3::Resource.new region: region
    bucket = s3.bucket(bucket)
    
    path = AWS_FOLDER.gsub(":user_id", id.to_s) + "/" + file_path.to_s
    
    obj = bucket.object(path)
    
    return obj
  end

end