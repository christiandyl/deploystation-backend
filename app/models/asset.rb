class Asset

  class << self
  
    def image_path path
      Settings.general.assets_host + "images/" + path
    end
  
  end

end