module Api
  module V1
    class ChargesController < ApiController
      ##
      # Get payments list
      # @resource /v1/charges
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result.current_page Current page
      # @response_field [Boolean] result.last_page Last page
      # @response_field [Array] result.list Charges list
      # @response_field [Integer] result.list[].id Charge id
      # @response_field [Integer] result.list[].user_id User id
      # @response_field [Integer] result.list[].container_id Container id
      # @response_field [Float] result.list[].amount Charge amount
      # @response_field [String] result.list[].details Details
      # @response_field [Datetime] result.list[].created_at Created at
      def index
        data = current_user.charges.to_api(paginate: pagination_params)
        render response_ok data
      end
    end
  end
end
