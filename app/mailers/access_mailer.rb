class AccessMailer < ApplicationMailer
  default from: "noreply@deploystation.com"

  def invite(access)
    @user      = access.user
    @container = access.container
    mail(to: @user.email, subject: "You received access to manage game server")
  end

end
