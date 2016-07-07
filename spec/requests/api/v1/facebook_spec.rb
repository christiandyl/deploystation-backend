# require 'rails_helper'

# describe 'Facebook API', :type => :request do

#   before :all do
#     config = Settings.connects.facebook
#     raise "Impossible to load facebook configuration" if config.nil?

#     @context.code  = get_fb_token
#     @context.fb_email = @context.code[:email]
#     @context.fb_password = @context.code[:password]
#   end
  
#   it "allows to check the absence of a user" do
#     params = {
#       connect_facebook: {
#         code: @context.code[:code],
#         redirect_uri: @context.code[:redirect_uri]
#       }
#     }.to_json
    
#     send :post, check_connect_path, :params => params

#     expect(response).to be_success
#     obj = JSON.parse(response.body)
#     expect(obj).to be_instance_of(Hash)
#     expect(obj['result']).to be(false)
#   end
  
#   it "allows to create user" do
#     @context.code = get_fb_token @context.fb_email, @context.fb_password
    
#     params = {
#       connect_facebook: {
#         code: @context.code[:code],
#         redirect_uri: @context.code[:redirect_uri]
#       }
#     }.to_json
    
#     send :post, users_path, :params => params

#     expect(response).to be_success
#     obj = JSON.parse(response.body)
#     expect(obj).to be_instance_of(Hash)
#     expect(obj['success']).to be(true)
#     expect(obj['result']['auth_token']).to be_truthy
    
#     # expect(obj['result']).to be_instance_of(Hash)
#     # expect(obj['result']['id']).to be_truthy
#     # expect(obj['result']['fullname']).to be_truthy
#     # expect(obj['result']['connect_login']).to be_nil
#     # expect(obj['result']['connect_facebook']).to be_instance_of(Hash)
#     @context.auth_token = obj['result']['auth_token']
#     # @context.user_id    = obj['result']['id']
#   end

# end