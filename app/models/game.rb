class Game < ActiveRecord::Base
  include ApiConverter

  attr_api [:id, :name, :plans_list]

  has_many :plans
  
  validates :name, :presence => true, :length => { in: 2..50 }
  
  def plans_list
    plans.map { |p| p.to_api(:public) }
  end

end
