class UserMailer < ApplicationMailer
  default from: "noreply@deploystation.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
  
  def password_recovery(user, new_password)
    @user         = user
    @email        = user.email
    @new_password = new_password
    
    mail(to: @email, subject: 'Your password is reseted')
  end

end
