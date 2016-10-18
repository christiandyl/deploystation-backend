Settings = OpenStruct.new(
  :general => OpenStruct.new(
    :host                => ENV['GENERAL_HOST'] || 'http://localhost:3000',
    :core_ip             => ENV['GENERAL_CORE_IP'] || '127.0.0.1',
    :ssl_path            => ENV['GENERAL_SSL_PATH'] || '/home/ubuntu/.ssl',
    :tmp_path            => ENV['GENERAL_TMP_PATH'] ? Pathname.new(ENV['GENERAL_TMP_PATH']) : Rails.root.join('tmp'),
    :assets_host         => ENV['GENERAL_ASSETS_HOST'] || 'https://s3.eu-central-1.amazonaws.com/com.deploystation.assets/',
    :client_settings_key => ENV['GENERAL_CLIENT_SETTINGS_KEY'] || 'yzmLbY2ZWvgW5raaxSa9AcQMVB24N9',
  ),
  :api => OpenStruct.new(
    enabled: ENV['API_ENABLED'].present? ? ENV['API_ENABLED'] == 'true' : true,
  ),
  :backoffice => OpenStruct.new(
    enabled: ENV['BACKOFFICE_ENABLED'] == 'true' || false,
  ),
  :token_encoding => OpenStruct.new(
    :algorithm        => ENV['TOKEN_ALGORITHM']        || 'HS512',
    :encryption_key   => ENV['TOKEN_ENCRYPTION_KEY']   || 'w421g4uk',
    :decryption_key   => ENV['TOKEN_DECRYPTION_KEY']   || 'w421g4uk',
    :referral_key     => ENV['TOKEN_REFERRAL_KEY']     || '5wwtnw7ifzalwas',
    :confirmation_key => ENV['TOKEN_CONFIRMATION_KEY'] || 'lrxoju9adfz5uya'
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
    :user_name => ENV['SENDGRID_USER_NAME'] || 'christiandyl',
    :password  => ENV['SENDGRID_PASSWORD']  || 'dsTest2015'
  ),
  :gibbon => OpenStruct.new(
    :api_key => ENV['MAILCHIMP_API_KEY'] || '24940f2fef207c7ff9bc20af8280eb1f-us13',
    :list_id => ENV['MAILCHIMP_LIST_ID'] || 'c86380935e'
  ),
  :mandrill => OpenStruct.new(
    :smtp_address  => ENV['MANDRILL_SMTP_ADDRESS']  || 'smtp.mandrillapp.com',
    :smtp_domain   => ENV['MANDRILL_SMTP_DOMAIN']   || 'deploystation.com',
    :smtp_username => ENV['MANDRILL_SMTP_USERNAME'] || 'christiandyl',
    :smtp_password => ENV['MANDRILL_SMTP_PASSWORD'] || 'PDsg43iGxEkq_d1OR3rY7w'
  ),
  :aws => OpenStruct.new(
    :key    => ENV['AWS_KEY']    || 'AKIAJVMDNUVIY64XXDOA',
    :secret => ENV['AWS_SECRET'] || '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',
    :region => ENV['AWS_REGION'] || 'eu-central-1',
    :s3 => OpenStruct.new(
      :bucket         => ENV['AWS_S3_BUCKET']         || 'com.deploystation.staging',
      :region         => ENV['AWS_S3_REGION']         || 'eu-central-1',
      :bucket_backups => ENV['AWS_S3_BUCKET_BACKUPS'] || 'com.deploystation.staging.backups',
    ),
    :dynamo_db => OpenStruct.new(
      :namespace => ENV['AWS_DYNAMO_DB_NAMESPACE'] || "ds_development"
    )
  ),
  :apns => OpenStruct.new(
    :host     => ENV['APNS_HOST']     || 'gateway.sandbox.push.apple.com',
    :pem_path => ENV['APNS_PEM_PATH'] || Rails.root.join('.apns_pem')
  ),
  :braintree => OpenStruct.new(
    :sandbox     => ENV['BRAINTREE_SANDBOX'] == 'true',
    :merchant_id => ENV['BRAINTREE_MERCHANT_ID'] || '8vz9fygsrydrggqb',
    :public_key  => ENV['BRAINTREE_PUBLIC_KEY']|| 'kprr7gxx549pc7jp',
    :private_key => ENV['BRAINTREE_PRIVATE_KEY'] || 'ffb5fbe45d4ed915ab9c590dba340025'
  ),
  :connects => OpenStruct.new(
    :facebook => OpenStruct.new(
      :client_id     => ENV['CONNECTS_FACEBOOK_APP_ID']     || '705287956273054',
      :client_secret => ENV['CONNECTS_FACEBOOK_APP_SECRET'] || '5feb1fbebdd2e3ba5026e9719d380217'
    )
  ),
  :slack => OpenStruct.new(
    :webhooks => OpenStruct.new(
      :events => ENV['SLACK_WEBHOOKS_EVENTS'] || "https://hooks.slack.com/services/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"
    )
  )
)

if Rails.env.development?
  eth_ip = `ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`
  Settings.general.host = "http://#{eth_ip}"
end
