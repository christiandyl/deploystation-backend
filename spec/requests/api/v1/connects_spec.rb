require 'rails_helper'

describe 'Connects API', :type => :request do
  include Capybara::DSL

  before :all do
    authenticate_test_user
  end
  
  it 'Allows to get user connects' do
    send :get, user_connects_path(user_id: 1), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
  end
  
  it 'Allows to add connect' do
    @context.code  = get_fb_token
    params = {
      connect_facebook: {
        code: @context.code[:code],
        redirect_uri: @context.code[:redirect_uri]
      }
    }.to_json
    
    send :post, user_connects_path(user_id: 1), :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    @context.connects = User.last.connects
    expect(@context.connects.count).to be_equal(2)
  end
  
  it 'Allows to destroy connect' do
    send :delete, user_connect_path(id: @context.connects.last.id, user_id: 1), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    connects = User.last.connects
    expect(connects.count).to be_equal(1)
  end

end