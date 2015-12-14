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
      # @required [Hash] access
      # @required [Integer] access.user_id User id
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
      # @response_field [Boolean] success
      def create
        opts = params.require(:access).permit(Access::PERMIT)
        user_id = opts[:user_id] or raise ArgumentError.new("User id doesn't exists")
        
        user   = User.find(user_id)
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