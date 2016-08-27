class ContainerMailer < BaseMandrillMailer
  def container_created_email(container_id)
    container = Container.find(container_id)
  
    tpl_name = "server-created-en"
    tpl_vars = {
      "GAME"     => container.game.name,
      "LOCATION" => container.host.location,
      "IP"       => container.ip
    }
    subject_vars = {}

    send_mail(container.user.email, tpl_name, tpl_vars, subject_vars)   
  end
  
  def container_prolongation_email(container_id)
    container = Container.find(container_id)
    user = container.user
  
    token = container.referral_token_extra_time
    link  = "http://app.deploystation.com/sign-up?rt=#{token}"
  
    tpl_name = "server-prolongation-en"
    tpl_vars = {
      "FNAME"      => user.full_name,
      "SHARE_LINK" => link
    }
    subject_vars = {}

    send_mail(container.user.email, tpl_name, tpl_vars, subject_vars)
  end
end
