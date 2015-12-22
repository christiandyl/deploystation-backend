class User < ActiveRecord::Base
  include ApiConverter

  attr_accessor :password

  attr_api [:id, :email, :full_name, :avatar_url]

  AWS_FOLDER = "users/:user_id"
  AVATAR_UPLOAD_TYPES = [:direct_upload, :url]

  has_many :connects
  has_many :containers, :class_name => "ApiDeploy::Container"
  has_many :shared_containers, through: :accesses, :source => :container
  has_many :accesses

  after_create   :send_welcome_mail
  after_create   :define_s3_bucket
  after_update   :on_after_update
  before_destroy :on_before_destroy

  validates :email, :presence => true, uniqueness: true

  def send_welcome_mail
    UserMailer.delay.welcome_email(self)
  end
  
  def define_s3_bucket
    self.s3_region = get_s3_region
    self.s3_bucket = get_s3_bucket
    self.save!
  end
  
  def avatar_url
    return nil unless has_avatar?
    return s3_root_url + "avatar.jpg"
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
    unless password.nil?
      connect_login.update(partner_auth_data: password)
      self.password = nil
    end
  end
  
  def connect_login
    @connect_login ||= ConnectLogin.find_by_user_id(id)
  end
  
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