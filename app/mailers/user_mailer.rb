class UserMailer < BaseMandrillMailer

  def welcome_email(user)
    tpl_name = "welcome-en"
    tpl_vars = {
      "FNAME" => user.full_name,
    }
    subject_vars = {}

    send_mail(user.email, tpl_name, tpl_vars, subject_vars)
  end
  
  def password_recovery(user, new_password)    
    tpl_name = "recovery-password-en"
    tpl_vars = {
      "FNAME"    => user.full_name,
      "NEW_PASS" => new_password
    }
    subject_vars = {}

    send_mail(user.email, tpl_name, tpl_vars, subject_vars)
  end
  
  def invitation(container, email)
    tpl_name = "invitation-en"
    tpl_vars = {
      "FNAME"     => container.user.full_name,
      "GAME_NAME" => container.game.name,
      "IPADD"     => container.address
    }
    subject_vars = {
      "FNAME" => container.user.full_name
    }

    send_mail(user.email, tpl_name, tpl_vars, subject_vars)
  end

end
