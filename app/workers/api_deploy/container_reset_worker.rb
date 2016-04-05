module ApiDeploy
  class ContainerResetWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container = Container.class_for(container.game.sname).find(container_id)
        container.reset(true)
      
        Pusher.trigger "container-#{container_id}", "reset", { success: true }
        notification = Notification.create user_id: container.user_id, alert: "Server is reseted"
      rescue => e
        Pusher.trigger "container-#{container_id}", "stop", { success: false }
        raise e
      end
    end

  end
end