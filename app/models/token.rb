class Token

  attr_accessor :user, :token, :decoded_token, :expires, :status

  def initialize option = nil
    unless option.nil?
      if option.is_a? User
        self.user = option
      elsif option.is_a? String
        self.token = option
      else
        raise ArgumentError
      end
    end
  end

  def generate_token
    raise 'User model need to be defined' if self.user.nil?
    begin
      self.token = JWT.encode payload, Settings.token_encoding.encryption_key, Settings.token_encoding.algorithm
      self.status = true
      return self.token
    rescue
      self.status = false
      return nil
    end
  end

  def decode_token
    raise 'Token need to be defined' if self.token.nil?
    begin
      self.decoded_token = JWT.decode self.token, Settings.token_encoding.decryption_key
      self.status = true
    rescue
      self.status = false
    end
  end

  def token_is_valid?
    self.status.nil? ? false : self.status
  end

  def find_user
    self.user = User.find(self.decoded_token.first['id']) rescue nil
  end

  private

  def payload
    self.expires = (Time.now + 5.years).to_i
    { id: @user.id, :exp => self.expires }
  end

end