ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => 587,
  :domain => "deploystation.com",
  :authentication => :plain,
  :user_name => Settings.sendgrid.user_name,
  :password => Settings.sendgrid.password,
  :enable_starttls_auto => true
}