module ApiDeploy
  module V1
    class PluginsController < ApplicationController

      skip_before_filter :ensure_logged_in, :only => [:index]
      before_filter :get_container
      before_filter :get_plugin, only: [:enable, :disable]

      ##
      # Get config properties list
      # @resource /v1/containers/:container_id/plugins
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [String] result[].id Plugin id
      # @response_field [String] result[].name Plugin name
      # @response_field [String] result[].author Plugin author
      # @response_field [String] result[].description Plugin description
      # @response_field [Hash] result[].configuration Plugin configuration
      # @response_field [String] result[].repo_url Plugin repository url
      # @response_field [Boolean] result[].status Plugin status
      def index
        private_request = params[:private] == 1 || params[:private] == true || params[:private] == "true"
        
        data = unless private_request
          @container.plugins.all.map { |p| p.to_api(:public) }
        else
          @container.plugins.enabled.map { |p| p.to_api(:private) }
        end
        
        render response_ok data
      end
      
      ##
      # Activate plugin
      # @resource /v1/containers/:container_id/plugins/:plugin_id/enable
      # @action POST
      #
      # @response_field [Boolean] success
      def enable
        @plugin.enable
        
        render response_ok
      end
      
      ##
      # Disactivate plugin
      # @resource /v1/containers/:container_id/plugins/:plugin_id/disable
      # @action DELETE
      #
      # @response_field [Boolean] success
      def disable
        @plugin.disable
        
        render response_ok
      end
      
      private
    
      def get_container
        container = Container.find(params[:id])
        app       = container.game.sname
      
        @container = Container.class_for(app).find(params[:id])
      end
      
      def get_plugin
        @plugin = @container.plugins.find_by_id(params[:plugin_id])
      end

    end
  end
end