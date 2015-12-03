module ApiDeploy
  module V1
    class HostsController < ApplicationController

      ##
      # Get available hosts list
      # @resource /v1/hosts
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].id Host id
      # @response_field [String] result[].name Host name
      # @response_field [String] result[].location Host location
      # @response_field [Array] result[].plans_list Plans list array
      # @response_field [Integer] result[].plans_list[].id Plan id
      # @response_field [String] result[].plans_list[].name Plan name
      # @response_field [Integer] result[].plans_list[].max_players Plan max players count
      # @response_field [Hash] result[].plans_list[].game_info Plans game info
      # @response_field [Integer] result[].plans_list[].game_info.id Game id
      # @response_field [String] result[].plans_list[].game_info.name Game name
      def index
        render success_response( Host.all.map { |h| h.to_api(:public) } )
      end

    end
  end
end