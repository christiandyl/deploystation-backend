module ApiBack
  module V1
    class ConnectsController < ApplicationController

      before_filter :get_user
      before_filter :check_permissions
      before_filter :get_connect, :only => [:destroy]

      ##
      # Getting user connects list
      # @resource /v1/users/:user_id/connects
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [String] result[].id Connect id
      # @response_field [String] result[].partner Connect partner
      # @response_field [String] result[].partner_id Connect partner id
      def index
        connects = @user.connects.map { |c| c.to_api(:public) }
        render success_response connects
      end
      
      ##
      # Adding connect to user
      # @resource /v1/users/:user_id/connects
      # @action POST
      #
      # @optional [Hash] connect_login
      # @optional [String] connect_login.email User email
      # @optional [String] connect_login.password User password
      # @optional [String] connect_login.fullname User full name
      #
      # @optional [Hash] connect_facebook
      # @optional [String] connect_facebook.code Short lived token
      # @optional [String] connect_facebook.redirect_uri OAUTH redirect uri
      #
      # @response_field [Boolean] success
      def create
        connect_name = Connect::SUPPORTED_CONNECTS.find { |c| !params["connect_#{c}"].nil? }
        raise "Connect doesn't exists" if connect_name.nil?
        raise "You can't create connect_login" if connect_name == "connect_login"
        
        opts = params.require("connect_#{connect_name}")

        connect = Connect::class_for(connect_name).new(opts)

        raise "Connect #{connect_name} already exists" unless connect.existing_connect.nil?
        
        connect.user_id = @user.id
        connect.save
        
        render success_response
      end
      
      ##
      # Removing connect from user
      # @resource /v1/users/:user_id/connects/:connect_id
      # @action DELETE
      #
      # @response_field [Boolean] success
      def destroy
        byebug
        raise "You can't destroy connect_login" if @connect.partner == "connect_login"
        @connect.destroy
        
        render success_response
      end

      private
      
      def get_user     
        id = params[:user_id]
        @user = User.find(id)
      end
      
      def check_permissions
        raise PermissionDenied unless @user.is_owner? current_user
      end
      
      def get_connect
        @connect = Connect.find_by id: params[:id], user_id: @user.id
      end

    end
  end
end
