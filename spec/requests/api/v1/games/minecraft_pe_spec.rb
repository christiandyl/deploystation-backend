require 'rails_helper'

describe 'Container(Minecraft PE) API', :type => :request do

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

    container = Containers::MinecraftPe.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
    
    ap "Port is #{container.port}"

    byebug
  end

  # Config

  it 'Allows to get container config list' do
    send :get, config_path(@context.container_id), token: @context.token

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

  it 'Allows to get container config list (text)' do
    send :get, config_path(@context.container_id, format: :text), token: @context.token
    expect(response.status).to eq(200)
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

  it 'Allows to destroy container' do    
    send :delete, container_path(@context.container_id), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    # expect(obj["result"]["id"]).not_to be_empty

    container = Container.find(@context.container_id) rescue nil
    expect(container).to be_nil
  end

end