module ApiController
  module V1
    class PlansController < Api

      ##
      # Get available games list
      # @resource /v1/plans
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      def index
        host_id = params[:host_id]
        game_id = params[:game_id]
        
        if !host_id.nil? && !game_id.nil?
          plans = Plan.where(host_id: host_id, game_id: game_id)
        elsif !host_id.nil?
          plans = Plan.where(host_id: host_id)
        elsif !game_id.nil?
          plans = Plan.where(game_id: game_id)
        else
          plans = Plan.all
        end
        
        data = plans.map { |p| p.to_api }
        
        render response_ok plans
      end

    end
  end
end