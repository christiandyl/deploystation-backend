require 'rails_helper'

describe 'Users API', :type => :request do
  include Capybara::DSL

  it 'Allows to create user with login connect' do
    email = 'test@test.com'
    locale = "fr"
    params = { 
      connect_login: { 
        full_name: 'Gordon Freeman',
        email: email,
        password: 'test123',
        locale: locale
      }
    }.to_json

    send :post, "/v1/users", :params => params

    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    expect(obj['result']).to be_instance_of(Hash)
    expect(obj['result']['auth_token']).to be_truthy
    expect(obj['result']['expires']).to be_truthy
    expect(obj['result']['user']['confirmation_required']).to be(false)
  
    user = User.find_by_email(email)
    expect(user.locale == locale).to be(true)
  
    @context.token = obj['result']['auth_token']
    @context.email = email
  end
  
  it 'Allows user to request email confirmation' do
    send :post, user_request_email_confirmation_path, :token => @context.token
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
  end
  
  it 'Allows user to confirm account' do
    user = User.find_by_email(@context.email)
    expect(user.confirmation).to be(false)
    
    confirmation_token = user.confirmation_token
    
    @context[:confirmation_params] = { 
      confirmation: { 
        token: confirmation_token
      }
    }

    send :post, user_confirmation_path, :params => @context[:confirmation_params].to_json
    
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)
    expect(obj['result']).to be_instance_of(Hash)
    expect(obj['result']['auth_token']).to be_truthy
    expect(obj['result']['expires']).to be_truthy
    
    user = User.find_by_email(@context.email)
    expect(user.confirmation).to be(true)
  end
  
  it 'Allows user to confirm account with old token (false)' do
    params = { 
      confirmation: { 
        token: "incorrecttoken"
      }
    }
    
    send :post, user_confirmation_path, :params => params.to_json

    expect(response.status).to eq(404)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(false)
  end
  
  it 'Allows user to confirm account with incorrect token (false)' do
    send :post, user_confirmation_path, :params => @context[:confirmation_params].to_json
    
    expect(response.status).to eq(404)

    obj = JSON.parse(response.body)

    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(false)
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