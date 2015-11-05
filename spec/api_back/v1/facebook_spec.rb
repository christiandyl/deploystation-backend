require 'rails_helper'

describe 'Facebook API', :type => :request do

  before :all do
    config = Settings.connects.facebook
    raise "Impossible to load facebook configuration" if config.nil?

    @context.test_users = Koala::Facebook::TestUsers.new(:app_id => config.client_id, :secret => config.client_secret)
    @context.fb_user = @context.test_users.create(true, "public_profile,email")
  end
  
  after(:all) do
    @context.test_users.delete(@context.fb_user)
  end
  
  it "allows to check the absence of a user" do
    params = {
      connect_facebook: { token: @context.fb_user['access_token'] }
    }.to_json

    send :post, check_connect_path, :params => params

    expect(response).to be_success
    obj = JSON.parse(response.body)
    expect(obj).to be_instance_of(Hash)
    expect(obj['result']).to be(false)
  end
  
  it "allows to create user" do
    params = {
      connect_facebook: { token: @context.fb_user['access_token'] }
    }.to_json
    
    send :post, users_path, :params => params

    expect(response).to be_success
    obj = JSON.parse(response.body)
    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    expect(obj['result']['auth_token']).to be_truthy
    
    # expect(obj['result']).to be_instance_of(Hash)
    # expect(obj['result']['id']).to be_truthy
    # expect(obj['result']['fullname']).to be_truthy
    # expect(obj['result']['connect_login']).to be_nil
    # expect(obj['result']['connect_facebook']).to be_instance_of(Hash)
    @context.auth_token = obj['result']['auth_token']
    # @context.user_id    = obj['result']['id']
  end

end