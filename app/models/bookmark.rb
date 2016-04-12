class Bookmark < ActiveRecord::Base
  include ApiConverter

  PERMIT = [:email]

  attr_api [:user_data]

  # Relations
  belongs_to :container, :class_name => "ApiDeploy::Container"
  belongs_to :user
  
  # Validations
  validates :container_id, :presence => true, uniqueness: { scope: :user_id }
  validates :user_id, :presence => true
  
  def user_data
    user.to_api(:public)
  end

end