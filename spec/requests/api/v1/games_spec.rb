require 'rails_helper'

describe 'Games API', :type => :request do

  before :all do
    authenticate_test_user
  end

  it 'Allows to get games list' do
    send :get, games_path, :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    expect(obj["result"]).to be_a(Array)
    expect(obj["result"][0]).to be_a(Hash)
    expect(obj["result"].first["id"]).to be_truthy
    expect(obj["result"].first["name"]).to be_truthy
  end
  
  it 'Allows to generate random name for minecraft' do
    game_mc = Game.find_by_sname("minecraft")
    
    send :get, game_random_name_path(game_mc), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    expect(obj["result"]).to be_a(String)
    expect(obj["result"]).to be_truthy
  end
  
  it 'Allows to generate random name for minecraft pe' do
    game_mc = Game.find_by_sname("minecraft_pe")
    
    send :get, game_random_name_path(game_mc), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    expect(obj["result"]).to be_a(String)
    expect(obj["result"]).to be_truthy
  end
  
  it 'Allows to generate random name for cs go' do
    game_mc = Game.find_by_sname("counter_strike_go")
    
    send :get, game_random_name_path(game_mc), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    expect(obj["result"]).to be_a(String)
    expect(obj["result"]).to be_truthy
  end
  
  it 'Allows to generate random name for cs go' do
    game_mc = Game.find_by_sname("counter_strike_go")
    
    send :get, game_check_availability_path(game_mc), :token => @context.token

    expect(response.status).to eq(200)
    obj = JSON.parse(response.body)
    
    expect(obj['success']).to be(true)
    
    expect(obj["result"]).to be_a(Hash)
    expect(obj["result"]["availability"]).to be_a(TrueClass)
    expect(obj["result"]["reason"]).to be_a(NilClass)
  end

end