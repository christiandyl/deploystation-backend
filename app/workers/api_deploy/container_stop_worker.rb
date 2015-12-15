module ApiDeploy
  class ContainerStopWorker
    include Sidekiq::Worker

    def perform(container_id)
      begin
        container = Container.find(container_id)
        container.stop(true)
      
        Pusher.trigger "container-#{container_id}", "stop", { success: true }
      rescue => e
        Pusher.trigger "container-#{container_id}", "stop", { success: false }
        raise e
      end
    end

  end
end