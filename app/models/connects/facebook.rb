module Connects
  class Facebook < Connect

    default_scope { where(:partner => 'facebook') }

    def self.authenticate data
      c = self.new data
      return c.existing_connect
    end

    def initialize data
      super(nil)

      if !data['access_token'].nil?
        oauth = Koala::Facebook::OAuth.new Settings.connects.facebook.client_id, Settings.connects.facebook.client_secret
        access_token = data['access_token']
      elsif !data['code'].nil? && !data['redirect_uri'].nil?
        oauth = Koala::Facebook::OAuth.new Settings.connects.facebook.client_id, Settings.connects.facebook.client_secret, data['redirect_uri']
        access_token = oauth.get_access_token(data['code'])
      else
        raise ArgumentError.new("Create initialize facebook connect, no correct data")
      end

      token_info = oauth.exchange_access_token_info(access_token)

      graph = Koala::Facebook::API.new(access_token)
      fb_user = graph.get_object('me', :fields=>"first_name,last_name,email")

      raise "Can't get email from Facebook, token: #{access_token}" if fb_user["email"].blank?

      self.partner = 'facebook'
      self.partner_id = fb_user['id']
      self.partner_auth_data= access_token
      self.partner_expire = token_info["expires"]
      self.partner_data = fb_user
      
      self.partner_data["locale"] = data["locale"] || I18n.default_locale
      
      Rails.logger.debug "ConnectFacebook has initialized, id: #{self.partner_id}, auth_data: #{self.partner_auth_data}, data: #{self.partner_data.to_s}"
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
    
    def locale
      partner_data["locale"]
    end

    def avatar_url
      "https://graph.facebook.com/#{partner_id}/picture?type=large"
    end
    
    def email
      partner_data["email"]
    end
  end
end
