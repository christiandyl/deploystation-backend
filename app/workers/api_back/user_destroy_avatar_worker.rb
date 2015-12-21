module ApiBack
  class UserDestroyAvatarWorker
    include Sidekiq::Worker

    def perform(user_id)
      begin
        user = User.find(user_id)
        user.destroy_avatar(true)
        
        result = {}
        Pusher.trigger "user-#{user_id}", "destroy_avatar", { success: true, result: result }
      rescue => e
         Pusher.trigger "user-#{user_id}", "destroy_avatar", { success: false }
         raise e
      end
    end
    
  end
end