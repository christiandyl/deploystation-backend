# ActionMailer::Base.smtp_settings = {
#   :address              => Settings.mandrill.smtp_address,
#   :authentication       => :plain,
#   :domain               => Settings.mandrill.smtp_domain,
#   :enable_starttls_auto => true,
#   :password             => Settings.mandrill.smtp_password,
#   :port                 => "587",
#   :user_name            => Settings.mandrill.smtp_username
# }
#
# ActionMailer::Base.default_url_options = {
#   :host => Settings.mandrill.smtp_domain
# }