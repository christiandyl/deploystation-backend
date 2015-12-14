class User < ActiveRecord::Base
  include ApiConverter

  attr_api [:id, :email]

  has_many :connects
  has_many :containers, :class_name => "ApiDeploy::Container"
  has_many :accesses, :class_name => "ApiDeploy::Access"

  after_create :send_welcome_mail

  validates :email, :presence => true, uniqueness: true

  def send_welcome_mail
    UserMailer.delay.welcome_email(self)
  end

end