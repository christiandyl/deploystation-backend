class Connect < ActiveRecord::Base
  include ApiConverter
  
  attr_api [:id, :partner, :partner_id]
  
  belongs_to :user

  SUPPORTED_CONNECTS = ['login', 'facebook']

  def email; raise "SubclassResponsibility"; end

  def self.class_for partner_name
    return "connect_#{partner_name}".classify.constantize
  end

  def class_for
    Connect.class_for partner
  end

  def user_exists?
    !user.nil?
  end

  def existing_connect
    self.class.where(partner: partner, partner_id: partner_id).first
  end

end
