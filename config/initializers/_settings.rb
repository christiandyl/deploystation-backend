Settings = OpenStruct.new(
  :general => OpenStruct.new(
    :host                => ENV['GENERAL_HOST'] || 'http://localhost:3000',
    :core_ip             => ENV['GENERAL_CORE_IP'] || '127.0.0.1',
    :ssl_path            => ENV['GENERAL_SSL_PATH'] || '/home/ubuntu/.ssl',
    :tmp_path            => ENV['GENERAL_TMP_PATH'] ? Pathname.new(ENV['GENERAL_TMP_PATH']) : Rails.root.join('tmp'),
    :assets_host         => ENV['GENERAL_ASSETS_HOST'] || 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/',
    :client_settings_key => ENV['GENERAL_CLIENT_SETTINGS_KEY'] || 'yzmLbY2ZWvgW5raaxSa9AcQMVB24N9',
  ),
  :token_encoding => OpenStruct.new(
    :algorithm      => ENV['TOKEN_ALGORITHM']      || 'HS512',
    :encryption_key => ENV['TOKEN_ENCRYPTION_KEY'] || 'w421g4uk',
    :decryption_key => ENV['TOKEN_DECRYPTION_KEY'] || 'w421g4uk'
  ),
  :redis => OpenStruct.new(
    :host     => ENV['REDIS_HOST']       || '127.0.0.1',
    :port     => ENV['REDIS_PORT']       || 6379,
    :password => ENV['REDIS_PASSWORD']   || nil
  ),
  :airbrake => OpenStruct.new(
    :api_key => ENV['AIRBRAKE_API_KEY'] || '4baa8bb8fc18a836dcc04fb0a756742b',
    :host    => ENV['AIRBRAKE_HOST']    || 'errbit.deploystation.com'
  ),
  :pusher => OpenStruct.new(
    :host   => ENV['PUSHER_HOST']   || 'api-mt1.pusher.com',
    :port   => ENV['PUSHER_PORT']   || nil,
    :app_id => ENV['PUSHER_APP_ID'] || '158644',
    :key    => ENV['PUSHER_KEY']    || '9e3aa42715e92c6e12b2',
    :secret => ENV['PUSHER_SECRET'] || '210f3bc51210d73d4b39'
  ),
  :sendgrid => OpenStruct.new(
    :user_name => ENV['SENDGRID_USER_NAME']|| 'christiandyl',
    :password  => ENV['SENDGRID_PASSWORD'] || 'dsTest2015'
  ),
  :aws => OpenStruct.new(
    :key    => ENV['AWS_KEY']    || 'AKIAJIP5KTJWEMQPGQZQ',
    :secret => ENV['AWS_SECRET'] || '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',
    :s3 => OpenStruct.new(
      :bucket => ENV['AWS_S3_BUCKET'] || 'com.deploystation.staging',
      :region => ENV['AWS_S3_REGION'] || 'eu-central-1'
    )
  ),
  :apns => OpenStruct.new(
    :host     => ENV['APNS_HOST']     || 'gateway.sandbox.push.apple.com',
    :pem_path => ENV['APNS_PEM_PATH'] || Rails.root.join('.apns_pem')
  ),
  :braintree => OpenStruct.new(
    :merchant_id => ENV['BRAINTREE_MERCHANT_ID'] || '8vz9fygsrydrggqb',
    :public_key  => ENV['BRAINTREE_PUBLIC_KEY']|| 'kprr7gxx549pc7jp',
    :private_key => ENV['BRAINTREE_PRIVATE_KEY'] || 'ffb5fbe45d4ed915ab9c590dba340025'
  ),
  :connects => OpenStruct.new(
    :facebook => OpenStruct.new(
      :client_id     => ENV['CONNECTS_FACEBOOK_APP_ID']     || '705287956273054',
      :client_secret => ENV['CONNECTS_FACEBOOK_APP_SECRET'] || '5feb1fbebdd2e3ba5026e9719d380217'
    )
  )
)