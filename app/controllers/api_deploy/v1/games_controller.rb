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
        render response_ok( Game.all.map { |h| h.to_api(:public) } )
      end
      
      ##
      # Get random name for game server
      # @resource /v1/games/:id/random_name
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].name Randomly generated name
      def random_name
        render response_ok Game.find(params[:game_id]).random_name
      end
      
      ##
      # Check game availability for user
      # @resource /v1/games/:id/check_availability
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Boolean] result.availability Availability status
      # @response_field [String] result.reason Unavailability reason
      def check_availability
        availability = true
        reason = nil

        if Rails.env.production?
          
          # if current_user.confirmation == false
          #   availability = false
          #   reason = I18n.t("games.availability.reason_email_confirmation")
          # else
            not_paid = Container.exists? user_id: current_user.id, is_paid: false
            if not_paid == true
              availability = false
              reason = I18n.t("games.availability.reason_not_paid")
            end
          # end
          
        end
        
        data = {
          :availability => availability,
          :reason       => reason
        }
        
        render response_ok data
      end

    end
  end
end