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
    end
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