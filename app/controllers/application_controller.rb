class ApplicationController < ActionController::API
  include AbstractController::Translation

  before_filter :check_auth_token, :check_app_key
  before_filter :ensure_logged_in, :except => [:root, :v1_client_settings]

  rescue_from Exception, :with => :render_internal_server_error
  rescue_from StandardError, :with => :render_internal_server_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from ActionController::RoutingError, :with => :render_not_found
  rescue_from PermissionDenied, :with => :render_permission_denied

  # Routes handlers

  ##
  # Root route for ping
  # @resource /
  # @action GET
  def root
    render json: {}
  end
  
  ##
  # Client settings
  # @resource /v1/client_settings
  # @action GET
  #
  # @required [String] key
  #
  # @response_field [Hash] result
  def v1_client_settings
    unless params[:key] == Settings.general.client_settings_key
      raise PermissionDenied
    end
    
    data = {
      :pusher => {
        :cluster => Settings.pusher.host,
        :key     => Settings.pusher.key
      },
      :facebook => {
        :app_id => Settings.connects.facebook.client_id
      }
    }
    
    render json: data
  end

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches /#{params[:unmatched_route]}")
  end

  private

  # Before filters

  def check_auth_token
    provided_token = params[:auth_token] || request.headers['X-Auth-Token'] || nil
    token = Token.new provided_token
    token.decode_token unless provided_token.nil?

    @current_user = token.find_user
  end

  def current_user
    @current_user || nil
  end

  def check_app_key
    @app_client = "Test APP"
  end

  def ensure_logged_in
    @current_user or raise PermissionDenied
  end

  # Response helpers

  def unsuccess_response
    { json: { success: false }, status: 500 }
  end

  def validation_error e
    { json: { success: false, error: e }, status: 422 }
  end

  def success_response d = nil
    json = { success: true }
    json[:result] = d unless d.nil?
    { json: json, status: 200 }
  end
  
  def success_response_with_pagination d = nil
    d_api = d.map { |c| c.to_api(:public) }
    {
      :status => 200,
      :json   => {
        :success => true,
        :result  => {
          :list         => d_api,
          :current_page => d.current_page,
          :is_last_page => (d.total_pages == d.current_page)
        }
      }
    }
  end

  # Render helpers

  # def render_error(e)
  #   session = current_user.nil? ? {} : { id: current_user.id }
  #   Airbrake.notify_or_ignore(
  #       e,
  #       :parameters => params,
  #       :cgi_data   => ENV.to_hash,
  #       :session    => session
  #   )
  #
  #   Rails.logger.error "Exception caught caused return 500 : #{e.message}"
  #   Rails.logger.debug e.backtrace.join("\n")
  #
  #   render json: {success: false, error: [e.message]}, status: 500
  # end

  # def render_permission_denied e
  #   render json: {success: false, error: [e.message]}, status: 401
  # end

  # def render_not_found(e = nil)
  #   render json: {success: false, error: [e.message]}, status: 404
  # end
  
  def render_args result, success, code
    return {
      :json   => Oj.dump({
        :success => success,
        :result  => result
      }),
      :status => code
    }
  end
  
  # Response helpers
  
  def response_ok result = nil
    render_args(result, true, 200)
  end
  
  def response_accepted result
    render_args(result, true, 202)
  end

  def response_created result
    render_args(result, true, 201)
  end
  
  def response_unprocessable_entity result
    render_args(result, false, 422)
  end
  
  def response_not_found result
    render_args(result, false, 404)
  end
  
  def response_unauthorized result
    render_args(result, false, 401)
  end
  
  def response_internal_server_error result
    render_args(result, false, 500)
  end
  
  def response_not_acceptable result
    render_args(result, false, 406)
  end
  
  def response_bad_request
    render_args(result, false, 400)
  end
  
  def response_ok_with_pagination d = nil
    result = {
      :list         => d.map { |c| c.to_api(:public) },
      :current_page => d.current_page,
      :is_last_page => (d.total_pages == d.current_page)
    }
    
    return response_ok(result)
  end

  # Render helpers

  def render_internal_server_error error
    session = current_user.nil? ? {} : { id: current_user.id }
    Airbrake.notify_or_ignore(
      error,
      :parameters => params,
      :cgi_data   => ENV.to_hash,
      :session    => session
    )
    
    Rails.logger.error "Exception caught caused return 500 : #{error.message}"
    Rails.logger.debug error.backtrace.join("\n")

    render response_internal_server_error error.message
  end

  def render_record_invalid error
    render response_unprocessable_entity error.record.errors.messages
  end

  def render_not_found error
    render response_not_found error.message
  end
  
  def render_permission_denied error
    render response_unauthorized error.message
  end
  
  # Pagination helper
  
  def pagination_params
    { :page => params[:page] || 1, :per_page => params[:per_page] || 15 }
  end
  
  # Generates json data for render
  # ==== Attributes
  # * +name+ - Param name (String)
  # * +opts+ - Additional opts (Hash)
  #
  # ==== Opts
  # * +:permit+ - permitted attributes, default nil (Array)
  def require_param name, opts=nil
    permit = nil

    if opts.is_a? Hash
      if opts[:permit]
        raise ArgumentError, 'Permit should be Array' unless opts[:permit].is_a? Array
        permit = opts[:permit].map { |p| p.to_s }
      end
    end

    attrs = params.require(name)
    attrs = JSON.parse(attrs) unless attrs.is_a? Hash

    return (permit ? attrs.slice(*permit) : attrs).with_indifferent_access
  end

end
