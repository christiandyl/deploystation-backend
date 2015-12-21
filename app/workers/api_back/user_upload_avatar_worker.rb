module ApiBack
  class UserUploadAvatarWorker
    include Sidekiq::Worker

    def perform(user_id, source, type)
      begin
        user = User.find(user_id)
        user.upload_avatar(source, type, true)
        
        result = { avatar_url: user.avatar_url }
        Pusher.trigger "user-#{user_id}", "upload_avatar", { success: true, result: result }
      rescue => e
         Pusher.trigger "user-#{user_id}", "upload_avatar", { success: false }
         raise e
      end
    end
    
  end
end