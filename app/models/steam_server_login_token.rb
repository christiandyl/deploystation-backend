class SteamServerLoginToken < ActiveRecord::Base
  
  validates :app_id,  allow_nil: false, numericality: { only_integer: true }
  validates :token,  allow_nil: false, uniqueness: { scope: :app_id }
  validates :in_use, allow_nil: false, inclusion: { in: [true, false] }
  
  def self.take_token app_id
    m = self.find_by(app_id: app_id, in_use: false)
    m.update! in_use: true
    
    return m.token
  end
  
  def self.return_token app_id, token
    self.find_by(app_id: app_id, token: token).update! in_use: false
  end
end
