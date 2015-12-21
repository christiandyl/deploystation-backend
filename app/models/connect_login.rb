class ConnectLogin < Connect

  default_scope { where(:partner => 'login') }

  alias_attribute :email, :partner_id
  alias_attribute :email=, :partner_id=
  alias_attribute :password, :partner_auth_data
  alias_attribute :password=, :partner_auth_data=

  def initialize data = nil
    super(nil)
    self.partner = 'login'

    if data.is_a? Hash
      data = data.with_indifferent_access
      self.partner_id = data[:email] || nil
      self.partner_auth_data = (Digest::SHA1.hexdigest(data['password']) rescue nil) || nil
      
      
      self.partner_data = {
        :full_name => data["full_name"]
      }
    end
  end

  def partner_data= val
    write_attribute :partner_data, val.to_json
  end

  def partner_data
    JSON.parse(read_attribute :partner_data) rescue nil
  end
  
  def first_name
    partner_data["full_name"].split(" ").first
  end

  def last_name
    partner_data["full_name"].split(" ").last
  end
  
  def full_name
    partner_data["full_name"]
  end
  
  def avatar_url
    return nil
  end
  
  def self.authenticate data
    c = self.new data
    d = c.existing_connect
    return nil if d.nil?
    return d if d.partner_id == data['email'] && d.partner_auth_data == Digest::SHA1.hexdigest(data['password'])
    return nil
  end

  def email
    partner_id
  end

end