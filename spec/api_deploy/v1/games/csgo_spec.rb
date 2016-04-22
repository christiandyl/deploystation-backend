require 'rails_helper'

describe 'Container(CS GO) API', :type => :request do

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
      container: { plan_id: 4, name: "CS GO Test" }
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

    container = ApiDeploy::ContainerCounterStrikeGo.find(@context.container_id) rescue nil
    expect(container).not_to be_nil
    
    ap "Port is #{container.port}"
    byebug
    container.players_online
    byebug
  end
  #
  # it 'Allows to destroy container' do
  #   send :delete, container_path(@context.container_id), :token => @context.token
  #
  #   expect(response.status).to eq(200)
  #   obj = JSON.parse(response.body)
  #
  #   expect(obj['success']).to be(true)
  #   # expect(obj["result"]["id"]).not_to be_empty
  #
  #   container = ApiDeploy::Container.find(@context.container_id) rescue nil
  #   expect(container).to be_nil
  # end

end