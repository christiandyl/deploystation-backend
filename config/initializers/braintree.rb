# Braintree::Configuration.environment = :sandbox unless Rails.env.production?
unless Rails.env.production?
  Braintree::Configuration.environment = Settings.braintree.sandbox ? :sandbox : :production
else
  Braintree::Configuration.environment = :production
end

Braintree::Configuration.merchant_id = Settings.braintree.merchant_id
Braintree::Configuration.public_key  = Settings.braintree.public_key
Braintree::Configuration.private_key = Settings.braintree.private_key