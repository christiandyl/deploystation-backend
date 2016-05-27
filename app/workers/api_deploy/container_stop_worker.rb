module ApiDeploy
  class ContainerStopWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'critical', :retry => false, :backtrace => true

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container.stop(true)
      
        Pusher.trigger "container-#{container_id}", "stop", { success: true }
        notification = Notification.create user_id: container.user_id, alert: "Server stopped"
      rescue => e
        Pusher.trigger "container-#{container_id}", "stop", { success: false }
        raise e
      end
    end

  end
end