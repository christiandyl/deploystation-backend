module ApiDeploy
  module V1
    class ConfigsController < ApplicationController

      before_filter :get_container
      before_action :check_super_permissions

      ##
      # Get config properties list
      # @resource /v1/containers/:container_id/config
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [String] result[].key Property key
      # @response_field [String] result[].type Property type (integer, string, boolean...)
      # @response_field [String] result[].title Property title
      # @response_field [String] result[].default_value Default value
      # @response_field [Boolean] result[].is_editable Is editable
      # @response_field [Hash] result[].validations Validations hash
      def show
        render success_response @container.config.all(:public)
      end
      
      ##
      # Updata config properties
      # @resource /v1/containers/:container_id/config
      # @action PUT
      #
      # @required [Hash] config
      # @required [String] config.<property_key> The value of property...
      # @required [String] config.<property_key> The value of property...
      # @required [String] config.<property_key> The value of property...
      # @required [String] config.<property_key> The value of property...
      #
      # @response_field [Boolean] success
      def update
        opts = params.require(:config).permit(@container.config.class.permit)
        
        @container.config.set_properties(opts)
        @container.config.export_to_database
        
        render success_response
      end
      
      private
    
      def get_container
        container = Container.find(params[:id])
        app       = container.game.name
      
        @container = Container.class_for(app).find(params[:id])
      end
      
      def check_super_permissions
        raise PermissionDenied unless @container.is_super_owner? current_user
      end

    end
  end
end