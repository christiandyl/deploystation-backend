module UserStorage
  extend ActiveSupport::Concern

  included do
    AWS_FOLDER = "users/:user_id"
    AVATAR_UPLOAD_TYPES = [:direct_upload, :url]

    after_create :define_s3_bucket
    before_destroy :destroy_storage
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
      UserWorkers::UploadAvatarWorker.perform_async(id, source, type)
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
      UserWorkers::DestroyAvatarWorker.perform_async(id)
      return true
    end
    
    obj = s3_obj("avatar.jpg")
    # obj.delete
    
    self.has_avatar = false
    save!
    
    return true
  end

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

  def destroy_storage
    s3 = Aws::S3::Resource.new region: get_s3_region
    bucket = s3.bucket(get_s3_bucket)
    path = AWS_FOLDER.gsub(":user_id", id.to_s)

    bucket.objects.delete("#{id.to_s}/")
  end
end
