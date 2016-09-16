require 'rails_helper'

describe 'Client options API', :type => :request do
  
  before(:all) do
    authenticate_test_user
    ClientOption.delete_all
  end

  it 'Create client option' do
    key = 'show_welcome_message'
    value = true
    params = {
      client_option: {
        vtype: 'bool',
        key: key,
        value: value
      }
    }.to_json

    path = '/v1/client_options'

    send :post, path, params: params, token: @context.token

    if response_success?
    end
  end
  
  it 'Get client options list' do
    key = 'show_welcome_message'

    path = '/v1/client_options'
    send :get, path, token: @context.token

    if response_success?
    end
  end

  it 'Show client option' do
    key = 'show_welcome_message'

    path = "/v1/client_options/#{key}"
    send :get, path, token: @context.token

    if response_success?
    end
  end

  it 'Destroy client option' do
    key = 'show_welcome_message'

    path = "/v1/client_options/#{key}"
    send :delete, path, token: @context.token

    if response_success?
    end
  end
end
