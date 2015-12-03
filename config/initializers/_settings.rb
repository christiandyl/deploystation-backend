Settings = OpenStruct.new(
  :general => OpenStruct.new(
    :host     => ENV['GENERAL_HOST'] || 'http://localhost:3000',
    :core_ip  => ENV['GENERAL_CORE_IP'] || '127.0.0.1',
    :ssl_path => ENV['GENERAL_SSL_PATH'] || '/home/ubuntu/.ssl'
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
  :pusher => OpenStruct.new(
    :app_id => ENV['PUSHER_APP_ID'] || '151255',
    :key    => ENV['PUSHER_KEY']    || 'e5404185a0460e3f52da',
    :secret => ENV['PUSHER_SECRET'] || '2df3b5a0303647b59b08'
  ),
  :sendgrid => OpenStruct.new(
    :user_name => ENV['SENDGRID_USER_NAME']|| 'deploy4play@gmail.com',
    :password  => ENV['SENDGRID_PASSWORD'] || 'dsTest2015'
  ),
  :connects => OpenStruct.new(
    :facebook => OpenStruct.new(
      :client_id     => ENV['CONNECTS_FACEBOOK_APP_ID']     || '705288129606370',
      :client_secret => ENV['CONNECTS_FACEBOOK_APP_SECRET'] || 'b3cc3532612805e9301738c6bb78a463'
    )
  )
)