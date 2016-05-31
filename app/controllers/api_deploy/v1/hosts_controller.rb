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
      # @response_field [String] result[].country_code Host country code
      # @response_field [Array] result[].plans_list Plans list array
      # @response_field [Integer] result[].plans_list[].id Plan id
      # @response_field [String] result[].plans_list[].name Plan name
      # @response_field [Integer] result[].plans_list[].max_players Plan max players count
      def index
        begin
          results = Geocoder.search(request.ip)
          unless results.blank?
            location = results.first
          
            if location.country_code == "RU"
              list = Host.where("country_code = ?", "ua")
            else
              list = Host.all
              # list = Host.where("country_code <> ?", "us")
            end
          else
            # list = Host.where("country_code <> ?", "us")
            list = Host.all
          end
        rescue
          list = Host.all
        end

        render response_ok( list.map { |h| h.to_api(:public) } )
      end

    end
  end
end