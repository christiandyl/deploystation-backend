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
      # @optional [String] connect_facebook.token Short lived token
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [String] result.id User id
      # @response_field [String] result.auth_token User access token
      # @response_field [Datetime] result.expires Token Expires time
      # @response_field [Hash] result.user User data
      def create
        connect = user = nil

        Connect::SUPPORTED_CONNECTS.each do |c|
          data = params["connect_#{c}"]
          if data
            connect = Connect::class_for(c).authenticate(data)
            user = connect.user if connect
            raise "Invalid credentials" if user.nil?
            break
          end
        end

        token = Token.new user
        token.generate_token

        render success_response(auth_token: token.token, expires: token.expires, user: user.to_api(:public))
      end

    end
  end
end