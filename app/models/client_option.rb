class ClientOption < ActiveRecord::Base
  include ApiExtension
  include DynamicValue

  self.primary_keys = :key, :user_id
  PERMIT = [:vtype, :key, :value]

  belongs_to :user

  validates :platform, inclusion: { in: %w(web ios) }
end
