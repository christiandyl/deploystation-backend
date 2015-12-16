class ConnectFacebook < Connect

  default_scope { where(:partner => 'facebook') }

  def self.authenticate data
    c = self.new data
    return c.existing_connect
  end

  def initialize data
    super(nil)

    short_lived_token = data['code']
    redirect_uri      = data['redirect_uri']

    oauth = Koala::Facebook::OAuth.new Settings.connects.facebook.client_id, Settings.connects.facebook.client_secret, redirect_uri
    token = oauth.get_access_token(short_lived_token)

    graph = Koala::Facebook::API.new(token)
    fb_user = graph.get_object('me', :fields=>"first_name,last_name,email")

    self.partner = 'facebook'
    self.partner_id = fb_user['id']
    self.partner_auth_data= token
    self.partner_expire = nil
    self.partner_data = fb_user
  end
  
  def partner_data= val
    write_attribute :partner_data, val.to_json
  end

  def partner_data
    JSON.parse(read_attribute :partner_data) rescue nil
  end

  def first_name
    self.partner_data['first_name']
  end

  def last_name
    self.partner_data['last_name']
  end
  
  def full_name
    self.partner_data['first_name'] + " " + self.partner_data['last_name']
  end

  def avatar_url
    "https://graph.facebook.com/#{partner_id}/picture?type=large"
  end
  
  def email
    partner_data["email"]
  end

end