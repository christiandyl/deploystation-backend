class ContainerStatGamingTime
  include Dynamoid::Document
  
  field :container_id, :integer
  field :total_gaming_time, :integer, { default: 0 }
  field :segment_gaming_time, :integer, { default: 0 }
  field :created_at, :datetime, { default: -> { Time.now } }
end