require 'rails_helper'

describe 'Sessions API', :type => :request do

  before :all do
    authenticate_test_user
  end

  it 'Allows to authenticate user with login connect' do
    params = { connect_login: { email: @context.user.email, password: @context.user_password } }.to_json
    send :post, "/v1/session", :params => params
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)
    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end

end