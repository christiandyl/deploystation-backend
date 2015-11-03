class Game < ActiveRecord::Base
  include ApiConverter

  attr_api [:id, :name]

  has_many :plans
  
  validates :name, :presence => true, :length => { in: 2..50 }

end
