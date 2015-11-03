module ApiBack
  module V1
    class UsersController < ApplicationController

      skip_before_filter :ensure_logged_in

      ##
      # Creating user profile (Sign up)
      # @resource /v1/users
      # @action POST
      #
      # @optional [String] fullname User full name
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
      def create
        connect = user = nil

        Connect::SUPPORTED_CONNECTS.each do |c|
          data = params["connect_#{c}"]
          if data
            connect = Connect::class_for(c).new(data)
            user = connect.user
            break
          end
        end

        raise "Connect is absent" if connect.nil?

        if user.nil?
          user = connect.user = User.create email: connect.get_email
          connect.save!
        end

        token = Token.new user
        token.generate_token
        
        render success_response(auth_token: token.token, expires: token.expires)
      end

    end
  end
end