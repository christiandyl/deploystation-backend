class ApplicationController < ActionController::Base
  # include BackOffice if Settings.backoffice.enabled

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
end
