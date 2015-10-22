class ApplicationController < ActionController::API
  
  before_filter :check_auth_token, :check_connection

  rescue_from Exception, :with => :render_error
  rescue_from StandardError, :with => :render_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  rescue_from ActionController::RoutingError, :with => :render_not_found
  rescue_from PermissionDenied, :with => :render_permission_denied

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
    @token = Token.new provided_token
    @token.decode_token unless provided_token.nil?
    
    raise PermissionDenied unless @token.valid?
  end

  def check_connection
    raise PermissionDenied unless Settings.general.core_ip == request.remote_ip
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

end
