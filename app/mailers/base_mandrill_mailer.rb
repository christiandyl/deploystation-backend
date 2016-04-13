require 'mandrill'

class BaseMandrillMailer < ActionMailer::Base
  default from: "DeployStation App <contact@deploystation.com>", reply_to: nil

  private

  def send_mail(email, tpl_name, tpl_vars={}, subject_vars={})
    body = mandrill_template(tpl_name, tpl_vars)
    info = mandrill_template_info(tpl_name)

    subject = info["subject"]
    subject_vars.each { |k,v| subject.gsub!("*|#{k}|*", v) }
    
    from_name  = info["publish_from_name"]
    from_email = info["publish_from_email"]
    if !info["publish_from_name"].blank? && !info["publish_from_email"].blank?
      from = "#{from_name} <#{from_email}>"
    else
      from = nil
    end

    opts = {
      :to           => email,
      :subject      => subject,
      :body         => body,
      :content_type => "text/html"
    }
    opts[:from] = from unless from.nil?
    
    mail(opts)
  end

  def mandrill_template_info(template_name)
    mandrill.templates.info(template_name)
  end

  def mandrill_template(template_name, attributes)
    merge_vars = attributes.map do |key, value|
      { name: key, content: value }
    end

    mandrill.templates.render(template_name, [], merge_vars)["html"]
  end
  
  def mandrill
    @mandrill ||= Mandrill::API.new(Settings.mandrill.smtp_password)
  end
end