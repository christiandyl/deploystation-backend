require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Bundler.require(:backoffice) if ENV['BACKOFFICE_ENABLED'] == 'true'

module Node
  class Application < Rails::Application
    if ENV['BACKOFFICE_ENABLED'] == 'true'
      config.middleware.use ActionDispatch::Flash
      config.middleware.use Rack::MethodOverride
      config.middleware.use ActionDispatch::Cookies
    else
      config.eager_load_paths.delete_at(0)
    end

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
    
    # Rack cors
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options, :delete, :put, :patch]
      end
    end
    
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')

      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    
    # custom logger formatter
    class LoggerFormatter
      USE_HUMOROUS_SEVERITIES = true
  
      def call(severity, time, progname, message)
        direct_prg_line = stack_line = buffer = buffer2 = ""

        message.split("\n").each do |line|
          next if line == ""
          line.gsub!(/^Started ([A-Z]+) /, "\033[0;1;34m\\0\033[0m")
          line = "%s - %s - #%d - %s%s%s\n" % [
            Time.now.strftime("%Y-%m-%d %H:%M:%S.%L"),
            severity,
            $$,
            direct_prg_line,
            line,
            stack_line
          ]

          buffer += line
        end

        return buffer
      end
    end
    config.log_formatter = LoggerFormatter.new
  end
end
