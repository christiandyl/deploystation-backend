module ApiDeploy
  class ContainerRestartWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container.restart(true)
      
        Pusher.trigger "container-#{container_id}", "restart", { success: true }
      rescue => e
        Pusher.trigger "container-#{container_id}", "restart", { success: false }
        raise e
      end
    end

  end
end