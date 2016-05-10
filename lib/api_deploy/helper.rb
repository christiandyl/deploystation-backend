require 'socket'
require 'slack-notifier'

module ApiDeploy
  class Helper  
    class << self
      
      def slack_ping message, opts={}
        url = Settings.slack.webhooks.events
        
        return if url.blank? || !Rails.env.production?
        
        begin
          notifier = Slack::Notifier.new(url)
          notifier.ping message, opts
          
          return true
        rescue
          return false
        end
      end
      
    end
  end
end