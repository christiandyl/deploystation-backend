require 'rails_helper'

describe 'Plugins(Minecraft PE) API', :type => :request do

  before :all do
    `docker rm --force container_1` if `docker ps -a`.include?("container_1")
    authenticate_test_user
  end

  after :all do
    container = Container.get(@context.container_id) rescue nil
    container.delete(:force => true) unless container.nil?
  end

  it 'Allows to create container' do
    params = {
      container: { plan_id: 5, name: "MCPE Test" }
    }.to_json

    send :post, containers_path, :params => params, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = Container.find(obj["result"]["id"]) rescue nil
    expect(container).not_to be_nil

    @context.container_id = container.id
  end
  
  it 'Allows to start container' do
    send :post, start_container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    @context.container = Containers::MinecraftPe.find(@context.container_id) rescue nil
    expect(@context.container).not_to be_nil
    
    ap "Port is #{@context.container.port}"
  end

  it 'Allows to get plugins list' do
    send :get, plugins_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj["result"]).to be_a(Array)
    expect(obj["result"][0]).to be_a(Hash)
    expect(obj["result"][0]["id"]).to be_a(String)
    expect(obj["result"][0]["name"]).to be_a(String)
    expect(obj["result"][0]["author"]).to be_a(String)
    expect(obj["result"][0]["description"]).to be_a(String)
    expect(obj["result"][0]["configuration"]).to be_a(Hash)
    expect(obj["result"][0]["status"]).to be_a(FalseClass)
    expect(obj["result"][0]["repo_url"]).to be_a(String)
    
    @context.plugins = obj["result"]
  end
  
  it 'Allows to enable plugin' do
    @context.plugin = @context.plugins.sample
    
    url = plugin_enable_path(@context.container_id, plugin_id: @context.plugin["id"])
    send :post, url, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)

    container = Containers::MinecraftPe.find(@context.container_id)
    status = container.plugins.find_by_id(@context.plugin["id"]).status
    
    expect(status).to be(true)
  end
  
  it 'Allows to disable plugin' do    
    url = plugin_disable_path(@context.container_id, plugin_id: @context.plugin["id"])
    send :delete, url, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)

    container = Containers::MinecraftPe.find(@context.container_id)
    status = container.plugins.find_by_id(@context.plugin["id"]).status
    
    expect(status).to be(false)
  end
end
