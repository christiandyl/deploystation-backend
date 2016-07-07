module ContainerWorkers
  class StopWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'critical', :retry => false, :backtrace => true, :unique => :while_executing

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