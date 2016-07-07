class SubscriptionRequest < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :container
  belongs_to :plan
  
  after_create :slack_ping
  
  def slack_ping
    Backend::Helper::slack_ping("User #{user.full_name} has send request for plan change for container - #{container.id}")
  end
  
end
