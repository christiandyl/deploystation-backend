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

end