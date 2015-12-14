require 'rails_helper'

describe 'Containers API', :type => :request do

  before :all do
    `docker rm --force container_1` if `docker ps -a`.include?("container_1")
    authenticate_test_user
  end

  after :all do
    container = ApiDeploy::Container.get(@context.container_id) rescue nil
    container.delete(:force => true) unless container.nil?
  end

  it 'Allows to create container' do
    params = {
      container: { plan_id: 1, name: "Server name" }
    }.to_json

    send :post, containers_path, :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(obj["result"]["id"]) rescue nil
    expect(container).not_to be_nil

    @context.container_id = container.id
  end
  
  it 'Allows to start container' do
    send :post, start_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
    
    byebug
  end
  
  it 'Allows to get containers list' do
    send :get, containers_path, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    expect(obj["result"][0]["id"]).to be_truthy
    expect(obj["result"][0]["status"]).to be_truthy
    expect(obj["result"][0]["host_info"]).to be_truthy
    expect(obj["result"][0]["plan_info"]).to be_truthy
  end
  
  it 'Allows to get container logs' do
    send :get, logs_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    # expect(obj["result"][0]["date"]).to be_truthy
    expect(obj["result"][0]["time"]).to be_truthy
    expect(obj["result"][0]["type"]).to be_truthy
    expect(obj["result"][0]["message"]).to be_truthy
  end 

  it 'Allows to restart container' do
    send :post, restart_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end

  it 'Allows to show container info' do
    send :get, container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end
  
  it 'Allows to update container info' do
    params = { container: {} }.to_json
    send :put, container_path(@context.container_id), :params => params, :token => @context.token
    
    expect(response.status).to eq(500)
    
    
    name       = "New Server name"
    is_private = true
    params = {
      container: { name: name, is_private: is_private }
    }.to_json
    send :put, container_path(@context.container_id), :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)

    container = ApiDeploy::Container.find(@context.container_id) rescue nil

    expect(container.name).to eq(name)
    expect(container.is_private).to eq(is_private)
  end
  
  it 'Allows to get game server commands list' do
    send :get, commands_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)

    expect(obj["result"]).to be_a(Array)
    expect(obj["result"][0]).to be_a(Hash)
    expect(obj["result"][0]["name"]).to be_truthy
    expect(obj["result"][0]["args"]).to be_a(Array)
    expect(obj["result"][0]["args"][0]["name"]).to be_truthy
    expect(obj["result"][0]["args"][0]["type"]).to be_truthy
    expect(obj["result"][0]["args"][0]["required"]).to be_truthy
  end
  
  it 'Allows to get game server commands list' do
    send :get, commands_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)

    expect(obj["result"]).to be_a(Array)
    expect(obj["result"][0]).to be_a(Hash)
    expect(obj["result"][0]["name"]).to be_truthy
    expect(obj["result"][0]["args"]).to be_a(Array)
    expect(obj["result"][0]["args"][0]["name"]).to be_truthy
    expect(obj["result"][0]["args"][0]["type"]).to be_truthy
    expect(obj["result"][0]["args"][0]["required"]).to be_truthy
  end
  
  # Access logics
  
  it 'Allows to create access for user' do
    @context.second_user = User.create! email: "new_user@email.com", full_name: "New User"

    params = {
      access: {
        user_id: @context.second_user.id
      }
    }.to_json

    send :post, container_accesses_path(container_id: @context.container_id), :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    
    access = Access.last
    
    expect(access.container_id).to eq(@context.container_id)
    expect(access.user_id).to eq(@context.second_user.id)
  end
  
  it 'Allows to get container accesses list' do
    send :get, container_accesses_path(container_id: @context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj['result'].class).to be(Array)
    expect(obj['result'][0].class).to be(Hash)
    expect(obj['result'][0]['user_data'].class).to be(Hash)
    expect(obj['result'][0]['user_data']['id']).to eq(@context.second_user.id)
  end
  
  it 'Allows to get delete containe access' do
    send :delete, container_access_path(container_id: @context.container_id, id: @context.second_user.id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    

    send :get, container_accesses_path(container_id: @context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj['result']).to be_empty
  end

  it 'Allows to stop container' do
    send :post, stop_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end

  it 'Allows to destroy container' do
    send :delete, container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).to be_nil
  end

end