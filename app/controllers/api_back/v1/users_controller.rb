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
      # @optional [String] connect_facebook.code Short lived token
      # @optional [String] connect_facebook.redirect_uri OAUTH redirect uri
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

        if connect.existing_connect.nil?
          connect.user = User.create(email: connect.email, full_name: connect.full_name)
          connect.save!
          unless connect.is_a?(ConnectLogin)
            new_password = SecureRandom.hex[0..8]
            login_data = { "email" => connect.email, "password" => Digest::SHA1.hexdigest(new_password) }
            connect_login = ConnectLogin.new(login_data).tap { |c| c.user_id = connect.user.id }
            connect_login.save
          end
        else
          raise "This user is already exists" if connect.is_a?(ConnectLogin)
          connect.user = User.find_by_email(connect.email)
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
      
      ##
      # Requests password recovery
      # @resource /v1/users/request_password_recovery
      # @action POST
      #
      # @required [Hash] password_recovery
      # @required [String] password_recovery.email
      #
      # @response_field [Boolean] success
      def request_password_recovery
        opts = require_param :password_recovery, :permit => [:email]
        raise "Email is absent" if opts["email"].blank?

        connect_login = ConnectLogin.find_by_partner_id(opts["email"]) or raise "Can't find connect_login with this email"
        user          = connect_login.user or raise "Can't find user"

        begin
          new_password = SecureRandom.hex[0..8]
          connect_login.partner_auth_data = Digest::SHA1.hexdigest(new_password)
          connect_login.save

          UserMailer.delay.password_recovery(user, new_password)
        rescue => message
          raise "Can't change user password : #{message.to_s}"
        end

        render success_response
      end

    end
  end
end