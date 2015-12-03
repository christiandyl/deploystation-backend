require 'rails_helper'

describe 'Containers API', :type => :request do

  before :all do
    authenticate_test_user
  end

  it 'Allows to create container' do
    # t.first.use
#     puts Docker::Container.all.count
    # byebug
    # 160.times do
    #   params = {
    #     container: { plan_id: 1 }
    #   }.to_json
    #
    #   send :post, containers_path, :params => params, :token => @context.token
    #
    #   expect(response.status).to eq(200)
    #   obj = JSON.parse(response.body)
    #
    #   expect(obj['success']).to be(true)
    #
    #   container = ApiDeploy::Container.find(obj["result"]["id"]) rescue nil
    #
    #   send :post, start_container_path(container.id), :token => @context.token
    # end
  end
  
end