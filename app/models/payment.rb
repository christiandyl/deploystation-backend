class Payment < ActiveRecord::Base
  include ApiExtension

  PERMIT = [:nonce_from_the_client, :amount].freeze

  STATUS_PAID = 'paid'.freeze
  STATUS_REFUNDED = 'refunded'.freeze

  #############################################################
  #### Accessors
  #############################################################

  store_accessor :metadata, :status, :transaction_id

  #############################################################
  #### Relations
  #############################################################

  belongs_to :user

  #############################################################
  #### Validations
  #############################################################

  validates :amount, presence: true
  validate :validate_amount

  def validate_amount
    correct = self.class.amounts_list.find { |h| h[:amount] == amount }
    errors.add(:amount, 'amount is not correct') if correct.nil?
  end

  #############################################################
  #### API attributes
  #############################################################

  def api_attributes(layers)
    h = {
      id: id,
      status: status,
      user_id: user_id,
      amount: amount,
      created_at: created_at,
      user: user.to_api
    }

    h[:metadata] = metadata if layers.include? :debug

    h
  end

  def self.amounts_list
    [
      { amount: 5 },
      { amount: 10 },
      { amount: 20 },
      { amount: 50 },
      { amount: 100 }
    ]
  end

  #############################################################
  #### Static methods
  #############################################################

  def self.client_token
    Braintree::ClientToken.generate
  end

  def self.create_transaction(opts = {})
    amount = opts[:amount] || opts['amount']
    nonce = opts[:nonce_from_the_client] || opts['nonce_from_the_client'] || nil
    user = opts[:user] || opts['user']

    payment = new(amount: amount, user: user)

    if payment.valid?
      # Default transaction payload
      transaction_data = {
        amount: amount,
        options: {
          submit_for_settlement: true
        }
      }

      # Looking for braintree customer record (create if doesn't exists)
      unless user.braintree_customer_exists?
        user.create_braintree_customer(payment_method_nonce: nonce)
      else
        transaction_data[:payment_method_nonce] = nonce if nonce
      end
      transaction_data[:customer_id] = user.braintree_customer.id

      # Creating transaction
      result = Braintree::Transaction.sale(transaction_data)

      # Validating transaction and saving payment record
      unless result.success?
        raise CustomError.new(code: 101, description: 'Braintree transaction is failed')
      else
        payment.transaction_id = result.transaction.id
        payment.status = STATUS_PAID
        payment.save

        user_credits = user.credits + amount
        user.update credits: credits
      end
    end

    payment
  end

  #############################################################
  #### Actions
  #############################################################

  def braintree_transaction
    Braintree::Transaction.find(transaction_id)
  end

  def refund_braintree_transaction
    Braintree::Transaction.refund(transaction_id)
  end
end
