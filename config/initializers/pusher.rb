Pusher.host   = Settings.pusher.host
Pusher.port   = Settings.pusher.port
Pusher.app_id = Settings.pusher.app_id
Pusher.key    = Settings.pusher.key
Pusher.secret = Settings.pusher.secret

if Rails.env.test?
  require "pusher-fake/support/base"
end