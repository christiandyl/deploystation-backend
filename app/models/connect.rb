class Connect < ActiveRecord::Base
  include ApiExtension
  
  belongs_to :user

  SUPPORTED_CONNECTS = ['login', 'facebook', 'twitter']

  def api_attributes(_layers)
    h = {
      id: id,
      partner: partner,
      partner_id: partner_id
    }

    h
  end

  def email; raise "SubclassResponsibility"; end

  def self.class_for(partner_name)
    "connects/#{partner_name}".classify.constantize
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
