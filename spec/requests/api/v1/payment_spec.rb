require 'rails_helper'

describe 'Braintree API', :type => :request do
  include Capybara::DSL

  before :all do
    authenticate_test_user
  end
  
  it 'Allows to get client token' do
    send :get, client_token_payment_path, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    @context.client_token = obj["result"]["client_token"]
  end
  
  it 'Allows to send checkout' do
    params = {
      payment: { payment_method_nonce: "fwefwef", plan_id: 1, duration: 2 }
    }.to_json
    send :post, payment_path, :token => @context.token, :params => params

    # expect(response.status).to eq(200)
    # obj = JSON.parse(response.body)
    #
    # expect(obj['success']).to be(true)
    #
    # @context.client_token = obj["result"]["client_token"]
  end

end