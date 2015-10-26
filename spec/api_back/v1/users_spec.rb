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
  end

  # it 'Allows to create user with facebook connect' do
  #   token = get_fb_token
  #   params = { connect_facebook: { token: token } }
  #   send :post, "/v1/users", :params => params
  #   expect(response.status).to eq(200)
  #
  #   obj = JSON.parse(response.body)
  #   expect(obj).to be_instance_of(Hash)
  #   expect(obj['success']).to be(true)
  # end

end