module ApiDeploy
  module V1
    class GamesController < ApplicationController

      ##
      # Get available games list
      # @resource /v1/games
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Game id
      # @response_field [String] result[].name Game name
      # @response_field [String] result[].features_list Features list
      def index
        render success_response( Game.all.map { |h| h.to_api(:public) } )
      end

    end
  end
end