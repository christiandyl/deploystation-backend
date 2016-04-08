module BaseHelper
  include Capybara::DSL

  DEFAULT_HEADERS    = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

  def send type, path, **opts
    raise ArgumentError, "Path option must be in hash" unless path

    method = method(type || 'get')
    params = opts[:params] || {}
    headers = opts[:headers] || get_headers(opts[:token] || nil)

    method.call path, params, headers
  end

  def current_params
    p = {}
    current_url.match(/\?(.*)$/)[1].split('#')[0].split("&").each do |e|
      spl = e.split('=')
      p[spl[0]] = spl[1] || nil
    end
    return p.with_indifferent_access
  end

  def authenticate_test_user
    params = { connect_login: { email: 'test@test.com', password: 'test123' } }
    token = create_user_token(params)

    @context.token = token.token
    @context.user  = token.find_user
    @context.user_password = params[:connect_login][:password]

    return true
  end

  def create_user_token params = nil
    params = (params || { connect_login: { email: 'test@test.com', password: 'test123' } }).to_json
    send :post, "/v1/users", :params => params
    expect(response.status).to eq(200)

    obj = JSON.parse(response.body)
    expect(obj).to be_instance_of(Hash)
    expect(obj['success']).to be(true)

    token = Token.new obj['result']['auth_token']
    token.decode_token

    return token
  end

  def get_headers(token = nil)
    headers = BaseHelper::DEFAULT_HEADERS
    headers['X-Auth-Token'] = token unless token.nil?
    headers
  end

  def get_fb_token email=nil, password=nil
    Capybara.current_driver = :poltergeist

    client_id     = Settings.connects.facebook.client_id
    client_secret = Settings.connects.facebook.client_secret
    redirect_uri  = "https://www.facebook.com/connect/login_success.html"
        
    if email.nil? || password.nil?
      fb_test_users = Koala::Facebook::TestUsers.new(:app_id => client_id, :secret => client_secret)
      fb_test_users.delete_all
      fb_test_user  =  fb_test_users.create(true, "public_profile,email")
    
      email    = fb_test_user["email"]
      password = fb_test_user["password"]
    end

    oauth = Koala::Facebook::OAuth.new client_id, client_secret, redirect_uri
    url = oauth.url_for_oauth_code
    
    visit url

    expect(page).to have_content('Facebook Login')

    fill_in :email, with: email
    fill_in :pass, with: password

    click_button 'Log In'

    click_button 'Okay' if body.include? 'will receive the following info'

    params = current_params
    expect(page).to have_content('Success')

    code = params[:code]
    expect(code).to be_truthy
    expect(code).to be_instance_of(String)

    return { code: code, redirect_uri: redirect_uri, email: email, password: password }
  end

end