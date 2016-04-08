class Notification < ActiveRecord::Base
  
  after_save :push
  belongs_to :user

  # Pushes notification to each of the recipient's devices
  def push
    notifications = self.user.devices.map{ |device|
      APNS::Notification.new(device.push_token,
        alert: self.alert,
        other: { some_extra_data: "can be sent too" }
      )
    }
    unless notifications.empty?
      APNS.send_notifications(notifications)
    end
  end
  
end