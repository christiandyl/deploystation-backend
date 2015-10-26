class UserMailer < ApplicationMailer
  default from: "noreply@lifevnt.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end

end
