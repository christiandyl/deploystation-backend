module ApiDeploy
  class ContainerMailer < BaseMandrillMailer
  
    def container_created_email(container_id)
      container = ApiDeploy::Container.find(container_id)
    
      tpl_name = "server-created-en"
      tpl_vars = {
        "GAME"    => container.game.name,
        "COUNTRY" => container.host.location
      }
      subject_vars = {}

      send_mail(container.user.email, tpl_name, tpl_vars, subject_vars)   
    end

  end
end