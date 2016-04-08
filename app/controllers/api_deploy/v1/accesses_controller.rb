module ApiDeploy
  module V1
    class AccessesController < ApplicationController

      before_filter :get_container
      before_action :check_super_permissions

      ##
      # Get accesses list
      # @resource /v1/containers/:container_id/access
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Hash] result[].user_data
      # @response_field [Integer] result[].user_data.id User id
      # @response_field [String] result[].user_data.full_name User full name
      def index
        render success_response( @container.accesses.all.map { |a| a.to_api(:public) } )
      end
      
      ##
      # Add new access
      # @resource /v1/containers/:container_id/access
      # @action POST
      #
      # @required [Hash] access
      # @required [Integer] access.email User email
      #
      # @response_field [Boolean] success
      def create
        opts = params.require(:access).permit(Access::PERMIT)
        email = opts[:email] or raise ArgumentError.new("Email doesn't exists")
        
        user   = User.find_by_email(email)
        access = Access.create container_id: @container.id, user_id: user.id
        
        render success_response
      end
      
      ##
      # Delete access
      # @resource /v1/containers/:container_id/access/:user_id
      # @action DELETE
      #
      # @response_field [Boolean] success
      def destroy
        access = @container.accesses.find_by_user_id(params[:id])
        access.destroy
        
        render success_response
      end
      
      private
    
      def get_container
        container = Container.find(params[:container_id])
        app       = container.game.name
      
        @container = Container.class_for(app).find(params[:container_id])
      end
      
      def check_super_permissions
        raise PermissionDenied unless @container.is_super_owner? current_user
      end

    end
  end
end