require 'rails_helper'

describe 'Devices API', :type => :request do
  include Capybara::DSL

  before :all do
    authenticate_test_user
  end
  
  it 'Allows to create device' do
    params = {
      device: { device_type: "ios", push_token: "tweweewgrger" }
    }.to_json
    send :post, devices_path, :token => @context.token, :params => params

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    byebug
  end

end