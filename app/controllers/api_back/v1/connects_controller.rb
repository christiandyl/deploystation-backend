module ApiBack
  module V1
    class ConnectsController < ApplicationController

      skip_before_filter :ensure_logged_in

      ##
      # Check connect exists
      # @resource /v1/connect/check
      # @action POST
      #
      # @optional [Hash] connect_login
      # @optional [String] connect_login.email User email
      # @optional [String] connect_login.password User password
      #
      # @optional [Hash] connect_facebook
      # @optional [String] connect_facebook.token Short lived token
      #
      # @response_field [Boolean] success
      # @response_field [Boolean] result Exists or not exists
      def check
        connect_name = Connect::SUPPORTED_CONNECTS.find { |c| !params["connect_#{c}"].nil? }
        raise "Connect doesn't exists" if connect_name.nil?
        
        opts = params.require("connect_#{connect_name}")
        connect = Connect::class_for(connect_name).new(opts)
        
        render success_response connect.user_exists?
      end

      def request_token
        connect_name = Connect::SUPPORTED_CONNECTS.find { |c| !params["connect_#{c}"].nil? }
        raise "Connect doesn't exists" if connect_name.nil?

        connect = Connect.class_for(connect_name)
        token   = connect.get_token rescue nil

        render success_response token

      end

    end
  end
end
