module ApiBack
  module V1
    class SessionsController < ApplicationController

      skip_before_filter :ensure_logged_in
      
      ##
      # Creating user session
      # @resource /v1/session
      # @action POST
      #
      # @optional [Hash] connect_login
      # @optional [String] connect_login.email User email
      # @optional [String] connect_login.password User password
      #
      # @optional [Hash] connect_facebook
      # @optional [String] connect_facebook.code Short lived token
      # @optional [String] connect_facebook.redirect_uri OAUTH redirect uri
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [String] result.id User id
      # @response_field [String] result.auth_token User access token
      # @response_field [Datetime] result.expires Token Expires time
      # @response_field [Hash] result.user User data
      def create
        connect_name = Connect::SUPPORTED_CONNECTS.find { |c| !params["connect_#{c}"].nil? }
        raise "Connect doesn't exists" if connect_name.nil?
        
        opts = params.require("connect_#{connect_name}")

        connect = Connect::class_for(connect_name).authenticate(opts)
        user = connect.user rescue nil
        raise "Invalid credentials" if user.nil?

        token = Token.new user
        token.generate_token
        
        render response_ok(auth_token: token.token, expires: token.expires, user: user.to_api(:public))
      end

    end
  end
end