require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'formatters/logger_formatter'
if ENV['BACKOFFICE_ENABLED'] == 'true'
  require 'activeadmin'
  require 'activeadmin_addons'
  require 'activeadmin_hstore_editor'
  require 'sidekiq/web'
end

module Node
  class Application < Rails::Application
    if ENV['BACKOFFICE_ENABLED'] == 'true'
      config.middleware.use ActionDispatch::Flash
      config.middleware.use Rack::MethodOverride
      config.middleware.use ActionDispatch::Cookies
    else
      config.eager_load_paths.delete_at(0)
    end

    config.autoload_paths << Rails.root.join('config/routes')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Using rspec instead of default tests
    config.generators do |g|
      g.test_framework  :rspec, :fixture => false
      g.view_specs      false
      g.helper_specs    false
    end

    # Using smtp to deliver emails
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.perform_deliveries = true
    config.action_mailer.delivery_method = :smtp

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    config.log_formatter = Formatters::LoggerFormatter.new
  end
end
