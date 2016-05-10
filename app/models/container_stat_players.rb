class ContainerStatPlayers
  include Dynamoid::Document
  
  field :container_id, :integer
  field :players_online, :integer, { default: 0 }
  field :created_at, :datetime, { default: -> { Time.now } }
end