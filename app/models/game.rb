class Game < ActiveRecord::Base
  include ApiExtension

  STATUS_ENABLED     = "enabled"
  STATUS_DISABLED    = "disabled"
  STATUS_COMING_SOON = "coming_soon"

  ASSETS_FOLDER_NAME = "games"

  default_scope { order(:order)}

  has_many :plans
  
  validates :name, :presence => true, :length => { in: 2..50 }

  def api_attributes(_layers)
    h = {
      id: id,
      name: name,
      sname: sname,
      images: images,
      status: status,
      plans_list: plans.map { |p| p.to_api },
      features_list: features_list
    }

    h
  end
  
  def images
    root = Asset.image_path ASSETS_FOLDER_NAME + "/" + sname + "/"
    {
      :wide => root + "wide.jpg",
      :icon => root + "icon.jpg"
    }
  end
  
  def features_list
    begin
      data = JSON.parse(features)
    rescue
      data = []
    end
    
    return data
  end
  
  def random_name
    name = case sname
    when "minecraft"
      rwords = ["Craft", "Mine", "Crafter", "Block", "World", "My", "Super", "Mini"]
      rwords.sample + rwords.sample + rand(100).to_s
    when "minecraft_pe"
      rwords = ["Craft", "Mine", "Crafter", "Block", "World", "My", "Super", "Mini", "Pocket", "PE", "My"]
      rwords.sample + rwords.sample + rand(100).to_s
    when "counter_strike_go"
      rwords = ["Cs", "Go", "Counter", "Strike"]
      rwords.sample + rwords.sample + rand(100).to_s
    else
      rwords = ["Game", "Server", "My", "Super", "Cool"]
      rwords.sample + rwords.sample + rand(100).to_s
    end
    
    return name
  end

end
