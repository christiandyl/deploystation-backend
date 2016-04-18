module ApiBack
  module V1
    class UsersController < ApplicationController

      skip_before_filter :ensure_logged_in, :only => [:create, :request_password_recovery, :confirmation]
      before_filter :get_user, :except => [:create, :me, :request_password_recovery, :confirmation]
      before_filter :check_permissions, :except => [:create, :me, :request_password_recovery, :confirmation]

      ##
      # Creating user profile (Sign up)
      # @resource /v1/users
      # @action POST
      #
      # @optional [Hash] connect_login
      # @optional [String] connect_login.email User email
      # @optional [String] connect_login.password User password
      # @optional [String] connect_login.full_name User full name
      # @optional [String] connect_login.locale User locale (by default is "en")
      #
      # @optional [Hash] connect_facebook
      # @optional [String] connect_facebook.code Short lived token
      # @optional [String] connect_facebook.redirect_uri OAUTH redirect uri
      # @optional [String] connect_facebook.locale User locale (by default is "en")
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
          connect.user = User.create(email: connect.email, full_name: connect.full_name, locale: connect.locale)
          avatar_url = connect.avatar_url
          unless avatar_url.nil?
            connect.user.upload_avatar({ "url" => avatar_url }, :url)
          end
          
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

        unless params["referral_token"].nil?
          rtoken = params["referral_token"]
          inviter = connect.user.find_by_referral_token rtoken, give_reward: true
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
      # Updating user info
      # @resource /v1/users
      # @action PUT
      #
      # @required [Hash] user
      # @optional [String] user.email User email
      # @optional [String] user.full_name User full_name
      # @optional [String] user.current_password Current user password
      # @optional [String] user.new_password New user password
      #
      # @response_field [Boolean] success
      def update
        opts = require_param :user, :permit => [:email, :full_name, :current_password, :new_password]
        @user.update(opts.to_hash)
        
        render success_response
      end
      
      ##
      # Uploading user avatar
      # @resource /v1/users/:user_id/avatar
      # @action PUT
      #
      # @required [Hash] avatar
      # @optional [String] avatar.type Avatar type
      # @required [String] avatar.source Avatar source
      #
      # @response_field [Boolean] success
      def avatar_update
        opts = require_param :avatar, :permit => [:source, :type]
        opts[:source] = params[:file] if params[:file]
        
        source = opts[:source] or raise ArgumentError.new("Source doesn't exists")
        type   = opts[:type] or raise ArgumentError.new("Type doesn't exists")
        type   = type.to_sym
        
        raise ArgumentError.new("#{source} is unknown type") unless User::AVATAR_UPLOAD_TYPES.include?(type)
        
        if type == User::AVATAR_UPLOAD_TYPES[0]
          raise ArgumentError, 'source "file" is incorrect' unless source.is_a? ActionDispatch::Http::UploadedFile

          file_path = Settings.general.tmp_path.join("uploaded_files", "avatar_#{SecureRandom.uuid}")
          File.open(file_path, "wb") { |f| f.write(source.tempfile.read) }
          
          source = { tmp_file_path: file_path }
        end
        
        @user.upload_avatar(source, type)
        
        render success_response
      end
      
      ##
      # Deleting user avatar
      # @resource /v1/users/:user_id/avatar
      # @action DELETE
      #
      # @response_field [Boolean] success
      def avatar_destroy
        @user.destroy_avatar
        
        render success_response
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
      
      ##
      # Confirm account
      # @resource /v1/user/confirmation
      # @action POST
      #
      # @required [Hash] confirmation
      # @required [String] confirmation.token
      #
      # @response_field [Boolean] success
      def confirmation
        opts = require_param :confirmation, :permit => [:token]
        
        # Confirmation token
        ctoken = opts[:token] or raise ArgumentError.new("There are no confirmation token")
        
        user = User.find_by_confirmation_token ctoken, confirm_email: true
        
        unless user
          raise "User confirmation failed"
        end
        
        # Access token
        atoken = Token.new(user)
        atoken.generate_token
        
        opts = {
          :auth_token => atoken.token,
          :expires    => atoken.expires,
          :user       => user.to_api(:public)
        }

        render success_response opts
      end
      
      ##
      # Request email confirmation
      # @resource /v1/user/request_email_confirmation
      # @action POST
      #
      # @response_field [Boolean] success
      def request_email_confirmation
        @user.send_confirmation_mail
        
        render success_response
      end
      
      def get_user     
        id = params[:id] || params[:user_id] || current_user.id
        @user = User.find(id)
      end
      
      def check_permissions
        raise PermissionDenied unless @user.is_owner? current_user
      end

    end
  end
end