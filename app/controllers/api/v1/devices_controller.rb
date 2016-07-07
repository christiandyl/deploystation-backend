module Api
  module V1
    class DevicesController < ApiController
      
      ##
      # Get braintree client token
      # @resource /v1/devices
      # @action POST
      #
      # @required [Hash] device
      # @required [String] device.device_type
      # @required [String] device.push_token
      #
      # @response_field [Boolean] success
      def create
        opts = params.require(:device)
        device_type = opts[:device_type] or raise ArgumentError.new("Device type doesn't exists")
        push_token  = opts[:push_token] or raise ArgumentError.new("Push token doesn't exists")
        
        device = Device.create user_id: current_user.id, device_type: device_type, push_token: push_token
        
        render response_ok
      end
      
      ##
      # Get braintree client token
      # @resource /v1/devices/:push_token
      # @action DELETE
      #
      # @response_field [Boolean] success
      def destroy
        device = Device.find_by_push_token(params[:push_token])
        device.delete
        
        render response_ok
      end
      
    end
  end
end