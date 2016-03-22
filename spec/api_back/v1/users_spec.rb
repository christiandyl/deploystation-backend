require 'rails_helper'

describe 'Users API', :type => :request do
  include Capybara::DSL

  it 'Allows to create user with login connect' do
    email = 'test@test.com'
    params = { connect_login: { full_name: 'Gordon Freeman', email: email, password: 'test123' } }.to_json
    send :post, "/v1/users", :params => params

    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    expect(obj['result']).to be_instance_of(Hash)
    expect(obj['result']['auth_token']).to be_truthy
    expect(obj['result']['expires']).to be_truthy
  
    @context.token = obj['result']['auth_token']
    @context.email = email
  end
  
  it 'Allows user to get own data' do
    send :get, users_me_path, :token => @context.token
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    expect(obj['result']).to be_instance_of(Hash)
    expect(obj['result']['id']).to be_truthy
    expect(obj['result']['email']).to be_truthy
  end
  
  it 'Allows user to update data' do
    new_email = "new_email@test.com"
    params = {
      :user => {
        :email     => new_email,
        :full_name => "Adam Janson"
      }
    }.to_json
    send :put, user_path(1), :params => params, :token => @context.token
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    
    @context.email = new_email
  end
  
  it 'Allows user to update password' do
    params = {
      :user => {
        :current_password => 'test12',
        :new_password     => 'newtest123'
      }
    }.to_json
    send :put, user_path(1), :params => params, :token => @context.token
    
    expect(response.status).to eq(500)
    
    params = {
      :user => {
        :current_password => 'test123',
        :new_password     => 'newtest123'
      }
    }.to_json
    send :put, user_path(1), :params => params, :token => @context.token
    
    valid = User.find_by_email(@context.email).connect_login.valid_password? 'newtest123'
    expect(valid).to be(true)
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end
  
  it 'Allows user to upload avatar (direct upload)' do
    file = Rack::Test::UploadedFile.new(Rails.root.join("spec", "files", "avatar.jpg"))
    params = {
      :file => file,
      :avatar => {
        :type => :direct_upload
      }
    }
    send :put, user_avatar_path(1), :params => params, :token => @context.token
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end
  
  it 'Allows user to upload avatar (url)' do
    params = {
      :avatar => {
        :type   => :url,
        :source => {
          :url => "https://graph.facebook.com/100001401312341/picture?type=large"
        }
      }
    }.to_json
    send :put, user_avatar_path(1), :params => params, :token => @context.token
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end
  
  it 'Allows user to destroy avatar' do
    send :delete, user_avatar_path(1), :token => @context.token

    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end
  
  it 'Allows to request password recovery' do
    params = { password_recovery: { email: @context.email } }.to_json
    send :post, users_request_password_recovery_path, :params => params
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end

end