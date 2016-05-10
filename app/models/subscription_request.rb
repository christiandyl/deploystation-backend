class SubscriptionRequest < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :container, :class_name => "ApiDeploy::Container"
  belongs_to :plan
  
  after_create :slack_ping
  
  def slack_ping
    ApiDeploy::Helper::slack_ping("User #{user.full_name} has send request for plan change for container - #{container.id}")
  end
  
end
