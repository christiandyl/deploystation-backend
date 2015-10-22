class Token

  attr_accessor :token, :decoded_token, :expires, :status

  def initialize option = nil
    unless option.nil?
      if option.is_a? String
        self.token = option
      else
        raise ArgumentError
      end
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

  def valid?
    self.status.nil? ? false : self.status
  end

end