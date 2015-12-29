class Game < ActiveRecord::Base
  include ApiConverter

  STATUS_ENABLED     = "enabled"
  STATUS_DISABLED    = "disabled"
  STATUS_COMING_SOON = "coming_soon"

  ASSETS_FOLDER_NAME = "games"

  attr_api [:id, :name, :images, :status, :plans_list]

  has_many :plans
  
  validates :name, :presence => true, :length => { in: 2..50 }
  
  def plans_list
    plans.map { |p| p.to_api(:public) }
  end
  
  def images
    root = Asset.image_path ASSETS_FOLDER_NAME + "/" + sname + "/"
    {
      :wide => root + "wide.jpg",
      :icon => root + "icon.jpg"
    }
  end

end
