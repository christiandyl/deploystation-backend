if Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end

Sidekiq.configure_server do |config|
  unless Settings.redis.password.blank?
    config.redis = { url: "redis://:#{Settings.redis.password}@#{Settings.redis.host}:#{Settings.redis.port}/sidekiq" }
  else
    config.redis = { url: "redis://#{Settings.redis.host}:#{Settings.redis.port}/sidekiq" }
  end
end

Sidekiq.configure_client do |config|
  unless Settings.redis.password.blank?
    config.redis = { url: "redis://:#{Settings.redis.password}@#{Settings.redis.host}:#{Settings.redis.port}/sidekiq" }
  else
    config.redis = { url: "redis://#{Settings.redis.host}:#{Settings.redis.port}/sidekiq" }
  end
end