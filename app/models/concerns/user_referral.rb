module UserReferral
  extend ActiveSupport::Concern

  included do
  end

  def find_by_referral_token token, opts={}
    opts[:give_reward] ||= false
    
    begin
      hs = JWT.decode token, Settings.token_encoding.referral_key
      user = User.find(hs[0]["id"])
      if opts[:give_reward]
        reward = hs[0]["reward"] || {}
        status = user.give_reward(reward)

        if status == true
          Backend::Helper::slack_ping("#{full_name} was invited by #{User.find(user.id).full_name}") rescue nil
          Reward.create!(inviter_id: user.id, invited_id: self.id, referral_data: reward )
        end
      end
      return user
    rescue
      return false
    end
  end
  
  def referral_token payload_extra = {}
    expires = (Time.now + 5.years).to_i
    
    payload = {
      :id => id,
      :reward => {},
      :exp => expires
    }
    payload_extra.each { |k,v| payload[k] = v }
    
    token = JWT.encode payload, Settings.token_encoding.referral_key, Settings.token_encoding.algorithm
    
    return token
  end
  
  def give_reward data = {}
    type = data["type"] or raise ArgumentError.new("Reward type doesn't exists")
    
    status = case type
      when "time"
        cid = data["cid"] or raise ArgumentError.new("Container id doesn't exists for this reward")
        container = Container.find(cid) rescue ArgumentError.new("Container id #{cid.to_s} doesn't exists for this reward")
        
        time_now = Time.now.to_time
        active_until = container.active_until.to_time
        time = active_until > time_now ? active_until : time_now
        
        active_until = time + container.class::REWARD_HOURS.hours
        container.update(active_until: active_until)
        
        true
      else
        raise ArgumentError.new("Reward type #{type} is incorrect")
    end
    
    return status
  end
end
