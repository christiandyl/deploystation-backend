Settings = OpenStruct.new(
  :general => OpenStruct.new(
    :host    => ENV['GENERAL_HOST'] || 'http://localhost:3000',
    :core_ip => ENV['GENERAL_CORE_IP'] || '127.0.0.1'
  ),
  :token_encoding => OpenStruct.new(
    :algorithm      => ENV['TOKEN_ALGORITHM']      || 'HS512',
    :encryption_key => ENV['TOKEN_ENCRYPTION_KEY'] || 'w421g4uk',
    :decryption_key => ENV['TOKEN_DECRYPTION_KEY'] || 'w421g4uk'
  ),
  :airbrake => OpenStruct.new(
      :api_key => ENV['AIRBRAKE_API_KEY'] || '4baa8bb8fc18a836dcc04fb0a756742b',
      :host    => ENV['AIRBRAKE_HOST']    || 'servers-errbit.herokuapp.com'
  ),
)