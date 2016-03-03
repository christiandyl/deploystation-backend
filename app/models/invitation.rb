class Invitation

  attr_accessor :container, :method_name, :method_data

  METHODS = ["email"]
  
  def initialize container, method_name, method_data
    raise "Container object is wrong" unless container.is_a? ApiDeploy::Container
    raise "Invitation method doesn't exists" unless METHODS.include?(method_name.to_s)
    
    self.container   = container
    self.method_name = method_name
    self.method_data = method_data
  end
  
  def send now = false
    unless now          
      ApiDeploy::InvitationWorker.perform_async(container.id, method_name, method_data)
      return true
    end

    if method_name == "email"
      method_email(method_data)
    end
  end
  
  def method_email data
    emails = data["emails"] or raise "Can't send invites, emails doesn't exists"
    raise "Emails should be a list" unless emails.is_a? Array
    
    emails.each do |email|
      Rails.logger.debug "Sending email invitation to #{email}"
      UserMailer.delay.invitation(container, email)
    end
  end

end