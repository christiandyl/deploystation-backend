class ClientOption < ActiveRecord::Base
  include ApiExtension
  include DynamicValue

  PERMIT = [:vtype, :key, :value]

  belongs_to :user

  validates :platform, inclusion: { in: %w(web ios) }
end
