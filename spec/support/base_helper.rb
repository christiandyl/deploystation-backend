module BaseHelper

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

  def get_fb_token
    Capybara.current_driver = :poltergeist

    oauth = Koala::Facebook::OAuth.new Settings.connects.facebook.app_id, Settings.connects.facebook.app_secret, 'https://mindcasts-api.herokuapp.com'
    visit oauth.url_for_oauth_code

    expect(page).to have_content('Facebook Login')

    fill_in :email, with: 'ydpcixg_baoman_1433080842@tfbnw.net'
    fill_in :pass, with: 'mindcaststest'

    click_button 'Log In'

    click_button 'Okay' if body.include? 'will receive the following info'

    # expect(page).to have_content('actvt')

    code = current_params[:code]
    byebug
    expect(code).to be_truthy
    expect(code).to be_instance_of(String)

    return code
  end

end