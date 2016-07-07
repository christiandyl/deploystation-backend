module Api
  module V1
    class PaymentsController < ApiController
      
      ##
      # Get braintree client token
      # @resource /v1/payment/client_token
      # @action GET
      #
      # @response_field [Boolean] success
      # @response_field [Hash] result
      # @response_field [String] result.client_token Braintree client token
      def client_token
        client_token = Braintree::ClientToken.generate
        
        render response_ok client_token: client_token
      end
      
      ##
      # Braintree checkout
      # @resource /v1/payment
      # @action POST
      #
      # @required [Hash] payment
      # @required [String] payment.payment_method_nonce
      # @required [Integer] payment.plan_id
      # @required [Integer] payment.duration
      #
      # @response_field [Boolean] success
      def create
        opts = params.require(:payment)
        nonce    = opts[:payment_method_nonce] or raise ArgumentError.new("Nonce doesn't exists")
        plan_id  = opts[:plan_id] or raise ArgumentError.new("Plan id doesn't exists")
        duration = opts[:duration] or raise ArgumentError.new("Duration doesn't exists")
        
        plan = Plan.find(plan_id) or raise "Plan with id #{plan_id} doesn't exists"

        result = Braintree::Transaction.sale(
          :amount => plan.price,
          :payment_method_nonce => nonce,
          :options => {
            :submit_for_settlement => true
          }
        )
        
        # ap result
        puts result.to_s
        
        render response_ok result
      end
      
    end
  end
end