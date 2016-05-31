source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'rails-api', '0.4.0'
gem 'pg'

# A lightweight Ruby client for the Docker Remote API
gem 'docker-api', '1.22.4'
# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server
gem 'puma'
# A Ruby implementation of JSON Web Token.
gem 'jwt', '1.5.1'
# Koala is a lightweight, flexible Ruby SDK for Facebook
gem 'koala', '2.2.0'
# Simple, efficient background processing for Ruby
gem 'sidekiq', '4.1.2'
# Additional sidekiq middleware
# gem 'sidekiq-middleware', '0.3.0'
gem 'sidekiq-unique-jobs', '4.0.17'
# The official AWS SDK for Ruby
gem 'aws-sdk'
# Exception notification for Rails apps
gem 'airbrake', '4.3.3'
# Makes http fun! Also, makes consuming restful web services dead easy.
gem 'httparty', '0.13.7'
# will_paginate provides a simple API for performing paginated queries with Active Record
gem 'will_paginate', '~> 3.1.0'
# pusher
gem 'pusher'
# net ssh
gem 'net-ssh'
# Rack cors
gem 'rack-cors', :require => 'rack/cors'
# Sendgrid for mailing
gem 'sendgrid'
# Minimagick
gem 'mini_magick'
# Apple Push Notification Service client
gem 'apns'
# Minecraft query
gem 'minecraft-query'
# Payment system
gem 'braintree'
# Gibbon is an API wrapper for MailChimp's AP
gem 'gibbon'
# A Ruby API library for the Mandrill email as a service platform
gem 'mandrill-api'
# A slim ruby wrapper for posting to slack webhooks
gem 'slack-notifier'
# A multi-language library for querying the Steam Community, Source, GoldSrc servers and Steam master servers
gem 'steam-condenser'
# Map Redis types directly to Ruby objects
gem 'redis-objects'
# A fast JSON parser and Object marshaller as a Ruby gem
gem 'oj'
# Dynamoid is an ORM for Amazon's DynamoDB
gem 'dynamoid', '~> 1.1.0'
# Provides object geocoding
gem 'geocoder', '~> 1.3.4'

group :development, :staging do
  gem 'spring'
  
  gem 'redcarpet'
  gem 'yard'
  gem 'yard-rest'
  
  gem 'daemons', :require => false
  gem 'clockwork', :require => false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'capybara-screenshot'

  # Strategies for cleaning databases. Can be used to ensure a clean state for testing.
  gem 'database_cleaner'
  # Faker is used to easily generate fake data: names, addresses, phone numbers...
  gem 'faker'
  # Poltergeist is a driver for Capybara that allows you to run your tests on a headless WebKit browser
  gem 'poltergeist'
  # Byebug is a Ruby 2 debugger
  gem 'byebug'
  gem 'pusher-fake'
end

group :development, :test, :staging do
  gem 'awesome_print'
end
