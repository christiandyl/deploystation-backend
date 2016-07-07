class Bookmark < ActiveRecord::Base
  include ApiExtension

  PERMIT = [:email]

  # Relations
  belongs_to :container
  belongs_to :user
  
  # Validations
  validates :container_id, :presence => true, uniqueness: { scope: :user_id }
  validates :user_id, :presence => true

  def api_attributes(_layers)
    h = {
      user_data: user.to_api
    }

    h
  end
end
