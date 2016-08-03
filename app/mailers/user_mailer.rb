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
      "IP"     => container.ip
    }
    subject_vars = {
      "FNAME" => container.user.full_name
    }

    send_mail(email, tpl_name, tpl_vars, subject_vars)
  end
  
  def confirmation_email(user_id)
    user = User.find(user_id)
    url = "http://app.deploystation.com/confirmation?token=#{user.confirmation_token}"
    
    tpl_name = "confirmation-en"
    tpl_vars = {
      "FNAME" => user.full_name,
      "URL"   => url
    }
    subject_vars = {}
    
    send_mail(user.email, tpl_name, tpl_vars, subject_vars)
  end

  def low_balance_remind(user_id)
    user = User.find(user_id)
    
    tpl_name = "low-balance-en"
    tpl_vars = {
      "FNAME"   => user.full_name,
      "CREDITS" => user.credits
    }
    subject_vars = {}
    
    send_mail(user.email, tpl_name, tpl_vars, subject_vars)
  end
end
