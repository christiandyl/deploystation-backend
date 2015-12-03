Airbrake.configure do |config|
  config.api_key = Settings.airbrake.api_key
  config.host    = Settings.airbrake.host
  config.port    = 80
  config.secure  = config.port == 443
end