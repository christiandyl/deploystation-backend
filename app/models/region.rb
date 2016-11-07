class Region < ActiveRecord::Base
  include ApiExtension

  STATUS_ENABLED = 'enabled'
  STATUS_DISABLED = 'disabled'

  geocoded_by :location

  default_scope { where(status: 'enabled') }

  has_many :hosts

  after_validation :geocode
end
