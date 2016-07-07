module Api
  module ErrorsHandling
    extend ActiveSupport::Concern

    included do
      rescue_from Exception, :with => :render_internal_server_error
      rescue_from StandardError, :with => :render_internal_server_error
      rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
      rescue_from ActionController::RoutingError, :with => :render_not_found
      rescue_from PermissionDenied, :with => :render_permission_denied
    end

    def render_record_invalid(error)
      render response_unprocessable_entity error.record.errors.messages
    end

    def render_not_found(error)
      render response_not_found error.message
    end

    def render_internal_server_error(error)
      description = 'Exception caught caused return 500'
      log_error(error, description: description, notify: true)
      render response_internal_server_error error.message
    end

    def render_permission_denied(error)
      render response_unauthorized error.message
    end

    private

    def log_error(error, **opts)
      description = opts[:description]
      notify = opts[:notify] || false

      Backend::Logger.error("#{description}: #{error.message}")
      Backend::Logger.debug(error.backtrace.join("\n"))

      notify_error(error) if notify
    end

    def notify_error(error)
      session = current_user.nil? ? {} : { id: current_user.id }
      Airbrake.notify_or_ignore(
        error,
        :parameters => params,
        :cgi_data   => ENV.to_hash,
        :session    => session
      )
      
      Rails.logger.error "Exception caught caused return 500 : #{error.message}"
      Rails.logger.debug error.backtrace.join("\n")
    end
  end
end
