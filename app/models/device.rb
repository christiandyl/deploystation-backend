class Device < ActiveRecord::Base
  
  belongs_to :user
  
  validates :device_type, :presence => true
  validates :push_token, :presence => true
  
end
