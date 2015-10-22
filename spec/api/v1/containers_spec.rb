require 'rails_helper'

describe 'Containers API', :type => :request do

  after :all do
    container = Container.get(@context.container_id) rescue nil
    container.delete(:force => true) unless container.nil?
  end

  it 'Allows to create container' do
    params = {
      container: { game: 'minecraft' }
    }.to_json
    send :post, v1_containers_path, :params => params
 
    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    expect(obj["result"]["id"]).not_to be_empty
    
    container = Container.get(obj["result"]["id"]) rescue nil
    expect(container).not_to be_nil
    
    @context.container_id = container.id
  end
  
  it 'Allows to start container' do
    send :post, start_v1_container_path(@context.container_id)

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj["result"]["id"]).not_to be_empty

    container = Container.get(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end

  it 'Allows to restart container' do
    send :post, restart_v1_container_path(@context.container_id)

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj["result"]["id"]).not_to be_empty

    container = Container.get(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end

  it 'Allows to show container info' do
    send :get, v1_container_path(@context.container_id)

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj["result"]["id"]).not_to be_empty

    container = Container.get(@context.container_id) rescue nil
    expect(container).not_to be_nil
  end

  it 'Allows to destroy container' do
    send :delete, v1_container_path(@context.container_id)

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)

    expect(obj['success']).to be(true)
    expect(obj["result"]["id"]).not_to be_empty

    container = Container.get(@context.container_id) rescue nil
    expect(container).to be_nil
  end

end