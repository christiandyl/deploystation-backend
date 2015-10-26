class ConnectFacebook < Connect

  default_scope { where(:partner => 'facebook') }

  def initialize data
    super(nil)

    short_lived_token = data['token']

    oauth = Koala::Facebook::OAuth.new Settings.connects.facebook.app_id, Settings.connects.facebook.app_secret
    token = oauth.exchange_access_token_info(short_lived_token)

    graph = Koala::Facebook::API.new(token['access_token'])
    fb_user = graph.get_object('me')

    self.partner = 'facebook'
    self.partner_id = fb_user['id']
    self.partner_auth_data= token['access_token']
    self.partner_expire = Time.now+token['expires'].to_i
    self.partner_data = fb_user
  end

  def self.authenticate data
    c = self.new data
    return c.existing_connect
  end

end