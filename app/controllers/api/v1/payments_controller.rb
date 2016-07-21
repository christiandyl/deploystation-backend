module Api
  module V1
    class PaymentsController < ApiController
      ##
      # Get payments list
      # @resource /v1/payments
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Integer] result[].user_id User id
      # @response_field [Float] result[].amount Amount
      # @response_field [Datetime] result[].created_at Created at
      def index
        data = current_user.payments.to_api(paginate: pagination_params)
        render response_ok data
      end
      
      ##
      # Braintree checkout
      # @resource /v1/payments
      # @action POST
      #
      # @required [Hash] payment
      # @required [String] payment.payment_method_nonce
      # @required [Integer] payment.amount
      #
      # @response_field [Array] result
      # @response_field [Integer] result.user_id User id
      # @response_field [Float] result.amount Amount
      # @response_field [Datetime] result.created_at Created at
      # @response_field [Hash] result.metadata Meta data (only in testing mode)
      def create
        opts = params.require(:payment).permit(Payment::PERMIT)
        opts[:user] = current_user
        payment = Payment.create_transaction(opts)

        api_layers = []
        api_layers << :debug unless Rails.env.production?

        render response_ok payment.to_api(layers: api_layers)
      end

      ##
      # Get braintree client token
      # @resource /v1/payments/braintree_client_token
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [String] result.client_token Braintree client token
      def braintree_client_token
        client_token = Payment.braintree_client_token
        render response_ok client_token: client_token
      end

      ##
      # Get credits sets
      # @resource /v1/payments/credits_sets
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Array] result
      # @response_field [Float] result[].amount Amount
      def credits_sets
        data = Payment.amounts_list
        render response_ok data
      end
    end
  end
end
