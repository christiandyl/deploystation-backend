module Api
  class ApiController < ActionController::API
    include AbstractController::Translation
    include ErrorsHandling
    include ResponseHandling

    before_filter :check_auth_token, :check_app_key, :set_locale
    before_filter :ensure_logged_in, :except => [:root, :v1_client_settings]

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
    
    def set_locale
      locale = params[:locale] || request.headers['Accept-Language'] || I18n.default_locale
      
      begin
        I18n.locale = locale.split("-").first rescue I18n.default_locale
      rescue
        I18n.locale = I18n.default_locale
      end
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

    def pagination_params(**opts)
      {
        page: params[:page] || 1,
        per_page: params[:per_page] || opts[:per_page] || WillPaginate.per_page
      }
    end

    def user_agent
      @user_agent ||= UserAgent.parse(request.user_agent)
    end

    def client_platform
      case user_agent.platform
        when 'iPad' then :ios
        when 'iPhone' then :ios
        when 'Android' then :android
        else :web
      end
    end
  end
end
