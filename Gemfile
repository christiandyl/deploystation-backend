source 'https://rubygems.org'

gem 'rails', '4.2.4'
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
gem 'sidekiq', '3.5.1'
# The official AWS SDK for Ruby
gem 'aws-sdk', '2.1.31'
# Exception notification for Rails apps
gem 'airbrake', '4.3.3'
# Makes http fun! Also, makes consuming restful web services dead easy.
gem 'httparty', '0.13.7'
# will_paginate provides a simple API for performing paginated queries with Active Record
gem 'will_paginate', '~> 3.0.7'
# pusher
gem 'pusher'
# net ssh
gem 'net-ssh'
# Rack cors
gem 'rack-cors', :require => 'rack/cors'
# Sendgrid for mailing
gem 'sendgrid'

group :development, :staging do
  gem 'spring', '1.3.6'
  
  gem 'redcarpet'
  gem 'yard'
  gem 'yard-rest'
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

group :development, :test do
  gem 'awesome_print'
end
