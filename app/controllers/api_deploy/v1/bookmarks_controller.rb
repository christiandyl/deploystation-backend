module ApiDeploy
  module V1
    class BookmarksController < ApplicationController

      before_filter :get_container
      
      ##
      # Create bookmark
      # @resource /v1/containers/:container_id/bookmarks
      # @action POST
      #
      # @response_field [Boolean] success
      def create
        bookmark = Bookmark.create container_id: @container.id, user_id: current_user.id
        
        render response_ok
      end
      
      ##
      # Delete bookmark
      # @resource /v1/containers/:container_id/bookmarks/:user_id
      # @action DELETE
      #
      # @response_field [Boolean] success
      def destroy
        bookmark = Bookmark.find_by! container_id: @container.id, user_id: current_user.id
        bookmark.delete
        
        render response_ok
      end
      
      private
    
      def get_container
        container = Container.find(params[:container_id])
        app       = container.game.sname
      
        @container = Container.class_for(app).find(params[:container_id])
        
        raise "Owner can't bookmark own server" if @container.id == current_user.id
      end

    end
  end
end