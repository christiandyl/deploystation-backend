class ApplicationController < ActionController::API
  include AbstractController::Translation

  before_filter :check_auth_token, :check_app_key

  rescue_from Exception, :with => :render_error
  rescue_from StandardError, :with => :render_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from ActionController::RoutingError, :with => :render_not_found
  rescue_from PermissionDenied, :with => :render_permission_denied

  # Routes handlers

  def root
    render json: {}
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
    @current_user || render_unauthorized
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
    json[:result] = d if d
    { json: json, status: 200 }
  end
  
  def success_response_with_pagination d = nil
    d_api = d.map { |c| c.to_api(:public) }
    {
      :status => 200,
      :json   => {
        :success       => true,
        :result        => d_api,
        :current_page  => d.current_page,
        :is_last_page  => d.total_pages == d.current_page
      }
    }
  end

  # Render helpers

  def render_error(e)
    Rails.logger.error "Exception caught caused return 500 : #{e.message}"
    Rails.logger.debug e.backtrace.join("\n")
    
    render json: {success: false, error: [e.message]}, status: 500
  end

  def render_permission_denied e
    render json: {success: false, error: [e.message]}, status: 550
  end

  def render_not_found(e = nil)
    render json: {success: false, error: [e.message]}, status: 404
  end
  
  # Pagination helper
  
  def pagination_params
    { :page => params[:page] || 1, :per_page => params[:per_page] || nil }
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
