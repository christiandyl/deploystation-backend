class User < ActiveRecord::Base
  include ApiConverter

  attr_api [:id, :email, :full_name, :avatar_url]

  AWS_FOLDER = "users/:user_id"
  AVATAR_UPLOAD_TYPES = [:direct_upload, :url]

  has_many :connects
  has_many :containers, :class_name => "ApiDeploy::Container"
  has_many :shared_containers, through: :accesses, :source => :container
  has_many :accesses

  after_create :send_welcome_mail
  before_destroy :on_before_destroy

  validates :email, :presence => true, uniqueness: true

  def send_welcome_mail
    UserMailer.delay.welcome_email(self)
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
      file_path = Rails.root.join("tmp", "uploaded_files", "avatar_#{SecureRandom.uuid}")
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
    
    self.avatar_url = obj.public_url
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
    obj.delete
    
    self.avatar_url = nil
    save!
    
    return true
  end
  
  def is_owner? user
    id == user.id
  end
  
  def on_before_destroy
    destroy_avatar(true)
  end
  
  private
  
  def s3_obj file_path
    s3 = Aws::S3::Resource.new region: Settings.aws.s3.region
    bucket = s3.bucket(Settings.aws.s3.bucket)
    
    path = AWS_FOLDER.gsub(":user_id", id.to_s) + "/" + file_path.to_s
    
    obj = bucket.object(path)
    
    return obj
  end

end