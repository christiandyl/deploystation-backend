module Connects
  class Twitter < Connect

    default_scope { where(:partner => 'twitter') }

    def self.authenticate data
      c = self.new data
      return c.existing_connect
    end

    def initialize data
      super(nil)

      if !data['oauth_echo'].nil?
        x_auth_service_provider = data['oauth_echo']['X-Auth-Service-Provider']
        x_verify_credentials_authorization = data['oauth_echo']['X-Verify-Credentials-Authorization']
        
        response = HTTParty.get(x_auth_service_provider, :headers => {
          "Authorization" => x_verify_credentials_authorization
        })

        if response.code == 200
          uid = response["id"]
          email = response["email"].nil? ? "#{uid.to_s}@twitter.com" : response["email"]
          
          self.partner = 'twitter'
          self.partner_id = uid
          self.partner_auth_data = data['access_token'] || nil
          self.partner_expire = nil
          self.partner_data = {
            email: email,
            name: response["name"],
            locale: data["locale"] || response["lang"] || I18n.default_locale,
            profile_image_url: response["profile_image_url"],
            additional: response.to_h
          }
      
          Rails.logger.debug "ConnectTwitter has initialized, id: #{self.partner_id}, auth_data: #{self.partner_auth_data}, data: #{self.partner_data.to_s}"
        else
          raise "Can't get oauth echo data"
        end
      else
        raise ArgumentError.new("Create initialize twitter connect, no correct data")
      end
    end
    
    def partner_data= val
      write_attribute :partner_data, val.to_json
    end

    def partner_data
      JSON.parse(read_attribute :partner_data) rescue nil
    end

    def first_name
      self.partner_data['name']
    end

    def last_name
      self.partner_data['name']
    end
    
    def full_name
      self.partner_data['name']
    end
    
    def locale
      partner_data["locale"]
    end

    def avatar_url
      partner_data["profile_image_url"]
    end
    
    def email
      partner_data["email"]
    end
  end
end
