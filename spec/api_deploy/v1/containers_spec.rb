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
    
    byebug
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
  
  it 'Allows to search containers' do
    send :get, search_containers_path(query: "Server")

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj["result"]["list"]).not_to be_empty
    expect(obj["result"]["current_page"]).to be_truthy
    expect(obj["result"]["is_last_page"]).to be_truthy
    
    send :get, search_containers_path(query: "rege3432rhethrthrthrthrthrth")

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    expect(obj["result"]["list"]).to be_empty
  end
  
  it 'Allows to start container' do
    send :post, start_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
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
  
  it 'Allows to show public container info' do
    send :get, container_path(@context.container_id)

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty
  end
  
  it 'Allows to update container info' do
    params = { container: {} }.to_json
    send :put, container_path(@context.container_id), :params => params, :token => @context.token
    
    expect(response.status).to eq(500)
    
    name       = "New Server name"
    is_private = false
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
  
  it 'Allows to get popular containers' do
    send :get, popular_containers_path, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    #
    # expect(obj['success']).to be(true)
    # expect(obj['result'].class).to be(Array)
    # expect(obj['result'][0].class).to be(Hash)
    # expect(obj['result'][0]['user_data'].class).to be(Hash)
    # expect(obj['result'][0]['user_data']['id']).to eq(@context.second_user.id)
  end
  
  # Access logics
  
  it 'Allows to create access for user' do
    second_user_params = { connect_login: { email: 'test2@test.com', password: 'test123' } }
    @context.second_user_token = create_user_token(second_user_params)
    @context.second_user_token.find_user
    @context.second_user = @context.second_user_token.user

    params = {
      access: {
        email: @context.second_user.email
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
  
  it 'Allows user to get shared containers list' do
    send :get, shared_containers_path, :token => @context.second_user_token.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    expect(obj["result"][0]["id"]).to be_truthy
    expect(obj["result"][0]["status"]).to be_truthy
    expect(obj["result"][0]["host_info"]).to be_truthy
    expect(obj["result"][0]["plan_info"]).to be_truthy
  end
  
  it 'Allows to delete container access' do
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
  
  # Bookmarks logics
  
  it 'Allows user to bookmark server' do
    send :post, container_bookmarks_path(container_id: @context.container_id), :token => @context.second_user_token.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    
    bookmark = Bookmark.last

    expect(bookmark.container_id).to eq(@context.container_id)
    expect(bookmark.user_id).to eq(@context.second_user.id)
  end
  
  it 'Allows user to get bookmarked containers list' do
    send :get, bookmarked_containers_path, :token => @context.second_user_token.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    expect(obj["result"][0]["id"]).to be_truthy
    expect(obj["result"][0]["status"]).to be_truthy
    expect(obj["result"][0]["host_info"]).to be_truthy
    expect(obj["result"][0]["plan_info"]).to be_truthy
  end
  
  it 'Allows to show container info with bookmark attribute' do
    send :get, container_path(@context.container_id), :token => @context.second_user_token.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = ApiDeploy::Container.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end
  
  it 'Allows user to delete bookmark server' do
    send :delete, container_bookmark_path(@context.second_user.id, container_id: @context.container_id), :token => @context.second_user_token.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
  end
  
  # Config
  
  it 'Allows to get container config list' do
    send :get, config_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj['result'].class).to be(Array)
    expect(obj['result'][0].class).to be(Hash)
    expect(obj['result'][0]['key'].class).to be_truthy
    expect(obj['result'][0]['type']).to be_truthy
    expect(obj['result'][0]['title']).to be_truthy
    expect(obj['result'][0]['default_value']).to be_truthy
    expect(obj['result'][0]['is_editable']).to be_truthy
    expect(obj['result'][0]['validations']).to be_truthy
    
    @context.config = obj['result']
  end
  
  it 'Allows to update container config list' do
    params = { :config => {} }
    @context.config.map { |p| params[:config][p["key"]] = p["default_value"] }
    params = params.to_json

    send :put, config_path(@context.container_id), :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
  end
  
  it 'Allows to invite friends by email' do
    params = {
      invitation: { method_name: "email", data: { emails: ["christian.dyl@outlook.com", "christian@deploystation.com"] } }
    }.to_json
    send :post, invitation_container_path(@context.container_id), :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
  end
  
  ####

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