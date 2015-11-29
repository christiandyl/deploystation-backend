class Plan < ActiveRecord::Base
  include ApiConverter

  attr_api [:id, :name, :max_players, :price, :host_id]

  belongs_to :game
  belongs_to :host
  
  validates :name, :presence => true, :length => { in: 2..50 }
  validates :max_players, :presence => true, :numericality => { only_integer: true, :greater_than_or_equal_to => 1 }
  validates :ram, :presence => true, :numericality => { only_integer: true, :greater_than_or_equal_to => 1 }
  validates :storage, :presence => true, :numericality => { only_integer: true, :greater_than_or_equal_to => 1 }
  validates :storage_type, :presence => true, :inclusion => { in: %w(hdd ssd) }

end
