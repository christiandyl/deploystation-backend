class Connect < ActiveRecord::Base
  belongs_to :user

  SUPPORTED_CONNECTS = ['login', 'facebook']

  def self.class_for partner_name
    return "connect_#{partner_name}".classify.constantize
  end

  def class_for
    Connect.class_for partner
  end

  def user_exists?
    self.class.where(partner: partner, partner_id: partner_id).first.user rescue nil
  end

  def existing_connect
    self.class.where(partner: partner, partner_id: partner_id).first
  end

end
