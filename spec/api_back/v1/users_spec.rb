require 'rails_helper'

describe 'Users API', :type => :request do
  include Capybara::DSL

  it 'Allows to create user with login connect' do
    params = { connect_login: { email: 'test@test.com', password: 'test123' } }.to_json
    send :post, "/v1/users", :params => params
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    expect(obj['result']).to be_instance_of(Hash)
    expect(obj['result']['auth_token']).to be_truthy
    expect(obj['result']['expires']).to be_truthy
  end

end