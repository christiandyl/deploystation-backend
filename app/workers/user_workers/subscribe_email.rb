module UserWorkers
  class SubscribeEmail
    include Sidekiq::Worker

    def perform user_id
      user = User.find(user_id)
      
      list_id = Settings.gibbon.list_id
      body = {
        email_address: user.email,
        status: "subscribed",
        merge_fields: {
          :FNAME  => user.full_name.to_s,
          :LNAME  => user.full_name.to_s,
          :FLNAME => user.full_name.to_s
        }
      }
      
      begin
        gb = Gibbon::Request.new
        gb.lists(list_id).members.create(body: body)
      rescue
      end
    end
    
  end
end