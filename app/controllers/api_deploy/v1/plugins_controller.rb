module ApiDeploy
  module V1
    class PluginsController < ApplicationController

      before_filter :get_container

      ##
      # Get config properties list
      # @resource /v1/containers/:container_id/plugins
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [String] result[].id Plugin id
      # @response_field [String] result[].name Plugin name
      # @response_field [String] result[].description Plugin description
      # @response_field [String] result[].status Plugin status
      def index
        data = @container.plugins.map { |p| p.to_api(:public) }
        
        render response_ok data
      end
      
      ##
      # Activate plugin
      # @resource /v1/containers/:container_id/plugins/:plugin_id/activate
      # @action POST
      #
      # @response_field [Boolean] success
      def activate
        @container.plugins.find { |p| p.id == params[:id] }.activate
        
        render response_ok
      end
      
      ##
      # Disactivate plugin
      # @resource /v1/containers/:container_id/plugins/:plugin_id/disactivate
      # @action DELETE
      #
      # @response_field [Boolean] success
      def disactivate
        @container.plugins.find { |p| p.id == params[:id] }.disactivate
        
        render response_ok
      end
      
      private
    
      def get_container
        container = Container.find(params[:id])
        app       = container.game.sname
      
        @container = Container.class_for(app).find(params[:id])
      end

    end
  end
end