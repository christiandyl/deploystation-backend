require 'rails_helper'

describe 'Braintree API', :type => :request do
  include Capybara::DSL

  before :all do
    authenticate_test_user
  end
  
  it 'Allows to get client token' do
    send :get, payments_braintree_client_token_path, :token => @context.token
    if response_success?      
      @context.client_token = response_body['client_token']
    end
  end
  
  it 'Allows to send checkout' do
    params = {
      payment: {
        nonce_from_the_client: "fake-valid-nonce",
        amount: Payment.amounts_list[0][:amount]
      }
    }.to_json
    send :post, payments_path, :token => @context.token, :params => params

    if response_success?
      expect(response_body['id']).to be_a(Integer)
      expect(response_body['user_id']).to be_a(Integer)
      expect(response_body['amount']).to be_a(Float)

      created_at = DateTime.parse response_body['created_at']
      expect(created_at).to be_a(DateTime)

      expect(response_body['metadata']).to be_a(Hash)
    end
  end

  it 'Allows to send checkout (failure)' do
    params = {
      payment: {
        nonce_from_the_client: "fake-luhn-invalid-nonce",
        amount: Payment.amounts_list[0][:amount]
      }
    }.to_json
    send :post, payments_path, :token => @context.token, :params => params

    if response_unsuccess?
      expect(response.code).to eq('406')
      expect(response_body['code']).to eq(101)
      expect(response_body['description']).not_to be_empty
    end
  end
end
