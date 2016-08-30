class Plan < ActiveRecord::Base
  include ApiExtension

  belongs_to :game
  belongs_to :host
  
  validates :name, :presence => true, :length => { in: 2..50 }
  validates :max_players, :presence => true, :numericality => { only_integer: true, :greater_than_or_equal_to => 1 }
  validates :ram, :presence => true, :numericality => { only_integer: true, :greater_than_or_equal_to => 1 }
  validates :storage, :presence => true, :numericality => { only_integer: true, :greater_than_or_equal_to => 1 }
  validates :storage_type, :presence => true, :inclusion => { in: %w(hdd ssd) }
  validates :price_per_hour, presence: true, numericality: true

  def api_attributes(_layers)
    h = {
      id: id,
      name: name,
      max_players: max_players,
      price: price,
      price_per_hour: price_per_hour,
      host_id: host_id
    }

    if h[:price_per_hour] < 0.005
      h[:price_per_hour] = 0.005
    end

    h
  end

end
