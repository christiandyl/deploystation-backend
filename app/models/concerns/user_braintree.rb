module UserBraintree
  extend ActiveSupport::Concern

  included do
    store_accessor :metadata, :braintree_id

    after_destroy :delete_braintree_account
  end

  def create_braintree_customer(**opts)
    data = {
      email: email
    }
    data[:payment_method_nonce] = opts[:payment_method_nonce] if opts[:payment_method_nonce]

    result = Braintree::Customer.create(data)
    if result.success?
      self.braintree_id = result.customer.id
      save
    else
      # TODO error
    end

    result.customer
  end

  def delete_braintree_customer
    Braintree::Customer.delete(braintree_id)
    self.braintree_id = nil
    save!
  end

  def braintree_customer
    Braintree::Customer.find(braintree_id)
  end

  def braintree_customer!
    create_braintree_customer if braintree_customer_exists?
    braintree_customer
  end

  def braintree_customer_exists?
    !braintree_id.nil?
  end
end
