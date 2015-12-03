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
        connect_name = Connect::SUPPORTED_CONNECTS.find { |c| !params["connect_#{c}"].nil? }
        raise "Connect doesn't exists" if connect_name.nil?
        
        opts = params.require("connect_#{connect_name}")

        connect = Connect::class_for(connect_name).new(opts)

        if connect.user.nil?
          connect.user = User.create email: connect.email
          connect.save!
        end

        token = Token.new connect.user
        token.generate_token

        opts = {
          :auth_token => token.token,
          :expires    => token.expires,
          :user       => connect.user.to_api(:public)
        }
        
        render success_response opts
      end
      
      ##
      # Get current user data
      # @resource /v1/users/me
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [String] result.id User id
      # @response_field [String] result.email User email
      def me
        render success_response current_user.to_api(:public)
      end

    end
  end
end