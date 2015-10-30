class Game < ActiveRecord::Base

  has_many :plans
  
  validates :name, :presence => true, :length => { in: 2..50 }

end
