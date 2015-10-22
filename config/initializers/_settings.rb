Settings = OpenStruct.new(
  :general => OpenStruct.new(
    :host    => ENV['GENERAL_HOST'] || 'http://localhost:3000',
    :core_ip => ENV['GENERAL_CORE_IP'] || '127.0.0.1'
  ),
  :token_encoding => OpenStruct.new(
    :algorithm      => ENV['TOKEN_ALGORITHM']      || 'HS512',
    :decryption_key => ENV['TOKEN_DECRYPTION_KEY'] || 'w421g4uk'
  )
)